---
title: Quant Resources — Entry Filters
type: source
tags: [quant, entry-filters, machine-learning, regime, sources]
date: 2026-09-18
sources:
  - https://github.com/Mrizalfahlepi/SR_Mapping_NN
  - https://github.com/Thordersonjg/freqtrade-regime-filter
  - https://github.com/jatin711-debug/Python-HFT-Engine
  - https://huggingface.co/ash001/nse-bot-history
  - https://skillsmp.com/skills/3182-regime-aware-entry-engine
---

# Quant Resources — Entry Filters

User-curated catalog, **2nd verified pass (2026-09-18)** — layer 4 of the
build plan: gating entries (regime, support/resistance, sentiment) — the
LAST layer, only after sizing/drawdown/walk-forward are solid (see
[[Quant Math Build Plan]]).

> [!warning] Verification notes (2nd pass)
> - SR_Mapping_NN now points to the **Mrizalfahlepi** repo (was
>   DonnerLab/SR-mapping).
> - The sentiment risk-filter paper is ingested per-document:
>   [[Quant Paper — Sentiment Risk Filter 2404.00012]].
> - IBKR item is a site search, not a direct link.

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [SR_Mapping_NN](https://github.com/Mrizalfahlepi/SR_Mapping_NN) | GitHub | XGBoost entry filter for MT5 — support/resistance mapping (the XGBoost-style filter idea) |
| 2 | [freqtrade-regime-filter](https://github.com/Thordersonjg/freqtrade-regime-filter) | GitHub | Regime-gated entries (freqtrade) — gate entries by market phase |
| 3 | [Python-HFT-Engine](https://github.com/jatin711-debug/Python-HFT-Engine) | GitHub | RSI + trend filters — execution-side filter reference |
| 4 | [livermore/signals.py](https://huggingface.co/ash001/nse-bot-history) | HuggingFace | Livermore state machine filters (trend/pullback states) |
| 5 | [Regime-aware entry engine](https://skillsmp.com/skills/3182-regime-aware-entry-engine) | SkillsMP | 9-column execution table — regime-aware entry logic |
| 6 | [Interactive Brokers backtest hypotheses](https://www.interactivebrokers.com) | IBKR | Trend-filter backtest hypotheses (site search) |

## What to extract (for our bots)

- **Two-filter framework**: trend filter (we already have EMA50 + channel)
  + entry filter (the candidate). The entry filter must be tested with
  [[Walk-Forward Analysis]] — the VP sweep proved filters can zero out all
  trades.
- **SR mapping** — candidate: only take breakouts that clear a mapped
  support/resistance level, not just the Donchian channel.
- **Regime gating** — freqtrade-regime-filter / Livermore state machine
  could replace the all-day window decision (see
  [[Hour Window Analysis 2026-09-12]]).

## Related

- [[Quant Math Build Plan]], [[Overfitting]], [[Walk-Forward Analysis]],
  [[Liquidity Sweep]], [[AMN Model]],
  [[Quant Paper — Sentiment Risk Filter 2404.00012]]