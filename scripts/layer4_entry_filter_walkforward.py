"""
Layer 4 - Entry-filter gate walk-forward (candidate 1) for the Gold bot.

Honor contract (see wiki/synthesis/layer-4-precommit-config.md, frozen
2026-09-19 BEFORE this run): the signal path is the FROZEN Layer-3 engine,
imported verbatim. This script adds ONLY two causal, pre-specified entry
gates. It never re-derives the trend/Donchian/ATR/SL/TP logic and never gazes
at Layer-4 OOS results with unfrozen knobs.

The two gates (both computed from bars strictly BEFORE the entry bar):

  Gate A - min-break distance (marginal-break trap):
      BUY  kept only if  entry - donchian_up(prior-20) >= MIN_BREAK_PTS
      SELL kept only if  donchian_dn(prior-20) - entry >= MIN_BREAK_PTS
      MIN_BREAK_PTS = 0.30 == SPREAD (any break narrower than the trade's own
      round-trip cost can never cover its border = documented marginal trap).

  Gate B - one entry per Donchian-20 channel level (re-entry decay):
      A BUY requiring a strictly NEW 20-bar channel-high level
      (don_up > last BUY's don_up); a SELL requiring a strictly NEW 20-bar
      channel-low level. No re-entry at the same level - the documented
      "re-entries into the same move decay" finding (#4-#6).

No-drift audit baked in: the gate-OFF pass must reproduce the certified
Layer-3 baseline (35 OOS trades, -4.42/trade, 25.71% WR, avg W/L 1.24) - i.e.
the SAME pooled per-trade PnL list as the frozen engine - otherwise this
script is not a faithful Layer-4 harness and its verdict is void.

Verdict rule (build-plan guardrail): filtered OOS expectancy must be
> 0 AND > unfiltered baseline. Verdict NO-GO otherwise -> stay 0.01 lots,

Run from repo root:
    python scripts/layer4_entry_filter_walkforward.py --csv raw/history/<file>.csv
"""

import argparse
import csv
import math
import os
import sys

import layer3_walkforward as l3  # the FROZEN engine (imported, never edited)

# Layer-4 gates - frozen 2026-09-19 (== Spread; principled, not tuned)
MIN_BREAK_PTS = 0.30

MIN_OOS_TRADES = l3.MIN_OOS_TRADES        # >= 30 filtered OOS trades
OOS_MIN_EXPECTANCY = l3.OOS_MIN_EXPECTANCY  # > 0 (and > unfiltered baseline)


def gated_loop(ts, o, h, l, c, gate_a=True, gate_b=True):
    """Re-run the FROZEN engine signal loop, optionally gated by A/B.

    Mirrors l3.run() exactly (same aggregation, EMA50 M15+H1, Donchian-20,
    ../../../ 03:00-03:59 UTC hour window, identical SL/TP + spread) and adds
    the two causal gates at entry emission. Returns the same pooled per-trade
    PnL list format the engine/audit use.
    """
    t15, o15, h15, l15, c15 = l3.aggregate(ts, o, h, l, c, 15)
    t1, o1, h1, l1, c1 = l3.aggregate(ts, o, h, l, c, 60)
    e15 = l3.ema(c15, l3.EMA_PERIOD)
    e_h1 = l3.ema(c1, l3.EMA_PERIOD)
    atr15 = l3.atr_wilder(list(zip(t15, o15, h15, l15, c15)), l3.ATR_PERIOD)
    don_up, don_dn = l3.donchian(h15, l15, l3.DONCHIAN)

    h1_ema = {t1[k]: e_h1[k] for k in range(len(t1))}

    trades = []          # list of dicts w/ entry metadata (for gating)
    last_buy_level = None   # don_up at last taken BUY
    last_sell_level = None  # don_dn at last taken SELL
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
            edge, level = "du", du
        elif dn and cn < dd:
            side, entry = "SELL", cn
            sl, tp = cn + l3.SL_ATR * a, cn - l3.TP_ATR * a
            edge, level = "dd", dd
        else:
            continue

        # ---- Gate A: min-break distance ----
        if gate_a:
            if side == "BUY" and (entry - level) < MIN_BREAK_PTS:
                continue
            if side == "SELL" and (level - entry) < MIN_BREAK_PTS:
                continue
        # ---- Gate B: one entry per channel level (fresh extreme only) ----
        if gate_b:
            if side == "BUY":
                if last_buy_level is not None and level <= last_buy_level:
                    continue  # same (or lower) channel-high level - re-entry decay
                last_buy_level = level
            else:
                if last_sell_level is not None and level >= last_sell_level:
                    continue  # same (or higher) channel-low level - re-entry decay
                last_sell_level = level

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
    off = gated_loop(ts, o, h, l, c, gate_a=False, gate_b=False)

    drift = 0
    if len(off["per_trade_pnl"]) != len(baseline["per_trade_pnl"]):
        drift = abs(len(off["per_trade_pnl"]) - len(baseline["per_trade_pnl"]))
    else:
        drift = sum(1 for x, y in zip(off["per_trade_pnl"], baseline["per_trade_pnl"])
                    if abs(x - y) > 1e-9)

    print("\n=== LAYER 4 - ENTRY-FILTER WALK-FORWARD (frozen config 2026-09-19) ===")
    print(f"[no-drift audit] gate-OFF vs frozen engine: {len(off['per_trade_pnl'])} vs "
          f"{len(baseline['per_trade_pnl'])} trades, {drift} PnL mismatches -> "
          f"{'NO DRIFT OK (harness faithful)' if drift == 0 else 'DRIFT - HARNESS VOID'}")

    gated = gated_loop(ts, o, h, l, c, gate_a=True, gate_b=True)

    print(f"\n[baseline] frozen engine OOS   : n={baseline['n']:3d}  "
          f"E={baseline['expectancy']:+.4f}  WR={baseline['win_rate']*100:.2f}%  "
          f"RR={baseline['rr']:.2f}  (certified 2026-09-19)")
    print(f"[gated A+B] Layer-4 filter OOS : n={gated['n']:3d}  "
          f"E={gated['expectancy']:+.4f}  WR={gated['win_rate']*100:.2f}%  "
          f"RR={gated['rr']:.2f}  (avg win {gated['avg_win']:+.4f} / "
          f"avg loss {gated['avg_loss']:+.4f})")
    print(f"  (emitted/would-trade {gated['n_emitted']:,} breakouts; {gated['n']} resolved OOS)")

    # ---- verdict: guardrail ----
    go = (gated["n"] >= MIN_OOS_TRADES and
          gated["expectancy"] == gated["expectancy"] and
          gated["expectancy"] > OOS_MIN_EXPECTANCY and
          gated["expectancy"] > baseline["expectancy"])
    print("\n--- GO / NO-GO (Layer 4 guardrail: filtered E > 0 AND > baseline) ---")
    print(f"  filtered trades >= 30      : {gated['n']} >= {MIN_OOS_TRADES}  -> "
          f"{gated['n'] >= MIN_OOS_TRADES}")
    print(f"  filtered E > 0             : {gated['expectancy']:+.4f} > 0  -> "
          f"{gated['expectancy'] > 0 if gated['expectancy']==gated['expectancy'] else False}")
    print(f"  filtered E > baseline(-{abs(baseline['expectancy']):.2f}) : "
          f"{gated['expectancy']:+.4f} vs {baseline['expectancy']:+.4f}  -> "
          f"{gated['expectancy'] > baseline['expectancy']}")
    print(f"  VERDICT: {'GO - filter beats no-filter on OOS; keep at 0.01 and size up ONLY via Layer-1 Kelly' if go else 'NO-GO - filter does not rescue the OOS edge; stay 0.01 lots, do NOT size up'}")
    return 0 if go else 3


if __name__ == "__main__":
    sys.exit(main())
