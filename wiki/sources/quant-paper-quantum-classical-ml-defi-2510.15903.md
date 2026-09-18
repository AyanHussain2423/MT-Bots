---
title: Quant Paper — Quantum Classical ML DeFi 2510.15903
type: source
tags: [quant, machine-learning, quantum, defi, backtesting, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/quantum-classical-ml-defi-2510.15903.pdf
  - https://arxiv.org/abs/2510.15903
---

# Quantum and Classical Machine Learning in Decentralized Finance: Comparative Evidence from Multi-Asset Backtesting of Automated Market Makers

Chi-Sheng Chen, Aidan Hung-Wen Tsai (Omnis Labs), arXiv:2510.15903v1
[q-fin.ST], Sep 2025. 14 pages. Downloaded + text-extracted 2026-09-18.

## What it is

An empirical comparison of **quantum ML (QML) vs classical ML (CML)** for
Automated Market Maker (AMM) / DeFi trading strategies, backtested across 10
models and multiple crypto assets.

## Key content

- **10 models compared**: classical (Random Forest, Gradient Boosting,
  Logistic Regression), pure quantum (VQE Classifier, QNN, QSVM), hybrid
  quantum-classical (QASA Hybrid, QASA Sequence, QuantumRWKV), and
  transformers.
- **Results**: hybrid quantum models 11.2% average return / 1.42 Sharpe;
  classical ML 9.8% / 1.47 Sharpe; **QASA Sequence hybrid best**: 13.99%
  return, 1.76 Sharpe.
- Classical models had the *higher* Sharpe; hybrids the higher return — no
  clear quantum advantage, which is the honest takeaway.

## What it gives our build

- **Reality check for layer 4**: quantum ML is not a practical edge for our
  gold bots — the paper's own data shows classical ML matches or beats it on
  risk-adjusted terms. We do not need quantum anything.
- The **backtest methodology** (multi-asset, 10-model comparison) is a
  template for how to evaluate ML entry-filter candidates honestly in
  [[Quant Resources — ML Regression]].
- The classical models (RF, GBM, logistic) are the realistic candidates for
  our entry filters — consistent with the XGBoost-style SR mapping filter in
  [[Quant Resources — Entry Filters]].

## Terminology

- **QML / CML** — quantum vs classical machine learning.
- **AMM (Automated Market Maker)** — DeFi exchange mechanism (e.g. Uniswap);
  the paper's trading environment.
- **Sharpe ratio** — return per unit of risk; the paper's risk-adjusted
  comparison metric.
- **VQE / QNN / QSVM** — variational quantum eigensolver, quantum neural
  network, quantum support vector machine (quantum model families).

## Related

- [[Overfitting]], [[Quant Math Build Plan]],
  [[Quant Resources — ML Regression]], [[Quant Resources — Entry Filters]]