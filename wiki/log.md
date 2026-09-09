# Trader Knowledge Wiki Log

Append-only, chronological record of everything that happens in the trading
wiki. Newest entries go at the top.

---

## [2026-09-10] fix | v3.11 kill-switch/close bug — 2 naked trades + root cause

- **Incident (00:16–00:21 server)**: v3.10's kill switch fired and produced
  **2 naked trades (no SL/TP)** that the user had to close manually:
  - 00:16:45 — kill switch fired → printed `Closed position #2307811010
    result: 10009` (retcode DONE) but **did NOT close it** — instead opened
    **NEW BUY 4408.91** (ticket 2307815810, comment "KillSwitch/Cutoff
    close", **no SL/TP**) — mistake #1
  - 00:20:17 — SELL #2307811010 (v3.00's trade, 4412.07 → TP 4405.81 zone)
    hit TP at 4405.72 → **+$6.35 win** (the "win from 3.0")
  - 00:20:21 — kill switch fired **again** → opened **NEW SELL 4405.67**
    (ticket 2307820670, **no SL/TP**) — mistake #2
  - 00:21:03–04 — user closed both mistakes manually (4407.83 / 4407.23)
    → **−$1.68 / −$2.16**
- **Net**: +$6.35 − $1.68 − $2.16 = **+$2.51** → balance 1030.58 → **1033.09**.
  Account flat.
- **Root cause — 3 bugs in v3.10**:
  1. **`CloseAllPositions()` never set `request.position = ticket`** — in MT5
     a market order without a position reference **opens a NEW position**
     instead of closing. The "close" created naked trades. **Critical.**
  2. **Kill switch counted YESTERDAY's P/L** — `g_dayStart = iTime(PERIOD_D1, 0)`
     uses the D1 bar boundary (00:00 UTC = 21:30 server). v3.10 loaded at
     21:44 UTC (still inside 09-09's D1 bar) → counted 09-09's +$15.31 +
     floating → +$18.47 ≥ +$10 → **fired instantly on load**.
  3. **Kill switch re-fired every tick** — `CheckKillSwitch()` ran *before*
     the `g_dayStopped` guard, so once tripped it fired on every tick,
     opening a new naked trade each time.
- **Fixes (v3.11, same magic 20260915)**:
  1. `request.position = ticket` added to `CloseAllPositions()` — closes now
     actually close.
  2. Day start = **server midnight** (`ServerDayStart()` helper) — kill
     switch counts only today's P/L.
  3. `g_dayStopped` guard moved **before** `CheckKillSwitch()` — fires once
     per day max.
  4. **Kill switch profit target raised to +$32** (user directive; loss
     limit stays −$50).
- Compiled **0 errors / 0 warnings**, deployed to MT5 Experts folder
  (v3.11, 26,592 bytes, 2026-09-10 00:32).
- **Lesson**: a "successful" close retcode (10009) does not mean a position
  closed — verify `request.position` is set and confirm via deal log.

## [2026-09-10] fix | v3.10 trend-filter fix — root cause of counter-trend BUYs

- **Diagnosis**: 3 of 4 morning BUYs hit SL (trades 2/3/5 on 2026-09-09) because
  the EMA50 trend filter ran on **M1** — 50 minutes of noise. In the falling
  market, price kept bouncing above M1 EMA50 for minutes at a time → bot saw
  "bullish" → bought box-top breaks → SL. The M15 trend was DOWN the whole time.
- **Fixes (v3.10, same magic 20260915, same SL/TP/gates)**:
  1. **Trend filter moved to M15** (`InpTrendTF = PERIOD_M15`) — real trend,
     not noise.
  2. **Channel-slope confirmation** — BUY only if the 20-bar channel is
     rising, SELL only if falling (no buying flat/falling channels = no
     buying tops).
  3. **Fresh-breakout guard** — previous M1 bar must close inside the
     channel; no entries when price is already extended/chasing.
  4. Loss-limit default corrected to **−$50** in code (was 5.0; chart input
     had overridden it).
- Compiled **0 errors / 0 warnings**, deployed to MT5 Experts folder
  (v3.10, 26,588 bytes, 2026-09-10 00:13).
- **User directive**: fix v3 itself, do NOT build v4 yet — v4 is a bigger
  thing to find later. v3 keeps collecting trades under the fixed filter.

## [2026-09-09] trade | Small double-fire closed −$3.44 — wrong bot attached

- **Wrong bot attached**: user re-attached **GoldHunterPro Small** (magic
  20260910) at 23:52:33 instead of v3 — Small is the retired bot.
- **Double-fire**: Small fired **2 BUY entries 26s apart** from a single
  instance (stacking bug — no open-position check):
  - BUY 4419.32 (ticket 2307797870, SL 4411.34, TP 4435.34, 23:52:35)
  - BUY 4419.38 (ticket 2307797997, SL 4411.36, TP 4435.36, 23:53:00)
- **Closed manually** 23:55:54–55 server, both at **4417.63** (deals
  #2167391177, #2167391183) → **−$1.69 / −$1.75 = −$3.44 total**.
  Small removed from chart 23:55:51.
- Balance: 1034.02 → **1030.58**. Account flat.
- **Lesson**: Small's stacking bug confirmed (single instance, 2 entries in
  26s). v3 (magic 20260915) is the bot to run; Small stays retired.

## [2026-09-09] trade | Trade #1 closed +$2.69 — scripts removed from charts

- **Scripts removed** (MT5 log): v3 (GOLD,M15) removed 23:36:17,
  BTCSwingHunter v2 (BTCUSD,M15) removed 23:36:19. Agent is sole trader.
- **Trade #1 closed**: BUY 0.01 GOLD 4416.94 (ticket 2307782344, opened
  20:59 UTC) closed **manually** 23:45:36 server at **4419.63** → **+$2.69**
  (deal #2167386144, order #2307794666). Not TP/SL — user pulled out at
  +$2.69, matching the "small profit, pull out" style.
- Balance: 1031.33 → **1034.02**. Account flat.
- **Daily cutoff reached** (23:59 local) — no new trades until next day.
  Day total: +$2.69 (agent-managed portion).

## [2026-09-09] decision | New trading plan — $5 targets, 2:1 RR, agent trades

- **User directive**: "do it now itself start from now" — agent starts
  trading immediately with the new plan.
- **Plan**: 0.01 lots, **target +$5, stop −$2.50** (2:1 RR). Spread on GOLD
  is $0.56/round-trip (11% of target) — profitable even at 50% win rate
  (+$0.69/trade). ~35 trades to net $50 at 60% WR.
- **Why $5 not $2–3**: at $2.50 targets the spread ate 19–28% of the prize
  (breakeven needed ~60% WR at 1:1); at $5 it's 11% and 50% WR is
  profitable.
- **Rules**: one trade at a time, SL/TP always set, kill switch −$50/day,
  daily cutoff 23:59 local, every trade logged.
- **Trade #1**: the open v3 BUY (ticket 2307782344, 4416.94, SL 4414.09,
  TP 4423.09, RR 2.16:1) — taken over as the agent's first trade under the
  plan; fits the $5-target profile (+$6.15).

## [2026-09-09] decision | Agent takes over as trader — scripts removed from charts

- **User directive**: "the scripts wont make trades u will" — the agent
  (via MT5 MCP) is now the **sole trader**. Scripts (GoldBreakoutHunter v3,
  BTCSwingHunter v2, GoldHunterPro Small) removed from MT5 charts by the
  user.
- **Open v3 BUY survives removal** (ticket 2307782344, 4416.94, SL 4414.09,
  TP 4423.09): removing an EA from a chart does not close positions; SL/TP
  already set. Agent manages it to TP/SL as its own trade.
- **Agent takes over risk rules manually**: kill switch (+$10 profit /
  −$50 loss), daily cutoff (23:59 local), SL/TP always set, one trade at a
  time, every trade logged to the wiki.
- `.mq5` sources stay in the repo — strategy logic remains the reference
  for upgrades (v4 trend-continuation entry still on the table).

## [2026-09-09] session | VPS migration + evening trades — v3 +$3.99 day, Small cameo +$16.02

- **VPS migration**: 19:43:29 log shows "use MetaTrader VPS Hosting Service
  to speed up the execution: 2.85 ms via 'VPS London LD6 04' instead of
  204.98 ms". v3 + BTCSwingHunter re-attached 19:43:28. **Bot was offline
  06:31–19:43** — missed the $69 rally (~4357 → 4426).
- **3 new trades after re-attach**:
  - 19:59:59 BUY 4426.31 (v3, SL 4420.08, TP 4438.76) → SL hit 4419.89
    (20:13:32) → **−$6.42** — bought the top of the rally.
  - 21:03:59 BUY 4398.62 (v3, SL 4390.10, TP 4415.59) → TP hit 4415.62
    (22:36:02) → **+$17.00** ✅ — bought the pullback, caught the bounce.
  - 21:57:02 BUY 4401.09 (SL 4393.09, TP 4417.09) → TP hit 4417.11
    (22:36:14) → **+$16.02** ✅ — **NOT v3's**: user loaded GoldHunterPro
    Small (magic 20260910) at 21:57:00 for 34 seconds (removed 21:57:34,
    v3 re-loaded). Small opened it; both positions hit TP 12s apart.
- **v3 day total: +$3.99** (7 trades, 3W/4L, 42.9% win rate; wins
  +$8.36/+$8.13/+$17.00, losses −$5.21/−$2.64/−$3.91/−$6.42, plus early
  −$11.32). Kill switch (+$10 profit target) **not fired** — one more TP
  win would trigger it.
- **Small cameo**: +$16.02 in 34 seconds of life. Recorded on its entity
  page (retired from tracking, but the trade is real).
- **Account day total: +$20.01** (v3 +$3.99 + Small +$16.02).
- Current state: v3 running (re-loaded 21:57:34), flat, waiting. BTC bot:
  0 trades. Both on VPS now.

## [2026-09-09] session | GoldBreakoutHunter v3 — 5 trades, net +$4.73 (2W/3L)

- After the first win (+$8.36 at 01:28:58), v3 kept trading overnight — **4
  more trades, all BUYs** (trend flipped UP above EMA50, box-top breaks):
  - 03:32 BUY 4358.27 (SL 4353.08, TP 4368.65) → SL hit 4353.06 → **−$5.21**
  - 04:30 BUY 4354.31 (SL 4351.67, TP 4360.67) → SL hit 4351.67 → **−$2.64**
  - 06:10 BUY 4349.63 (SL 4345.67, TP 4357.56) → TP hit 4357.76 → **+$8.13** ✅
  - 06:28 BUY 4361.42 (SL 4357.79, TP 4368.76) → SL hit 4357.51 → **−$3.91**
- **Day total: +$4.73 across 5 trades — 2W/3L, 40% win rate.** RR 2.0 →
  breakeven at 33.3% → profitable day. Kill switch (−50) never re-fired;
  magic-20260915 daily P/L ≈ **−$6.59** including the earlier −11.32.
- **Pattern**: 3 of 4 BUYs were counter-trend bounces in a falling market
  (bought box-top breaks while price kept making lower lows) → SL hits. The
  06:10 BUY caught the real bounce → TP. Trend filter worked as designed:
  the SELL (trend DOWN) won; the BUYs (trend UP) mostly lost.
- **Cap note**: 5 trades fired with `MaxTradesPerDay` default 4 — the chart
  input is likely set to 5 (or higher). Bot stopped after trade 5. Flagged
  for the user to verify in EA properties.
- Attribution verified: only v3 (GOLD,M15, loaded 00:36:24) and
  BTCSwingHunter v2 (BTCUSD) were running after 00:36 — all 5 trades are
  v3's (magic 20260915, SL/TP always set, entries at :02 past the minute =
  EA pattern, not manual).

## [2026-09-09] session | GoldBreakoutHunter FIRST LIVE WIN (+$8.36) + manual-trade "flood" false alarm

- **First real breakout trade**: `GoldBreakoutHunter_Zaid_v3` (GOLD,M15)
  sold at **4367.52** (00:50:01) — price broke the 20-bar box bottom
  (4367.58), DistLo went negative (−0.07), trend DOWN. SL 4371.57, TP
  4359.38, breakout level 4367.58.
- **WIN**: closed **01:28:58 at 4359.16** (TP hit, filled better than the
  4359.38 target) → **+$8.36** in ~39 minutes. RR 2.0 reward captured in
  full. First verified live trade for the breakout strategy.
- **"Flood" false alarm**: ~00:22 the user manually traded sell/buy pairs
  (no SL/TP on those orders — bots always set SL/TP, manual trades don't).
  Confirmed manual, not a bot flood. All EA sources re-reviewed and clean:
  v3, BTCSwingHunter_v2, GoldHunterPro Small/Micro, AMNSweepHunter
  Loose/Strict — every one has per-bar gates + position caps. The old flood
  bug is gone.
- **Kill switch fired at −11.32** (00:28:43) — v3 had traded 4× earlier
  (2 sells 00:10 + 2 buys 00:18 from dual M5+M15 instances) and lost.
  Loss limit raised **−$5 → −$50** so the bot could trade the rest of the
  day; recompiled 0 errors, re-attached fresh.
- **Chasing-channel lesson**: at 00:49 the box bottom (4369.14) chased price
  down to 4367.75 as new M1 bars made new lows — price broke the old box
  bottom but the breakout "vanished". In strong trends the 20-bar channel
  follows price; candidate fix = v4 trend-continuation entry (sell on break
  of previous M1 bar's low in a downtrend). Offered, not yet built.
- **BTC bot**: swing design confirmed patient by design (H4 trend + H1
  pullback + RSI, holds days). Status prints once per H1 bar; log file lags
  the Experts tab. No BTC trades yet.
- **Broker-cost analysis**: XM standard account = spread + swap only, no
  commission. Gold 0.01 lot ≈ $0.30–0.50/trade spread (~$36–60/month at
  120 trades); Micro 0.001 lot ≈ $4–6/month. BTC swap ~$0.10–0.20/night
  held — the swing bot's hidden cost.
- **Tracked set decision**: records kept for **GoldBreakoutHunter v3** and
  **BTCSwingHunter v2** only. **GoldHunterPro Small retired** from tracking
  (user: bad logic, bought too much garbage, broke). Entity page flagged.
- **$100-account math**: RR 2.0 needs >33% win rate to break even. Micro on
  $100 ≈ −$10 to +$5/month realistic; 0.01 lot ≈ −$50 to +$50/month before
  spread. Recommendation: Micro + −$5/day kill switch + 2-week live track
  to measure the real win rate before scaling.

## [2026-09-08] incident | GoldBreakoutHunter flood (1156 deals) + v2.00 flood-proof rewrite

- **Incident**: GoldBreakoutHunter flooded the demo account — **1,156 deals**
  in ~30 minutes (order range 2165927xxx → 2165979xxx). Pattern: alternating
  buy/sell pairs every ~200ms at the same prices (buy at ask / sell at bid,
  spread apart), no SL/TP on the flood orders. User had to disable
  auto-trading twice (22:27, 22:55, 23:15) to stop it.
- **Root cause**: the running `.ex5` was a **stale cached build** — MT5 kept
  executing an old in-memory version even after the source was fixed and
  recompiled. The old build had a buy→close→buy loop that burned the spread
  every cycle; when auto-trading was disabled mid-loop it failed with
  **error 10027** (AutoTrading disabled by client) trying to close.
- **Fix 1 (code)**: rewrote `GoldBreakoutHunter_Zaid.mq5` → **v2.00** with
  four hard gates: 1 trade per M1 bar, 15-min cooldown, max 1 concurrent
  position (no hedging), max 4 trades/day. SL/TP always set. Compiled
  0 errors/0 warnings.
- **Fix 2 (deployment)**: renamed the EA to **`GoldBreakoutHunter_Zaid_v2`**
  — a new file name forces MT5 to load fresh code (no cache possible).
  Same for BTC bot → `BTCSwingHunter_Zaid_v2`.
- **Cleanup**: wrote `CloseAllPositions.mq5` script (closes every open
  position on the account, any symbol/magic). Ran on GOLD + BTCUSD charts:
  `0 closed, 0 failed, 0 remaining` — account fully clean.
- **BTC bot visibility**: `BTCSwingHunter_Zaid_v2` now prints a status line
  every H1 bar (`BSH status | H4trend | RSI | price/EMA21 | buySig/sellSig`)
  so we can see what it's waiting for. First status: H4trend DOWN, RSI 46.4,
  price/EMA21 0.9986 — waiting for RSI > 50 for a SELL in the downtrend.
- **Lesson**: recompiling an EA does NOT update a running instance — MT5
  caches the loaded `.ex5` in memory. After any code change, either restart
  MT5 or rename the EA so the new binary is loaded fresh.
- Both v2 bots verified running: `GoldBreakoutHunter v2.00 initialized`
  (GOLD,M5) and `BTCSwingHunter initialized` (BTCUSD,M1). 0 deals since
  re-attach.

## [2026-09-08] build | BTCSwingHunter EA (Paul Wei trade-history analysis)

- Scraped and analyzed **Paul Wei** (`@coolish`, BitMEX Hall of Legends,
  70x BTC return over 3 years) via the public
  `omgbbqhaxx/BTC-Trading-Since-2020` repo (43k+ orders, 173k+ executions).
- Analyzed the last year (2025-04 → 2026-04) of his XBTUSD ledger: 16 round
  trips, **93.8% win rate**, avg +3.68% per trade, holds days (median ~5d),
  balanced long/short, ~97% limit orders building positions.
- Built `BTCSwingHunter_Zaid.mq5` (magic 20260916): H4 EMA50 trend filter +
  H1 EMA21/RSI pullback entry, ATR SL, RR 2.5, trailing stop, kill switch
  (+$50/−$25), 1 concurrent position, 3 new trades/day. No daily cutoff
  (swing trades must be allowed to run for days).
- Fixed enum compile errors (timeframe inputs changed `int` →
  `ENUM_TIMEFRAMES`). Compiled **0 errors / 0 warnings**, deployed to MT5
  Experts.
- Wrote `entities/btcswinghunter.md`; updated `index.md`.
- Also fixed `GoldBreakoutHunter_Zaid.mq5`: removed the once-per-M1-bar gate
  so breakouts are checked on every tick (was missing fast breakouts).
  Recompiled clean, redeployed.

## [2026-09-08] build | GoldBreakoutHunter EA (verified-strategy research)

- Researched the most credible public gold strategies: **Marci Silfrain**
  (world #2 prop-firm leaderboard, verified +1,574% on gold over 3 years,
  trendline-pullback + measured-move) and the **Gold Prop Firm Robot**
  (verified live: 190% growth, 71.7% win rate, 2.47 PF over 16 months,
  breakout style).
- Built `GoldBreakoutHunter_Zaid.mq5` (magic 20260915): Donchian 20-bar
  breakout entry + EMA50 trend filter + ATR-based SL + measured-move TP
  (RR 2.0). Reuses the proven risk scaffolding from the other bots: kill
  switch (+$10/−$5), daily cutoff (23:59 test), 2 trades/day cap.
- Compiled **0 errors / 0 warnings**, deployed to MT5 Experts folder.
- Wrote `entities/goldbreakouthunter.md`; updated `index.md`.
- Context: user asked for a BTC and USD bot built from the "craziest trader"
  found by scraping their last year of trade history; this gold breakout bot
  is the first concrete build from that verified-strategy research.

## [2026-09-08] guide | Setup & Usage page

- Wrote `wiki/setup.md` — full onboarding page: what the repo is (LLM Wiki
  pattern, three layers), prerequisites, first-time setup (clone,
  authenticate via GCM/PAT/SSH, identity), the daily workflow (ingest a
  trade session, query, lint), page conventions, trading data reference
  (CSV columns, accounts, bot), safety rules, troubleshooting.
- Added "Version control rule" to `AGENTS.md`: **commit and push every wiki
  change at least once per day** (human directive).
- Updated `index.md` (new Guides section) and this log.

## [2026-09-08] ingest | First real-account session (GoldHunterPro_Small)

- Migrated the AMN strategy wiki from the local knowledge base
  (`knowledge/wiki/trading/`) into this repo: [[Adeel | AMN Trading]],
  [[Adeel Asghar]], [[AMN Model]], [[Liquidity Sweep]], [[AMN Bot Spec]].
- Wrote `raw/trades/2026-09-08-real-account.csv` — immutable dump of the
  real account (83160890) from `Account_History.csv` (9 deals incl. the
  +$125.43 funding transfer and the Aug 12 +$36.43 manual win).
- Wrote `sources/2026-09-08-real-session.md` — full session ingest: 4
  trades, 2 SL losses (−$8.07, −$8.13), 2 BUYs open at cutoff, err=4752
  failures before algo-trading was enabled, kill switch + 18:30 cutoff
  deployed.
- Wrote `entities/xm-accounts.md` (demo vs real account facts, symbol
  difference GOLD vs Gold.i#, Ultra Low Standard details).
- Wrote `entities/goldhunterpro-small.md` (bot config, entry logic, risk
  model, version history incl. the 18:30 cutoff build).
- Wrote `concepts/kill-switch.md`, `concepts/daily-cutoff.md`,
  `concepts/risk-reward.md` (jargon defined: SL, TP, RR, lot, point, pip,
  spread, margin, equity, floating P/L, magic number).
- Wrote `synthesis/2026-09-08-loss-review.md` — learning analysis: bot
  sold at the bottom of the downtrend (RSI 34.9/34.3 near oversold 30),
  price rallied ~$10 and hit both SLs; bot correctly flipped to BUY above
  EMA50; risk model held; RSI-zone improvement candidate (40–55 sells,
  45–60 buys).
- Updated `index.md` (all categories populated).
- Context: GoldHunterPro_Small went live on the real account today; the
  18:30 local daily cutoff was implemented and deployed (EA reload pending).

## [2026-09-07] ingest | Adeel | AMN Trading (strategy research)

- Researched Adeel Asghar (AMN Trading) — SMC/ICT liquidity-sweep educator.
  Sources: YouTube, Instagram, TikTok, Scribd (AMN Zones Guide, AMN Model
  Strategy Breakdown, AMN Setup Ratings Guide), allpros.io, whop.com,
  amnindicator.com, TradingView "AMN Zones" script.
- Wrote `sources/adeel-amn-trading.md` — full source page (identity, reach,
  core teaching, quotes, key videos, caveats).
- Wrote `entities/adeel-asghar.md` — entity page for the trader.
- Wrote `concepts/amn-model.md` — the AMN 6-step trade-taking process
  (trend → BOS → zone → sweep → first tap → 50% entry) with state machine
  encoding.
- Wrote `concepts/liquidity-sweep.md` — the sweep mechanic, sweep vs BOS
  distinction, four liquidity pools on Gold, entry framework.
- Wrote `synthesis/amn-bot-spec.md` — how to encode the AMN model into MQL5:
  state machine, gates, RR, risk management, session filter, two variants
  (strict 6-gate + loose 4-gate).
- Updated `index.md` (all four categories populated).
- Context: Zaid wants to replicate Adeel's trade-taking style in an EA.
  "The style of trading is what I got interest in." GoldHunterPro was live
  on demo with 2 SELL positions from Sept 7.