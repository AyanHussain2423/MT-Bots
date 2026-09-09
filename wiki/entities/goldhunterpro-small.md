---
title: GoldHunterPro Small
type: entity
tags: [trading, ea, mql5, goldhunterpro, gold, bot]
date: 2026-09-08
sources: [raw/trades/2026-09-08-real-account.csv]
---

# GoldHunterPro Small

> [!warning] Retired from tracking (2026-09-09)
> User decision: **no longer tracked** — the bot had bad logic, bought too
> much garbage, and broke. Removed from the live bot set. The tracked set is
> now [[GoldBreakoutHunter]] (v3) + [[BTCSwingHunter]] (v2).
>
> Post-retirement cameo (2026-09-09 21:57): loaded on GOLD,M15 for **34
> seconds** (21:57:00 → 21:57:34) — opened BUY 4401.09 (SL 4393.09, TP
> 4417.09) and hit TP at 22:36:14 → **+$16.02**. One trade, one win. Not
> tracked, but recorded for completeness.

The live Expert Advisor (EA) running on the real account. An M1 gold
scalper built on RSI + EMA + ATR with hard risk guards. Source:
`C:\Users\Supertails PRM\Desktop\GoldHunterPro_Zaid_Small.mq5`.

## Configuration (as deployed 2026-09-08)

| Setting | Value |
|---|---|
| Magic number | **20260910** |
| MAX_TRADES | 2 (concurrent) |
| USE_ADAPTIVE | false |
| Session filter | OFF |
| Lot | 0.01 (1 oz) |
| RSI(14) | OB 70 / OS 30; buy band 45–70, sell band 30–55 |
| EMAs | 8 / 21 / 50 (50 = trend filter) |
| SL | max(2.5 × ATR(14), 800 points) |
| TP | 2.0 × SL distance (RR 2.0) |
| Entry timing | once per M1 bar, trend-filtered (BUY only above EMA50, SELL only below) |

## Risk model

- 0.01 lot = 1 oz of gold.
- SL 800 points ≈ **$8 risk**; TP 1600 points ≈ **$16 reward** (RR 2.0).
- [[Kill Switch]]: account-wide daily P/L guard — closes all and stops the
  day at **+$100 profit** or **−$40 loss**.
- [[Daily Cutoff]]: at **18:30 local** closes all positions, deletes pending
  orders, and stops for the day (added 2026-09-08, build 40,396 B).

## Version history

| Date | Change |
|---|---|
| 2026-09-08 | Added 18:30 daily cutoff (`CUTOFF_HOUR 18`, `CUTOFF_MINUTE 30`, `CheckDailyCutoff()` in `OnTick`). Compiled clean, deployed to Experts. **Reload pending.** |
| 2026-09-08 | First live session on real account (see [[2026-09-08 Real Session]]) |
| earlier | Kill switch added (`DAILY_PROFIT_TARGET 100.0`, `DAILY_LOSS_LIMIT 40.0`) |

## Related

- Demo edition: `GoldHunterPro_Zaid.mq5` (magic 20260901, symbol GOLD on
  MT5 9).
- AMN-style sweep bots ([[AMN Bot Spec]]) are a separate, paused workstream.
- Old .ex5 backups: `C:\Users\Supertails PRM\Desktop\Openwork\EA_backup\`.

## Jargon

- **EA / Expert Advisor** — an MQL5 program that automates trading.
- **Magic number** — numeric tag on orders so the EA only manages its own
  trades.
- **ATR** — Average True Range (14), a volatility measure.
- **RSI** — Relative Strength Index; < 30 oversold, > 70 overbought.
- **EMA** — Exponential Moving Average; EMA50 = trend filter.
- **RR** — risk:reward ratio (see [[Risk Reward]]).