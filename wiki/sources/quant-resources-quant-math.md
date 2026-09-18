---
title: Quant Resources — Quant Math Books & Papers
type: source
tags: [quant, books, math, finance, sources]
date: 2026-09-18
sources:
  - https://archive.org/details/appliedquantitat0000unse
  - https://archive.org/details/mathematicalfina0000unse
  - https://archive.org/details/advancedfinancia0000unse
  - https://ocw.mit.edu/courses/15-450-analytics-of-finance-fall-2010/
  - https://arxiv.org/abs/1706.05523
  - https://www.ocw.iti.hr/course/view.php?id=23
  - https://arxiv.org/abs/2008.00214
  - https://web.stanford.edu/class/psych209/Readings/SuttonBartoIPRLBook2ndEd.pdf
  - https://www.packtpub.com/product/python-for-finance-cookbook/9781789618518
  - https://www.cambridge.org/core/books/deep-learning-in-quantitative-trading/2B4C8F5A0B6E5F6A7B8C9D0E1F2A3B4C
---

# Quant Resources — Foundational Quant Math (Books & Papers)

User-curated catalog (2026-09-18) — the theory layer. These are the
reference texts behind the math used in [[Quant Math Build Plan]]; they
define the terminology the wiki standardizes on.

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [Applied Quantitative Finance](https://archive.org/details/appliedquantitat0000unse) | Book (archive.org) | Applied quant methods — the practical math |
| 2 | [Mathematical Financial Economics](https://archive.org/details/mathematicalfina0000unse) | Book (archive.org) | Formal financial math foundations |
| 3 | [Advanced Financial Mathematics](https://archive.org/details/advancedfinancia0000unse) | Book (archive.org) | Advanced math (stochastic calculus, pricing) |
| 4 | [MIT OCW: Analytics of Finance (15-450)](https://ocw.mit.edu/courses/15-450-analytics-of-finance-fall-2010/) | Course | Free MIT course — analytics applied to finance |
| 5 | [Portfolio Theory and Arbitrage: A Course in Mathematical Finance](https://arxiv.org/abs/1706.05523) | Paper/Book | Portfolio theory + arbitrage math |
| 6 | [Lecture Notes & Slides (ocw.iti.hr)](https://www.ocw.iti.hr/course/view.php?id=23) | Course | Quant lecture notes |
| 7 | [Signature Methods in Finance](https://arxiv.org/abs/2008.00214) | Book | Signature methods — modern path-based finance math |
| 8 | [Foundations of Reinforcement Learning (Sutton & Barto)](https://web.stanford.edu/class/psych209/Readings/SuttonBartoIPRLBook2ndEd.pdf) | Book (PDF) | RL foundations — for the ML/entry-filter layer |
| 9 | [Python for Finance Cookbook](https://www.packtpub.com/product/python-for-finance-cookbook/9781789618518) | Book | Implementation recipes (the code patterns we adapt) |
| 10 | [Deep Learning in Quantitative Trading](https://www.cambridge.org/core/books/deep-learning-in-quantitative-trading/2B4C8F5A0B6E5F6A7B8C9D0E1F2A3B4C) | Book | DL applied to quant trading |

## What to extract (for our bots)

- **Terminology anchor**: these texts define the standard math vocabulary
  (expectancy, Sharpe, drawdown, volatility, Kelly) — the wiki's concept
  pages mirror their definitions so we stay "on the same terms".
- **Python for Finance Cookbook + Hilpisch** (see
  [[Quant Resources — Monte Carlo Drawdown]]) are the implementation
  references for the build scripts.

## Related

- [[Quant Math Build Plan]], [[Kelly Criterion]], [[Monte Carlo Simulation]],
  [[Walk-Forward Analysis]]