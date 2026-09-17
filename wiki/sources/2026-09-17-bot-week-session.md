---
title: 2026-09-17 Bot Week Session
type: source
tags: [trading, session, gold, btc, gbh, bbh, bsh, losses]
date: 2026-09-17
sources: [mt5-mcp-deals-2026-09-17, mt5-mcp-account-2026-09-17]
---

# Bot Week Session (2026-09-12 → 2026-09-17)

The week after the [[Hour Window Analysis 2026-09-12]] build. The wiki was
5 days behind — this page ingests everything the bots did from 09-12 to
09-17 (MCP deal pull 2026-09-17 ~21:50 UTC, account 169324224).

**Bottom line: balance $100 → $71.82 (−$28.18 since the 09-10 reset).**
Gold bot bled −$8.79 (2W/5L), BTC breakout bot made +$5.55 (2W/2L), and the
BTC swing bot took its **first trades ever** and lost −$8.02 (1 open).

## Gold ([[GoldBreakoutHunter]], magic 20260915) — 7 trades, 2W/5L, −$8.79

All 7 entries were **trend-continuation** entries (comment tag `GBH BUY T` /
`GBH SELL T`) — the channel-break path never fired. **All 7 fired OUTSIDE
the 03-04 UTC hour window** (the deployed v3.25 defaulted to 0/0 = all day).

| # | Time (UTC) | Entry | SL | TP | Exit | Result |
|---|---|---|---|---|---|---|
| 1 | 09-15 21:48 | BUY 4308.31 | 4300.59 | — | 4300.53 (SL, 22:14:14) | **−$7.78** ⚠️ |
| 2 | 09-16 02:56 | SELL 4281.03 | 4286.89 | — | 4286.89 (SL, 04:14:10) | **−$5.86** |
| 3 | 09-16 05:31 | BUY 4304.68 | — | 4314.49 | 4314.60 (TP, 05:36:15) | **+$9.92** ✅ |
| 4 | 09-16 05:37 | BUY 4313.35 | — | 4323.45 | 4323.60 (TP, 06:00:03) | **+$10.25** ✅ |
| 5 | 09-17 01:21 | SELL 4261.06 | 4266.04 | — | 4266.07 (SL, 01:32:47) | **−$5.01** |
| 6 | 09-17 04:25 | BUY 4310.23 | 4305.20 | — | 4305.11 (SL, 04:54:20) | **−$5.12** |
| 7 | 09-17 05:09 | SELL 4287.39 | 4292.48 | — | 4292.58 (SL, 05:19:40) | **−$5.19** |

Notes:

- **Trade #1 risked $7.72, not $5** — SL was 7.72 pts from entry (4308.31 →
  4300.59). The other SLs were ~5.0–5.9 pts. Root cause unknown: chart
  inputs or a different EA build may have been live that evening. Flagged as
  an open question; v3.26's init print now shows the computed SL/TP mode and
  distances so this is visible on next attach.
- **Trades #3/#4 (the two wins)** were back-to-back BUYs 6 minutes apart on
  09-16 05:31/05:37 — bought a real bounce, both TP'd within ~30 min. The
  only clean wins of the week.
- **Trades #5/#6/#7** fired the morning after the **09-16 21:00 UTC crash**
  (gold fell 4367 → 4235, ~132 pts in an hour — see the M15 bars below).
  The market was in crash aftermath; all three lost.

## BTC breakout ([[BTCBreakoutHunter]], magic 20260917) — 4 trades, 2W/2L, +$5.55

| # | Time (UTC) | Entry | Exit | Result |
|---|---|---|---|---|
| 1 | 09-14 18:20 | BUY 78589.65 | 79150.95 (KillSwitch/Cutoff close, 21:29:01) | **+$5.61** ✅ |
| 2 | 09-14 22:20 | BUY 79232.35 | 78730.05 (SL, 09-15 00:59:13) | **−$5.02** (−$0.32 swap) |
| 3 | 09-15 04:05 | SELL 77800.55 | 76794.15 (TP, 11:08:05) | **+$10.06** ✅ |
| 4 | 09-15 17:40 | SELL 75837.35 | 76347.70 (SL, 18:24:49) | **−$5.10** |

The only bot that did its job this week — net positive, 2:1 RR working as
designed. No trades 09-16/09-17 (BTC was quiet or the setup didn't fire).

## BTC swing ([[BTCSwingHunter]], magic 20260916) — FIRST trades ever

The "patient by design" swing bot finally traded — twice on 09-17:

| # | Time (UTC) | Entry | Exit | Result |
|---|---|---|---|---|
| 1 | 09-17 04:00 | SELL 76318.25 | 77119.95 (SL, 15:30:39) | **−$8.02** |
| 2 | 09-17 19:08 | SELL 76696.80 | open (SL 77362.31, TP 74716.60) | **+$0.25 floating** |

Trade #1's SL was **ATR-based** (798 pts ≈ $8 on 0.01 lot) — bigger than the
$5 fixed SL the breakout bots use. The swing model is designed for wider
stops (RR 2.5), but this is the first live evidence of what that costs.

## Account

- **Balance: $71.82**, equity $72.07 (MCP pull 09-17 ~21:50 UTC). One open
  position (BSH SELL, +$0.25).
- No balance operations in the 7-day window — the drop is all trading.
- Kill switch never fired this week (daily P/L never hit +$32/−$50).

## M15 evidence for the 09-16 crash (volatility filter rationale)

From the M15 pull (09-16 20:45 → 22:00 UTC):

| Bar (UTC) | High | Low | Range |
|---|---|---|---|
| 20:45 | 4364.77 | 4342.35 | 22.4 |
| 21:00 | 4367.01 | 4307.65 | **59.4** |
| 21:15 | 4323.99 | 4306.09 | 17.9 |
| 21:30 | 4323.56 | 4261.82 | **61.7** |
| 21:45 | 4307.36 | 4257.12 | 50.2 |
| 22:00 | 4287.19 | 4235.12 | 52.1 |

Peak-to-trough 4367.01 → 4235.12 = **131.9 pts in ~1 hour**. Typical M15
ranges that week were 5–15 pts, so the 21:00/21:30 bars were **4–6x the
average** — exactly what v3.26's volatility spike filter (3x threshold,
30-min pause) is designed to catch.

## Lessons

1. **The hour window matters and it was OFF.** v3.25 shipped with
   `InpStartHourUTC = 0 / InpEndHourUTC = 0` (all day) — the opposite of
   v3.24's 03-04 UTC default. Every gold trade this week fired outside the
   only window the 21-month backtest found profitable. Fixed in v3.26
   (default 3-4 UTC).
2. **Trend-continuation entries are below breakeven.** Since 09-11, trend
   entries are 4W/9L (30.8%) — under the 33.3% breakeven for 2:1 RR. The
   channel-break path hasn't produced a trade since 09-11. v3.26 adds the
   fresh guard (previous M1 bar must close inside the channel) to stop
   chasing extended moves.
3. **$5 SL is inside the noise.** 5 of 7 gold losers died on 5–8 pt wiggles
   in 10–30 minutes while M15 bars swing 10–30 pts. v3.26 switches to
   ATR-based SL/TP (1.5x/3.0x M15 ATR) by default — wider stops, same 2:1.
4. **Crash aftermath is dangerous.** The 09-16 21:00 crash preceded 3 losing
   trades. v3.26 pauses entries 30 min after a volatility spike.
5. **BSH is now live-risk.** The swing bot's first two trades ever cost
   −$8.02 (closed) and are −$8 at risk (open). Decide whether it stays on
   the chart.

See [[2026-09-17 Loss Causes]] for the full analysis and the v3.26 fix list.