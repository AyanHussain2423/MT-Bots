---
title: Quant Paper — Kelly Lévy 2002.03448
type: source
tags: [quant, kelly, position-sizing, fat-tails, levy, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/kelly-levy-2002.03448.pdf
  - https://arxiv.org/abs/2002.03448
---

# Kelly Criterion: From a Simple Random Walk to Lévy Processes

Sergey Lototsky & Austin Pollok, arXiv:2002.03448v1 [math.PR], Feb 2020.
22 pages. Downloaded + text-extracted 2026-09-18.

## What it is

The rigorous math of the [[Kelly Criterion]], generalized from the original
binary (Bernoulli) bet to **continuous-time and fat-tailed (Lévy) return
processes** — i.e., what Kelly looks like when returns are not just
win/loss, which is the reality of gold.

## Key content

- **The core result**: for a biased coin with win prob `p`, betting fraction
  `f` of wealth compounds as `W_n = W0 · Π(1 + f·r_k)`, and the long-term
  growth rate is `gr(f) = E[ln(1 + f·r)]`. Maximizing it gives the classic
  **`f* = 2p − 1`** (edge = win prob − loss prob).
- **NS-NL condition**: `0 ≤ f ≤ 1` (no shorting, no leverage) — the sane
  constraint for our bots.
- **Continuous-time / high-frequency limit**: the paper extends Kelly to
  Lévy processes (jumps, fat tails) — the regime where gold's crash moves
  live. Fractional Kelly emerges as the conservative choice when the return
  distribution is uncertain or heavy-tailed.

## What it gives our build

- The **mathematical justification for fractional Kelly** on gold: our live
  stats (WR ≈ 40%, RR 2:1) give a raw `f*` ≈ 0.10; fat tails + estimation
  error argue for half-Kelly (5% risk/trade) — the number already in
  [[Quant Resources — Kelly & Volatility Sizing]].
- The growth-rate objective `gr(f) = E[ln(1+fr)]` is the exact objective our
  layer-1 sizing optimizer should maximize (log-utility, not arithmetic
  expectancy).

## Terminology

- **Bernoulli model** — each bet is win/loss with fixed probabilities.
- **Edge** — positive expected return per bet (`E[r] > 0`).
- **Growth rate** — long-run log-wealth per bet; what Kelly maximizes.
- **Lévy process** — stochastic process with independent stationary
  increments, allowing jumps (fat tails); models crash regimes.
- **NS-NL** — no-shorting / no-leverage constraint (`0 ≤ f ≤ 1`).

## Related

- [[Kelly Criterion]], [[Quant Math Build Plan]],
  [[Quant Resources — Kelly & Volatility Sizing]]