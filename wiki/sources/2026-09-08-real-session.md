---
title: 2026-09-08 Real Session
type: source
tags: [trading, gold, real-account, goldhunterpro, session]
date: 2026-09-08
sources: [raw/trades/2026-09-08-real-account.csv]
---

# 2026-09-08 Real Session — First Live Day of GoldHunterPro_Small

First session of [[GoldHunterPro Small]] on the real account
([[XM Accounts]]: 83160890 / XMGlobal-MT5 4). The EA was attached to the
**Gold.i# M1** chart (the real server's symbol — the demo's "GOLD" chart
stays black on this server).

## What happened (local times, Asia/Kolkata)

| Time | Event |
|---|---|
| 15:37 | MT5 relaunched (process had been closed); EA re-attached to Gold.i# M1 |
| 16:06–16:07 | Two SELL attempts fail with `err=4752` ("auto trading disabled by client") — algo trading was still OFF |
| 16:07:23 | Algo trading enabled |
| 16:08 | SELL 4395.53 (SL 4403.53 / TP 4379.53) |
| 16:09 | SELL 4395.36 (SL 4403.36 / TP 4379.36) |
| 17:03 | Both SELLs stopped out (SL hit) → **−$8.07, −$8.13** |
| 17:03 | Bot flips to BUY mode (price above EMA50): BUY 4403.49 (SL 4395.49 / TP 4419.49, RSI 63.4) |
| 17:04 | BUY 4404.92 (SL 4396.92 / TP 4420.92, RSI 66.8) |
| 17:10 | History dump: Balance **$145.66**, Equity **$148.51**, floating **+$2.85** |
| 18:30 | Daily cutoff armed (EA reload pending at time of writing) |

## Trades (all magic 20260910, 0.01 lot, GOLD.i#)

| # | Type | Entry | SL | TP | Exit | Result |
|---|---|---|---|---|---|---|
| 1 | SELL | 4395.53 | 4403.53 | 4379.53 | SL 4403.58 | **−$8.07** |
| 2 | SELL | 4395.36 | 4403.36 | 4379.36 | SL 4403.49 | **−$8.13** |
| 3 | BUY | 4403.49 | 4395.49 | 4419.49 | open at cutoff | floating |
| 4 | BUY | 4404.92 | 4396.92 | 4420.92 | open at cutoff | floating |

**Realized: −$16.20.** Net daily incl. floating ≈ **−$13.35** at last dump.

## Account context

- Balance math: +$125.43 (transfer from 34259555, 2026.07.12) + $36.43
  (Aug 12 manual GOLD.i# win) − $16.20 = **$145.66**.
- Kill switch ([[Kill Switch]]: +$100 / −$40) correctly **did not fire** —
  the day never approached either bound.

## Bot behavior notes

- The two SELLs were opened at the **bottom of the downtrend** (RSI 34.9 /
  34.3, near the oversold 30 line). Price then rallied ~$10 (4395 → 4405),
  stopping both out. See [[2026-09-08 Loss Review]].
- After price broke above EMA50, the bot correctly flipped to BUY mode and
  opened two longs with RSI 63.4 / 66.8 (inside the 45–70 buy band).
- No bot bugs observed. The only errors were the two `err=4752` failures
  caused by algo trading being off — operator state, not code.

## Deployed changes this session

- **18:30 daily cutoff** added to `GoldHunterPro_Zaid_Small.mq5`
  (`CUTOFF_HOUR 18`, `CUTOFF_MINUTE 30`): at 18:30 local the EA closes all
  positions, deletes pending orders, and stops for the day. Compiled clean
  (0 errors / 0 warnings), .ex5 40,396 B deployed to Experts.
  **EA reload (restart MT5 or re-attach) still pending** — the running
  instance predates the cutoff build.

## Jargon used in this session

- **SL / TP** — stop loss / take profit (see [[Risk Reward]]).
- **err=4752** — MT5 error "auto trading disabled by client".
- **Magic number** — order tag (20260910) used to identify the EA's trades.
- **Floating P/L** — unrealized profit/loss on open positions.
- **Equity** — balance + floating P/L.
- **Spread** — difference between bid and ask (see [[XM Accounts]]).
- **RSI** — Relative Strength Index (14), oversold < 30, overbought > 70.
- **EMA50** — 50-period exponential moving average, the trend filter.