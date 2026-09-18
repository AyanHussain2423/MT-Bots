---
title: Quant Book — Sutton & Barto RL
type: source
tags: [quant, reinforcement-learning, machine-learning, books, sources]
date: 2026-09-18
sources:
  - raw/strategy/quant/rl-sutton-barto-2nd-ed.pdf
  - https://web.stanford.edu/class/psych209/Readings/SuttonBartoIPRLBook2ndEd.pdf
---

# Reinforcement Learning: An Introduction (2nd ed.)

Richard S. Sutton & Andrew G. Barto, MIT Press 2018. 352 pages extracted
(737 KB text). Downloaded + text-extracted 2026-09-18.

## What it is

The canonical textbook on **reinforcement learning (RL)** — how an agent
learns to act from reward signals through trial and error. The theory layer
for any future "bot as learning agent" work (layer 4 ML side).

## Key content

- **MDP framework**: state, action, reward, transition — the formal model
  for a trading bot deciding entries/exits.
- **Value functions & policies**: estimating "how good is this state/action"
  — the machinery behind Q-learning and policy gradients.
- **Temporal-difference (TD) learning**: learning from incomplete episodes —
  matches trading where outcomes arrive continuously.
- **Exploration vs exploitation**: the fundamental tradeoff — try new
  strategies vs. stick with known-good ones. Directly maps to our parameter
  search: the VP sweep over-exploited one dataset (see [[Overfitting]]).
- **Function approximation**: scaling RL to large state spaces (neural
  nets) — the bridge to deep RL.

## What it gives our build

- The **vocabulary and algorithms** if we ever train an agent to trade gold
  M1 — but per [[Quant Math Build Plan]], ML is the LAST layer, after
  sizing/drawdown/walk-forward are proven.
- The **exploration/exploitation framing** for how we search bot parameters:
  a principled reason to prefer walk-forward (structured exploration) over
  full-data sweeps (over-exploitation of noise).

## Terminology

- **MDP (Markov Decision Process)** — state/action/reward/transition model.
- **Policy** — the agent's mapping from state to action.
- **Value function** — expected future reward from a state (or state-action).
- **Reward** — the scalar signal the agent maximizes (for us: P/L).
- **TD learning** — learning from partial episodes via bootstrapping.
- **Q-learning** — off-policy TD method learning action values.
- **Exploration / exploitation** — trying new actions vs. using known best.

## Related

- [[Overfitting]], [[Quant Math Build Plan]],
  [[Quant Resources — Quant Math Foundation]],
  [[Quant Resources — ML Regression]]