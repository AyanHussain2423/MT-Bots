---
title: Quant Resources — Quant Math Foundation
type: source
tags: [quant, math, books, courses, sources]
date: 2026-09-18
sources:
  - https://www.ams.org/books/gsm/214/
  - https://link.springer.com/book/10.1007/978-3-031-97239-3
  - https://www.oreilly.com/library/view/python-for-finance/9781492024323/
  - https://github.com/stefan-jansen/machine-learning-for-trading
  - https://archive.org/details/appliedquantitat0000unse
  - https://ocw.mit.edu/courses/15-450-analytics-of-finance-fall-2016/
  - https://web.stanford.edu/class/psych209/Readings/SuttonBartoIPRLBook2ndEd.pdf
---

# Quant Resources — Quant Math Foundation

User-curated catalog, **2nd verified pass (2026-09-18)** — the math
foundation for all four layers. Terminology anchored in
[[Quant Math Build Plan]].

> [!warning] Verification notes (2nd pass)
> - **Portfolio Theory and Arbitrage** now points to the official AMS page
>   (https://www.ams.org/books/gsm/214/) — replaces the bookstore link.
> - **Signature Methods in Finance is a REAL open-access Springer book**
>   (DOI 10.1007/978-3-031-97239-3) — replaces the earlier "closest match"
>   note (2207.13136).
> - Python for Finance moved here from the Monte Carlo topic per the
>   curated catalog.

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [Portfolio Theory and Arbitrage (Karatzas & Kardaras)](https://www.ams.org/books/gsm/214/) | Book (AMS) | The math of portfolio theory — the theory behind [[Kelly Criterion]] |
| 2 | [Signature Methods in Finance](https://link.springer.com/book/10.1007/978-3-031-97239-3) | Book (Springer, open access) | Signature/rough-path methods — feature engineering for price paths |
| 3 | [Python for Finance (Hilpisch)](https://www.oreilly.com/library/view/python-for-finance/9781492024323/) | Book (O'Reilly) | Python quant toolkit — the implementation reference |
| 4 | [Machine Learning for Trading (Jansen)](https://github.com/stefan-jansen/machine-learning-for-trading) | Book + GitHub | ML-for-trading cookbook with walk-forward examples |
| 5 | [Applied Quantitative Finance](https://archive.org/details/appliedquantitat0000unse) | Book (archive.org) | Applied quant methods (lending-restricted — borrow only) |
| 6 | [MIT OCW 15.450 Analytics of Finance](https://ocw.mit.edu/courses/15-450-analytics-of-finance-fall-2016/) | Course | **Ingested**: [[Quant Course — MIT 15.450 Analytics of Finance]] — stochastic calculus, MLE/GMM, GARCH |
| 7 | [Reinforcement Learning (Sutton & Barto)](https://web.stanford.edu/class/psych209/Readings/SuttonBartoIPRLBook2ndEd.pdf) | Book (PDF) | **Ingested**: [[Quant Book — Sutton & Barto RL]] — the RL foundation |

## What to extract (for our bots)

- **MIT 15.450** (ingested, 33 PDFs) — the working math: MLE/GMM
  parameter estimation, GARCH volatility models, bootstrap inference.
  These are the exact tools for the sizing and walk-forward layers.
- **Signature methods** — candidate feature set for the entry-filter layer
  (path signatures of gold M1/M15 windows).
- **Sutton & Barto** (ingested) — the RL framework if we ever graduate the
  bots from rules to learned policies.

## Related

- [[Quant Math Build Plan]], [[Quant Course — MIT 15.450 Analytics of Finance]],
  [[Quant Book — Sutton & Barto RL]], [[Kelly Criterion]],
  [[Monte Carlo Simulation]]