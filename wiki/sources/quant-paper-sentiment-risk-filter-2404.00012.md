---
title: Quant Paper — Sentiment Risk Filter 2404.00012
type: source
tags: [quant, sentiment, risk-filter, regime, volatility, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/sentiment-risk-filter-2404.00012.pdf
  - https://arxiv.org/abs/2404.00012
---

# Stress Index Strategy Enhanced with Financial News Sentiment Analysis for the Equity Markets

Baptiste Lefort, Eric Benhamou, Jean-Jacques Ohana, David Saltiel, Beatrice
Guez, Thomas Jacquot (Ai For Alpha), arXiv:2404.00012v1 [q-fin.ST], Mar 2024.
41 pages. Downloaded + text-extracted 2026-09-18.

## What it is

A **risk-on/risk-off regime strategy**: a financial stress indicator built
from volatility and credit spreads, **enhanced by GPT-4 sentiment** read from
Bloomberg daily market summaries. The combination improves Sharpe ratio and
cuts maximum drawdown, consistently across NASDAQ, S&P 500 and six major
equity markets.

## Key content

- **Stress index alone works; stress + sentiment works better** — combining
  a quantitative regime signal with a language-model sentiment signal beats
  either alone. The paper's central, reproducible finding.
- **Sentiment is a regime filter, not a signal**: news sentiment gates
  risk-on/risk-off exposure rather than predicting price direction — exactly
  the "filter" role layer 4 of [[Quant Math Build Plan]] needs.
- **LLM sentiment is now practical**: GPT-4-class models reading daily
  market summaries produce usable sentiment (vs. older FinBERT-era results
  that were "less than compelling" out-of-sample).
- **Generalization evidence**: the improvement holds across multiple markets
  and out-of-sample backtests — the discipline our own walk-forward layer
  demands.

## What it gives our build

- A **candidate regime gate for gold**: a stress index (gold vol + spread
  proxies) combined with news sentiment could gate the bot's risk-on/risk-off
  exposure — layer 4 material, after sizing/drawdown/walk-forward are solid.
- The **"combine two weak signals"** pattern: our gold bot already has
  channel + EMA50; adding a regime filter is the same architecture.
- Caveat for the wiki: sentiment data (Bloomberg summaries) is not free —
  a practical implementation would need a news feed; note this cost in the
  build plan.

## Terminology

- **Risk-on / risk-off** — regime where investors seek (risk-on) or flee
  (risk-off) risky assets; drives exposure sizing.
- **Stress index** — composite of volatility and credit-spread measures.
- **Sentiment** — machine-read tone of financial news (here: GPT-4).
- **Sharpe ratio** — return per unit of volatility.
- **Maximum drawdown** — worst peak-to-trough equity decline.

## Related

- [[Volatility Targeting]], [[Quant Math Build Plan]],
  [[Quant Resources — Entry Filters]], [[Quant Resources — Risk Management]]