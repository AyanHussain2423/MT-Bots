---
title: 2026-09-17 Loss Causes
type: synthesis
tags: [trading, analysis, losses, gold, gbh, v3.26, fixes]
date: 2026-09-17
sources: [2026-09-17-bot-week-session, mt5-mcp-deals-2026-09-17]
---

# What Made the Trades Fail (2026-09-12 → 09-17) and the v3.26 Fixes

Filed after the [[2026-09-17 Bot Week Session]] ingest. The user's question:
"we lost all of trades" — the honest answer is 4 wins and 9 losses across
the three bots (−$11.26 closed since 09-12), with three fixable root causes
on the gold bot.

## The scoreboard

| Bot | Trades | W/L | Net |
|---|---|---|---|
| [[GoldBreakoutHunter]] (gold) | 7 | 2W/5L | **−$8.79** |
| [[BTCBreakoutHunter]] (BTC breakout) | 4 | 2W/2L | **+$5.55** |
| [[BTCSwingHunter]] (BTC swing) | 2 | 0W/1L (+1 open) | **−$8.02** |
| **Total closed** | 13 | 4W/9L | **−$11.26** |

Balance: $100 (09-10 reset) → **$71.82**.

## Root cause 1 — the hour window was OFF (the big one)

v3.24 (09-12) shipped the 03-04 UTC window as the default — the **only**
hour window positive in both 2025 (+0.95) and 2026 (+0.67) over 21 months
(see [[Hour Window Analysis 2026-09-12]]). But the next build, v3.25,
changed the defaults to `0/0 = all day` (the comment literally says
"0/0 = all day"). **All 7 gold trades this week fired outside 03-04 UTC** —
21:48, 02:56, 05:31, 05:37, 01:21, 04:25, 05:09. The bot was trading the
hours the backtest says are negative (−0.11 all-hours expectancy).

> [!warning] Flagged contradiction
> `wiki/entities/goldbreakouthunter.md` documented v3.24 (03-04 UTC default)
> while the deployed v3.25 actually ran all-day. The wiki was stale for 5
> days (last entry 09-12). Fixed in this ingest.

**Fix (v3.26):** `InpStartHourUTC = 3`, `InpEndHourUTC = 4` are the defaults
again. The window cannot silently revert to all-day on a re-attach.

## Root cause 2 — trend-continuation entries are below breakeven

Every gold entry this week was a trend-continuation entry (`GBH BUY T` /
`GBH SELL T`); the channel-break path never fired. Combined with the
[[Entry Quality Retrospective 2026-09-11]] sample, trend entries are now
**4W/9L = 30.8%** — below the 33.3% breakeven for 2:1 RR. The pattern from
09-11 repeated: trend sells entered near the channel low = selling the
bottom of the range; trend buys chased bounces.

**Fix (v3.26):** trend entries now require the **fresh guard** — the
previous M1 bar must have closed inside the channel (same rule channel
breaks already had). No more entries when price is already extended past
the channel edge.

## Root cause 3 — the $5 SL is inside the noise

5 of the 7 gold losers died on **5–8 pt wiggles in 10–30 minutes**, while
M15 bars routinely swing 10–30 pts. A $5 SL on 0.01 GOLD = 5.00 price
points = less than one typical M15 bar range. The stop was tighter than the
market's normal breathing room, so the bot got knocked out by noise, not by
being wrong about direction.

**Fix (v3.26):** ATR-based SL/TP by default — **SL = 1.5x M15 ATR(14)**,
**TP = 3.0x** (still 2:1 RR). Wider stops that sit outside the noise; the
fixed $5/$10 remains available via `InpUseATRSL = false`.

> [!note] Risk trade-off
> Wider SL means bigger losses per trade when wrong (e.g. 1.5x ATR ≈ 8–20
> pts ≈ $8–20 on 0.01 lot). The −$50 daily kill switch now covers ~3–6
> losing trades instead of 10. This is the deliberate trade for fewer
> noise-stops.

## Root cause 4 — crash aftermath (09-16 21:00 UTC)

Gold crashed **~132 pts in one hour** (4367.01 → 4235.12, 09-16 21:00–22:00
UTC; the 21:00 and 21:30 M15 bars had 59-pt and 62-pt ranges vs a 5–15 pt
norm). The bot's next three trades (09-17 01:21, 04:25, 05:09) all lost in
the choppy aftermath.

**Fix (v3.26):** volatility spike filter — when a closed M15 bar's range
exceeds **3x the 20-bar average**, entries pause for **30 minutes**
(`InpVolatilitySpikeMult`, `InpVolatilityPauseMin`; set multiplier 0 to
disable).

## Root cause 5 — the 09-15 21:48 trade risked $7.72, not $5

SL was 7.72 pts from entry (4308.31 → 4300.59) — the only trade this week
with a non-$5 SL. Root cause unknown (chart inputs? a different build?).
**Open question** — v3.26's init print now reports the SL/TP mode and
distances so the next attach shows exactly what the bot computed.

## What was NOT the problem

- **The BTC breakout bot is fine** — +$5.55, 2:1 RR working as designed.
- **The kill switch never fired** — risk model held all week.
- **No code bugs found** in the losing trades — the bot did what it was
  configured to do; the configuration was the problem (hours, entry type,
  stop width).

## The v3.26 fix list (compiled 0 errors / 0 warnings, 2026-09-17)

1. Hour window default **03-04 UTC** (was 0/0 = all day).
2. **ATR-based SL/TP** default ON (1.5x/3.0x M15 ATR; `InpUseATRSL=false`
   keeps $5/$10).
3. **Volatility spike filter** — 30-min pause after a 3x-range M15 bar.
4. **Fresh guard on trend entries** — previous M1 bar must close inside the
   channel.

Deploy: remove + re-attach `GoldBreakoutHunter_Zaid_v3` on GOLD,M1. Expect
`GoldBreakoutHunter v3.26 initialized ... HourWindow: 3-4 UTC, SL/TP: ATR
(1.5x/3.0x M15 ATR), VolFilter: ON`.

## Open questions

- What set the 09-15 21:48 SL at 7.72 pts? (chart inputs vs build)
- Should [[BTCSwingHunter]] keep running? Its ATR SL costs ~$8 per loss and
  it just started trading.
- Does the 03-04 UTC window + channel-break-only config actually trade
  often enough? (Trend entries were the only thing firing since 09-11.)