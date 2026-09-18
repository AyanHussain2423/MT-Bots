---
title: Overfitting
type: concept
tags: [quant, backtesting, overfitting, statistics]
date: 2026-09-18
sources: [sources/quant-resources-walk-forward, synthesis/2026-09-17-loss-causes]
---

# Overfitting — fitting the noise, not the signal

The #1 way backtests lie. A strategy tuned too hard to historical data
memorizes its random wiggles and fails live. The wiki's own proof: the VP
sweep (2026-09) tested ~30 TP/SL/filter configs on 21 months of gold M1;
the "best" (SL $4.0 / TP $1.0, WR 84.6%, +$46) was **noise** — it only
"won" by abandoning the strategy's own TP=POC rule with an inverted 1:4
R/R, and +$46 over 21 months ≈ $0.23/trade ≈ zero.

## Warning signs

- **Multiple testing**: try 30 configs, pick the best → it will look great
  by chance. The more configs tried, the less the "best" means.
- **Extreme configs win**: the best config being the most extreme (biggest
  SL, smallest TP) is an overfit signature.
- **Inverted R/R grind**: high WR with tiny TP and huge SL barely beats
  breakeven (84.6% vs 80% breakeven at 1:4 R/R) — spread variance eats it.
- **In-sample only**: no [[Walk-Forward Analysis]] = no proof.
- **Small samples**: ~200 trades cannot support 30 parameter choices.

## Antidotes

1. [[Walk-Forward Analysis]] — parameters must prove themselves OOS.
2. **Fewer, pre-committed configs** — decide the configs *before* looking
   at results.
3. **Deflated/robust Sharpe** — penalize the number of trials.
4. **Economic logic first** — a config that only works with an inverted
   R/R is not an edge, it's a grind.
5. [[Monte Carlo Simulation]] — quantifies variance, does not fix overfit.

## Related

- [[Walk-Forward Analysis]] — the primary antidote.
- [[Kelly Criterion]] — garbage WR/RR inputs → garbage sizing.
- [[Quant Math Build Plan]] — the build order exists to avoid this.

## Jargon

- **In-sample** — data used for fitting.
- **Out-of-sample** — held-out data; the honest test.
- **Multiple testing / data snooping** — trying many configs on one dataset.
- **Deflated Sharpe ratio** — Sharpe adjusted for number of trials.