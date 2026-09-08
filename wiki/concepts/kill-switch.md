---
title: Kill Switch
type: concept
tags: [trading, risk-management, kill-switch, daily-pl]
date: 2026-09-08
sources: [entities/goldhunterpro-small]
---

# Kill Switch — Account-Wide Daily P/L Guard

A hard risk guard in [[GoldHunterPro Small]] that caps the damage (or locks
in the win) of a single trading day. It is **account-wide**: it sums the
daily P/L across *all* positions (closed + floating), not per trade.

## How it works

- `DAILY_PROFIT_TARGET = 100.0` — if the day's P/L reaches **+$100**, the
  EA closes everything and stops trading for the day.
- `DAILY_LOSS_LIMIT = 40.0` — if the day's P/L reaches **−$40**, the EA
  closes everything and stops trading for the day.
- After triggering, the EA sets a `dayStopped` flag and does not trade again
  until the server day rolls over (auto-reset).

## Why it matters

- A 37.5%-win-rate strategy (see [[2026-09-08 Loss Review]]) can easily
  produce 2–3 losses in a row. The kill switch makes sure a bad streak
  costs at most $40, not the account.
- It also prevents "revenge trading" — the EA physically cannot keep
  trading after the bound is hit.

## Observed behavior

- 2026-09-08 (first live day): day bottomed around −$16.20 realized; the
  −$40 bound was never approached, so the kill switch **correctly did not
  fire**. A kill switch that fires every day is misconfigured; one that
  never fires on a losing day is doing its job.

## Jargon

- **Daily P/L** — profit/loss for the current trading day (closed + floating).
- **Floating P/L** — unrealized P/L on open positions.
- **dayStopped flag** — in-memory state that blocks new entries for the day.