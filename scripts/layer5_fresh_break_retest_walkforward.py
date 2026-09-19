"""
Layer 5 - Retest-confirmed breakout gate walk-forward (candidate) for the Gold bot.

Honor contract (see wiki/synthesis/layer-5-precommit-config.md, frozen
2026-09-19 BEFORE this run): the signal path is the FROZEN Layer-3 engine,
imported verbatim. This script adds ONLY one causal, pre-specified entry
gate (Gate C - retest-confirmed breakout). It never re-derives the
trend/Donchian/ATR/SL/TP logic and never gazes at Layer-5 OOS results with
unfrozen knobs.

Gate C - retest-confirmed breakout (break -> retest -> re-break):
    A BUY at bar i (close > don_up[i], level L = don_up[i]) is kept ONLY IF
    there exists a prior bar j in [i - RETEST_LOOKBACK, i) such that:
      1. prior break : close[j] > don_up[j]
      2. same level  : |don_up[j] - L| <= RETEST_TOL
      3. retest      : min(low[j+1 .. i-1]) <= L + RETEST_TOL
    SELL symmetric: prior close[j] < don_dn[j], |don_dn[j] - L| <= RETEST_TOL,
    max(high[j+1 .. i-1]) >= L - RETEST_TOL.
    If no such j exists, the break is a VIRGIN break -> skip (the documented
    failure mode: 75.5% of virgin breakouts fail to reach target).

    RETEST_TOL      = 1.0 x ATR(14) M15 at the entry bar (vol family of SL/TP)
    RETEST_LOOKBACK = 96 M15 bars (24h; engine fires once/day at 03:00 UTC)

No-drift audit baked in: the gate-OFF pass must reproduce the certified
Layer-3 baseline (35 OOS trades, -4.42/trade, 25.71% WR, RR 1.24) - i.e.
the SAME pooled per-trade PnL list as the frozen engine - otherwise this
script is not a faithful Layer-5 harness and its verdict is void.

Verdict rule (build-plan guardrail): filtered OOS expectancy must be
> 0 AND > unfiltered baseline. Verdict NO-GO otherwise -> stay 0.01 lots.

Run from repo root:
    python scripts/layer5_fresh_break_retest_walkforward.py --csv raw/history/<file>.csv
"""

import argparse
import math
import os
import sys

import layer3_walkforward as l3  # the FROZEN engine (imported, never edited)

# Layer-5 gate - frozen 2026-09-19 (principled, not tuned)
RETEST_TOL_MULT = 1.0    # RETEST_TOL = 1.0 x ATR(14) M15 at entry bar
RETEST_LOOKBACK = 96     # M15 bars (24 h)

MIN_OOS_TRADES = l3.MIN_OOS_TRADES        # >= 30 filtered OOS trades
OOS_MIN_EXPECTANCY = l3.OOS_MIN_EXPECTANCY  # > 0 (and > unfiltered baseline)


def retest_confirmed(i, side, level, c15, h15, l15, don_up, don_dn, tol):
    """Gate C: is the break at bar i a re-break after a retest of the same
    level? Causal: only bars strictly before i are used."""
    lo = max(l3.WARMUP_M15, i - RETEST_LOOKBACK)
    if side == "BUY":
        for j in range(lo, i):
            if j + 1 >= i:
                continue  # no bars between prior break and entry -> no retest
            if c15[j] > don_up[j] and abs(don_up[j] - level) <= tol:
                if min(l15[j + 1:i]) <= level + tol:
                    return True
    else:  # SELL
        for j in range(lo, i):
            if j + 1 >= i:
                continue  # no bars between prior break and entry -> no retest
            if c15[j] < don_dn[j] and abs(don_dn[j] - level) <= tol:
                if max(h15[j + 1:i]) >= level - tol:
                    return True
    return False


def gated_loop(ts, o, h, l, c, gate_c=True):
    """Re-run the FROZEN engine signal loop, optionally gated by Gate C.

    Mirrors l3.run() exactly (same aggregation, EMA50 M15+H1, Donchian-20,
    03:00-03:59 UTC hour window, identical SL/TP + spread) and adds the one
    causal gate at entry emission. Returns the same pooled per-trade PnL
    list format the engine/audit use.
    """
    t15, o15, h15, l15, c15 = l3.aggregate(ts, o, h, l, c, 15)
    t1, o1, h1, l1, c1 = l3.aggregate(ts, o, h, l, c, 60)
    e15 = l3.ema(c15, l3.EMA_PERIOD)
    e_h1 = l3.ema(c1, l3.EMA_PERIOD)
    atr15 = l3.atr_wilder(list(zip(t15, o15, h15, l15, c15)), l3.ATR_PERIOD)
    don_up, don_dn = l3.donchian(h15, l15, l3.DONCHIAN)

    h1_ema = {t1[k]: e_h1[k] for k in range(len(t1))}

    trades = []          # list of dicts w/ entry metadata (for gating)
    for i in range(l3.WARMUP_M15, len(t15)):
        ts_end = t15[i]
        if l3.hour_utc(ts_end) != l3.WINDOW_HOUR:
            continue
        cn = c15[i]
        e15i, e_h1i = e15[i], h1_ema.get(ts_end)
        a = atr15[i]
        if math.isnan(e15i) or e_h1i is None or math.isnan(e_h1i) or math.isnan(a):
            continue
        up = cn > e15i and cn > e_h1i
        dn = cn < e15i and cn < e_h1i
        if not (up or dn):
            continue
        du, dd = don_up[i], don_dn[i]
        if math.isnan(du) or math.isnan(dd):
            continue
        if up and cn > du:
            side, entry = "BUY", cn
            sl, tp = cn - l3.SL_ATR * a, cn + l3.TP_ATR * a
            level = du
        elif dn and cn < dd:
            side, entry = "SELL", cn
            sl, tp = cn + l3.SL_ATR * a, cn - l3.TP_ATR * a
            level = dd
        else:
            continue

        # ---- Gate C: retest-confirmed breakout (virgin break -> skip) ----
        if gate_c:
            tol = RETEST_TOL_MULT * a
            if not retest_confirmed(i, side, level, c15, h15, l15,
                                    don_up, don_dn, tol):
                continue

        trades.append({"ts": ts_end, "side": side, "entry": entry,
                       "sl": sl, "tp": tp, "level": level})

    # ---- forward resolution: identical to the frozen engine ----
    per_trade, wins = [], 0
    for tr in trades:
        j = next((k for k in range(len(t15)) if t15[k] >= tr["ts"]), None)
        if j is None:
            continue
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
            continue
        if outcome == "TP":
            pts = (tr["tp"] - tr["entry"]) if tr["side"] == "BUY" else (tr["entry"] - tr["tp"])
        else:
            pts = (tr["sl"] - tr["entry"]) if tr["side"] == "BUY" else (tr["entry"] - tr["sl"])
        pnl = pts - l3.SPREAD_USD
        per_trade.append(pnl)
        if pnl > 0:
            wins += 1

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
            "avg_win": aw, "avg_loss": al, "per_trade_pnl": per_trade,
            "n_emitted": len(trades)}


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--csv", default=None)
    args = ap.parse_args(argv)

    csv_path = args.csv
    if not csv_path:
        hist = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "raw", "history")
        cand = sorted(os.listdir(hist))[-1] if os.listdir(hist) else None
        if not cand:
            print("no history CSV found; pass --csv")
            return 1
        csv_path = os.path.join(hist, cand)

    print(f"loading {os.path.basename(csv_path)} ...")
    ts, o, h, l, c = l3.load_csv(csv_path)
    print(f"  {len(ts):,} M1 bars | first={l3._fmt(ts[0])} last={l3._fmt(ts[-1])}")

    # ---- no-drift audit: gate-OFF must equal the certified Layer-3 engine ----
    baseline = l3.run(ts, o, h, l, c)          # the FROZEN engine, verbatim
    off = gated_loop(ts, o, h, l, c, gate_c=False)

    drift = 0
    if len(off["per_trade_pnl"]) != len(baseline["per_trade_pnl"]):
        drift = abs(len(off["per_trade_pnl"]) - len(baseline["per_trade_pnl"]))
    else:
        drift = sum(1 for x, y in zip(off["per_trade_pnl"], baseline["per_trade_pnl"])
                    if abs(x - y) > 1e-9)

    print("\n=== LAYER 5 - RETEST-CONFIRMED BREAKOUT WALK-FORWARD (frozen config 2026-09-19) ===")
    print(f"[no-drift audit] gate-OFF vs frozen engine: {len(off['per_trade_pnl'])} vs "
          f"{len(baseline['per_trade_pnl'])} trades, {drift} PnL mismatches -> "
          f"{'NO DRIFT OK (harness faithful)' if drift == 0 else 'DRIFT - HARNESS VOID'}")

    gated = gated_loop(ts, o, h, l, c, gate_c=True)

    print(f"\n[baseline] frozen engine OOS   : n={baseline['n']:3d}  "
          f"E={baseline['expectancy']:+.4f}  WR={baseline['win_rate']*100:.2f}%  "
          f"RR={baseline['rr']:.2f}  (certified 2026-09-19)")
    print(f"[gated C]  retest gate OOS     : n={gated['n']:3d}  "
          f"E={gated['expectancy']:+.4f}  WR={gated['win_rate']*100:.2f}%  "
          f"RR={gated['rr']:.2f}  (avg win {gated['avg_win']:+.4f} / "
          f"avg loss {gated['avg_loss']:+.4f})")
    print(f"  (emitted/would-trade {gated['n_emitted']:,} retest-confirmed breaks; "
          f"{gated['n']} resolved OOS)")

    # ---- verdict: guardrail ----
    go = (gated["n"] >= MIN_OOS_TRADES and
          gated["expectancy"] == gated["expectancy"] and
          gated["expectancy"] > OOS_MIN_EXPECTANCY and
          gated["expectancy"] > baseline["expectancy"])
    print("\n--- GO / NO-GO (Layer 5 guardrail: filtered E > 0 AND > baseline) ---")
    print(f"  filtered trades >= 30      : {gated['n']} >= {MIN_OOS_TRADES}  -> "
          f"{gated['n'] >= MIN_OOS_TRADES}")
    print(f"  filtered E > 0             : {gated['expectancy']:+.4f} > 0  -> "
          f"{gated['expectancy'] > 0 if gated['expectancy']==gated['expectancy'] else False}")
    print(f"  filtered E > baseline(-{abs(baseline['expectancy']):.2f}) : "
          f"{gated['expectancy']:+.4f} vs {baseline['expectancy']:+.4f}  -> "
          f"{gated['expectancy'] > baseline['expectancy']}")
    print(f"  VERDICT: {'GO - retest gate beats no-filter on OOS; keep at 0.01 and size up ONLY via Layer-1 Kelly' if go else 'NO-GO - retest gate does not rescue the OOS edge; stay 0.01 lots, do NOT size up'}")
    return 0 if go else 3


if __name__ == "__main__":
    sys.exit(main())