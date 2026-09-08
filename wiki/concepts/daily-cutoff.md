---
title: Daily Cutoff
type: concept
tags: [trading, risk-management, cutoff, schedule]
date: 2026-09-08
sources: [entities/goldhunterpro-small]
---

# Daily Cutoff — No Risk After Hours

A hard time-based rule in [[GoldHunterPro Small]]: **stop trading at 18:30
local time, no risk after that.** The human's rule: "no risk after 6:30 PM."

## How it works

- `CUTOFF_HOUR = 18`, `CUTOFF_MINUTE = 30` (local time, via `TimeLocal()`).
- `CheckDailyCutoff()` runs in `OnTick` after `CheckKillSwitch()`.
- At the cutoff moment the EA:
  1. **Closes all open positions** (both directions).
  2. **Deletes all pending orders.**
  3. Sets `dayStopped` so no new entries happen for the rest of the day.
  4. Prints `DAILY CUTOFF ...` to the Experts log.
- Auto-resets at the server day rollover, like the [[Kill Switch]].

## Why it matters

- Gold keeps moving overnight (US session, rollover, news). A bot left
  running can open trades at 2 AM that the human never sees.
- The cutoff guarantees the account is **flat and safe** every evening —
  the human can sleep without monitoring.
- It complements the kill switch: the kill switch bounds *losses*, the
  cutoff bounds *exposure time*.

## Deployment status

- Implemented 2026-09-08 in `GoldHunterPro_Zaid_Small.mq5`; compiled clean
  (0 errors / 0 warnings); .ex5 (40,396 B) deployed to `MQL5\Experts\`.
- **The running MT5 instance predates the build** — the EA must be reloaded
  (restart MT5, or remove + re-attach on the Gold.i# M1 chart) for the
  cutoff to be active.

## Jargon

- **Pending order** — an order to buy/sell at a future price (e.g. limit,
  stop). The cutoff deletes these too.
- **Flat** — no open positions.
- **TimeLocal()** — MT5 function returning the terminal's local time.