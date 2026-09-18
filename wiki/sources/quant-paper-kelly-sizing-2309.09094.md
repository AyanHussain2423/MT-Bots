---
title: Quant Paper — Kelly Sizing 2309.09094
type: source
tags: [quant, position-sizing, kelly, volatility, var, backtest, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/kelly-sizing-2309.09094.pdf
  - https://arxiv.org/abs/2309.09094
---

# Sizing Strategies for Algorithmic Trading in Volatile Markets

S. M. Masrur Ahmed (Brac University), arXiv:2309.09094v2 [q-fin.CP], Sep 2023.
56 pages. Downloaded + text-extracted 2026-09-18.

## What it is

An academic study of **position sizing models under high volatility**: how
different sizing schemes lower Value-at-Risk (VaR) during crisis events.
Backtests sizing strategies on stocks/ETFs with AR, ARIMA, LSTM and GARCH
models, and compares backtesting methodologies.

## Key content

- **Sizing as risk control**: the paper's core claim — sizing (not signal
  quality) is the lever that reduces VaR in crisis regimes. Directly supports
  layer 1 of [[Quant Math Build Plan]].
- **Backtesting methodologies compared**: Bernoulli trials (Kelly 1956),
  independence/joint tests, **geometric VaR backtest**, Markov model test,
  **Kalman-filter backtest**, minimum-variance backtest. The geometric-VaR
  and Kalman approaches are candidates for our own backtest engine's risk
  metrics.
- **Technical indicators catalog**: RSI, Bollinger Bands, SMA, Aroon, PVT,
  Acceleration Bands, Stochastic, Chaikin Money Flow, Parabolic SAR, Keltner
  Channels, Ichimoku, MFI — with correlation analysis between them. Useful
  reference for layer 4 entry filters.
- **Volatility forecasting**: GARCH used as the volatility input to sizing —
  the same idea as [[Volatility Targeting]] (forecast vol → size).

## What it gives our build

- The **"size down when vol is high"** evidence base for gold: our bots trade
  fixed 0.01 lots; layer 1 replaces that with vol-scaled size.
- A menu of **backtest risk metrics** (geometric VaR, Kalman) to reuse in the
  backtest engine that must replicate the EA's `simulate()`.
- GARCH-as-sizing-input pattern, cross-referenced with the Garch-Method repo
  in [[Quant Resources — Kelly & Volatility Sizing]].

## Terminology

- **VaR (Value-at-Risk)** — worst expected loss over a horizon at a
  confidence level; the paper's target metric.
- **Backtest** — replaying a strategy on historical data to estimate
  performance.
- **Kalman filter** — recursive estimator of a hidden state (here: true
  volatility) from noisy observations.
- **GARCH** — volatility model where current variance depends on past
  variance and shocks; see [[Volatility Targeting]].

## Related

- [[Kelly Criterion]], [[Volatility Targeting]], [[Quant Math Build Plan]],
  [[Quant Resources — Kelly & Volatility Sizing]]