---
title: Layer 1 Sizing Design
type: synthesis
tags: [quant, position-sizing, kelly, volatility-targeting, layer-1, design]
date: 2026-09-18
sources:
  - sources/2026-09-17-bot-week-session
  - sources/quant-paper-kelly-sizing-2309.09094
  - sources/quant-paper-kelly-levy-2002.03448
  - sources/quant-paper-optimal-growth-1510.05123
  - raw/strategy/quant/kelly-sizing-2309.09094.pdf
---

# Layer 1 Design — Kelly / Volatility Sizing for the Gold Bot

First design pass for layer 1 of [[Quant Math Build Plan]]: replacing the
bots' fixed 0.01 lots with edge/volatility-based sizing. Inputs: the live
trade sample (21 gold trades, 09-09 → 09-17), the 21-month gold M1 CSV
(744,518 M1 bars → 49,636 M15 bars), and the five sizing papers ingested
2026-09-18.

## 1. Edge check first — the honest Kelly number

Kelly from the live sample ([[2026-09-17 Bot Week Session]] + 09-09/09-11
sessions): **21 trades, 7W/14L = 33.3% WR**, realized RR ≈ 1.74 (avg win
$10.09 / avg loss $5.79, 09-12→17 sample).

```
f* = p − q/b = 0.333 − 0.667/1.74 ≈ −0.05   →   NO POSITIVE EDGE
```

**Kelly says: do not size up.** At 33.3% WR the bot needs RR ≥ 2.0 just to
break even; it realized 1.74. Sizing scales edge — it cannot create it.
This is the core Layer 1 finding: **the current trade sample does not
justify any risk above the 0.01-lot minimum.** The v3.26/v3.27 fixes (03-04
UTC window, ATR SL/TP, spike filter, fresh guard) target exactly the
failure modes that killed the edge; the sizing layer waits for that sample.

## 2. Volatility targeting reality check (21-month CSV)

M15 ATR(14) distribution (49,636 bars, 2025-01 → 2026-09):

| Stat | ATR(14) pts | 1.5×ATR SL (pts) | Risk @ 0.01 lot | % of $100 acct |
|------|------------|------------------|-----------------|----------------|
| p25  | 3.07       | 4.6              | $4.61           | 4.6%           |
| median | 5.65     | 8.48             | $8.48           | 8.5%           |
| p75  | 8.71       | 13.07            | $13.07          | 13.1%          |
| p90  | 12.24      | 18.37            | $18.37          | 18.4%          |

- **Only 27.6% of bars** (28.7% inside 03-04 UTC) have 1.5×ATR ≤ 5 pts —
  i.e., the ATR stop fits a $5 risk budget less than a third of the time.
- 03-04 UTC vol is only marginally lower (median ATR 5.22 vs 5.65) — the
  hour window does NOT fix the risk-per-trade problem.
- D1 ATR(14): median $59.36, p90 $136.69 — the 09-16 crash (~132 pts) was a
  p90 daily move, i.e. a ~1-in-10-day event, not a black swan.

**The account-size constraint is the binding one.** $100 account + 0.01 lot
minimum (1 pt = $1) + ATR-based stop = 8–13% risk per trade. The sizing
layer cannot fix this with formulas; it is a capital decision.

## 3. The sizing formula to implement (once edge is positive)

```
f*      = p − q/b                     (full Kelly, from live stats)
f       = 0.5 × f*                    (half-Kelly — fat tails, see
                                       [[Quant Paper — Kelly Lévy 2002.03448]])
risk    = min(f × equity, 2% × equity)   (risk cap)
lots    = risk / (SL_pts × $1)        (0.01 lot floor; 1 pt = $1 on gold)
```

- **SL distance** = 1.5 × M15 ATR(14) (already in v3.26) — the volatility
  targeting input; risk therefore varies with vol, which is the point.
- **TP** = 3.0 × ATR keeps the 2:1 RR the strategy is designed around.
- **Half-Kelly** is the conservative choice per the Lévy paper (fat tails)
  and the optimal-growth paper (non-ergodicity, capacity constraints).
- **The 0.01-lot floor binds first**: with SL ≈ 8.5 pts median, even 2% of
  $100 ($2) cannot be expressed — minimum risk per trade is $8.48. Sizing
  only becomes meaningful above ~$300 equity.

## 4. Decision needed (user)

The ATR stop (v3.26, correct for noise) and the $100 account are
incompatible at 0.01 lots. Options:

| Option | Risk/trade | Verdict |
|--------|-----------|---------|
| A. Fixed $5 SL (5 pts) | 5% | Inside M15 noise — the v3.26 rationale for ATR SL; 5 of 7 losers died on 5–8 pt wiggles |
| B. ATR SL on $100 | 8–13% | Too much risk per trade; one bad week = −28% (already happened) |
| C. **Fund to ~$300–500** | 2–3% | ATR SL becomes sane; sizing layer becomes meaningful |
| D. 03-04 UTC only + ATR SL | 7.8–11.6% | Window vol barely lower — does not fix it |

**Recommendation: C** — keep v3.26 ATR SL/TP, fund the demo account to
~$300–500 so 1.5×ATR ≈ 2–3% risk, and let the sizing layer scale from
there. Until then, stay at 0.01 lots regardless of what Kelly says.

## 5. Measurement plan (the go/no-go gate)

- With v3.27 live, collect the **filtered sample**: 03-04 UTC entries only,
  ATR SL/TP, spike filter + fresh guard active.
- Recompute WR/RR monthly; **Kelly gate**: size up only when f* > 0 on
  ≥ 30 trades. Until then, 0.01 lots.
- Track realized RR vs designed 2:1 — the 1.74 realized RR (not 2.0) is
  what killed the edge; the ATR SL/TP should restore it.
- Cross-check with [[Monte Carlo Simulation]] (layer 2) once the sample
  exists: worst drawdown at the chosen risk must stay inside the kill
  switch (−$50).

## Related

- [[Quant Math Build Plan]], [[Kelly Criterion]], [[Volatility Targeting]],
  [[2026-09-17 Loss Causes]], [[Quant Paper — Kelly Sizing 2309.09094]],
  [[Quant Paper — Kelly Lévy 2002.03448]],
  [[Quant Paper — Optimal Growth 1510.05123]]