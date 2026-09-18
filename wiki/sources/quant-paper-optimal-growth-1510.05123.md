---
title: Quant Paper — Optimal Growth 1510.05123
type: source
tags: [quant, kelly, position-sizing, growth-optimal, ergodicity, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/optimal-growth-carrying-capacity-1510.05123.pdf
  - https://arxiv.org/abs/1510.05123
---

# Optimal Growth Trajectories with Finite Carrying Capacity

F. Caravelli, L. Sindoni, F. Caccioli, C. Ududec (Invenia Labs / UCL / LSE),
arXiv:1510.05123. 10 pages. Downloaded + text-extracted 2026-09-18.

## What it is

Generalizes the [[Kelly Criterion]] from geometric Brownian motion to
**growth with finite carrying capacity** — i.e., growth that saturates
because of limits (account caps, broker constraints, market capacity).
Solves the optimal control problem for power-law and logarithmic carrying
capacity functions and verifies with numerical simulation.

## Key content

- **The non-ergodicity argument**: for GBM, `E[dK/K] = µρ dt` but
  `E[d ln K] = ρ(µ − σ²/2) dt` — ensemble average ≠ time average. Maximizing
  expected log-return (Kelly) is the correct long-run objective, not
  maximizing average return. This is the mathematical case for log-utility
  sizing.
- **Kelly as constant leverage**: for GBM the optimal strategy is investing a
  **constant fraction** of capital each step — the classic Kelly result.
- **Carrying capacity changes the answer**: when growth saturates (finite
  capacity), the optimal investment fraction is no longer constant — it
  follows a trajectory that declines as capacity is approached. Relevant to
  a small account ($100) where broker minimums and margin constraints act as
  capacity limits.

## What it gives our build

- The **theoretical floor for layer 1**: why we maximize log-growth
  (non-ergodicity), and why fractional Kelly is the practical answer when
  capacity/constraints bind.
- A **framework for account-limit-aware sizing**: our $100 demo account with
  fixed $5 SLs is capacity-constrained; the paper's optimal-trajectory idea
  suggests sizing should shrink as constraints bind, not stay constant.

## Terminology

- **Carrying capacity** — the level at which growth saturates (account/broker
  limits in our case).
- **Ergodicity** — when time average equals ensemble average; GBM is
  non-ergodic, which is why log-utility (Kelly) beats mean-return
  maximization.
- **Leverage** — fraction of capital invested in the risky asset (ρ in the
  paper).
- **Geometric Brownian Motion (GBM)** — the standard continuous-time model
  `dK = K(µ dt + σ dW)`.
- **Itô's formula** — the calculus rule used to derive the log-growth
  expression.

## Related

- [[Kelly Criterion]], [[Quant Math Build Plan]],
  [[Quant Resources — Kelly & Volatility Sizing]]