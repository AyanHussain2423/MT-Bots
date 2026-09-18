---
title: Quant Resources — Entry Filters
type: source
tags: [quant, entry-filters, machine-learning, regime, sources]
date: 2026-09-18
sources:
  - https://github.com/DonnerLab/SR-mapping
  - https://github.com/jatin711-debug/Python-HFT-Engine
  - https://github.com/mtusman/livermore-state-machine
  - https://www.project-kintoun.com/
  - https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2731722
  - https://www.jstor.org/stable/2328889
  - https://arxiv.org/abs/2404.00012
  - https://www.researchgate.net/publication/334604635_Herangehensweise_zur_quantitativen_Analyse_und_Optimierung_von_Filtern
  - https://www.tradingsystemlab.com/wp-content/uploads/2018/03/Entry-Filters-in-Trading-Systems.pdf
  - https://www.smartmoneyconcepts.com/free-guide
---

# Quant Resources — Entry Filters

User-curated catalog (2026-09-18) for **layer 4 of the build plan**: gating
entries (regime, support/resistance, sentiment) — the LAST layer, only after
sizing/drawdown/walk-forward are solid (see [[Quant Math Build Plan]]).

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [SR_Mapping_NN (DonnerLab/SR-mapping)](https://github.com/DonnerLab/SR-mapping) | GitHub | Support/resistance mapping with neural nets — the XGBoost-style entry filter idea |
| 2 | [Python-HFT-Engine](https://github.com/jatin711-debug/Python-HFT-Engine) | GitHub | HFT engine reference (execution-side filters) |
| 3 | [Livermore State Machine](https://github.com/mtusman/livermore-state-machine) | GitHub | Regime state machine (trend/pullback) — gates entries by market phase |
| 4 | [Project Kintoun](https://www.project-kintoun.com/) | Article | Trading system project — filter design |
| 5 | [Two-filter trading strategies](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2731722) | Paper | The classic two-filter framework (trend + entry filter) |
| 6 | [Filter rules, moving averages, support/resistance](https://www.jstor.org/stable/2328889) | Paper | Academic filter-rule evidence |
| 7 | [Stress index strategy enhanced with financial news sentiment](https://arxiv.org/abs/2404.00012) | Paper | Sentiment + stress-index risk-on/risk-off filter |
| 8 | [Quantitative analysis and optimization of filters](https://www.researchgate.net/publication/334604635_Herangehensweise_zur_quantitativen_Analyse_und_Optimierung_von_Filtern) | Paper | Filter optimization methodology |
| 9 | [Entry Filters in Trading Systems](https://www.tradingsystemlab.com/wp-content/uploads/2018/03/Entry-Filters-in-Trading-Systems.pdf) | PDF | Practical entry-filter design |
| 10 | [SMC Guide](https://www.smartmoneyconcepts.com/free-guide) | PDF | Smart-money concepts — the AMN-style liquidity framework (see [[Liquidity Sweep]]) |

## What to extract (for our bots)

- **Two-filter framework** (paper #5): trend filter (we already have EMA50 +
  channel) + entry filter (the candidate). The entry filter must be tested
  with [[Walk-Forward Analysis]] — the VP sweep proved filters can zero out
  all trades.
- **SR mapping** — candidate: only take breakouts that clear a mapped
  support/resistance level, not just the Donchian channel.
- **Regime gating** — Livermore-style state machine could replace the
  all-day window decision (see [[Hour Window Analysis 2026-09-12]]).

## Related

- [[Quant Math Build Plan]], [[Overfitting]], [[Walk-Forward Analysis]],
  [[Liquidity Sweep]], [[AMN Model]]