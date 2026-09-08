# Trader Knowledge Wiki Log

Append-only, chronological record of everything that happens in the trading
wiki. Newest entries go at the top.

---

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