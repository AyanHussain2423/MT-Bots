---
title: Quant Paper — Double-OOS Walk-Forward 2602.10785
type: source
tags: [quant, walk-forward, backtesting, overfitting, out-of-sample, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/walkforward-double-oos-2602.10785.pdf
  - https://arxiv.org/abs/2602.10785
---

# A Novel Approach to Trading Strategy Parameter Optimization, Using Double Out-of-Sample Data and Walk-Forward Techniques

Tomasz Mroziewicz & Robert Ślepaczuk (University of Warsaw), arXiv:2602.10785v1
[q-fin.TR], Feb 2026. 40 pages. Downloaded + text-extracted 2026-09-18.
This is the arxiv version of the SSRN 3135062 paper in
[[Quant Resources — Walk-Forward Framework]].

## What it is

A walk-forward optimization study that **parameterizes the train/test window
lengths themselves** (1–28 days, 81 combinations) on an EMA-crossover
strategy over intraday crypto (BTC/ETH/BNB, 1m–60m), with a strict
**single-time out-of-sample execution** protocol.

## Key content

- **Window length matters**: performance under walk-forward depends heavily
  on chosen train/test window sizes — so window choice is itself a parameter
  to be tested, not assumed.
- **Double-OOS discipline**: parameters picked on a 19-month training period
  were applied **once** to a 21-month unseen test period. No iterative
  re-optimization on OOS data — the exact anti-pattern our VP sweep
  committed (see [[Overfitting]]).
- **Robust Sharpe Ratio** as the selection metric (not raw return).
- **Bootstrap significance** (RH3): is the strategy better than random?
  Bootstrap resampling answers it — the same tool as
  [[Monte Carlo Simulation]].
- **Cost sensitivity**: break-even transaction cost ≈ 0.4%; at 0.1% fees the
  strategy holds. Every backtest must state its cost assumption.
- **Portfolio effect**: combining Buy-and-Hold with the strategy beat all
  individual strategies with a **50% drawdown reduction** — a sizing/portfolio
  idea, not just a signal idea.

## What it gives our build

- The **protocol for layer 3**: rolling walk-forward with parameterized
  windows + single OOS execution + bootstrap significance + cost sensitivity
  — the honest replacement for the full-data VP sweep.
- The **"strategy + passive" portfolio** idea: even a mediocre signal can
  improve risk-adjusted results when blended — relevant to how we size the
  gold bot against simply holding.
- GitHub repo with all calculations: `github.com/tmr-crypto/wf_optim_crypto_analysis`.

## Terminology

- **Walk-forward** — rolling train/test optimization; see
  [[Walk-Forward Analysis]].
- **Out-of-sample (OOS)** — data never used in parameter selection.
- **Robust Sharpe Ratio** — Sharpe adjusted for non-normality of returns.
- **Bootstrap** — resampling with replacement to estimate the distribution
  of a statistic (here: whether the strategy beats random).
- **Break-even cost** — the transaction cost at which strategy profit → 0.

## Related

- [[Walk-Forward Analysis]], [[Overfitting]], [[Monte Carlo Simulation]],
  [[Quant Math Build Plan]], [[Quant Resources — Walk-Forward Framework]]