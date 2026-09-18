---
title: Quant Paper — Drawdown Beyond Brownian 2608.00127
type: source
tags: [quant, monte-carlo, drawdown, risk-management, sharpe, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/drawdown-beyond-brownian-2608.00127.pdf
  - https://arxiv.org/abs/2608.00127
---

# Drawdown Risk Beyond Brownian Motion: A Monte-Carlo Framework, Non-Gaussian Extensions, and Long Memory

Francesco Landolfi (Epiphany), arXiv:2608.00127v1 [q-fin.RM], Jul 2026.
19 pages. Downloaded + text-extracted 2026-09-18.

## What it is

Answers "how deep and how long should a strategy's drawdowns run, given its
Sharpe ratio and return structure?" — building on the Rej–Seager–Bouchaud
(RSB 2017) closed-form drawdown framework, reframed as a transparent
**Monte-Carlo experiment** with non-Gaussian and long-memory extensions.

## Key content

- **RSB baseline**: P&L as drifted Brownian motion normalized to unit
  volatility → annualized Sharpe = drift → closed-form drawdown depth/length
  distributions from that single number.
- **Four decision-relevant measures** (the keep-or-kill dashboard): maximum
  drawdown, maximum loss, final negative time, longest recovery time — cast
  as lookup tables.
- **Non-Gaussian extensions**: holding true Sharpe and volatility fixed while
  varying skewness, fat tails, volatility clustering and Sharpe-estimation
  uncertainty across strategy archetypes — the four measures move
  *differently*, so a single Gaussian table mis-warns.
- **Long memory (fBm)**: the apparent drawdown amplification under
  persistence is mostly self-similar dispersion scaling T^(H−1/2) — a failure
  of square-root-of-time calibration, not intrinsic danger.
- Reproducible lookup tables + a practical calibration recipe (Section 7).

## What it gives our build

- **Layer 2 directly**: the MC framework is exactly the resampling engine we
  need for the bots' trade lists — but with the non-Gaussian warning: gold's
  returns are fat-tailed (the 09-16 crash was a p90 daily move, see
  [[Layer 1 Sizing Design]]), so a Gaussian-only drawdown table would
  mis-warn.
- **The four measures** map to our risk dashboard: max drawdown (kill-switch
  sizing), max loss, time under water (patience before judging the edge
  dead), longest recovery time.
- **Calibration recipe** (Section 7) — the practical steps to calibrate the
  tables to our own gold/BTC P&L from the 21-month CSV.

## Terminology

- **Sharpe ratio** — annualized excess return per unit of volatility; the
  single input to the RSB tables.
- **Drawdown** — decline from a historical peak; see [[Monte Carlo Simulation]].
- **Fractional Brownian motion (fBm)** — Gaussian process with long memory
  (Hurst H ≠ 0.5); used to model persistent P&L.
- **Square-root-of-time** — the assumption that risk scales with √T; the
  paper shows persistence breaks it.

## Related

- [[Monte Carlo Simulation]], [[Risk Reward]], [[Kill Switch]],
  [[Layer 1 Sizing Design]], [[Quant Math Build Plan]],
  [[Quant Resources — Monte Carlo Drawdown]]