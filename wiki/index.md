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
- [[Adeel | AMN Trading]] — Adeel Asghar: SMC/ICT liquidity-sweep
  day-trader. YouTube, Instagram, TikTok, mentorship ($99/mo), 6-Tap
  indicator, AMN Zones Guide. The strategy we are encoding into a bot.

## Entities

- [[XM Accounts]] — the two XM accounts: demo 334640751 (MT5 9, "GOLD")
  and real 83160890 (MT5 4, "Gold.i#", Ultra Low Standard).
- [[GoldHunterPro Small]] — M1 gold scalper (RSI+EMA+ATR, magic 20260910).
  **Retired from tracking 2026-09-09** (bad logic, bought garbage, broke).
- [[GoldBreakoutHunter]] — demo EA built from verified strategies (Marci
  Silfrain + Gold Prop Firm Robot): Donchian breakout + EMA50 trend filter,
  magic 20260915, v3.00 flood-proof (1 trade/M1 bar, 15-min cooldown, max 1
  position, 4 trades/day). **2026-09-09: 5 trades, net +$4.73 (2W/3L, 40%
  win rate)** — first win +$8.36 (SELL 4367.52 → TP 4359.16), then 4 BUYs
  (3 SL hits, 1 TP hit +$8.13).
- [[BTCSwingHunter]] — demo BTC/USD swing EA built from Paul Wei's public
  BitMEX trade history (93.8% win rate, holds days): H4 trend + H1 pullback,
  magic 20260916, v2.00 with status prints. 0 trades so far (patient by
  design).
- [[Adeel Asghar]] — the trader behind AMN Trading.

## Concepts

- [[Kill Switch]] — account-wide daily P/L guard (+$100 / −$40) that closes
  everything and stops the day.
- [[Daily Cutoff]] — hard stop-trading time (18:30 local): close all, delete
  pending, no risk after hours.
- [[Risk Reward]] — SL/TP sizing, RR ratio, lot sizing, points vs pips on
  Gold.
- [[AMN Model]] — the AMN 6-step trade-taking process (trend → BOS → zone →
  liquidity sweep → first tap → 50% entry).
- [[Liquidity Sweep]] — the sweep mechanic and how it differs from a break
  of structure.

## Synthesis

- [[2026-09-08 Loss Review]] — why the two SELLs lost (bot sold at the
  bottom of the downtrend, RSI near oversold), what held (risk model,
  kill switch), and the RSI-zone improvement candidate.
- [[AMN Bot Spec]] — how to encode the AMN model into an MQL5 EA: state
  machine, gates, RR, and the two variants (strict vs loose) being built.