---
title: Monte Carlo Simulation
type: concept
tags: [quant, risk-management, drawdown, monte-carlo]
date: 2026-09-18
sources: [sources/quant-resources-monte-carlo]
---

# Monte Carlo Simulation — drawdown estimation

Resampling a trade sequence thousands of times to estimate what the
**worst realistic outcome** looks like, instead of trusting the single
historical equity curve.

## Why the historical curve is not enough

One backtest = one path. The same strategy with the same trades could have
been dealt in a different order (wins and losses shuffled) and produced a
very different drawdown. Monte Carlo shuffles/resamples the trade list
(typically 1,000–10,000 runs) and builds a **distribution** of outcomes:
max drawdown, longest losing streak, final equity percentiles.

## What it answers for our bots

- "What is the 95th-percentile max drawdown over 3 months?" — the number
  the kill switch and sizing should be built around.
- "Is this month's loss within normal variance or a broken strategy?"
- "How many consecutive losses can this bot realistically hit?" (feeds the
  [[Kelly Criterion]] inputs and the [[Kill Switch]] limits).

## Two flavors

1. **Resample trades** — shuffle/re-sample the actual trade list (keeps
   each trade's P/L, changes the order). Best for our use: we have real
   trades from the bots.
2. **Parametric** — draw P/L from a fitted distribution (normal, t, etc.).
   Needs the distribution to be right; less faithful for fat-tailed
   strategies.

## Related

- [[Quant Math Build Plan]] — layer 2 of the build order.
- [[Kelly Criterion]] — sizing needs the drawdown distribution first.
- [[Overfitting]] — Monte Carlo does not fix overfitting; it quantifies
  variance of a *given* strategy.

## Jargon

- **Resampling** — drawing with replacement from the observed trade list.
- **Percentile** — e.g. 95th-percentile drawdown = only 5% of simulated
  runs exceed it.
- **Max drawdown** — largest peak-to-trough equity decline in a run.
- **Losing streak** — consecutive losing trades.