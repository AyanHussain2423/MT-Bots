---
title: Quant Paper — Cluster Regression VI 2205.00605
type: source
tags: [quant, machine-learning, regression, regimes, forecasting, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/cluster-regression-vi-2205.00605.pdf
  - https://arxiv.org/abs/2205.00605
---

# Cluster-based Regression using Variational Inference and Applications in Financial Forecasting

Udai G. Nagpal (Goldman Sachs), Krishan M. Nagpal (Wells Fargo),
arXiv:2205.00605v3 [q-fin.ST], v3 Dec 2023. 19 pages.
Downloaded + text-extracted 2026-09-18.

## What it is

A method that **simultaneously identifies clusters and estimates
cluster-specific regression parameters** using Variational Inference (VI) —
learning different input→output relationships in different regions of the
input space, which is exactly what market regimes are.

## Key content

- **VI approach**: approximate Bayesian posteriors via optimization (vs
  sampling methods like Metropolis-Hastings) — computationally efficient,
  elegant, interpretable.
- **Output**: both the expected value AND the full distribution of predicted
  output per cluster.
- **Financial framing**: markets have regimes ("rates increasing" vs
  "decreasing", "risk on" vs "risk off") with different patterns and
  correlations in each — cluster-based regression captures this.
- **Illustrative example**: predicting one-day S&P change, compared against
  standard regression without clusters.
- Authors are practitioners (Goldman Sachs asset management, Wells Fargo
  corporate risk) — applied, not purely academic.

## What it gives our build

- **Regime-aware forecasting for layer 4**: the clusters ≈ market regimes —
  the same regime-gating idea as [[Quant Resources — Entry Filters]] and the
  freqtrade-regime-filter, but with a principled Bayesian method.
- **Candidate for the sizing regime input (layer 1)**: cluster membership
  could drive the volatility regime used by [[Volatility Targeting]] — e.g.
  cluster 1 = low-vol trend, cluster 2 = high-vol crash regime (the 09-16
  crash day).
- **Full predictive distribution** (not just point forecast) fits our
  risk-first philosophy: we size from the distribution, not the mean.

## Terminology

- **Variational Inference (VI)** — approximating posterior distributions via
  optimization; faster than MCMC sampling.
- **Cluster** — a group of observations with similar input→output behavior;
  here ≈ market regime.
- **Posterior** — the updated belief about parameters after seeing data
  (Bayesian statistics).
- **Regime** — a persistent market state with distinct behavior; see
  [[Volatility Targeting]].

## Related

- [[Volatility Targeting]], [[Quant Math Build Plan]],
  [[Quant Resources — ML Regression]], [[Quant Resources — Entry Filters]],
  [[Overfitting]]