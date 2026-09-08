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

## Configuration (as deployed 2026-09-08, v2.00)

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
| Max concurrent positions | **1** (no hedging possible) |
| Max trades per day | **4** |
| Cooldown between trades | **15 minutes** |
| Kill switch | +$10 profit / −$50 loss (raised from −$5 on 2026-09-09) |
| Daily cutoff | 23:59 local (test setting) |

> [!warning] v2.00 flood-proof rewrite (2026-09-08)
> The original build flooded the demo account with **1,156 deals** in ~30
> minutes (alternating buy/sell pairs, no SL/TP) because MT5 kept running a
> **stale cached `.ex5`** of an older broken build. v2.00 adds four hard
> gates — 1 trade per M1 bar, 15-min cooldown, max 1 concurrent position,
> max 4 trades/day — and is deployed under a **new file name**
> (`GoldBreakoutHunter_Zaid_v2`) so MT5 cannot load the old cached binary.
> See [[2026-09-08 Flood Incident]] in the log.

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

## Live results

| Date | Trade | Entry | SL | TP | Exit | Result |
|---|---|---|---|---|---|---|
| 2026-09-09 | SELL (box-bottom break, trend DOWN) | 4367.52 | 4371.57 | 4359.38 | 4359.16 (TP hit, 01:28:58) | **+$8.36** ✅ |

First verified live trade for the breakout strategy: sold when price broke
the 20-bar box bottom (DistLo −0.07), price fell $8, TP captured in ~39
minutes. RR 2.0 reward in full.

## Version history

| Date | Change |
|---|---|
| 2026-09-08 | Created from verified-strategy research (Marci Silfrain + Gold Prop Firm Robot). Compiled 0 errors/0 warnings, deployed to MT5 Experts. |
| 2026-09-08 | **v2.00 flood-proof rewrite** after a 1,156-deal flood incident: 1 trade per M1 bar, 15-min cooldown, max 1 position, max 4 trades/day. Redeployed as `GoldBreakoutHunter_Zaid_v2` (new name = fresh binary, no MT5 cache). |
| 2026-09-08 | **v3.00** — renamed again (`GoldBreakoutHunter_Zaid_v3`) to force a fresh binary; M1-bar status prints (`GBH status | Bid | Range | DistHi/DistLo | Trend | buyBreak/sellBreak`). |
| 2026-09-09 | **First live win +$8.36** (SELL 4367.52 → TP 4359.16). Kill-switch loss limit raised −$5 → −$50 after the day's earlier losses (−11.32) kept re-triggering it. |

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
