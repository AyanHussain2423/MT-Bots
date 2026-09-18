---
title: Quant Resources — ML Regression & Training
type: source
tags: [quant, machine-learning, regression, training, sources]
date: 2026-09-18
sources:
  - https://github.com/chinmaygithub/ST-AI-Trading
  - https://github.com/robertmartin8/market_forecaster
  - https://github.com/stefan-jansen/machine-learning-for-trading
  - https://github.com/huseinzol05/Stock-Prediction-Models
  - https://github.com/huseinzol05/Forex-LSTM-Models
  - https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3015609
  - https://archive.org/details/machinelearningf0000jans
  - https://github.com/dingran/quant-awesome-machine-learning-trading
  - https://github.com/georgezouq/awesome-ai-in-finance
  - https://arxiv.org/abs/2104.04041
---

# Quant Resources — Machine Learning Regression & Training

User-curated catalog (2026-09-18) for the ML side of **layer 4** (entry
filters / prediction). Caution: ML is the most overfit-prone layer — every
model must pass [[Walk-Forward Analysis]] before it touches a live bot.

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [ST-AI-Trading](https://github.com/chinmaygithub/ST-AI-Trading) | GitHub | Stock/time-series AI trading pipeline |
| 2 | [market_forecaster](https://github.com/robertmartin8/market_forecaster) | GitHub | Forecasting library (Robert Martin) |
| 3 | [machine-learning-for-trading (Stefan Jansen)](https://github.com/stefan-jansen/machine-learning-for-trading) | GitHub | The canonical ML-for-trading repo (2nd ed. companion) |
| 4 | [Stock-Prediction-Models (huseinzol05)](https://github.com/huseinzol05/Stock-Prediction-Models) | GitHub | LightGBM + many model families for prediction |
| 5 | [Forex-LSTM-Models (huseinzol05)](https://github.com/huseinzol05/Forex-LSTM-Models) | GitHub | LSTM models on forex — closest to our gold M1 data |
| 6 | [Machine Learning for Trading (Ritter, SSRN)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3015609) | Paper | Survey of ML for trading |
| 7 | [Machine Learning for Algorithmic Trading (2nd ed., Jansen)](https://archive.org/details/machinelearningf0000jans) | Book (archive.org) | Full textbook — the training methodology reference |
| 8 | [Awesome-Quant-Machine-Learning-Trading](https://github.com/dingran/quant-awesome-machine-learning-trading) | List | Curated ML-trading resource list |
| 9 | [Awesome AI in Finance](https://github.com/georgezouq/awesome-ai-in-finance) | List | Curated AI-finance resource list |
| 10 | [CLVSA: Convolutional LSTM variational seq2seq for trend prediction](https://arxiv.org/abs/2104.04041) | Paper | LSTM trend prediction — the catalog's "quantum ML" link was actually this |

## What to extract (for our bots)

- **Jansen's methodology** (repo + book): feature engineering, walk-forward
  training, backtest hygiene — the discipline that prevents the VP-style
  overfit (see [[Overfitting]]).
- **Forex-LSTM-Models** — candidate for a gold M1 regime/predictor model;
  must be validated with [[Walk-Forward Analysis]] and [[Monte Carlo Simulation]] on OOS trades before any live use.
- **SR_Mapping_NN** (see [[Quant Resources — Entry Filters]]) is the
  XGBoost-style entry filter the user flagged — ML layer 4 candidate.

## Related

- [[Quant Math Build Plan]], [[Overfitting]], [[Walk-Forward Analysis]],
  [[Quant Resources — Entry Filters]]