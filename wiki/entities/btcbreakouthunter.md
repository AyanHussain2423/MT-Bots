---
title: BTCBreakoutHunter
type: entity
tags: [trading, ea, mql5, breakout, btc, bot]
date: 2026-09-11
sources: [goldbreakouthunter-entity, log-2026-09-10]
---

# BTCBreakoutHunter

A demo-account Expert Advisor (EA) for BTC/USD — a **port of
[[GoldBreakoutHunter]] v3.14+** to BTCUSD. Built because the swing bot
([[BTCSwingHunter]]) sat for 24h+ with 0 trades and the user wanted a bot
that actually trades ("build another btc usd one is never trades i need one
atleewasy"). BTC moves enough that M5/M15 breakouts fire daily.

Source: `D:\Workspace\Trader-knowledge\BTCBreakoutHunter_Zaid_v1.mq5`
(deployed to the MT5 Experts folder).

## Configuration (as deployed 2026-09-12, v1.06)

| Setting | Value |
|---|---|
| Magic number | **20260917** |
| Symbol | BTCUSD (XM demo 169324224) |
| Lot | 0.01 (0.01 BTC) |
| Channel period | 20 bars on **M5** (`InpChannelTF` — M1 too noisy on BTC) |
| EMA | 50 on **M15** (trend filter) |
| SL / TP | **Fixed $5 / $10** (2:1 RR) — on BTC ≈ 500/1000 points (0.6%/1.3% of price) |
| Max concurrent positions | **1** |
| Max trades per day | **4** |
| Re-entry gate | **Stop-out penalty** (v1.04 — replaces the 15-min cooldown) |
| Daily counter | **Restored from history on init + refreshed every minute** (v1.05 port of gold v3.21 `CountTradesToday()`; v1.06 refresh in the gate) |
| Trend continuation | **ON** (v1.01): price ≥ 300 pts from EMA50 and within 500 pts of channel edge |
| Kill switch | +$32 profit / −$50 loss |
| Reopen guard | 20 min after broker-maintenance gaps (BTC is 24/7, rarely fires) |

## Strategy logic

Same proven filters as gold v3.14+: Donchian breakout (M5 channel) + M15
EMA50 trend + EMA slope + H1 confirm + fresh-breakout guard + reopen guard.
Trend-continuation entries (v1.01) catch slow grinds; trend entries use
**raw** price-vs-EMA50 (v1.02 fix — the slope filter was silently blocking
them, same bug as gold v3.18). Stop-out penalty gate (v1.04) replaces the
time cooldown. See [[GoldBreakoutHunter]] and [[Stop-Out Penalty]].

## Live results

| Date | Trade | Entry | SL | TP | Exit | Result |
|---|---|---|---|---|---|---|
| 2026-09-11 | SELL | 77048.45 | 77548.45 | 76048.45 | 77555.45 (SL hit, 15:37:21) | **−$5.07** |

**First trade ever** — fired 01:30 UTC after ~30h attached (v1.00 09-10
21:35 → v1.04 00:38). SELL 0.01 BTCUSD @ 77048.45, SL/TP 500/1000 points =
the fixed $5/$10 (2:1 RR). SL hit 15:37:21 at 77555.45 (order 77548.45, 7
pts slippage) → **−$5.07**.

**Day total (2026-09-11): 3 trades, 1W/2L, net +$0.15** (ledger-authoritative
from the previous session; 2 of the 3 trades not visible in the current MCP
history pull — same lag that hides gold trade #7). Combined with gold
(−$5.37): account $100 → $94.78.

## Version history

| Date | Change |
|---|---|
| 2026-09-10 | **v1.00** — port of gold v3.14 to BTCUSD: M5 Donchian channel, M15 EMA50 trend, EMA slope, H1 confirm, fixed $5/$10, kill switch, 4 trades/day, 15-min cooldown, magic 20260917, `BBH BUY`/`BBH SELL` comments. Compiled 0/0, deployed 21:35 (28,718 B). |
| 2026-09-10 | **v1.01** — trend-continuation entries (port of gold v3.16/v3.17): price distance from EMA50 (≥300 pts) replaces the slope test; proximity 500 pts. |
| 2026-09-11 | **v1.02** — raw trend fix (port of gold v3.18): `bearish`/`bullish` were slope-filtered, silently blocking trend entries. Compiled 0/0, deployed 00:19 (30,006 B). |
| 2026-09-11 | **v1.03** — status print before gates + cooldown 15→5 (port of gold v3.19). Compiled 0/0, deployed 00:30 (31,308 B). |
| 2026-09-11 | **v1.04** — stop-out penalty gate replaces the cooldown (port of gold v3.20). Compiled 0/0, deployed 00:38 (31,936 B). |
| 2026-09-11 | **v1.05** — daily counter restored from history on init (port of gold v3.21 `CountTradesToday()`). Compiled 0/0, deployed 20:18 (32,892 B). |
| 2026-09-12 | **v1.06 hard cap + diagnostic** — daily cap refreshed from history every minute (holds across re-attaches); limit message printed once per day; `CountTradesToday(true)` at init prints each counted deal (resolves the 09-12 "TradesToday: 4 vs 3 entries" discrepancy on next attach). Compiled 0/0, deployed. |

## Related

- [[GoldBreakoutHunter]] — the gold bot this is ported from.
- [[BTCSwingHunter]] — the patient swing bot this replaced on the chart.
- [[Stop-Out Penalty]] — the re-entry gate.
- [[Risk Reward]] — the $5/$10 sizing.

## Jargon

- **Donchian channel** — highest high / lowest low over N bars; a breakout
  above/below it signals a new range extension.
- **Breakout** — price moving beyond a prior high/low or range boundary.
- **EA / Expert Advisor** — an MQL5 program that automates trading.
- **Magic number** — numeric tag on orders so the EA only manages its own
  trades.
- **RR** — risk:reward ratio (see [[Risk Reward]]).