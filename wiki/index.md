# Trader Knowledge Wiki

Persistent, compounding knowledge base for Zaid's MT5/XM gold trading bots
and strategy research. Every trade is ingested and linted.

## Categories

- **Sources** — one page per ingested source (trading session, document, video)
- **Entities** — accounts, bots, people, brokers, systems
- **Concepts** — ideas, patterns, topics (with all trader jargon defined)
- **Synthesis** — answered questions / analyses filed back into the wiki

---

## Guides

- [[Setup & Usage]] — how to set up this repo (clone, authenticate, identity)
  and use it (ingest a trade session, query, lint). Start here if you are
  new to the repo.

## Sources

- [[2026-09-08 Real Session]] — first real-account session of
  GoldHunterPro_Small on XM (83160890): 4 trades, 2 SL losses (−$16.20),
  2 BUYs open at cutoff, kill-switch + 18:30 cutoff deployed.
- [[2026-09-17 Bot Week Session]] — the 09-12 → 09-17 week for all three
  bots (gold −$8.79, BTC breakout +$5.55, BTC swing −$8.02 first trades):
  every trade, the 09-16 21:00 UTC ~132-pt gold crash (M15 evidence), and
  the lessons that became v3.26.
- [[Adeel | AMN Trading]] — Adeel Asghar: SMC/ICT liquidity-sweep
  day-trader. YouTube, Instagram, TikTok, mentorship ($99/mo), 6-Tap
  indicator, AMN Zones Guide. The strategy we are encoding into a bot.

## Entities

- [[XM Accounts]] — the three XM accounts: demo 334640751 (MT5 9, "GOLD"),
  real 83160890 (MT5 4, "Gold.i#", Ultra Low Standard), and the bot demo
  169324224 (MT5 2, GOLD/BTCUSD, home of the breakout bots; balance $71.82
  as of 09-17).
- [[GoldHunterPro Small]] — M1 gold scalper (RSI+EMA+ATR, magic 20260910).
  **Retired from tracking 2026-09-09** (bad logic, bought garbage, broke).
  Post-retirement cameo: +$16.02 in 34 seconds (21:57 BUY → TP).
- [[GoldBreakoutHunter]] — demo EA built from verified strategies (Marci
  Silfrain + Gold Prop Firm Robot): Donchian breakout + EMA50 trend filter,
  magic 20260915, **v3.26** (ATR-based SL/TP, trend-continuation entries
  with fresh guard, stop-out penalty gate, **03-04 UTC hour window**,
  volatility spike filter, daily cap refreshed from history every minute).
  **2026-09-09: 7 trades, net +$3.99 (3W/4L)**.
  **2026-09-11: 7 trades, net −$5.37 (2W/5L) → balance $94.63** — the 4/day
  cap bug (counter reset on re-attach) cost −$15.76; fixed in v3.21, made
  re-attach-proof in v3.24.
  **2026-09-12→17: 7 trades, net −$8.79 (2W/5L)** — v3.25 regressed the
  hour window to all-day; every trade fired outside 03-04 UTC. Fixed in
  v3.26 (see [[2026-09-17 Loss Causes]]).
  Running on VPS (London LD6 04).
- [[BTCBreakoutHunter]] — demo BTC breakout EA (magic 20260917), port of
  gold v3.14+ to BTCUSD: M5 Donchian channel, M15 EMA50 trend, fixed
  $5/$10, v1.06 with stop-out penalty gate + daily counter restored and
  refreshed from history.
  **2026-09-11: 3 trades, 1W/2L, net +$0.15** (first trade SELL 77048.45 →
  SL −$5.07).
  **2026-09-12→17: 4 trades, 2W/2L, net +$5.55** — the only profitable bot
  of the week.
- [[BTCSwingHunter]] — demo BTC/USD swing EA built from Paul Wei's public
  BitMEX trade history (93.8% win rate, holds days): H4 trend + H1 pullback,
  magic 20260916, v2.00 with status prints. **First trades 2026-09-17**
  (2 SELLs: 1 SL'd −$8.02, 1 open) — the ATR SL costs ~$8 per loss.
- [[Adeel Asghar]] — the trader behind AMN Trading.

## Concepts

- [[Kill Switch]] — account-wide daily P/L guard that closes everything and
  stops the day: +$100/−$40 (real-account scalper), +$32/−$50 (breakout
  bots, user directive).
- [[Daily Cutoff]] — hard stop-trading time (18:30 local): close all, delete
  pending, no risk after hours.
- [[Risk Reward]] — SL/TP sizing, RR ratio, lot sizing, points vs pips on
  Gold.
- [[Stop-Out Penalty]] — the signal-based re-entry gate that replaced the
  time cooldown: after an SL, same-direction entries need a new channel
  extreme; after a TP, no restriction.
- [[AMN Model]] — the AMN 6-step trade-taking process (trend → BOS → zone →
  liquidity sweep → first tap → 50% entry).
- [[Liquidity Sweep]] — the sweep mechanic and how it differs from a break
  of structure.

## Synthesis

- [[2026-09-08 Loss Review]] — why the two SELLs lost (bot sold at the
  bottom of the downtrend, RSI near oversold), what held (risk model,
  kill switch), and the RSI-zone improvement candidate.
- [[Entry Quality Retrospective 2026-09-11]] — exact M1 reconstruction of
  all 7 gold trades: every entry was a trend-continuation sell (channel
  break never fired), trend sells entered 27–41 pts below EMA50 at the
  channel low = breakeven at best; cap-bug trades #5/#6/#7 all lost
  (−$15.76); lessons for the next bot.
- [[AMN Bot Spec]] — how to encode the AMN model into an MQL5 EA: state
  machine, gates, RR, and the two variants (strict vs loose) being built.
- [[Hour Window Analysis 2026-09-12]] — 21-month hour-by-hour backtest:
  the volatility filter is dead; **03-04 UTC is the only window positive in
  both 2025 and 2026** (+0.81/trade, 16/21 positive months) → gold v3.24
  hour window.
- [[2026-09-17 Loss Causes]] — why the 09-12→09-17 trades lost (hour window
  off, trend entries below breakeven, $5 SL inside the noise, crash
  aftermath) and the four v3.26 fixes.