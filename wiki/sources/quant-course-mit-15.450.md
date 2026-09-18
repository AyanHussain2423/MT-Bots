---
title: Quant Course — MIT 15.450 Analytics of Finance
type: source
tags: [quant, mit, course, stochastic-calculus, garch, bootstrap, simulation, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/mit-15.450/
  - https://ocw.mit.edu/courses/15-450-analytics-of-finance-fall-2010/
---

# MIT OCW 15.450 — Analytics of Finance (Fall 2010)

Leonid Kogan, MIT Sloan. Full course site downloaded (16.8 MB zip) and
extracted 2026-09-18: **33 PDFs** (10 lectures, 8 recitations, 6 assignments,
4 handouts, 2 review sessions, problem set + solutions, final exam) at
`raw/strategy/quant/mit-15.450/`.

## Lecture map (verified from PDFs)

| Lec | Topic | Build-plan link |
|-----|-------|-----------------|
| 1 | Arbitrage-Free Pricing Models (SPD, factor pricing, risk-neutral) | Theory |
| 2 | Stochastic Calculus & Option Pricing (Itô, Black-Scholes, SDEs) | Theory |
| 3 | **Simulation Methods** (random numbers, variance reduction, quasi-MC) | [[Monte Carlo Simulation]] |
| 4 | Dynamic Portfolio Choice I (expected utility, risk aversion) | [[Kelly Criterion]] |
| 5 | Dynamic Portfolio Choice II (dynamic programming) | [[Kelly Criterion]] |
| 6 | Dynamic Portfolio Choice III (numerical approximations) | [[Kelly Criterion]] |
| 7 | Parameter Estimation (MLE, AR/VAR, model selection, GMM, QMLE) | [[Walk-Forward Analysis]] |
| 8 | Standard Errors and Tests (delta method, GMM SEs, hypothesis tests) | [[Walk-Forward Analysis]] |
| 9 | **Small-Sample Inference and Bootstrap** | [[Monte Carlo Simulation]] |
| 10 | **Volatility Models** (heteroscedasticity, GARCH, MLE/QMLE, multivariate) | [[Volatility Targeting]] |

## What it gives our build

- **Layer 1 (sizing)**: lectures 4–6 give the utility/DP foundation for
  growth-optimal sizing; lecture 10 gives GARCH estimation — the forecast-vol
  input to [[Volatility Targeting]] (same model as the Garch-Method repo).
- **Layer 2 (drawdown)**: lecture 3 (variance reduction, quasi-Monte Carlo)
  and lecture 9 (bootstrap) are the exact tools for resampling trade lists
  into drawdown distributions.
- **Layer 3 (walk-forward)**: lectures 7–8 (MLE, GMM, standard errors,
  hypothesis tests) are the statistical backbone for honest parameter
  selection and significance testing.
- **Terminology anchor**: the course defines the standard quant vocabulary
  (Itô, SDE, risk-neutral, MLE, GMM, QMLE, bootstrap, GARCH) the wiki's
  concept pages mirror.

## Terminology

- **Itô's lemma / SDE** — stochastic calculus rules for continuous-time
  processes.
- **Risk-neutral pricing** — pricing derivatives under the risk-neutral
  measure.
- **MLE / QMLE** — maximum likelihood (quasi-) estimation of model
  parameters.
- **GMM** — generalized method of moments estimation.
- **Bootstrap** — resampling to estimate statistic distributions.
- **GARCH** — volatility model; see [[Volatility Targeting]].

## Related

- [[Monte Carlo Simulation]], [[Volatility Targeting]],
  [[Walk-Forward Analysis]], [[Kelly Criterion]], [[Quant Math Build Plan]],
  [[Quant Resources — Quant Math Books & Papers]]