---
title: Quant Paper — Axiomatic Trader 2608.23416
type: source
tags: [quant, position-sizing, kelly, backtest, overfitting, robustness, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/axiomatic-trader-2608.23416.pdf
  - https://arxiv.org/abs/2608.23416
---

# The Axiomatic Trader: Latent Regularity, Information Budgets, and the Canonical Form of a Quantitative Investment System

Jiayu Li, arXiv:2608.23416v2 [cs.LG], Aug/Sep 2026. 97 pages.
Downloaded + text-extracted 2026-09-18.

## What it is

A theory paper that states the "faith" of systematic trading as **five
quantified axioms** and proves they force a **five-stage canonical form** for
any quantitative investment system. The quantities are *declared*, not
estimated — the paper's whole empirical content is five constants.

## Key content

- **The five axioms**: (A1) a decision may use only what was known when it
  was made; (A2) apparent rule changes are state changes (same machinery,
  unobserved state); (A3) the future may replay stretches of the past, not in
  history's proportions; (A4) states persist, dependence dies out; (A5)
  predictability is slight even knowing the state.
- **Five declared constants**: invariance defect ε₀, recurrence bound Λ at
  block scale b, coherence times ℓᵢ, signal ceiling ρ, invariance ratio κ.
- **The forced five-stage canonical form** (each stage *necessary* — omitting
  it does strictly worse under a law the axioms admit):
  - S1 **declared representation** (what the system models)
  - S2 **capacity-bounded shrunk ensemble** (shrink model capacity to the
    information budget)
  - S3 **contiguous purged block evaluation aggregated by CVaR₁/Λ** (purged
    walk-forward-style blocks, tail-aggregated)
  - S4 **budgeted, deflated search** (search cost counted against the budget)
  - S5 **robust fractional Kelly sizing**
- **Empirical test**: axioms tested on real market series at their declared
  constants — no axiom overturned so far; the data reject particular
  declarations (conservative κ = 1, exponential decay instance).

## What it gives our build

- **S5 is our layer 1**: robust fractional Kelly sizing is *derived* as
  necessary, not chosen — direct theoretical backing for the half-Kelly × 2%
  cap in [[Layer 1 Sizing Design]].
- **S3 is our layer 3**: contiguous purged block evaluation = the
  [[Walk-Forward Analysis]] protocol, with CVaR aggregation instead of mean
  P/L — a candidate upgrade for how we score walk-forward windows.
- **S2/S4 are the [[Overfitting]] guardrails**: capacity-bounded ensembles +
  deflated search formalize why the VP sweep's best config was noise (30
  configs searched = budget spent).
- The five declared constants give us a vocabulary to *declare* our own
  assumptions (e.g. gold's regime coherence time ℓ) instead of silently
  assuming them.

## Terminology

- **CVaR (Conditional Value-at-Risk)** — expected loss beyond the VaR
  threshold; the tail-risk aggregation used in stage S3.
- **Purged blocks** — evaluation windows with a gap around train/test
  boundaries so overlapping observations don't leak; see
  [[Walk-Forward Analysis]].
- **Deflated search** — penalizing results by how many configurations were
  tried; see [[Overfitting]].
- **Fractional Kelly** — betting a fraction of the full Kelly f\*; see
  [[Kelly Criterion]].

## Related

- [[Kelly Criterion]], [[Layer 1 Sizing Design]], [[Walk-Forward Analysis]],
  [[Overfitting]], [[Quant Math Build Plan]],
  [[Quant Resources — Kelly & Volatility Sizing]]