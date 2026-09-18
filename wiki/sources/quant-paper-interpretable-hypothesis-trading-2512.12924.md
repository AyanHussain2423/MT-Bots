---
title: Quant Paper — Interpretable Hypothesis Trading 2512.12924
type: source
tags: [quant, walk-forward, backtesting, overfitting, machine-learning, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/interpretable-hypothesis-trading-2512.12924.pdf
  - https://arxiv.org/abs/2512.12924
---

# Interpretable Hypothesis-Driven Trading: A Rigorous Walk-Forward Validation Framework for Market Microstructure Signals

Gagan Deep, Akash Deep, William Lamptey (Texas Tech), arXiv:2512.12924v1
[q-fin.TR], Dec 2025. 35 pages. Downloaded + text-extracted 2026-09-18.

## What it is

A **walk-forward validation framework** for algorithmic trading designed to
mitigate overfitting and lookahead bias: interpretable hypothesis-driven
signals + reinforcement learning + strict out-of-sample testing, with
complete mathematical specifications and open-source implementation.

## Key content

- **Four methodological innovations**: strict information-set discipline;
  rolling-window validation across **34 independent test periods**; complete
  interpretability via natural-language hypothesis explanations; realistic
  transaction costs and position constraints.
- **Honest results**: 5 microstructure patterns × 100 US equities (2015–2024)
  → modest returns (0.55% annualized, Sharpe 0.33), exceptional downside
  protection (max drawdown −2.76%), market-neutral (β = 0.058), and
  **statistically insignificant aggregate results (p-value 0.34)** — reported
  deliberately as a reproducible, honest protocol.
- **Regime dependence**: positive in high-volatility periods (+0.60%
  quarterly, 2020–2024), negative in stable markets (−0.16%, 2015–2019).
- **Key empirical finding**: daily OHLCV-based microstructure signals need
  elevated information arrival and trading activity to work.
- Extends naturally to LLM-based hypothesis generators.

## What it gives our build

- **Layer 3 template**: the 34-period rolling validation + information-set
  discipline is the strictest published walk-forward protocol we have —
  directly comparable to the double-OOS protocol in
  [[Quant Paper — Double-OOS Walk-Forward 2602.10785]].
- **The honesty standard**: reporting insignificant results (p = 0.34) is the
  anti-[[Overfitting]] discipline — our walk-forward layer must be willing to
  conclude "no edge" (exactly what the Kelly gate in [[Layer 1 Sizing Design]] does).
- **Regime dependence finding** matches our own: gold's edge is hour-window
  dependent ([[Hour Window Analysis 2026-09-12]]); signals that work in high
  vol may not work in low vol.
- The hypothesis-driven framing (state a hypothesis, test it OOS) is the
  right way to evaluate our entry-filter candidates in layer 4.

## Terminology

- **Walk-forward validation** — rolling train/test evaluation; see
  [[Walk-Forward Analysis]].
- **Lookahead bias** — using information unavailable at decision time; the
  framework's information-set discipline prevents it.
- **Beta (β)** — market exposure; β ≈ 0.058 = market-neutral.
- **p-value** — probability of seeing results this extreme under the null
  hypothesis; p = 0.34 = no statistically significant edge.

## Related

- [[Walk-Forward Analysis]], [[Overfitting]], [[Quant Math Build Plan]],
  [[Quant Paper — Double-OOS Walk-Forward 2602.10785]],
  [[Quant Resources — Walk-Forward Framework]]