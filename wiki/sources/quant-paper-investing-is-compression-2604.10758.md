---
title: Quant Paper — Investing Is Compression 2604.10758
type: source
tags: [quant, position-sizing, kelly, information-theory, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/investing-is-compression-2604.10758.pdf
  - https://arxiv.org/abs/2604.10758
---

# Investing Is Compression

Oscar Stiffelman (NAND Capital), arXiv:2604.10758v3 [cs.CE], Apr 2026.
15 pages. Downloaded + text-extracted 2026-09-18.

## What it is

An information-theory reframing of the [[Kelly Criterion]]: using a trick
from Tom Cover's universal portfolio, the paper shows Kelly's objective —
even in its most general form — **factors into three terms: a money term, an
entropy term, and a divergence term**. Maximizing growth = minimizing
divergence (measured in bits). Investing is, fundamentally, a compression
problem.

## Key content

- **The three-term factorization**: money term (payoff / rules of the game),
  entropy term (uncertainty), divergence term (difference between our chosen
  distribution and the unknown true distribution, in bits).
- **Why it matters**: the money and entropy terms are constant across
  strategies in a given backtest → the difference in log growth between two
  strategies measures their **relative divergence in bits**.
- **Winner fraction heuristic**: allocates capital in proportion to each
  asset's probability of dominating the candidate set; its growth shortfall
  vs the optimal portfolio is bounded by the entropy of the winner-fraction
  distribution. Both the heuristic and the bound are claimed original.
- Historical framing: Kelly 1956 (Bell Labs) → Samuelson's rejection →
  Cover's universal portfolio → this paper.

## What it gives our build

- **Layer 1 theory upgrade**: our sizing formula (half-Kelly × 2% cap in
  [[Layer 1 Sizing Design]]) minimizes the same objective — the divergence
  term — so sizing error is literally measured in bits of growth drag.
- **Strategy comparison tool**: the "difference in log growth = divergence
  in bits" result gives us a principled way to compare bot configurations
  (e.g. v3.25 vs v3.26) beyond raw P/L.
- **Winner fraction heuristic** — a candidate allocation rule for the
  multi-bot account (gold + BTC breakout + BTC swing) once we have enough
  trade data to estimate each bot's dominance probability.

## Terminology

- **Kelly criterion** — edge-based position sizing; see [[Kelly Criterion]].
- **Entropy** — information-theoretic measure of uncertainty (bits).
- **Divergence (KL)** — information lost when approximating the true
  distribution with our chosen one.
- **Universal portfolio** — Cover's portfolio that asymptotically matches the
  best constant-rebalanced portfolio in hindsight.

## Related

- [[Kelly Criterion]], [[Layer 1 Sizing Design]], [[Quant Math Build Plan]],
  [[Quant Resources — Kelly & Volatility Sizing]]