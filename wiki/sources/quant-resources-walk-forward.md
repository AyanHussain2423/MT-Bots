---
title: Quant Resources — Walk-Forward Framework
type: source
tags: [quant, walk-forward, backtesting, overfitting, sources]
date: 2026-09-18
sources:
  - https://pypi.org/project/pyalloq/
  - https://github.com/satyamdas03/factor-forge
  - https://github.com/AmirRezaFarokhy/Advanced_AI_ML_Trading_Framework
  - https://github.com/KarhouTam/quanteval
  - https://github.com/DaruFinance/quant-research-framework
  - https://github.com/endlesscheng/oos-lab
  - https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3135062
  - https://arxiv.org/abs/2602.10785
  - https://www.researchgate.net/publication/338752453_Walk-Forward_Cross-Validation
  - https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3073795
---

# Quant Resources — Walk-Forward Framework

User-curated catalog (2026-09-18) for **layer 3 of the build plan**: honest
out-of-sample testing so no parameter choice ever sees the answer again
(the VP sweep lesson, see [[Overfitting]]). Terminology anchored in
[[Walk-Forward Analysis]].

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [pyalloq](https://pypi.org/project/pyalloq/) | PyPI | Walk-forward optimization library (train/test rolling windows) |
| 2 | [factor-forge](https://github.com/satyamdas03/factor-forge) | GitHub | Factor research with WFA support |
| 3 | [Advanced_AI_ML_Trading_Framework](https://github.com/AmirRezaFarokhy/Advanced_AI_ML_Trading_Framework) | GitHub | Full ML trading framework with walk-forward validation |
| 4 | [quanteval](https://github.com/KarhouTam/quanteval) | GitHub | Strategy evaluation incl. walk-forward + robustness metrics |
| 5 | [quant-research-framework (DaruFinance)](https://github.com/DaruFinance/quant-research-framework) | GitHub | Backtester with walk-forward + robustness checks |
| 6 | [oos-lab](https://github.com/endlesscheng/oos-lab) | GitHub | Out-of-sample testing lab |
| 7 | [Double out-of-sample + walk-forward parameter optimization](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3135062) | Paper | The double-OOS technique (train → validate → test) |
| 8 | [Double out-of-sample + walk-forward parameter optimization (arxiv version)](https://arxiv.org/abs/2602.10785) | Paper | Formal WFO scheme — the arxiv version of #7 (Mroziewicz & Ślepaczuk) |
| 9 | [Walk-Forward Cross-Validation](https://www.researchgate.net/publication/338752453_Walk-Forward_Cross-Validation) | Paper | WFCV — the rolling train/test procedure |
| 10 | [Walk-Forward Methodology for Meta-Models](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3073795) | Paper | WFA applied to meta-models (fits our ML layer 4) |

## What to extract (for our bots)

- **WFO on the 21-month gold M1 CSV**: rolling train/test windows over the
  SL/TP/filter configs — the honest replacement for the VP-style full-data
  sweep. OOS expectancy per trade is the go/no-go number.
- **Double-OOS** (paper #7) — the strictest protocol; use it for any
  parameter we intend to ship.
- **quanteval / pyalloq** — candidate libraries to wrap our backtest engine
  instead of hand-rolling the framework.

## Related

- [[Walk-Forward Analysis]], [[Overfitting]], [[Quant Math Build Plan]],
  [[2026-09-17 Loss Causes]]