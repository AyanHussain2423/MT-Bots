"""
Layer 1 Sizing Script — Kelly gate + volatility-targeted position sizing
for the Gold bot (and BTC bots).

Implements the formula from wiki/synthesis/layer-1-sizing-design.md:

    f*      = p - q/b                     (full Kelly, from live stats)
    f       = 0.5 * f*                    (half-Kelly, fat tails)
    risk    = min(f * equity, 2% * equity)   (risk cap)
    lots    = risk / (SL_pts * $1)        (0.01 lot floor; 1 pt = $1 on gold)

Kelly gate: size up ONLY when f* > 0 on >= 30 trades. Otherwise 0.01 lots.

Usage:
    python layer1_sizing.py                 # run with documented stats
    python layer1_sizing.py --trades trades.csv   # recompute stats from CSV
    python layer1_sizing.py --p 0.40 --b 2.0 --n 35   # override stats

CSV format (--trades): one row per closed trade with a profit column
(header: ...,profit,...). Positive = win, negative = loss.
"""

import argparse
import csv
import sys

# --- Documented verified stats (2026-09-18, layer-1-sizing-design.md) ---
DOC_P = 7 / 21          # 7W/14L = 33.3% win rate
DOC_B = 1.74            # realized RR (avg win $10.09 / avg loss $5.79)
DOC_N = 21              # sample size

# M15 ATR(14) distribution, 49,636 bars 2025-01 -> 2026-09 (design doc table)
ATR_PTS = {"p25": 3.07, "median": 5.65, "p75": 8.71, "p90": 12.24}
SL_MULT = 1.5           # SL distance = 1.5 x ATR
TP_MULT = 3.0           # TP distance = 3.0 x ATR (2:1 RR design)
POINT_VALUE = 1.0       # $1 per point per 0.01 lot on gold (1.0 lot = 100 oz)
MIN_LOTS = 0.01
RISK_CAP = 0.02         # 2% of equity
KELLY_FRACTION = 0.5    # half-Kelly
GATE_MIN_TRADES = 30    # Kelly gate: need >= 30 trades to size up


def kelly(p, b, n):
    """Full Kelly fraction. p = win rate, b = avg win / avg loss."""
    q = 1.0 - p
    f_star = p - q / b
    return f_star


def lots_for(risk_usd, sl_pts):
    """Lots to express risk_usd with an sl_pts stop.

    risk = sl_pts * $1 * (lots / 0.01)  ->  lots = risk / sl_pts * 0.01
    Floor at 0.01 (broker minimum).
    """
    lots = risk_usd / sl_pts * 0.01
    return max(lots, MIN_LOTS)


def main():
    ap = argparse.ArgumentParser(description="Layer 1 sizing: Kelly gate + ATR sizing")
    ap.add_argument("--trades", help="CSV with a profit column to recompute stats")
    ap.add_argument("--p", type=float, help="win rate override")
    ap.add_argument("--b", type=float, help="avg win/avg loss override")
    ap.add_argument("--n", type=int, help="trade count override")
    args = ap.parse_args()

    # --- Stats: from CSV if given, else documented/overridden ---
    if args.trades:
        wins, losses = [], []
        with open(args.trades, newline="", encoding="utf-8-sig") as fh:
            for row in csv.DictReader(fh):
                prof = row.get("profit") or row.get("Profit")
                if prof is None or prof == "":
                    continue  # skip footer/note lines, non-trade rows
                v = float(prof)
                (wins if v > 0 else losses).append(v)
        n = len(wins) + len(losses)
        p = len(wins) / n if n else 0.0
        b = (sum(wins) / len(wins)) / (abs(sum(losses)) / len(losses)) if wins and losses else 0.0
        print(f"From CSV: {len(wins)}W/{len(losses)}L, p={p:.3f}, b={b:.2f}")
    else:
        p = args.p if args.p is not None else DOC_P
        b = args.b if args.b is not None else DOC_B
        n = args.n if args.n is not None else DOC_N
        print(f"Stats: {n} trades, p={p:.3f}, b={b:.2f} (documented 2026-09-18)")

    # --- Kelly gate ---
    f_star = kelly(p, b, n)
    print("\n=== KELLY GATE ===")
    print(f"f* (full Kelly) = p - q/b = {p:.3f} - {1-p:.3f}/{b:.2f} = {f_star:+.3f}")

    if f_star <= 0:
        print("VERDICT: NO POSITIVE EDGE -> stay at 0.01 lots. Sizing scales edge,")
        print("         it cannot create it. Recheck after the v3.27 filtered sample.")
        if n < GATE_MIN_TRADES:
            print(f"         (also: only {n} trades, gate needs >= {GATE_MIN_TRADES})")
        return 0

    if n < GATE_MIN_TRADES:
        print(f"VERDICT: f* > 0 but sample too small ({n} < {GATE_MIN_TRADES}) -> 0.01 lots")
        return 0

    f = KELLY_FRACTION * f_star
    print(f"VERDICT: EDGE CONFIRMED (f*={f_star:+.3f} > 0, n={n} >= {GATE_MIN_TRADES})")
    print(f"half-Kelly f = {f:.4f}")

    # --- Sizing table across equity levels x ATR percentiles ---
    print("\n=== SIZING TABLE (half-Kelly x 2% cap, 0.01 floor) ===")
    print(f"{'Equity':>8} {'ATR':>8} {'SL pts':>7} {'risk $':>8} {'lots':>6}  note")
    for equity in (100, 300, 500):
        for label, atr in ATR_PTS.items():
            sl_pts = SL_MULT * atr
            risk = min(f * equity, RISK_CAP * equity)
            lots = lots_for(risk, sl_pts)
            note = ""
            if lots == MIN_LOTS:
                note = "<- floor binds (risk not expressible)"
            print(f"{equity:>8} {label:>8} {sl_pts:>7.2f} {risk:>8.2f} {lots:>6.2f}  {note}")

    # --- Volatility-targeting check: what risk does 0.01 lot imply? ---
    print("\n=== 0.01-LOT RISK AT CURRENT ATR (the binding constraint) ===")
    for label, atr in ATR_PTS.items():
        sl_pts = SL_MULT * atr
        risk = sl_pts * POINT_VALUE  # $1 per pt per 0.01 lot
        print(f"  ATR {label:>6}: SL {sl_pts:>6.2f} pts -> risk ${risk:>6.2f} per 0.01 lot")
    print("\nAt $100 equity, 0.01 lots = 8-13% risk/trade (design doc: capital decision,")
    print("recommendation C: fund demo to ~$300-500 so 1.5xATR ~ 2-3% risk).")
    return 0


if __name__ == "__main__":
    sys.exit(main())