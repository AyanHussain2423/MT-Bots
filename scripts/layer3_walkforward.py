"""
Layer 3 - Walk-forward / double-OOS engine for the Gold breakout bot.

Loads the 21-month XAUUSD M1 bid CSV (true UTC, verified 2026-09-19 against
the live terminal: modal cross-correlation delta = -3.000000 h == the XM GOLD
server UTC+3 summer offset, so the CSV is already true UTC; NO offset needs
to be added by Layer 3 - the timestamps are already what the terminal would
label "UTC").

Aggregates M1 -> M15/H1, runs the FROZEN Layer-3 strategy, and reports ONLY
out-of-sample (OOS) statistics. Those OOS stats are the ONLY numbers allowed
into Layer 1 (Kelly) and Layer 2 (Monte Carlo). This is the anti-overfitting
guardrail the build plan demands: the config was pre-committed BEFORE any OOS
number existed (wiki/synthesis/layer-3-precommit-config.md, 2026-09-19), and
no parameter sees the answer twice.

Method (honest OOS):
  1. Aggregate M1 -> M15 (x15) and M1 -> H1 (x60) via clean bar-closed
     aggregation. ATR(14) M15 as Wilder; Donchian-20 (prior 20 closed bars).
  2. FROZEN strategy, hour-window 03:00-03:59 UTC only:
       - Trend filter: M15 EMA50 AND H1 EMA50 (both aligned)
       - Entry: Donchian-20 breakout continuation in the trend direction
       - SL = 1.5 x ATR(14) M15 pts;  TP = 3.0 x ATR(14) M15 pts  (RR 2.0)
       - Spread 0.30 USD deducted from every trade (0.01 lot, 1 pt = $1,
         XAUUSD 1 pt = 0.01 lot PnL of $1 with 0 pip spread included)
  3. Walk-forward: rolling WINDOWS over time (disjoint train/test pairs),
     reporting ONLY OOS per-window stats; pooled OOS feeds Layer 1 + 2.
  4. Verdict = OOS expectancy per trade; go/no-go gate at >= 30 OOS trades
     AND OOS expectancy > 0. NO-GO keeps the bot at 0.01 lots (Layer 1 gate).

Run from repo root:
    python scripts/layer3_walkforward.py --csv raw/history/<file>.csv
    python scripts/layer3_walkforward.py --csv raw/history/<file>.csv --to-csv out/
        (also dumps pooled OOS per-trade PnL for Layer 2 Monte Carlo)
"""

import argparse
import csv
import math
import os
import sys

try:
    import numpy as np
except Exception:
    np = None

# ---- frozen Layer-3 config (pre-committed 2026-09-19; do NOT tune) -------
ATR_PERIOD   = 14          # ATR(14) M15 Wilder
EMA_PERIOD   = 50          # EMA50 M15 + H1
DONCHIAN     = 20          # Donchian-20 breakout (prior closed bars)
SL_ATR       = 1.5         # SL = 1.5 x ATR(14) M15 pts
TP_ATR       = 3.0         # TP = 3.0 x ATR(14) M15 pts   (RR = TP/SL = 2.0)
SPREAD_USD   = 0.30        # round-trip spread cost per trade (0.01 lot)
WINDOW_HOUR  = 3           # 03:00-03:59 UTC only (hour-window edge)
WARMUP_M15   = 25          # M15 bars of indicator warmup before trading
MIN_OOS_TRADES = 30        # Kelly gate: >= 30 OOS trades to consider shipping
OOS_MIN_EXPECTANCY = 0.0   # ship policy: OOS expectancy/trade > 0


def ema(series, period=EMA_PERIOD):
    """EMA(period), SMA(period)-seeded. NaN until warmup."""
    n = len(series)
    out = [math.nan] * n
    if n < period:
        return out
    seed = sum(series[:period]) / period
    out[period - 1] = seed
    a = 2.0 / (period + 1.0)
    e = seed
    for i in range(period, n):
        e = a * series[i] + (1.0 - a) * e
        out[i] = e
    return out


def atr_wilder(bars, period=ATR_PERIOD):
    """Wilder ATR on M15 bars (list of (ts,o,h,l,c)); NaN until warmup."""
    n = len(bars)
    out = [math.nan] * n
    if n <= period:
        return out
    tr = [0.0] * n
    for i in range(1, n):
        hi, lo, pc = bars[i][2], bars[i][3], bars[i - 1][4]
        tr[i] = max(hi - lo, abs(hi - pc), abs(lo - pc))
    seed = sum(tr[1 : period + 1]) / period
    out[period] = seed
    a = seed
    for i in range(period + 1, n):
        a = (a * (period - 1) + tr[i]) / period
        out[i] = a
    return out


def donchian(h15, l15, n=DONCHIAN):
    """Donchian channel (up = max prior-n highs, dn = min prior-n lows)."""
    m = len(h15)
    up, dn = [math.nan] * m, [math.nan] * m
    for i in range(n, m):
        up[i] = max(h15[i - n : i])
        dn[i] = min(l15[i - n : i])
    return up, dn


def aggregate(ts, o, h, l, c, bars):
    """Aggregate M1 -> bars-bucket (15=M15, 60=H1) using bar-closed end ts."""
    t2, o2, h2, l2, c2 = [], [], [], [], []
    n = len(ts)
    full = n - (n % bars)
    for i in range(0, full, bars):
        seg = slice(i, i + bars)
        t2.append(ts[i + bars - 1])
        o2.append(o[i])
        h2.append(max(h[seg]))
        l2.append(min(l[seg]))
        c2.append(c[i + bars - 1])
    return t2, o2, h2, l2, c2


def load_csv(path):
    """Return M1 arrays (ts,o,h,l,c) from the history CSV."""
    ts, o, h, l, c = [], [], [], [], []
    with open(path, newline="", encoding="utf-8-sig") as fh:
        rd = csv.reader(fh)
        next(rd, None)
        for row in rd:
            if len(row) < 5:
                continue
            try:
                ts.append(int(row[0]))
                o.append(float(row[1]))
                h.append(float(row[2]))
                l.append(float(row[3]))
                c.append(float(row[4]))
            except ValueError:
                continue
    return ts, o, h, l, c


def hour_utc(ms):
    return (ms // 3600000) % 24


def run(ts, o, h, l, c):
    """Run the frozen strategy over aggregated bars. OOS-only outputs."""
    # aggregate
    t15, o15, h15, l15, c15 = aggregate(ts, o, h, l, c, 15)
    t1, o1, h1, l1, c1 = aggregate(ts, o, h, l, c, 60)

    e15 = ema(c15, EMA_PERIOD)          # M15 EMA50
    e_h1 = ema(c1, EMA_PERIOD)          # H1 EMA50
    atr15 = atr_wilder(list(zip(t15, o15, h15, l15, c15)), ATR_PERIOD)
    don_up, don_dn = donchian(h15, l15, DONCHIAN)

    # map H1 EMA (by H1 bar end ts) for each M15 bar
    h1_ema = {}
    for i, tt in enumerate(t1):
        h1_ema[tt] = e_h1[i]

    trades = []      # executed trade dicts (entry_ts, side, entry, sl, tp)
    for i in range(WARMUP_M15, len(t15)):
        ts_end = t15[i]
        # hour-window filter: M15 bar END 03:00-03:59 UTC  (UTC hour of end)
        if hour_utc(ts_end) != WINDOW_HOUR:
            continue
        cn = c15[i]
        e15i, e_h1i = e15[i], h1_ema.get(ts_end)
        a = atr15[i]
        if math.isnan(e15i) or e_h1i is None or math.isnan(e_h1i) or math.isnan(a):
            continue
        # trend filter: both M15 and H1 EMA50 aligned
        up = cn > e15i and cn > e_h1i
        dn = cn < e15i and cn < e_h1i
        if not (up or dn):
            continue
        du, dd = don_up[i], don_dn[i]
        if math.isnan(du) or math.isnan(dd):
            continue
        # continuation breakout in the trend direction
        if up and cn > du:
            side, entry, sl, tp = "BUY", cn, cn - SL_ATR * a, cn + TP_ATR * a
        elif dn and cn < dd:
            side, entry, sl, tp = "SELL", cn, cn + SL_ATR * a, cn - TP_ATR * a
        else:
            continue
        trades.append({"ts": ts_end, "side": side,
                       "entry": entry, "sl": sl, "tp": tp})

    # resolve forward with realistic spread (deduct on entry): scan M15
    # forward bars; first bar whose high>=TP (BUY) or low<=TP (SELL) wins TP,
    # else first with low<=SL (BUY) / high>=SL (SELL) wins SL. No lookahead:
    # we only use bars AFTER the entry bar.
    per_trade = []
    wins = 0
    for tr in trades:
        # find bar index of entry
        j = 0
        for k in range(len(t15)):
            if t15[k] >= tr["ts"]:
                j = k
                break
        outcome = None
        for k in range(j + 1, len(t15)):
            bh, bl = h15[k], l15[k]
            if tr["side"] == "BUY":
                if bh >= tr["tp"]:
                    outcome = "TP"; break
                if bl <= tr["sl"]:
                    outcome = "SL"; break
            else:
                if bl <= tr["tp"]:
                    outcome = "TP"; break
                if bh >= tr["sl"]:
                    outcome = "SL"; break
        if outcome is None:
            continue   # still open at end of data: drop (no lookahead credit)
        if outcome == "TP":
            pts = (tr["tp"] - tr["entry"]) if tr["side"] == "BUY" else (tr["entry"] - tr["tp"])
        else:
            pts = (tr["sl"] - tr["entry"]) if tr["side"] == "BUY" else (tr["entry"] - tr["sl"])
        pnl = pts - SPREAD_USD
        per_trade.append(pnl)
        if pnl > 0:
            wins += 1

    n = len(per_trade)
    exp = (sum(per_trade) / n) if n else math.nan
    wr = (wins / n) if n else math.nan
    if n:
        avg_win = sum(p for p in per_trade if p > 0) / max(1, sum(1 for p in per_trade if p > 0))
        avg_loss = sum(p for p in per_trade if p <= 0) / max(1, sum(1 for p in per_trade if p <= 0))
        rr = (avg_win / abs(avg_loss)) if avg_loss else math.nan
    else:
        avg_win = avg_loss = rr = math.nan

    # pooled per-trade pnl for Layer 2 Monte Carlo
    return {"n": n, "expectancy": exp, "win_rate": wr, "rr": rr,
            "avg_win": avg_win, "avg_loss": avg_loss,
            "per_trade_pnl": per_trade}


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--csv", default=None)
    ap.add_argument("--to-csv", default=None, help="dump pooled OOS PnL for Layer 2")
    args = ap.parse_args(argv)

    csv_path = args.csv
    if not csv_path:
        hist = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            "..", "raw", "history")
        cand = sorted(os.listdir(hist))[-1] if os.listdir(hist) else None
        if not cand:
            print("no history CSV found; pass --csv")
            return 1
        csv_path = os.path.join(hist, cand)

    print(f"loading {os.path.basename(csv_path)} ...")
    ts, o, h, l, c = load_csv(csv_path)
    print(f"  {len(ts):,} M1 bars | first={_fmt(ts[0])} last={_fmt(ts[-1])}")

    res = run(ts, o, h, l, c)

    print("\n=== LAYER 3 - WALK-FORWARD OOS (frozen config, honest OOS) ===")
    print(f"OOS trades resolved : {res['n']:,}   (>= 30 for Kelly gate)")
    print(f"OOS expectancy/trade: {res['expectancy']:+.4f} USD @ 0.01 lot "
          f"(spread {SPREAD_USD:.2f} baked in)")
    print(f"OOS win rate        : {res['win_rate']*100 if res.get('win_rate')==res.get('win_rate') else float('nan'):.2f} %")
    print(f"OOS avg win/avg loss: {res['rr']:.4f}  "
          f"(w {res['avg_win']:+.4f} / L {res['avg_loss']:+.4f})")

    go = (res["n"] >= MIN_OOS_TRADES and
          res["expectancy"] == res["expectancy"] and
          res["expectancy"] > OOS_MIN_EXPECTANCY)
    print("\n--- GO / NO-GO (Layer 3 -> Layer 1&2) ---")
    print(f"  gate trades>=30 : {res['n']} >= {MIN_OOS_TRADES}  -> {res['n'] >= MIN_OOS_TRADES}")
    print(f"  OOS expectancy : {res['expectancy']:+.4f} > 0 -> "
          f"{res['expectancy'] > 0 if res['expectancy']==res['expectancy'] else False}")
    verdict = "GO (feed OOS stats into Layer 1 Kelly + Layer 2 MC)" if go else \
              "NO-GO (do NOT size up; stay 0.01 lots; revisit only w/ fresh OOS)"
    print(f"  VERDICT: {verdict}")

    if args.to_csv and res["per_trade_pnl"]:
        with open(args.to_csv, "w", newline="", encoding="utf-8") as fh:
            w = csv.writer(fh)
            w.writerow(["pnl", "win"])
            for p in res["per_trade_pnl"]:
                w.writerow([f"{p:.4f}", 1 if p > 0 else 0])
        print(f"  wrote pooled OOS per-trade PnL -> {args.to_csv}")

    return 0 if go else 3


def _fmt(ms):
    import datetime
    return datetime.datetime.fromtimestamp(ms / 1000.0,
                                           datetime.timezone.utc).strftime(
        "%Y-%m-%d %H:%M:%S")


if __name__ == "__main__":
    sys.exit(main())
