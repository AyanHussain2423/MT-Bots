---
title: Quant Resources — Monte Carlo Drawdown
type: source
tags: [quant, monte-carlo, drawdown, risk-management, sources]
date: 2026-09-18
sources:
  - https://github.com/michaelsboost/StrategyArena
  - https://github.com/bartonguestier1725-collab/backtest-engine
  - https://github.com/robert-hannah/fractal_visual_tools
  - https://browse-export.arxiv.org/pdf/2608.00127
  - https://arxiv.org/abs/2011.06618
  - https://arxiv.org/abs/2103.15310
  - https://www.npmjs.com/package/grademark
---

# Quant Resources — Monte Carlo Drawdown Simulation

User-curated catalog, **2nd verified pass (2026-09-18)** — layer 2 of the
build plan: estimating the worst realistic drawdown of the bots' trade
sequences. Terminology anchored in [[Monte Carlo Simulation]].

> [!warning] Verification notes (2nd pass)
> - **Corrected IDs**: "Simulation of the drawdown and its duration in Lévy
>   models" is **2011.06618** (not 2103.14744; González Cázares & Mijatović,
>   Finance & Stochastics 2022); "Monte Carlo algorithm for the extrema of
>   tempered stable processes" is **2103.15310** (not 2103.15265; Adv. Appl.
>   Prob. 2023).
> - Confirmed on arXiv: **2608.00127** (Drawdown Risk Beyond Brownian
>   Motion).
> - **Unconfirmed**: montecarlosimulationreport (raw.githubusercontent
>   search), Deeptest Library (TradingView search).

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [StrategyArena](https://github.com/michaelsboost/StrategyArena) | GitHub | Monte Carlo stress-testing arena for strategies |
| 2 | [backtest-engine](https://github.com/bartonguestier1725-collab/backtest-engine) | GitHub | **10,000-shuffle drawdown distribution** — the exact resampling pattern for our trade list |
| 3 | [montecarlosimulationreport](https://raw.githubusercontent.com/) | GitHub | Bootstrap drawdown simulation report (search repo) |
| 4 | [Backtest Result Visualiser (fractal_visual_tools)](https://github.com/robert-hannah/fractal_visual_tools) | GitHub | Visualizing backtest/MC results |
| 5 | [Drawdown Risk Beyond Brownian Motion](https://browse-export.arxiv.org/pdf/2608.00127) | Paper | Drawdown risk when returns are fat-tailed — gold's crash regime |
| 6 | [Simulation of the drawdown and its duration in Lévy models](https://arxiv.org/abs/2011.06618) | Paper | MC + multilevel MC for drawdown/duration under Lévy (fat tails) |
| 7 | [Monte Carlo algorithm for the extrema of tempered stable processes](https://arxiv.org/abs/2103.15310) | Paper | MC for drawdown risk measures under CGMY/tempered stable |
| 8 | [grademark](https://www.npmjs.com/package/grademark) | npm | JavaScript backtester with Monte Carlo built in |
| 9 | [Deeptest Library](https://br.tradingview.com/script/) | TradingView | 50+ metrics incl. Monte Carlo (search) |

## What to extract (for our bots)

- **Resample the real trade list** (gold + BTC bots, ~30+ trades since
  09-10) — 1,000–10,000 shuffles → 95th-percentile max drawdown and longest
  losing streak. These numbers set the [[Kill Switch]] limits and the
  fractional-Kelly size in [[Layer 1 Sizing Design]].
- **backtest-engine's 10,000-shuffle approach** is the closest match to our
  data (list of real trades, not parametric).
- **Lévy drawdown papers** (#6/#7) — the fat-tailed math for gold's crash
  regime; the 09-16 crash was a p90 daily move (see [[Layer 1 Sizing Design]]),
  so tail-aware drawdown matters.

## Related

- [[Monte Carlo Simulation]], [[Quant Math Build Plan]], [[Kill Switch]],
  [[Kelly Criterion]], [[Layer 1 Sizing Design]]