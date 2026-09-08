---
title: AMN Bot Spec
type: synthesis
tags: [trading, ea, mql5, amn-model, liquidity-sweep, gold]
date: 2026-09-07
sources: [concepts/amn-model, concepts/liquidity-sweep]
---

# AMN Bot Spec — Encoding the AMN Model into MQL5

## Goal

Replicate the trade-taking style of [[Adeel Asghar]] in an
MQL5 Expert Advisor. The bot must replicate his *patience* — hard gates that
prevent entry until every condition is met — not just the entry trigger.

## Two variants

### Strict (AMNSweepHunter_Strict_Zaid.mq5)
- All 6 gates must pass: trend + BOS + zone + sweep + first-tap + 50%
  freshness check.
- Fewest trades, highest quality. This is the live-account candidate.

### Loose (AMNSweepHunter_Loose_Zaid.mq5)
- Gates 1–4 only: trend + BOS + zone + sweep (no first-tap / 50%
  freshness requirement).
- More trades, slightly lower quality. Useful for demo testing to get
  more data points faster.

## Symbol / timeframe

- Symbol: GOLD (XAUUSD)
- LTF entry: M1 (matches GoldHunterPro's chart slot)
- HTF bias: H1 (2-timeframe model, per Adeel's "You Can Do Anything With
  Just 2 Timeframes")
- TP/SL in points (not pips) — GOLD = 2-digit, so 1 point = $0.01.
  1000 points = $10.

## State machine

```
STATE_WAITING_FOR_BOS
  ↓ (BOS detected on H1)
STATE_BOS_CONFIRMED (zone = last opposing swing range)
  ↓ (liquidity sweep detected on M1: wick beyond prior swing high/low,
     close back inside)
STATE_SWEPT
  ↓ (first tap into zone, zone ≥50% unmitigated — strict only)
STATE_READY_TO_ENTER
  ↓ (market order at 50% of zone)
STATE_IN_TRADE (SL beyond sweep wick + ATR buffer, TP at opposite pool)
  ↓ (TP/SL hit, or zone invalidated)
STATE_WAITING_FOR_BOS (reset)
```

## Gate details

### Gate 1: Trend (H1)
- EMA 50 on H1. Price > EMA50 = bullish bias (demand zones only).
  Price < EMA50 = bearish bias (supply zones only).
- Alternate: swing structure (higher highs / lower lows).

### Gate 2: Break of Structure (H1)
- Detect swing points on H1.
- In bullish trend: price closes above the most recent swing high → BOS.
- In bearish trend: price closes below the most recent swing low → BOS.
- Only the most recent BOS matters; older BOSes are superseded.

### Gate 3: Zone (H1)
- After BOS, draw the zone from the last opposing swing:
  - Bullish BOS: zone = range of the last swing low candle (the down-candle
    that preceded the upward BOS). Zone top = candle open (or high),
    zone bottom = candle low.
  - Bearish BOS: zone = range of the last swing high candle (the up-candle
    that preceded the downward BOS). Zone top = candle high,
    zone bottom = candle low (or open).

### Gate 4: Liquidity Sweep (M1)
- Track key pools on M1: previous swing high/low, session high/low.
- Sweep detected when: candle wick (high or low) goes beyond a pool level,
  but candle closes back inside.
- Sweep must happen *before* or *as* price enters the zone (not after).

### Gate 5: First Tap + 50% Freshness (strict only)
- After sweep, price must tap the zone.
- The tap must leave ≥50% of the zone unmitigated: candle body does not
  close beyond the 50% level of the zone range.
- If body closes through 50% → zone is consumed → reset to WAITING_FOR_BOS.

### Gate 6: Entry
- Market order at 50% of the zone range.
- Direction = trend direction.
- Lot size: input (default 0.01).

## Risk management

### Stop Loss
- Beyond the sweep wick's extreme + ATR(14) buffer (0.3–0.5 ATR).
- This means SL is dynamic per setup — tighter on small sweeps, wider on
  large ones.
- Minimum SL: 2000 points ($20). Maximum SL: 8000 points ($80).

### Take Profit
- Opposite end of the recent consolidation range, OR
- Next structural level (next swing high/low on H1), OR
- 3× the SL distance (minimum 3:1 R:R enforced).
- If R:R < 3:1 after computing TP, skip the trade.

### Breakeven
- Move SL to entry + 50 points ($0.50) after price reaches entry + 1× SL
  distance in profit.

## Session filter
- Only trade during London (07:00–16:00 GMT) and New York (12:30–21:00 GMT)
  sessions — the highest-liquidity windows for Gold.
- Avoid the Asian session (22:00–07:00 GMT) except for marking the session
  high/low as a liquidity pool.

## Trade limits
- Max 2 concurrent positions.
- Max 4 trades per day.
- 1 trade per zone (no re-entering a mitigated zone).

## Logging
- CSV log: `AMN_Sweep_Log.csv` — timestamp, direction, entry, SL, TP,
  sweep level, zone range, R:R at entry, outcome.
- Comment tag on each order for identification.

## Compilation & deployment
- Source: `C:\Users\Supertails PRM\Desktop\Openwork\trading\AMNSweepHunter_Strict_Zaid.mq5`
  and `...Loose_Zaid.mq5`
- Compile via: `Start-Process -FilePath "C:\Program Files\XM Global MT5\metaeditor64.exe" -ArgumentList "/compile:... /include:... /log /conf:""C:\Users\Supertails PRM\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5"" /portable" -Wait`
- After compile, copy .ex5 to `...\MQL5\Experts\` (or compile directly there).
- Deploy to a new M1 chart on GOLD (separate chart from GoldHunterPro).
- Verify Algo Trading is ON.

## Risks & caveats
- Sweep detection on M1 is the hardest gate to automate — wick/boundary
  detection needs careful tuning.
- Zone drawing from "last opposing swing" is subjective; the EA uses a
  simplified swing-point detection (rolling N-candle high/low).
- Double sweeps (Gold sweeps once, then again deeper) may invalidate the
  first sweep signal. The EA resets and waits for a new sweep.
- This is a demo-test first. Do not deploy to live until 50+ trades show
  positive expectancy with verified R:R.