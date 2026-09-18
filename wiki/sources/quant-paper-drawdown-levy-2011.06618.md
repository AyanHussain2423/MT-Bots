---
title: Quant Paper — Drawdown Lévy 2011.06618
type: source
tags: [quant, monte-carlo, drawdown, levy, fat-tails, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/drawdown-levy-2011.06618.pdf
  - https://arxiv.org/abs/2011.06618
---

# Simulation of the Drawdown and its Duration in Lévy Models via Stick-Breaking Gaussian Approximation

Jorge González Cázares, Aleksandar Mijatović, arXiv:2011.06618v2 [math.PR],
v2 Mar 2021. 45 pages. Published: **Finance and Stochastics 26, 671–732
(2022)**, DOI 10.1007/s00780-022-00486-7. Downloaded + text-extracted
2026-09-18.

> [!warning] ID correction
> The catalog originally listed this as 2103.14744 (xxx.itp.ac.cn mirror).
> Verified: the correct ID is **2011.06618**. Code: SBG.jl
> (github.com/jorgeignaciogc/SBG.jl).

## What it is

A computational method for **expected functionals of the drawdown and its
duration in exponential Lévy models** — the fat-tailed generalization of
drawdown simulation. Core: a novel simulation algorithm for the joint law of
(state, supremum, time of supremum) of the Gaussian approximation of a
general Lévy process, via the **SBG coupling** (stick-breaking Gaussian).

## Key content

- **Why Lévy**: diffusion models can't produce the large, heavy-tailed sudden
  moves seen in real markets (gold's 09-16 crash is exactly this — see
  [[Layer 1 Sizing Design]]). Lévy processes model them naturally.
- **Drawdown quantities**: drawdown = decline from historical peak; duration
  = time since the peak. Neither distribution is analytically tractable for a
  general Lévy process → simulation is the only route.
- **SBG coupling**: bounds on Wasserstein distances between a Lévy process
  and its Gaussian approximation → bias bounds for locally Lipschitz and
  discontinuous payoffs.
- **Complexity**: MC + multilevel MC estimators; up to two orders of
  magnitude cheaper when jump activity is high.
- **Implementation**: dedicated GitHub repo (SBG.jl) — numerical performance
  matches the theoretical bounds.

## What it gives our build

- **Layer 2 tail-aware drawdown**: the honest drawdown distribution for gold
  must allow fat tails — this paper (with its companion
  [[Quant Paper — Tempered Stable Extrema 2103.15310]]) is the math for it.
- **SBG.jl is Julia** — not our Python stack, but the algorithm is the
  reference; our Python MC resampler can implement the stick-breaking idea or
  use the paper's bias bounds to justify simpler approximations.
- **The joint law (state, supremum, time)** is exactly what we need for
  "how deep AND how long" drawdown questions on the bots' P&L.

## Terminology

- **Lévy process** — stochastic process with stationary independent
  increments; includes jumps (fat tails).
- **Drawdown / duration** — decline from peak / time since peak; see
  [[Monte Carlo Simulation]].
- **Multilevel Monte Carlo (MLMC)** — variance-reduction technique combining
  cheap coarse + expensive fine simulations.
- **Wasserstein distance** — metric between probability distributions; used
  to bound the approximation error.

## Related

- [[Monte Carlo Simulation]], [[Quant Math Build Plan]],
  [[Quant Paper — Tempered Stable Extrema 2103.15310]],
  [[Quant Resources — Monte Carlo Drawdown]]