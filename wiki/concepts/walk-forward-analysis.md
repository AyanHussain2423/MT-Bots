---
title: Walk-Forward Analysis
type: concept
tags: [quant, backtesting, walk-forward, overfitting]
date: 2026-09-18
sources: [sources/quant-resources-walk-forward]
---

# Walk-Forward Analysis (WFA) — honest out-of-sample testing

The framework that makes a backtest **trustworthy**: parameters are fit on
one window and tested on the *next* window, rolling forward through time.
No lookahead — the test data is never seen during fitting.

## The problem it solves

The VP sweep lesson (2026-09): ~30 configs tested on the same 21 months,
the "best" (+$46, WR 84.6%) was noise. Any parameter picked by looking at
the full dataset is **in-sample** — it has already seen the answer. WFA
forces every parameter choice to prove itself on data it has never seen.

## How it works

```
[ train ][ test ]  →  record test result
         [ train ][ test ]  →  record test result
                  [ train ][ test ]  →  ...
```

- **Anchored** — training window always starts at the beginning and grows.
- **Rolling** — training window is fixed length and slides forward.
- Each test segment is **out-of-sample (OOS)**. The aggregate OOS result is
  the honest estimate of the edge.

## What to measure

- OOS expectancy per trade (compare to in-sample — big gap = overfit).
- OOS win rate and R/R (feed [[Kelly Criterion]]).
- **Robust Sharpe ratio** / deflated Sharpe — penalizes the number of
  configurations tried (multiple testing).

## Related

- [[Overfitting]] — WFA is the primary antidote.
- [[Quant Math Build Plan]] — layer 3 of the build order.
- [[Monte Carlo Simulation]] — run Monte Carlo *on the OOS trades* for the
  drawdown distribution.

## Jargon

- **In-sample (IS)** — data used to fit/choose parameters.
- **Out-of-sample (OOS)** — data held back from fitting; the honest test.
- **Lookahead bias** — accidentally using future data in a decision.
- **Walk-forward optimization (WFO)** — the rolling train/test procedure.
- **Robust Sharpe ratio** — Sharpe adjusted for the number of trials.