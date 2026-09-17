---
title: Risk Reward
type: concept
tags: [trading, risk-management, rr, sl, tp, lot-sizing]
date: 2026-09-08
sources: [entities/goldhunterpro-small]
---

# Risk Reward — SL/TP, RR, and Lot Sizing

The core risk math behind [[GoldHunterPro Small]] and every trade in this
wiki. On gold, everything is measured in **points** (not pips).

## Points vs pips on Gold

- GOLD / GOLD.i# quotes to 2 decimals → **1 point = $0.01** of price.
- 1000 points = $10 of price movement.
- "Pip" is loosely used for points on gold; be precise in the wiki.

## The risk model (0.01 lot = 1 oz)

| Item | Value |
|---|---|
| Lot | 0.01 (1 oz) |
| SL distance | 800 points ($8.00) |
| TP distance | 1600 points ($16.00) |
| RR | **2.0** (reward = 2× risk) |
| Max concurrent | 2 trades |
| Daily loss cap | $40 ([[Kill Switch]]) |

So a full losing day (2 trades stopped out) costs ~$16 — 2 × the designed
$8 risk. The kill switch's −$40 bound allows ~5 such losses before firing.

## Why RR 2.0 with ~37.5% win rate

- Expected value per trade ≈ 0.375 × $16 − 0.625 × $8 = $6 − $5 = **+$1**.
- The strategy loses more often than it wins; it wins *bigger*. That is the
  whole design. Two losses in a row is normal, not a bug (see
  [[2026-09-08 Loss Review]]).

## SL sizing

- **Current (gold breakout bot, v3.26)**: **ATR-based** — SL = 1.5× M15
  ATR(14), TP = 3.0× (2:1). Wider than the old $5 fixed SL (which sat
  inside M15 noise — 5 of 7 losers 09-12→09-17 died on 5–8 pt wiggles).
  Fixed $5/$10 still available via `InpUseATRSL=false`. Gold 0.01 lot:
  $1 = 1.00 price move.
- **Current (BTC breakout bot, v1.06)**: **fixed $5 SL / $10 TP** (2:1) —
  converted to price via tick value/size; BTC 0.01 lot ≈ 500/1000 points.
- **Current (BTC swing bot, v2.00)**: ATR-based — SL = max(2.0 × ATR(14),
  100 pts), TP = 2.5 × SL (RR 2.5). Live evidence 09-17: SL 798 pts ≈ $8
  per loss.
- **Historical (GoldHunterPro Small, real account)**: SL = max(2.5 ×
  ATR(14), 800 points) — volatility-adaptive with a floor. On the real
  account the floor (800 pts ≈ $8) is what binds at current volatility.
  Superseded by the fixed-money directive for the breakout bots.

## Jargon

- **SL / Stop Loss** — order that closes a losing trade at a fixed price.
- **TP / Take Profit** — order that closes a winning trade at a fixed price.
- **RR / Risk:Reward** — TP distance ÷ SL distance.
- **ATR** — Average True Range (14), volatility measure used to size SL.
- **Lot** — contract size; 0.01 lot = 1 oz of gold.
- **Expected value** — probability-weighted average outcome per trade.