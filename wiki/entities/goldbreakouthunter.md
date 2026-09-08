---
title: GoldBreakoutHunter
type: entity
tags: [trading, ea, mql5, breakout, gold, bot]
date: 2026-09-08
sources: [web-research-marci-silfrain, web-research-gold-prop-firm-robot]
---

# GoldBreakoutHunter

A demo-account Expert Advisor (EA) for gold built from **verified** public
strategies rather than a single educator's claims. Combines the two most
credible approaches found in research:

1. **Marci Silfrain** — world #2 on global prop-firm leaderboards; verified
   backtest **+1,574% on gold over 3 years**. Trendline-pullback style,
   measured-move targets, no custom indicators.
2. **Gold Prop Firm Robot** — verified live results: **190% growth, 71.7%
   win rate, 2.47 profit factor over 16 months**. Breakout style.

Source: `D:\Workspace\Trader-knowledge\GoldBreakoutHunter_Zaid.mq5` (also
deployed to the MT5 Experts folder).

## Configuration (as deployed 2026-09-08)

| Setting | Value |
|---|---|
| Magic number | **20260915** |
| Symbol | GOLD (XM demo 169324224) |
| Lot | 0.01 (1 oz) |
| Channel period | 20 (Donchian breakout range) |
| EMA | 50 (trend filter) |
| ATR | 14 |
| SL | max(2.0 × ATR(14), 300 points) |
| TP | 2.0 × SL distance (RR 2.0) |
| Max concurrent trades | 2 |
| Max trades per day | 2 |
| Kill switch | +$10 profit / −$5 loss |
| Daily cutoff | 23:59 local (test setting) |

## Strategy logic

- **Breakout entry**: price breaks above the 20-bar Donchian channel high
  (BUY) or below the channel low (SELL) — the "Gold Prop Firm Robot"
  breakout mechanic.
- **Trend filter**: only BUY above EMA50, only SELL below EMA50 — prevents
  fading the trend (the lesson from the [[2026-09-08 Loss Review]]).
- **Measured-move target**: TP = 2.0 × SL distance, echoing Marci Silfrain's
  measured-move approach where wins are ~2× bigger than losses.
- **Volatility-adaptive SL**: ATR-based stop so risk scales with market
  conditions, floored at 300 points.

## Risk model

- 0.01 lot = 1 oz of gold.
- ATR-based SL ≈ **$3–$6 risk**; TP ≈ **$6–$12 reward** (RR 2.0).
- [[Kill Switch]]: daily P/L guard — closes all and stops the day at
  **+$10 profit** or **−$5 loss**.
- [[Daily Cutoff]]: at **23:59 local** closes all positions, deletes pending
  orders, and stops for the day.
- **2 trades/day cap** — added because the earlier bots traded too often.

## Version history

| Date | Change |
|---|---|
| 2026-09-08 | Created from verified-strategy research (Marci Silfrain + Gold Prop Firm Robot). Compiled 0 errors/0 warnings, deployed to MT5 Experts. |

## Related

- [[GoldHunterPro Small]] — the RSI+EMA+ATR scalper this breakout bot is a
  complementary alternative to.
- [[AMN Bot Spec]] — the separate AMN sweep workstream.
- [[Risk Reward]] — RR sizing used here.

## Jargon

- **Donchian channel** — highest high / lowest low over N bars; a breakout
  above/below it signals a new range extension.
- **Measured move** — a target projected from prior price structure, rather
  than a fixed pip count.
- **Breakout** — price moving beyond a prior high/low or range boundary.
- **EA / Expert Advisor** — an MQL5 program that automates trading.
- **Magic number** — numeric tag on orders so the EA only manages its own
  trades.
- **ATR** — Average True Range (14), a volatility measure.
- **RR** — risk:reward ratio (see [[Risk Reward]]).
