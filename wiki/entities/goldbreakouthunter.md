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

## Configuration (as deployed 2026-09-17, v3.26)

| Setting | Value |
|---|---|
| Magic number | **20260915** |
| Symbol | GOLD (XM demo 169324224) |
| Lot | 0.01 (1 oz) |
| Channel period | 20 (Donchian breakout range, M1) |
| EMA | 50 (trend filter) — **on M15 since v3.10** (was M1) |
| Trend filter TF | **M15** (v3.10 fix) |
| SL / TP | **ATR-based** (v3.26): SL = 1.5× M15 ATR(14), TP = 3.0× (2:1 RR). Fixed $5/$10 fallback via `InpUseATRSL=false` (v3.14 user directive) |
| Max concurrent positions | **1** (no hedging possible) |
| Max trades per day | **4** |
| Re-entry gate | **Stop-out penalty** (v3.20 — replaces the 15-min cooldown): after an SL, same-direction entries need a new channel extreme; after a TP, no restriction |
| Daily counter | **Restored from history on init + refreshed every minute** (v3.21 `CountTradesToday()`; v3.24 refresh in the gate — the cap now holds across re-attaches and manual resets) |
| Hour window | **03-04 UTC** (v3.24, restored as default in v3.26 — `InpStartHourUTC`/`InpEndHourUTC`; the only window positive in both 2025 and 2026, +0.81/trade over 21 months; see [[Hour Window Analysis 2026-09-12]]). ⚠️ v3.25 regressed the defaults to `0/0 = all day` — all 7 trades 09-12→09-17 fired outside 03-04 UTC |
| Trend continuation | **ON** (v3.16): enter near the channel edge when price is ≥10 pts from EMA50 (v3.17 distance), max 3/day. **Fresh guard added v3.26** — previous M1 bar must close inside the channel (no chasing extended moves) |
| Volatility spike filter | **ON** (v3.26): pause entries 30 min after a closed M15 bar's range exceeds 3× the 20-bar average (`InpVolatilitySpikeMult`, `InpVolatilityPauseMin`; multiplier 0 = off) |
| Kill switch | **+$32 profit / −$50 loss** (v3.11, user directive) |
| Daily cutoff | 23:59 local (test setting) |
| Reopen guard | 20 min after daily market break (v3.13) |

> [!warning] v2.00 flood-proof rewrite (2026-09-08)
> The original build flooded the demo account with **1,156 deals** in ~30
> minutes (alternating buy/sell pairs, no SL/TP) because MT5 kept running a
> **stale cached `.ex5`** of an older broken build. v2.00 adds four hard
> gates — 1 trade per M1 bar, 15-min cooldown, max 1 concurrent position,
> max 4 trades/day — and is deployed under a **new file name**
> (`GoldBreakoutHunter_Zaid_v2`) so MT5 cannot load the old cached binary.
> See the `2026-09-08 incident | GoldBreakoutHunter flood` entry in
> `wiki/log.md`.

## Strategy logic

- **Breakout entry**: price breaks above the 20-bar Donchian channel high
  (BUY) or below the channel low (SELL) — the "Gold Prop Firm Robot"
  breakout mechanic. Requires a **fresh break** (previous bar closed inside
  the channel) and a **channel slope** in the trade direction (v3.10).
- **Trend filter**: only BUY above EMA50, only SELL below EMA50 — prevents
  fading the trend (the lesson from the [[2026-09-08 Loss Review]]). M15
  EMA50 since v3.10; **EMA slope** (3-bar smoothed, v3.15) + **H1 confirm**
  (v3.13) gate channel breaks.
- **Trend continuation (v3.16–v3.18, +v3.26 fresh guard)**: catches slow
  grinds the channel break misses — in a grind the channel low ratchets
  down with price, so price never "breaks" it. When price is ≥
  `InpTrendDistance` (10 pts) from the EMA50 and within `InpChannelProximity`
  (5 pts) of the channel edge, enter near the edge. Trend entries use
  **raw** price-vs-EMA50 (v3.18 fix — the slope filter was silently
  blocking them). **v3.26**: trend entries now also require the previous M1
  bar to have closed inside the channel (fresh guard) — no entries when
  price is already extended past the edge (trend entries were 4W/9L =
  30.8% < 33.3% breakeven since 09-11).
- **SL/TP (v3.26)**: **ATR-based by default** — SL = 1.5× M15 ATR(14), TP =
  3.0× (2:1 RR), so stops sit outside the M15 noise (the $5 fixed SL was
  inside it — 5 of 7 losers 09-12→09-17 died on 5–8 pt wiggles). Fixed
  $5/$10 (v3.14) remains via `InpUseATRSL=false`.
- **Stop-out penalty (v3.20)**: after an SL, same-direction entries need a
  new channel extreme (the market must prove the bounce failed); after a TP
  there is no restriction. See [[Stop-Out Penalty]].

## Risk model

- 0.01 lot = 1 oz of gold; $1 ≈ 1.00 price move.
- **ATR-based SL/TP (v3.26 default)**: SL = 1.5× M15 ATR(14), TP = 3.0× —
  wider stops than the old $5, so per-loss risk is higher (~$8–20) but
  noise-stops drop. Fixed $5/$10 via `InpUseATRSL=false` (v3.14 user
  directive).
- [[Kill Switch]]: daily P/L guard — closes all and stops the day at
  **+$32 profit** or **−$50 loss** (v3.11, user directive).
- [[Daily Cutoff]]: at **23:59 local** closes all positions, deletes pending
  orders, and stops for the day.
- **4 trades/day cap** — added because the earlier bots traded too often.
- **Stop-out penalty** replaces the old 15-min cooldown (v3.20) — see
  [[Stop-Out Penalty]].

## Live results

| Date | Trade | Entry | SL | TP | Exit | Result |
|---|---|---|---|---|---|---|
| 2026-09-09 | SELL (box-bottom break, trend DOWN) | 4367.52 | 4371.57 | 4359.38 | 4359.16 (TP hit, 01:28:58) | **+$8.36** ✅ |
| 2026-09-09 | BUY (box-top break) | 4358.27 | 4353.08 | 4368.65 | 4353.06 (SL hit, 03:38:50) | **−$5.21** |
| 2026-09-09 | BUY (box-top break) | 4354.31 | 4351.67 | 4360.67 | 4351.67 (SL hit, 05:22:06) | **−$2.64** |
| 2026-09-09 | BUY (box-top break) | 4349.63 | 4345.67 | 4357.56 | 4357.76 (TP hit, 06:22:16) | **+$8.13** ✅ |
| 2026-09-09 | BUY (box-top break) | 4361.42 | 4357.79 | 4368.76 | 4357.51 (SL hit, 06:31:18) | **−$3.91** |
| 2026-09-09 | BUY (box-top break) | 4426.31 | 4420.08 | 4438.76 | 4419.89 (SL hit, 20:13:32) | **−$6.42** |
| 2026-09-09 | BUY (box-top break) | 4398.62 | 4390.10 | 4415.59 | 4415.62 (TP hit, 22:36:02) | **+$17.00** ✅ |
| 2026-09-10 | BUY (reopen gap fakeout) | 4405.75 | 4400.75 | 4415.75 | 4402.70 (SL hit, 01:10:17) | **−$3.05** |
| 2026-09-10 | BUY (pullback) | 4401.74 | 4396.74 | 4411.74 | 4408.12 (TP hit, 04:01:06) | **+$6.38** ✅ |
| 2026-09-10 | BUY (top of spike) | 4417.29 | 4412.29 | 4427.29 | 4411.31 (SL hit, 04:16:33) | **−$5.98** |
| 2026-09-10 | BUY (higher top) | 4418.58 | 4413.58 | 4428.58 | 4413.85 (SL hit, 05:11:52) | **−$4.73** |
| 2026-09-11 | SELL (trend cont., 5/5 filters) | 4331.49 | 4336.53 | 4321.53 | 4336.75 (SL hit, 21:51:19) | **−$5.26** |
| 2026-09-11 | SELL (trend cont.) | 4326.68 | 4331.53 | 4316.53 | 4316.50 (TP hit, 22:02:50) | **+$10.18** ✅ |
| 2026-09-11 | SELL (trend cont.) | 4324.12 | 4329.20 | 4314.20 | 4314.21 (TP hit, 01:41:17) | **+$9.91** ✅ |
| 2026-09-11 | SELL (trend cont.) | 4315.54 | 4320.10 | 4305.10 | 4320.11 (SL hit, 02:01:54) | **−$4.57** |
| 2026-09-11 | SELL (trend cont.) | 4314.60 | 4319.60 | 4304.60 | 4319.86 (SL hit, 03:01:03) | **−$5.26** |
| 2026-09-11 | SELL (trend cont.) | 4309.21 | 4314.45 | 4299.21 | 4314.47 (SL hit, 07:08:07) | **−$5.26** |
| 2026-09-11 | BUY (channel break, marginal) | 4396.61 | 4401.85 | 4386.61 | ~4401.85 (SL hit, ~16:59) | **−$5.24** |
| 2026-09-15 | BUY (trend cont.) | 4308.31 | 4300.59 | — | 4300.53 (SL hit, 22:14:14) | **−$7.78** ⚠️ |
| 2026-09-16 | SELL (trend cont.) | 4281.03 | 4286.89 | — | 4286.89 (SL hit, 04:14:10) | **−$5.86** |
| 2026-09-16 | BUY (trend cont.) | 4304.68 | — | 4314.49 | 4314.60 (TP hit, 05:36:15) | **+$9.92** ✅ |
| 2026-09-16 | BUY (trend cont.) | 4313.35 | — | 4323.45 | 4323.60 (TP hit, 06:00:03) | **+$10.25** ✅ |
| 2026-09-17 | SELL (trend cont.) | 4261.06 | 4266.04 | — | 4266.07 (SL hit, 01:32:47) | **−$5.01** |
| 2026-09-17 | BUY (trend cont.) | 4310.23 | 4305.20 | — | 4305.11 (SL hit, 04:54:20) | **−$5.12** |
| 2026-09-17 | SELL (trend cont.) | 4287.39 | 4292.48 | — | 4292.58 (SL hit, 05:19:40) | **−$5.19** |

**Day total (2026-09-09): +$3.99 for v3 across 7 trades — 3W/4L, 42.9% win
rate** (wins +$8.36/+$8.13/+$17.00 = +$33.49; losses −$5.21/−$2.64/−$3.91/
−$6.42 = −$18.18; net +$15.31, plus the pre-kill-switch −$11.32 from the
early dual-instance trades). RR 2.0 means breakeven is 33.3% win rate, so
42.9% = profitable day. Kill switch (+$10 profit target) NOT fired — daily
P/L +$3.99 is just under it.

**2026-09-10 (pre-reset): 4 trades, 1W/3L, net −$7.38** (balance 1033.09 →
1025.71) — all BUYs into a dead-cat bounce after hours of downtrend. This
sample exposed the weak trend filter → v3.13 (EMA slope + H1 confirm +
reopen guard). Account then reset to $100.00 (09:43 UTC, `SetCustomBalance
−925.71`).

**2026-09-11 (fresh $100): 7 trades, 2W/5L, net −$5.37 → balance $94.63**
(gold only; combined with BTC +$0.15 → $94.78). Trade #1 SELL 4331.49 → SL
−$5.26 (entry 1.45 pts above channel low = selling into support; trade lasted
80 s). Trade #2 SELL 4326.68 → TP +$10.18 (fired 1 min after v3.19
re-attach; the old 15-min cooldown would have blocked it). Overnight session
(v3.20): trade #3 SELL 4324.12 → TP +$9.91; trade #4 SELL 4315.54 → SL
−$4.57 (fired 1 min after the TP — the "no restriction after TP" gate
working as designed); trade #5 SELL 4314.60 → SL −$5.26 (fired 37 min after
the SL, only after the channel made a new low — the stop-out penalty
required proof, got it, and the market bounced anyway); trade #6 SELL
4309.21 → SL −$5.26 (06:22 entry, SL 07:08:07 — a normal SL, not a shutdown
close); trade #7 BUY 4396.61 → SL −$5.24 (16:29 entry, marginal channel
break 0.17 pts above the 20-bar high after a 50-pt rally).

**The 4/day cap bug cost −$15.76.** All 7 trades fired on one server day
(UTC+3: server day 09-11 starts 09-10 21:00 UTC) because `g_tradesToday` was
memory-only and reset on every re-attach. If the cap had held (#1–#4 only):
net **+$10.39**. The cap-bug trades (#5, #6, #7) all lost. Fixed in v3.21
(`CountTradesToday()` restores the counter from history on init). See
[[Entry Quality Retrospective 2026-09-11]] for the full entry-quality
analysis — all 6 sells were trend-continuation entries (the channel-break
path never fired), and the 3/day trend-continuation counter was also
violated by re-attach resets (residual gap in v3.21).

**2026-09-12 → 09-17 (v3.25, all-day window): 7 trades, 2W/5L, net −$8.79 →
balance $71.82.** All 7 entries were trend-continuation (`GBH BUY T`/`SELL
T`); the channel-break path never fired. **All 7 fired OUTSIDE 03-04 UTC** —
v3.25 had regressed the hour-window defaults to `0/0 = all day`. Trade #1
(09-15 21:48 BUY) risked $7.72, not $5 (SL 7.72 pts — root cause unknown,
flagged). The two wins (09-16 05:31/05:37 BUYs, +$9.92/+$10.25) were the
only clean trades. Trades #5/#6/#7 (09-17) fired in the aftermath of the
09-16 21:00 UTC crash (gold fell 4367 → 4235, ~132 pts in an hour). Full
ingest: [[2026-09-17 Bot Week Session]]; analysis: [[2026-09-17 Loss
Causes]].

First verified live trade for the breakout strategy: sold when price broke
the 20-bar box bottom (DistLo −0.07), price fell $8, TP captured in ~39
minutes. RR 2.0 reward in full.

Overnight pattern: after the win, trend flipped UP (price above EMA50) and
the bot bought 4 box-top breaks. 3 of those were counter-trend bounces in a
falling market (price kept making lower lows) → SL hits. The 06:10 BUY
caught the real bounce → TP. The trend filter worked as designed — the
SELL (trend DOWN) won, the BUYs (trend UP) mostly lost because the market
was still falling.

Evening session (after VPS migration): bot was offline 06:31–19:43 (missed
the $69 rally from ~4357 → 4426), re-attached 19:43:28 on VPS. Bought the
top of the rally at 4426.31 → SL hit (−$6.42), then bought the pullback at
4398.62 → TP hit (+$17.00). The 21:57 BUY 4401.09 (+$16.02) was NOT v3's —
GoldHunterPro Small (magic 20260910) was loaded for 34 seconds and opened
it; both positions hit TP within 12 seconds of each other at 22:36.

## Version history

| Date | Change |
|---|---|
| 2026-09-08 | Created from verified-strategy research (Marci Silfrain + Gold Prop Firm Robot). Compiled 0 errors/0 warnings, deployed to MT5 Experts. |
| 2026-09-08 | **v2.00 flood-proof rewrite** after a 1,156-deal flood incident: 1 trade per M1 bar, 15-min cooldown, max 1 position, max 4 trades/day. Redeployed as `GoldBreakoutHunter_Zaid_v2` (new name = fresh binary, no MT5 cache). |
| 2026-09-08 | **v3.00** — renamed again (`GoldBreakoutHunter_Zaid_v3`) to force a fresh binary; M1-bar status prints (`GBH status | Bid | Range | DistHi/DistLo | Trend | buyBreak/sellBreak`). |
| 2026-09-09 | **First live win +$8.36** (SELL 4367.52 → TP 4359.16). Kill-switch loss limit raised −$5 → −$50 after the day's earlier losses (−11.32) kept re-triggering it. |
| 2026-09-09 | **5-trade day, net +$4.73** (2W/3L, 40% win rate): first win +$8.36, then 4 BUYs — 3 SL hits (−$5.21, −$2.64, −$3.91) and 1 TP hit (+$8.13). Kill switch (−50) held. Note: 5 trades fired with MaxTradesPerDay default 4 — chart input likely set to 5. |
| 2026-09-09 | **VPS migration + evening session**: bot offline 06:31–19:43 (missed $69 rally), re-attached 19:43 on VPS (London LD6 04, 2.85 ms execution). 2 more trades: BUY 4426.31 → SL −$6.42, BUY 4398.62 → TP +$17.00. v3 day total **+$3.99** (7 trades, 3W/4L). Kill switch (+$10) not fired. |
| 2026-09-10 | **v3.10 trend-filter fix** — root cause of the 3 counter-trend BUY SL hits (trades 2/3/5): EMA50 trend filter was on **M1** (50 min of noise; price kept bouncing above it in the falling market → false "bullish"). Fixed: EMA50 now on **M15** (real trend), plus **channel-slope confirmation** (only BUY a rising channel / SELL a falling one) and **fresh-breakout guard** (previous M1 bar must close inside the channel — no chasing extended moves). Same magic/SL/TP/gates. Compiled 0 errors/0 warnings, deployed to MT5 Experts. |
| 2026-09-10 | **v3.11 kill-switch/close bug fix** — 2 naked trades (no SL/TP) from a "close" that opened new positions: `request.position` was never set; kill switch counted yesterday's P/L (D1 boundary vs server midnight); kill switch re-fired every tick. Fixed all 3; profit target raised to **+$32** (user directive). |
| 2026-09-10 | **v3.12 bar-gate robustness** — indicator reads moved before the bar gate so a failed read retries next tick instead of skipping the whole bar. |
| 2026-09-10 | **v3.13 trend quality** — EMA slope filter (BUY only if M15 EMA50 rising), H1 EMA50 confirmation, post-reopen guard (20 min after daily market break). Fixes the 09-10 1W/3L −$7.38 sample (all BUYs into a dead-cat bounce). |
| 2026-09-10 | **v3.14 fixed $5 SL / $10 TP** (user directive, 2:1 RR) — ATR-based SL/TP replaced with fixed money amounts converted via tick value/size. |
| 2026-09-10 | **v3.15 smoothed EMA slope** — 3-bar comparison (45 min on M15) instead of bar-to-bar; the 1-bar wiggle kept printing RISE while the EMA fell for an hour, blocking sells. |
| 2026-09-10 | **v3.16 trend-continuation mode** — catches slow grinds the channel break misses (channel low ratchets down with price in a grind, so price never "breaks" it): enter near the channel edge when the EMA50 is falling hard. New inputs: `InpUseTrendContinuation`, `InpChannelProximity`, `InpMaxTrendEntriesPerDay`. |
| 2026-09-10 | **v3.17 trend distance** — replaced the slope test for trend entries with price distance from EMA50 (≥10 pts); the slope (even 3-bar smoothed) flips to RISE on a single bounce and blocks sells for 45 min while price falls 40+ pts. |
| 2026-09-11 | **v3.18 raw trend fix** — root cause: `bearish`/`bullish` were themselves slope-filtered, silently blocking trendSell/trendBuy. Trend entries now use raw price-vs-EMA50. Trade #1 (00:20 SELL → SL −$5.26) proved the fix: 5/5 filters green → trade fired. |
| 2026-09-11 | **v3.19 status print before gates + cooldown 15→5** — the bot went silent (looked dead) during cooldown because the print sat after the gates; now prints every M1 bar regardless. Trade #2 (+$10.18) fired 1 min after re-attach — the old 15-min cooldown would have blocked it. |
| 2026-09-11 | **v3.20 stop-out penalty gate** — time cooldown removed entirely. After an SL, same-direction entries need a new channel extreme; after a TP, no restriction. Status print shows `SLpenalty: ON/off`. See [[Stop-Out Penalty]]. |
| 2026-09-11 | **v3.21 daily counter restored on init** — `g_tradesToday` was memory-only; every re-attach reset it to 0, so the 4/day cap never held across restarts (09-11: 7 gold trades fired on one server day; trades #5/#6/#7 all lost = −$15.76). OnInit now calls `CountTradesToday()` (counts today's `DEAL_ENTRY_IN` deals with our magic). **Residual gap**: `g_trendEntriesToday` still resets on re-attach (3/day trend-continuation sub-cap was violated 09-11). |
| 2026-09-11 | **v3.22/v3.23 reset override** — `InpResetDailyCounters` input (one-shot per server day via GlobalVariable). **Contributed to the 09-11 7-trade day**: attaching with reset=true zeroed the counter mid-day, restarting the 4/day cap. |
| 2026-09-12 | **v3.24 hour window + hard cap** — (1) `InpStartHourUTC`/`InpEndHourUTC` (default 3-4 UTC): the only hour window positive in both 2025 (+0.95) and 2026 (+0.67) over 21 months; all-hours expectancy −0.11. (2) daily cap refreshed from history every minute — holds across re-attaches and manual resets. (3) limit message printed once per day. (4) trend-entry comments tagged `GBH BUY T`/`GBH SELL T` + `CountTrendEntriesToday()` restores the 3/day trend cap (closes the v3.21 residual gap). Compiled 0/0, deployed. |
| 2026-09-17 | **v3.25 (regression, never documented in wiki)** — hour-window defaults changed to `0/0 = all day` (comment: "0/0 = all day"). All 7 trades 09-12→09-17 fired outside 03-04 UTC; net −$8.79. The wiki was stale for 5 days (still documented v3.24). |
| 2026-09-17 | **v3.26 THE FOUR FIXES** — (1) hour window default restored to **3-4 UTC**; (2) **ATR-based SL/TP** default ON (SL = 1.5× M15 ATR(14), TP = 3.0×; fixed $5/$10 via `InpUseATRSL=false`); (3) **volatility spike filter** — 30-min entry pause after a closed M15 bar's range > 3× the 20-bar average (catches events like the 09-16 21:00 ~132-pt crash); (4) **fresh guard on trend entries** — previous M1 bar must close inside the channel. Init print now reports version, hour window, SL/TP mode, and filter state. Compiled 0 errors/0 warnings, 2026-09-17. |

## Related

- [[BTCBreakoutHunter]] — the BTC port of this bot.
- [[Stop-Out Penalty]] — the re-entry gate (v3.20).
- [[2026-09-17 Loss Causes]] — the 09-12→09-17 failure analysis + v3.26 fixes.
- [[2026-09-17 Bot Week Session]] — the week's source ingest.
- [[GoldHunterPro Small]] — the RSI+EMA+ATR scalper this breakout bot is a
  complementary alternative to.
- [[AMN Bot Spec]] — the separate AMN sweep workstream.
- [[Risk Reward]] — RR sizing used here.

## Jargon

- **Donchian channel** — highest high / lowest low over N bars; a breakout
  above/below it signals a new range extension.
- **Measured move** — a target projected from prior price structure, rather
  than a fixed pip count. *Historical*: replaced by fixed $5/$10 in v3.14.
- **Breakout** — price moving beyond a prior high/low or range boundary.
- **EA / Expert Advisor** — an MQL5 program that automates trading.
- **Magic number** — numeric tag on orders so the EA only manages its own
  trades.
- **ATR** — Average True Range (14), a volatility measure. Used for SL/TP
  sizing since v3.26 (SL = 1.5×, TP = 3.0× M15 ATR). *Historical*: ATR-based
  SL/TP was replaced by fixed $5/$10 in v3.14, then restored as the default
  in v3.26.
- **RR** — risk:reward ratio (see [[Risk Reward]]).
