---
title: Quant Resources — ML Regression
type: source
tags: [quant, machine-learning, regression, forecasting, sources]
date: 2026-09-18
sources:
  - https://github.com/Sahiltheram/ST-AI-Trading
  - https://github.com/gkeiel/market_forecaster
  - https://huggingface.co/jc-builds/stockprediction-ai
  - https://github.com/JonusNattapong/AI-XAUUSD-Trading
  - https://arxiv.org/abs/2104.04041
  - https://arxiv.org/abs/2510.15903
  - https://arxiv.org/abs/2205.00605
  - https://www.cambridge.org/core/books/deep-learning-in-quantitative-trading/
---

# Quant Resources — ML Regression

User-curated catalog, **2nd verified pass (2026-09-18)** — ML forecasting
models (the "predict the next bar" family). Terminology anchored in
[[Overfitting]].

> [!warning] Verification notes (2nd pass)
> - ST-AI-Trading now points to the **Sahiltheram** repo (was
>   chinmaygithub); market_forecaster now points to the **gkeiel** repo
>   (was robertmartin8).
> - Confirmed on arXiv: **2104.04041** (CLVSA — already ingested),
>   **2510.15903** (Quantum and Classical ML in DeFi), **2205.00605**
>   (Cluster-based Regression using Variational Inference).
> - Deep Learning in Quantitative Trading moved here from the quant-math
>   topic per the curated catalog.

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [ST-AI-Trading](https://github.com/Sahiltheram/ST-AI-Trading) | GitHub | LSTM + sentiment + technicals — multi-signal forecasting |
| 2 | [market_forecaster](https://github.com/gkeiel/market_forecaster) | GitHub | LSTM price forecasting with walk-forward evaluation |
| 3 | [stockprediction-ai](https://huggingface.co/jc-builds/stockprediction-ai) | HuggingFace | LightGBM regime-based stock prediction |
| 4 | [AI-XAUUSD-Trading](https://github.com/JonusNattapong/AI-XAUUSD-Trading) | GitHub | **Gold-specific** ML trading — closest to our XAUUSD bots |
| 5 | [CLVSA (LSTM trend)](https://arxiv.org/abs/2104.04041) | Paper | **Ingested**: [[Quant Paper — CLVSA 2104.04041]] — LSTM trend classification |
| 6 | [Quantum and Classical ML in DeFi](https://arxiv.org/abs/2510.15903) | Paper | Quantum vs classical ML for crypto/DeFi forecasting |
| 7 | [Cluster-based Regression using Variational Inference](https://arxiv.org/abs/2205.00605) | Paper | Clustered regression with variational inference — regime-aware forecasting |
| 8 | [Deep Learning in Quantitative Trading](https://www.cambridge.org/core/books/deep-learning-in-quantitative-trading/) | Book (Cambridge) | DL methods for quant trading |

## What to extract (for our bots)

- **AI-XAUUSD-Trading** (#4) — gold-specific ML pipeline; the most
  directly transferable repo for our XAUUSD bots.
- **CLVSA** (ingested) — LSTM trend classifier; candidate for the
  entry-filter layer (after walk-forward validation).
- **Cluster-based regression** (#7) — regime-aware forecasting: clusters
  ≈ market regimes, which is exactly the regime-gating idea from
  [[Quant Resources — Entry Filters]].

## Related

- [[Overfitting]], [[Quant Math Build Plan]],
  [[Quant Paper — CLVSA 2104.04041]], [[Quant Resources — Entry Filters]]