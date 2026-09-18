---
title: Kelly Criterion
type: concept
tags: [quant, position-sizing, risk-management, kelly]
date: 2026-09-18
sources: [sources/quant-resources-kelly-sizing]
---

# Kelly Criterion — edge-based position sizing

The formula that sizes a bet from the **edge** (win rate + payoff ratio)
instead of a fixed lot. This is the math behind replacing the bots' fixed
0.01 lots with edge-based sizing.

## The formula

For a bet with win probability `p`, loss probability `q = 1 − p`, and payoff
ratio `b` (average win ÷ average loss):

```
f* = (b·p − q) / b = p − q/b
```

- `f*` = fraction of equity to risk per trade (the **Kelly fraction**).
- If `b·p − q ≤ 0` there is **no edge** — Kelly says bet nothing. This is
  the first filter: a strategy that fails Kelly's edge test should not be
  traded at all.

## Worked example (gold breakout bot)

Live-ish stats: WR ≈ 40%, RR 2:1 → `f* = 0.40 − 0.60/2 = 0.10` → risk 10%
of equity per trade. That is **full Kelly** — too aggressive (drawdowns are
wild). Standard practice is **fractional Kelly**: 25–50% of `f*` → risk
2.5–5% per trade.

## Why fractional Kelly

- Full Kelly maximizes long-run growth but with ~50% drawdowns in practice.
- Half Kelly gives ~75% of the growth with ~half the drawdown.
- On a $100 demo account, 0.01 lot with a $5 SL already risks 5% — that is
  roughly half-Kelly territory for a 40% WR / 2:1 RR edge.

## Related

- [[Volatility Targeting]] — the alternative sizing school (size by risk,
  not by edge).
- [[Risk Reward]] — the RR side of the formula.
- [[Overfitting]] — Kelly is only as good as the WR/RR inputs; garbage
  inputs → garbage size.
- [[Quant Math Build Plan]] — where this fits in the build order (layer 1).

## Jargon

- **Kelly fraction (f\*)** — optimal fraction of equity to risk.
- **Fractional Kelly** — using a fraction (typically 25–50%) of f\*.
- **Edge** — positive expected value per trade (see [[Risk Reward]]).
- **Optimal f** — Ralph Vince's generalization of Kelly for asymmetric
  payoffs (see [[Quant Math Build Plan]]).