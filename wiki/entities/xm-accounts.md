---
title: XM Accounts
type: entity
tags: [trading, xm, broker, accounts, gold]
date: 2026-09-08
sources: [raw/trades/2026-09-08-real-account.csv]
---

# XM Accounts

Two XM accounts are in play: a demo account for testing and the real
account for live trading. They run on **different servers with different
symbol names** — a recurring source of confusion.

## Real account (live)

- **Login:** 83160890
- **Server:** XMGlobal-MT5 4
- **Type:** Hedge, XM Global Limited
- **Account type:** **Ultra Low Standard**
  - Tighter spreads (GOLD typical ~1.6 pips vs ~3.6 on Standard)
  - No commission
  - 1 lot = 100,000 units
  - 6 base currencies
  - No deposit bonuses
- **Symbol for gold:** **Gold.i#** (the demo's "GOLD" chart stays black here)
- **Balance:** $145.66 (after 2026-09-08 session; see
  [[2026-09-08 Real Session]])
- **Funding:** +$125.43 transfer from 34259555 (2026.07.12); +$36.43 manual
  GOLD.i# win (2026.08.12)

## Demo account (testing)

- **Login:** 334640751
- **Server:** XMGlobal-MT5 9
- **Account type:** Standard (wider spreads, no commission)
- **Symbol for gold:** **GOLD**
- Same contract size as real → same risk math carries over (0.01 lot = 1 oz).

## Key facts

- **Window title format:** `83160890 - XMGlobal-MT5 4 - Hedge - XM Global
  Limited - [Gold.i#,M1]` — a quick way to verify which account/chart is
  active.
- **History export:** `HistoryDump_Zaid` script (drag onto a chart) writes
  `Account_History.csv` to `MQL5\Files\`.
- **Server time** is GMT+2/+3 (DST-dependent); local (Asia/Kolkata) is
  server + 2.5h in summer. Trade times in dumps are server time.

## Jargon

- **Hedge account** — positions can be opened in both directions
  simultaneously (no netting).
- **Lot** — contract size unit; 1.00 lot = 100,000 units of base currency.
- **Pip / point** — on GOLD (2-digit quote), 1 point = $0.01; 1000 points =
  $10. "Pip" is loosely used for points on gold.
- **Spread** — bid/ask difference; the cost of entering a trade.
- **Margin** — collateral required to hold a position.