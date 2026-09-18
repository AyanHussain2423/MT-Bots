---
title: Quant Resources — Walk-Forward Framework
type: source
tags: [quant, walk-forward, backtesting, overfitting, sources]
date: 2026-09-18
sources:
  - https://github.com/TonyMa1/walk-forward-backtester
  - https://github.com/Avan22/walkforward-momentum
  - https://github.com/CodingEye/Advanced_AI_ML_Trading_Framework
  - https://ar5iv.labs.arxiv.org/html/2512.12924v1
  - https://github.com/tmr-crypto/wf_optim_crypto_analysis
  - https://github.com/OutOfSampleLab/oos-lab
---

# Quant Resources — Walk-Forward Framework

User-curated catalog, **2nd verified pass (2026-09-18)** — layer 3 of the
build plan: honest out-of-sample testing so no parameter choice ever sees
the answer again (the VP sweep lesson, see [[Overfitting]]). Terminology
anchored in [[Walk-Forward Analysis]].

> [!warning] Verification notes (2nd pass)
> - Confirmed on arXiv: **2512.12924** (Interpretable Hypothesis-Driven
>   Trading).
> - **Unconfirmed**: Quantum-Assisted Optimal Rebalancing (arxiv 2603.xxx —
>   search), "A novel approach to trading strategy parameter optimization"
>   (ar5iv search — **we already hold this paper**: it is
>   [[Quant Paper — Double-OOS Walk-Forward 2602.10785]], arxiv version of
>   SSRN 3135062).
> - oos-lab moved to the **OutOfSampleLab** org (was endlesscheng).

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [walk-forward-backtester](https://github.com/TonyMa1/walk-forward-backtester) | GitHub | WFO with Bayesian Optimization — parameter search + walk-forward |
| 2 | [walkforward-momentum](https://github.com/Avan22/walkforward-momentum) | GitHub | Production-style WFO MVP (momentum strategy) |
| 3 | [Advanced_AI_ML_Trading_Framework](https://github.com/CodingEye/Advanced_AI_ML_Trading_Framework) | GitHub | Full ML trading framework with walk-forward validation |
| 4 | [A novel approach to trading strategy parameter optimization](https://ar5iv.labs.arxiv.org/html/) | Paper | The double-OOS technique — **ingested**: [[Quant Paper — Double-OOS Walk-Forward 2602.10785]] |
| 5 | [Interpretable Hypothesis-Driven Trading](https://ar5iv.labs.arxiv.org/html/2512.12924v1) | Paper | Walk-forward validation with interpretable hypotheses |
| 6 | [Quantum-Assisted Optimal Rebalancing](https://arxiv.org/abs/2603.xxx) | Paper | Walk-forward QUBO rebalancing (ID unconfirmed — search) |
| 7 | [wf_optim_crypto_analysis](https://github.com/tmr-crypto/wf_optim_crypto_analysis) | GitHub | **Companion repo to our double-OOS paper** — all calculations |
| 8 | [oos-lab](https://github.com/OutOfSampleLab/oos-lab) | GitHub | Walk-forward splitters / out-of-sample testing lab |

## What to extract (for our bots)

- **WFO on the 21-month gold M1 CSV**: rolling train/test windows over the
  SL/TP/filter configs — the honest replacement for the VP-style full-data
  sweep. OOS expectancy per trade is the go/no-go number.
- **Double-OOS** (#4, ingested) — the strictest protocol; use it for any
  parameter we intend to ship. The companion repo (#7) has the full
  implementation to adapt.
- **Bayesian-optimized WFO** (#1) — candidate for the parameter search
  itself, replacing grid sweeps.

## Related

- [[Walk-Forward Analysis]], [[Overfitting]], [[Quant Math Build Plan]],
  [[Quant Paper — Double-OOS Walk-Forward 2602.10785]],
  [[2026-09-17 Loss Causes]]