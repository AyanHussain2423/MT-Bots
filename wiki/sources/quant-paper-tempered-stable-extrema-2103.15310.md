---
title: Quant Paper — Tempered Stable Extrema 2103.15310
type: source
tags: [quant, monte-carlo, drawdown, levy, fat-tails, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/tempered-stable-extrema-2103.15310.pdf
  - https://arxiv.org/abs/2103.15310
---

# Monte Carlo Algorithm for the Extrema of Tempered Stable Processes

Jorge Ignacio González Cázares, Aleksandar Mijatović, arXiv:2103.15310v2
[q-fin.MF], v2 Dec 2022. 31 pages. Published: **Advances in Applied
Probability (2023)**, DOI 10.1017/apr.2023.1. Downloaded + text-extracted
2026-09-18.

> [!warning] ID correction
> The catalog originally listed this as 2103.15265 (xxx.itp.ac.cn mirror).
> Verified: the correct ID is **2103.15310**.

## What it is

A novel Monte Carlo algorithm (**TSB-Alg**, tempered stick-breaking) for the
vector (supremum, time of supremum, position at time T) of an exponentially
tempered Lévy process — the engine for drawdown risk measures under the
**CGMY / tempered stable** model calibrated to real-world data.

## Key content

- **TSB-Alg**: based on simulating the increments of the process *without*
  tempering; converges geometrically fast for discontinuous and locally
  Lipschitz functions of the vector.
- **MLMC estimator**: optimal computational complexity (ε⁻² for MSE ≤ ε²)
  with a central limit theorem → **confidence intervals** for barrier option
  prices and drawdown-based risk measures.
- **CGMY model**: tempered stable (CGMY) calibrated/estimated on real-world
  data — the fat-tailed, asymmetric jump model used for the numerical work.
- **Rule-of-thumb guidelines**: non-asymptotic and asymptotic comparisons
  with existing approximations → which method to use for which parameters.
- Companion to [[Quant Paper — Drawdown Lévy 2011.06618]] (same authors,
  same stick-breaking family).

## What it gives our build

- **Layer 2 tail-aware drawdown, part 2**: together with the Lévy drawdown
  paper, this gives us the confidence-interval machinery for drawdown risk
  under fat tails — the honest answer to "how bad can gold's drawdown get?"
- **CGMY calibration** is the concrete model family to fit to gold's M1/M15
  returns from the 21-month CSV if we want parametric (vs resampled) drawdown
  estimates.
- The **rule-of-thumb guidance** tells us when the simpler Gaussian MC
  ([[Quant Paper — Drawdown Beyond Brownian 2608.00127]]) is good enough vs
  when we need the jump-aware machinery.

## Terminology

- **Tempered stable process** — Lévy process with heavy-tailed jumps that are
  "tempered" (exponentially damped) so exponential moments exist.
- **CGMY** — the Carr–Geman–Madan–Yor tempered stable model family.
- **Supremum** — the running maximum of the process; drawdown is measured
  against it.
- **Multilevel Monte Carlo (MLMC)** — variance-reduction combining coarse and
  fine simulations; see [[Quant Paper — Drawdown Lévy 2011.06618]].

## Related

- [[Monte Carlo Simulation]], [[Quant Math Build Plan]],
  [[Quant Paper — Drawdown Lévy 2011.06618]],
  [[Quant Paper — Drawdown Beyond Brownian 2608.00127]],
  [[Quant Resources — Monte Carlo Drawdown]]