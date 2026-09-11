---
title: Stop-Out Penalty
type: concept
tags: [trading, risk, re-entry, gate, mql5]
date: 2026-09-11
sources: [log-2026-09-11, goldbreakouthunter-entity]
---

# Stop-Out Penalty

A **signal-based re-entry gate** that replaced the time cooldown in
[[GoldBreakoutHunter]] (v3.20) and [[BTCBreakoutHunter]] (v1.04).

## The problem with a time cooldown

The old rule was: after any trade, wait N minutes before the next one. It
was a **clock**, not a market signal:

- **Blind time** — the bot waited on a timer while the market moved. After
  an SL it looked dead for 15 minutes (and the status print sat behind the
  gate, so it printed nothing — v3.19 fixed that).
- **Punished winners** — after a TP the trend is *confirmed*; re-entering
  quickly is how trend-following catches big moves. The cooldown blocked
  that too.
- **Arbitrary** — the market doesn't care that we traded 15 minutes ago.

## The fix: a flag + a proof

Track how the last position closed (via `HistorySelect` + `DEAL_REASON` on
our magic number):

- **After an SL** (`DEAL_REASON_SL`): set `g_afterSL = true` and store the
  channel extreme (low for sells / high for buys) at detection. Same-
  direction entries are then blocked until the channel makes a **NEW
  extreme** — the market must prove the bounce failed. No time blindness:
  the bot waits as long as needed, but the moment the low breaks, it's
  free. A fresh **opposite** signal is never blocked.
- **After a TP** (`DEAL_REASON_TP`): `g_afterSL = false` — no restriction.
  Re-enter on the next signal (bar gate + daily limit + kill switch still
  apply).
- Kill-switch and manual closes (reason ≠ SL/TP) do **not** trigger the
  penalty.

## Why it works

The failure mode it prevents: selling into support, getting bounced, and
selling into the same support again (repeated SL hits in one zone). The
penalty forces the market to make a new low before the bot sells again —
if it can't break the low, we shouldn't be selling.

Validated on 2026-09-11: trade #1 SELL → SL (channel low ~4330.04). Price
made a new low below it before 00:31 → the gate passed → trade #2
(+$10.18) still fired. The gate blocks only repeated entries into the same
zone, not valid continuations.

## Jargon

- **Stop-out** — a position closed by its stop loss (SL).
- **Whipsaw** — getting stopped out repeatedly as price chops back and
  forth; the pattern this gate prevents.
- **Channel extreme** — the Donchian channel high (for buys) or low (for
  sells) over the channel period.
- **Magic number** — numeric tag on orders so the EA only manages its own
  trades.
- **SL / TP** — stop loss / take profit (see [[Risk Reward]]).

## Related

- [[GoldBreakoutHunter]] — v3.20 implementation.
- [[BTCBreakoutHunter]] — v1.04 implementation.
- [[Risk Reward]] — the $5/$10 sizing the gate protects.