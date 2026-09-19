"""
Strategy Search Batch 1 - 7 frozen candidate walk-forwards for the Gold bot.

Honor contract (see wiki/synthesis/strategy-search-batch-1-precommit.md,
frozen 2026-09-19 BEFORE this run): every candidate config below is
pre-registered and derived ONLY from its cited public source. No parameter
was chosen after any run on our data, and none may be tuned after results.

All candidates run on the SAME frozen M1 bid history, aggregated M1->M15 with
the frozen engine's own aggregate(); spread cost 0.30 USD per trade; SL/TP
resolved forward on closed bars only (no lookahead, no open-trade credit).
Baseline = certified Layer-3 engine (-4.42/trade).

Verdict rule: GO only if OOS n >= 30 AND expectancy > 0 AND > baseline.
Multiple-testing honesty: any GO is provisional until split-sample check.

Run from repo root:
    python scripts/strategy_search_batch1.py --csv raw/history/<file>.csv
"""

import argparse
import datetime
import math
import os

import layer3_walkforward as l3  # the FROZEN engine (imported, never edited)

SPREAD = l3.SPREAD_USD
MIN_OOS_TRADES = l3.MIN_OOS_TRADES


# --------------------------------------------------------------------------
# shared indicator helpers (Wilder ADX, Wilder RSI, Bollinger)
# --------------------------------------------------------------------------

def adx_wilder(h, l, c, period=14):
    n = len(h)
    out = [math.nan] * n
    if n <= period:
        return out
    tr = [0.0] * n
    pdm = [0.0] * n
    ndm = [0.0] * n
    for i in range(1, n):
        up = h[i] - h[i - 1]
        dn = l[i - 1] - l[i]
        tr[i] = max(h[i] - l[i], abs(h[i] - c[i - 1]), abs(l[i] - c[i - 1]))
        pdm[i] = up if (up > dn and up > 0) else 0.0
        ndm[i] = dn if (dn > up and dn > 0) else 0.0
    str_ = sum(tr[1:period + 1])
    spdm = sum(pdm[1:period + 1])
    sndm = sum(ndm[1:period + 1])
    pdi = [math.nan] * n
    ndi = [math.nan] * n
    dx = [math.nan] * n
    pdi[period] = 100.0 * spdm / str_ if str_ else 0.0
    ndi[period] = 100.0 * sndm / str_ if str_ else 0.0
    dx[period] = (100.0 * abs(pdi[period] - ndi[period]) /
                  (pdi[period] + ndi[period])) if (pdi[period] + ndi[period]) else 0.0
    for i in range(period + 1, n):
        str_ = str_ - str_ / period + tr[i]
        spdm = spdm - spdm / period + pdm[i]
        sndm = sndm - sndm / period + ndm[i]
        pdi[i] = 100.0 * spdm / str_ if str_ else 0.0
        ndi[i] = 100.0 * sndm / str_ if str_ else 0.0
        dx[i] = (100.0 * abs(pdi[i] - ndi[i]) /
                 (pdi[i] + ndi[i])) if (pdi[i] + ndi[i]) else 0.0
    adx = [math.nan] * n
    if 2 * period <= n:
        adx[2 * period - 1] = sum(dx[period:2 * period]) / period
        for i in range(2 * period, n):
            adx[i] = (adx[i - 1] * (period - 1) + dx[i]) / period
    return adx


def rsi_wilder(c, period=14):
    n = len(c)
    out = [math.nan] * n
    if n <= period:
        return out
    gains = [0.0] * n
    losses = [0.0] * n
    for i in range(1, n):
        ch = c[i] - c[i - 1]
        gains[i] = max(ch, 0.0)
        losses[i] = max(-ch, 0.0)
    ag = sum(gains[1:period + 1]) / period
    al = sum(losses[1:period + 1]) / period
    out[period] = 100.0 - 100.0 / (1.0 + ag / al) if al else 100.0
    for i in range(period + 1, n):
        ag = (ag * (period - 1) + gains[i]) / period
        al = (al * (period - 1) + losses[i]) / period
        out[i] = 100.0 - 100.0 / (1.0 + ag / al) if al else 100.0
    return out


def bollinger(c, period=20, mult=2.0):
    n = len(c)
    mid = [math.nan] * n
    up = [math.nan] * n
    dn = [math.nan] * n
    for i in range(period - 1, n):
        w = c[i - period + 1:i + 1]
        m = sum(w) / period
        var = sum((x - m) ** 2 for x in w) / period
        sd = math.sqrt(var)
        mid[i] = m
        up[i] = m + mult * sd
        dn[i] = m - mult * sd
    return mid, up, dn


# --------------------------------------------------------------------------
# shared forward resolution (identical to the frozen engine)
# --------------------------------------------------------------------------

def resolve(trades, t15, h15, l15, c15, time_exit_bars=None):
    per_trade, wins = [], 0
    for tr in trades:
        j = next((k for k in range(len(t15)) if t15[k] >= tr["ts"]), None)
        if j is None:
            continue
        outcome = None
        k_exit = None
        max_k = len(t15)
        if time_exit_bars:
            max_k = min(max_k, j + 1 + time_exit_bars)
        for k in range(j + 1, max_k):
            bh, bl = h15[k], l15[k]
            if tr["side"] == "BUY":
                if bh >= tr["tp"]:
                    outcome = "TP"; k_exit = k; break
                if bl <= tr["sl"]:
                    outcome = "SL"; k_exit = k; break
            else:
                if bl <= tr["tp"]:
                    outcome = "TP"; k_exit = k; break
                if bh >= tr["sl"]:
                    outcome = "SL"; k_exit = k; break
        if outcome is None:
            if time_exit_bars and max_k < len(t15):
                outcome = "TIME"; k_exit = max_k - 1
            else:
                continue
        if outcome == "TP":
            pts = (tr["tp"] - tr["entry"]) if tr["side"] == "BUY" else (tr["entry"] - tr["tp"])
        elif outcome == "SL":
            pts = (tr["sl"] - tr["entry"]) if tr["side"] == "BUY" else (tr["entry"] - tr["sl"])
        else:  # TIME exit at close
            pts = (c15[k_exit] - tr["entry"]) if tr["side"] == "BUY" else (tr["entry"] - c15[k_exit])
        pnl = pts - SPREAD
        per_trade.append(pnl)
        if pnl > 0:
            wins += 1
    return per_trade, wins


def stats(per_trade, wins, n_emitted):
    n = len(per_trade)
    exp = (sum(per_trade) / n) if n else math.nan
    wr = (wins / n) if n else math.nan
    if n:
        aw = sum(p for p in per_trade if p > 0) / max(1, sum(1 for p in per_trade if p > 0))
        al = sum(p for p in per_trade if p <= 0) / max(1, sum(1 for p in per_trade if p <= 0))
        rr = (aw / abs(al)) if al else math.nan
    else:
        aw = al = rr = math.nan
    return {"n": n, "expectancy": exp, "win_rate": wr, "rr": rr,
            "avg_win": aw, "avg_loss": al, "n_emitted": n_emitted}


# --------------------------------------------------------------------------
# Candidate 1 - UT Bot ATR trailing stop (always-in-market, reverse on signal)
# --------------------------------------------------------------------------

def c1_ut_bot(ts, o, h, l, c):
    t15, o15, h15, l15, c15 = l3.aggregate(ts, o, h, l, c, 15)
    atr15 = l3.atr_wilder(list(zip(t15, o15, h15, l15, c15)), 10)
    kv = 4.5
    n = len(t15)
    stop = [0.0] * n
    pos = [0] * n  # 1 long, -1 short, 0 flat
    for i in range(1, n):
        a = atr15[i]
        if math.isnan(a):
            stop[i] = stop[i - 1]
            pos[i] = pos[i - 1]
            continue
        ps = stop[i - 1]
        if c15[i] > ps and c15[i - 1] > ps:
            stop[i] = max(ps, c15[i] - kv * a)
        elif c15[i] < ps and c15[i - 1] < ps:
            stop[i] = min(ps, c15[i] + kv * a)
        elif c15[i] > ps:
            stop[i] = c15[i] - kv * a
        else:
            stop[i] = c15[i] + kv * a
        pp = pos[i - 1]
        if c15[i] < ps and c15[i - 1] > ps:
            pos[i] = -1
        elif c15[i] > ps and c15[i - 1] < ps:
            pos[i] = 1
        else:
            pos[i] = pp

    # trades: flip events; entry/exit at signal-bar close
    trades = []
    cur = 0
    entry = None
    entry_ts = None
    side = None
    for i in range(1, n):
        if pos[i] == cur:
            continue
        if cur != 0:
            trades.append({"ts": entry_ts, "side": side, "entry": entry,
                           "exit": c15[i]})
        if pos[i] != 0:
            cur = pos[i]
            side = "BUY" if pos[i] == 1 else "SELL"
            entry = c15[i]
            entry_ts = t15[i]
        else:
            cur = 0
    # final open position dropped (no lookahead credit)
    per_trade, wins = [], 0
    for tr in trades:
        pnl = (tr["exit"] - tr["entry"]) if tr["side"] == "BUY" else (tr["entry"] - tr["exit"])
        pnl -= SPREAD
        per_trade.append(pnl)
        if pnl > 0:
            wins += 1
    return stats(per_trade, wins, len(trades))


# --------------------------------------------------------------------------
# Candidate 2 - Session range breakout (Asian range -> London open)
# --------------------------------------------------------------------------

def c2_session_range(ts, o, h, l, c):
    t15, o15, h15, l15, c15 = l3.aggregate(ts, o, h, l, c, 15)
    atr15 = l3.atr_wilder(list(zip(t15, o15, h15, l15, c15)), l3.ATR_PERIOD)
    n = len(t15)
    trades = []
    i = 0
    while i < n:
        if l3.hour_utc(t15[i]) != 3:
            i += 1
            continue
        # range window: bars ending 03:00-07:59 UTC
        j = i
        rh = -1e18
        rl = 1e18
        while j < n and l3.hour_utc(t15[j]) <= 7:
            rh = max(rh, h15[j])
            rl = min(rl, l15[j])
            j += 1
        # trade window: bars ending 08:00-20:59 UTC, first breakout only
        done = False
        while j < n and l3.hour_utc(t15[j]) <= 20 and not done:
            a = atr15[j]
            cn = c15[j]
            if not math.isnan(a):
                if cn > rh:
                    trades.append({"ts": t15[j], "side": "BUY", "entry": cn,
                                   "sl": cn - l3.SL_ATR * a, "tp": cn + l3.TP_ATR * a})
                    done = True
                elif cn < rl:
                    trades.append({"ts": t15[j], "side": "SELL", "entry": cn,
                                   "sl": cn + l3.SL_ATR * a, "tp": cn - l3.TP_ATR * a})
                    done = True
            j += 1
        i = j
    per_trade, wins = resolve(trades, t15, h15, l15, c15)
    return stats(per_trade, wins, len(trades))


# --------------------------------------------------------------------------
# Candidate 3 - Xaulgnition long-only momentum (US session, no Fridays)
# --------------------------------------------------------------------------

def c3_xaulgnition(ts, o, h, l, c):
    t15, o15, h15, l15, c15 = l3.aggregate(ts, o, h, l, c, 15)
    e198 = l3.ema(c15, 198)
    atr15 = l3.atr_wilder(list(zip(t15, o15, h15, l15, c15)), l3.ATR_PERIOD)
    n = len(t15)
    trades = []
    for i in range(200, n):
        hr = l3.hour_utc(t15[i])
        if hr < 13 or hr > 20:
            continue
        wd = datetime.datetime.fromtimestamp(t15[i] / 1000.0,
                                             datetime.timezone.utc).weekday()
        if wd == 4:  # Friday
            continue
        cn = c15[i]
        a = atr15[i]
        e = e198[i]
        if math.isnan(a) or math.isnan(e):
            continue
        if cn <= e:
            continue
        body = abs(c15[i] - o15[i])
        if body < a:
            continue
        if cn < (h15[i] + l15[i]) / 2.0:
            continue
        if cn <= h15[i - 1]:
            continue
        trades.append({"ts": t15[i], "side": "BUY", "entry": cn,
                       "sl": cn - 3.7 * a, "tp": cn + 3.9 * a})
    per_trade, wins = resolve(trades, t15, h15, l15, c15, time_exit_bars=96)
    return stats(per_trade, wins, len(trades))


# --------------------------------------------------------------------------
# Candidate 4 - EMA crossover + ADX trend filter
# --------------------------------------------------------------------------

def c4_ema_adx(ts, o, h, l, c):
    t15, o15, h15, l15, c15 = l3.aggregate(ts, o, h, l, c, 15)
    ef = l3.ema(c15, 20)
    es = l3.ema(c15, 50)
    adx = adx_wilder(h15, l15, c15, 14)
    atr15 = l3.atr_wilder(list(zip(t15, o15, h15, l15, c15)), l3.ATR_PERIOD)
    n = len(t15)
    trades = []
    flat = True
    for i in range(60, n):
        a = atr15[i]
        d = adx[i]
        if math.isnan(a) or math.isnan(d) or math.isnan(ef[i]) or math.isnan(es[i]):
            continue
        cn = c15[i]
        if flat:
            if ef[i] > es[i] and ef[i - 1] <= es[i - 1] and d > 25:
                trades.append({"ts": t15[i], "side": "BUY", "entry": cn,
                               "sl": cn - l3.SL_ATR * a, "tp": cn + l3.TP_ATR * a})
                flat = False
            elif ef[i] < es[i] and ef[i - 1] >= es[i - 1] and d > 25:
                trades.append({"ts": t15[i], "side": "SELL", "entry": cn,
                               "sl": cn + l3.SL_ATR * a, "tp": cn - l3.TP_ATR * a})
                flat = False
    per_trade, wins = resolve(trades, t15, h15, l15, c15)
    return stats(per_trade, wins, len(trades))


# --------------------------------------------------------------------------
# Candidate 5 - Bollinger mean reversion + RSI
# --------------------------------------------------------------------------

def c5_bb_reversion(ts, o, h, l, c):
    t15, o15, h15, l15, c15 = l3.aggregate(ts, o, h, l, c, 15)
    mid, bup, bdn = bollinger(c15, 20, 2.0)
    rsi = rsi_wilder(c15, 14)
    atr15 = l3.atr_wilder(list(zip(t15, o15, h15, l15, c15)), l3.ATR_PERIOD)
    n = len(t15)
    trades = []
    for i in range(30, n):
        a = atr15[i]
        r = rsi[i]
        if math.isnan(a) or math.isnan(r) or math.isnan(bdn[i]) or math.isnan(bup[i]):
            continue
        cn = c15[i]
        if cn < bdn[i] and r < 30:
            trades.append({"ts": t15[i], "side": "BUY", "entry": cn,
                           "sl": cn - 1.5 * a, "tp": cn + 1.5 * a})
        elif cn > bup[i] and r > 70:
            trades.append({"ts": t15[i], "side": "SELL", "entry": cn,
                           "sl": cn + 1.5 * a, "tp": cn - 1.5 * a})
    per_trade, wins = resolve(trades, t15, h15, l15, c15)
    return stats(per_trade, wins, len(trades))


# --------------------------------------------------------------------------
# Candidate 6 - Pullback-window breakout (volatility expansion)
# --------------------------------------------------------------------------

def c6_pullback_window(ts, o, h, l, c):
    t15, o15, h15, l15, c15 = l3.aggregate(ts, o, h, l, c, 15)
    e14 = l3.ema(c15, 14)
    e24 = l3.ema(c15, 24)
    atr15 = l3.atr_wilder(list(zip(t15, o15, h15, l15, c15)), l3.ATR_PERIOD)
    n = len(t15)
    trades = []
    i = 30
    while i < n:
        a = atr15[i]
        if math.isnan(a) or math.isnan(e14[i]) or math.isnan(e24[i]):
            i += 1
            continue
        if e14[i] > e24[i]:
            # bullish: wait for 1-3 red pullback candles
            pb = 0
            j = i
            while j < n and pb < 3 and c15[j] < c15[j - 1]:
                pb += 1
                j += 1
            if pb >= 1 and j < n:
                wh = max(h15[k] for k in range(i, j))
                k = j
                while k < n and c15[k] <= wh:
                    k += 1
                if k < n:
                    ak = atr15[k]
                    if not math.isnan(ak):
                        trades.append({"ts": t15[k], "side": "BUY", "entry": c15[k],
                                       "sl": c15[k] - 2.5 * ak, "tp": c15[k] + 12.0 * ak})
                    i = k + 1
                else:
                    i = n
            else:
                i = j if j > i else i + 1
        elif e14[i] < e24[i]:
            # bearish: wait for 1-3 green pullback candles
            pb = 0
            j = i
            while j < n and pb < 3 and c15[j] > c15[j - 1]:
                pb += 1
                j += 1
            if pb >= 1 and j < n:
                wl = min(l15[k] for k in range(i, j))
                k = j
                while k < n and c15[k] >= wl:
                    k += 1
                if k < n:
                    ak = atr15[k]
                    if not math.isnan(ak):
                        trades.append({"ts": t15[k], "side": "SELL", "entry": c15[k],
                                       "sl": c15[k] + 2.5 * ak, "tp": c15[k] - 12.0 * ak})
                    i = k + 1
                else:
                    i = n
            else:
                i = j if j > i else i + 1
        else:
            i += 1
    per_trade, wins = resolve(trades, t15, h15, l15, c15)
    return stats(per_trade, wins, len(trades))


# --------------------------------------------------------------------------
# Candidate 7 - Liquidity sweep (SMC wick-through + close-back)
# --------------------------------------------------------------------------

def c7_liquidity_sweep(ts, o, h, l, c):
    t15, o15, h15, l15, c15 = l3.aggregate(ts, o, h, l, c, 15)
    atr15 = l3.atr_wilder(list(zip(t15, o15, h15, l15, c15)), l3.ATR_PERIOD)
    n = len(t15)
    trades = []
    for i in range(3, n):
        hr = l3.hour_utc(t15[i])
        if hr < 7 or hr > 20:
            continue
        a = atr15[i]
        if math.isnan(a):
            continue
        sh = max(h15[i - 1], h15[i - 2])
        sl_ = min(l15[i - 1], l15[i - 2])
        cn = c15[i]
        if h15[i] > sh and cn < sh:
            trades.append({"ts": t15[i], "side": "SELL", "entry": cn,
                           "sl": cn + l3.SL_ATR * a, "tp": cn - l3.TP_ATR * a})
        elif l15[i] < sl_ and cn > sl_:
            trades.append({"ts": t15[i], "side": "BUY", "entry": cn,
                           "sl": cn - l3.SL_ATR * a, "tp": cn + l3.TP_ATR * a})
    per_trade, wins = resolve(trades, t15, h15, l15, c15)
    return stats(per_trade, wins, len(trades))


# --------------------------------------------------------------------------
# runner
# --------------------------------------------------------------------------

CANDIDATES = [
    ("C1 UT Bot trailing stop", c1_ut_bot),
    ("C2 Session range breakout", c2_session_range),
    ("C3 Xaulgnition momentum", c3_xaulgnition),
    ("C4 EMA cross + ADX", c4_ema_adx),
    ("C5 BB mean reversion", c5_bb_reversion),
    ("C6 Pullback-window breakout", c6_pullback_window),
    ("C7 Liquidity sweep", c7_liquidity_sweep),
]


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--csv", default=None)
    args = ap.parse_args(argv)

    csv_path = args.csv
    if not csv_path:
        hist = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "raw", "history")
        files = sorted(f for f in os.listdir(hist) if f.endswith(".csv")) if os.path.isdir(hist) else []
        if not files:
            print("no history CSV found; pass --csv")
            return 1
        csv_path = os.path.join(hist, files[-1])

    print("loading %s ..." % os.path.basename(csv_path))
    ts, o, h, l, c = l3.load_csv(csv_path)
    print("  %d M1 bars | first=%s last=%s" % (len(ts), l3._fmt(ts[0]), l3._fmt(ts[-1])))

    baseline = l3.run(ts, o, h, l, c)
    print("")
    print("=== STRATEGY SEARCH BATCH 1 (frozen configs 2026-09-19) ===")
    print("[baseline] frozen engine OOS: n=%3d  E=%+.4f  WR=%.2f%%  RR=%.2f  (certified 2026-09-19)"
          % (baseline["n"], baseline["expectancy"], baseline["win_rate"] * 100, baseline["rr"]))

    print("")
    print("%-26s%5s%10s%8s%7s%9s%9s  %s" % ("candidate", "n", "E/trade", "WR", "RR", "avgW", "avgL", "verdict"))
    print("-" * 92)
    results = {}
    for name, fn in CANDIDATES:
        r = fn(ts, o, h, l, c)
        results[name] = r
        go = (r["n"] >= MIN_OOS_TRADES and r["expectancy"] == r["expectancy"]
              and r["expectancy"] > 0 and r["expectancy"] > baseline["expectancy"])
        verdict = "GO (provisional)" if go else "NO-GO"
        wr = r["win_rate"] * 100 if r["win_rate"] == r["win_rate"] else float("nan")
        print("%-26s%5d%+10.4f%7.2f%%%7.2f%+9.4f%+9.4f  %s"
              % (name, r["n"], r["expectancy"], wr, r["rr"], r["avg_win"], r["avg_loss"], verdict))

    print("")
    print("--- GO / NO-GO guardrail (n>=30 AND E>0 AND E>baseline -4.42) ---")
    any_go = False
    for name, r in results.items():
        go = (r["n"] >= MIN_OOS_TRADES and r["expectancy"] == r["expectancy"]
              and r["expectancy"] > 0 and r["expectancy"] > baseline["expectancy"])
        if go:
            any_go = True
            print("  %s: GO (provisional) - n=%d, E=%+.4f -> MUST pass split-sample robustness check before shipping"
                  % (name, r["n"], r["expectancy"]))
        else:
            reason = []
            if r["n"] < MIN_OOS_TRADES:
                reason.append("n=%d < 30" % r["n"])
            if not (r["expectancy"] == r["expectancy"]):
                reason.append("no resolved trades")
            elif r["expectancy"] <= 0:
                reason.append("E=%+.4f <= 0" % r["expectancy"])
            elif r["expectancy"] <= baseline["expectancy"]:
                reason.append("E=%+.4f <= baseline %+.4f" % (r["expectancy"], baseline["expectancy"]))
            print("  %s: NO-GO (%s)" % (name, "; ".join(reason)))
    if not any_go:
        print("  -> no candidate passed; continue hunting (batch 2) with freeze-first discipline")
    return 0


if __name__ == "__main__":
    sys_exit = main()
    raise SystemExit(sys_exit)