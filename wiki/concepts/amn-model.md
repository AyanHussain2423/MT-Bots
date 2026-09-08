---
title: AMN Model
type: concept
tags: [trading, smc, ict, liquidity-sweep, entry-model]
date: 2026-09-07
sources: [sources/adeel-amn-trading]
---

# AMN Model — 6-Step Trade-Taking Process

The AMN Model is the core trade-taking process taught by
[[Adeel Asghar]] (AMN Trading). It is a simplified SMC/ICT
approach that maps cleanly to a state-machine EA because every step is a
hard gate — no ambiguity.

## The 6 steps

### 0. Setup — 2 timeframes
- **HTF (H1 or H4):** trend bias, major structure
- **LTF (M1 or M5):** entry timing, zone detail
- Quote: "You Can Do Anything With Just 2 Timeframes"

### 1. Trend — only trade with the current direction
- Uptrend → demand zones only. Downtrend → supply zones only.
- Counter-trend setups drastically lower edge.
- Implementation: EMA alignment or swing structure on HTF.

### 2. Break of Structure (BOS) — wait for a clean structural break
- Price must break a key swing high (uptrend continuation) or swing low
  (downtrend continuation) to confirm momentum.
- No BOS → no trade. This is the patience gate.

### 3. Zone — draw the zone from the last opposing move
- The zone is the **last candle range** (swing low → swing high, or vice
  versa) that *caused* the BOS. This is where institutional orders likely
  sat. This is also called the "order block" in ICT terminology.
- Zone = the high-to-low range of the last opposing swing before the break.

### 4. Liquidity sweep — wait for price to sweep the pool
- Before price reaches the zone, institutions sweep liquidity: price pushes
  beyond a visible pool of stops (previous high/low, equal highs/lows,
  session high/low), triggers them, then reverses.
- **Sweep = wick beyond a level + close back inside.** A close beyond = BOS
  (continuation, not a sweep).
- This is the hardest gate to automate but the most important.

### 5. First tap — zone must stay unmitigated (fresh)
- The first tap into the zone should react quickly, leaving most of the zone
  **unmitigated** (≥50% fresh).
- Deep tap / full mitigation = zone consumed = edge gone = no trade.
- "Shallow tap keeps the zone fresh."

### 6. Entry — execute at 50% of the zone
- Entry = 50% of the zone range, in the trend direction.
- SL = beyond the sweep wick's extreme + ATR buffer (0.3–0.5 ATR).
- TP = opposite liquidity pool / next structural level.
- Expected RR: 3:1 to 5:1 on clean setups.

## State machine encoding

```
WAITING_FOR_BOS → BOS_CONFIRMED (zone drawn)
  → WAITING_FOR_SWEEP → SWEPT (wick beyond pool, close back inside)
  → FIRST_TAP (zone ≥50% unmitigated)
  → ENTER (market order at 50% of zone)
  → SL beyond sweep wick + ATR buffer
  → TP opposite pool / next structure
```

If any gate fails (zone mitigated, price runs away, no sweep), the state
resets and the EA waits for the next setup.

## Why this works as a bot

- Every step is a discrete boolean gate → no subjective judgment needed.
- The EA literally *cannot* enter until all gates pass → replicates Adeel's
  patience.
- Few trades, high probability, good RR — the whole point.

See [[Liquidity Sweep]] for the sweep mechanic in detail.
See [[AMN Bot Spec]] for the bot encoding.