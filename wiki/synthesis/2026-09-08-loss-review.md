---
title: 2026-09-08 Loss Review
type: synthesis
tags: [trading, gold, review, learning, rsi, goldhunterpro]
date: 2026-09-08
sources: [sources/2026-09-08-real-session]
---

# 2026-09-08 Loss Review — Why the SELLs Lost

Analysis of the first live day of [[GoldHunterPro Small]] (see
[[2026-09-08 Real Session]]). The day lost **−$16.20 realized** on two
stopped-out SELLs. This page files the learning so it compounds.

## What happened

1. The bot opened **SELL 4395.53** and **SELL 4395.36** at 16:08–16:09 local.
2. Both entries were at the **bottom of the downtrend**: RSI(14) was
   **34.9 / 34.3** — near the oversold line (30).
3. Price then **rallied ~$10** (4395 → 4405), hitting both SLs at ~17:03.
4. Once price closed above EMA50, the bot **correctly flipped to BUY** and
   opened two longs (RSI 63.4 / 66.8, inside the 45–70 buy band).

## What held up (the design worked)

- **Risk model:** each loss was the designed ~$8 (0.01 lot × 800-pt SL).
  Total damage: $16.20 — exactly 2 × designed risk. No overshoot.
- **Kill switch:** −$40 bound never approached; correctly did not fire.
- **Trend flip:** the bot's EMA50 filter worked — it stopped selling and
  started buying when structure flipped. The SELLs were *late* in the
  downtrend, not counter-trend.

## The core lesson

**The bot sold into an oversold market.** RSI 34.9/34.3 is one candle away
from the oversold zone (30). Selling at the bottom of a downtrend with RSI
collapsing is selling into exhaustion — the exact moment a bounce (and a
stop-out) becomes likely.

The strategy's ~37.5% win rate with RR 2.0 (see [[Risk Reward]]) means
losing streaks are expected. But *this* loss pattern is partially
avoidable: entries near the RSI extremes are the lowest-quality entries.

## Improvement candidate (not yet applied)

Tighten the RSI entry bands to avoid exhaustion zones:

| Band | Current | Proposed |
|---|---|---|
| SELL | RSI 30–55 | **RSI 40–55** |
| BUY | RSI 45–70 | **RSI 45–60** |

Rationale: require momentum confirmation, not exhaustion. A SELL at RSI 40
has room to fall; a SELL at RSI 34 is selling into the floor.

**Status: proposed only.** Needs the human's approval before touching
`GoldHunterPro_Zaid_Small.mq5`. Would also need re-validation on demo
before live.

## Jargon

- **Oversold / overbought** — RSI < 30 / > 70; price seen as stretched.
- **Exhaustion** — a move that has run out of momentum, prone to reversal.
- **Stop-out** — position closed by hitting the SL.
- **Trend flip** — price crossing the EMA50 filter, changing the bot's bias.