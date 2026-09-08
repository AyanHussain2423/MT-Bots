---
title: Liquidity Sweep
type: concept
tags: [trading, smc, ict, liquidity, stop-hunt, sweep]
date: 2026-09-07
sources: [sources/adeel-amn-trading]
---

# Liquidity Sweep — The Mechanic

A liquidity sweep (also called a "stop hunt," "stop run," or "liquidity
grab") is the core pattern in the [[AMN Model]]. It is the
moment institutions trigger clustered stop-loss orders to access the
liquidity they need to fill large positions.

## What it looks like

- Price pushes **beyond** a visible high or low (where retail stops cluster),
  triggers them, then **immediately reverses**.
- Visually: a long wick beyond the level + candle closes back inside.

## Sweep vs Break of Structure (the single most important distinction)

| Pattern | What to expect |
|---|---|
| **Wick beyond, close inside** | Liquidity sweep → reversal |
| **Body close beyond** | Break of Structure → continuation |

Getting this wrong flips a winner into a losing reversal trade.

## The four highest-probability liquidity pools on Gold

1. **Equal Highs / Equal Lows (EQH/EQL):** two+ swings at the same level;
   retail sees double tops/bottoms, institutions see a stop shelf.
2. **Previous Day High / Low (PDH/PDL):** the most reliable intraday targets;
   Gold sweeps PDH or PDL on ~70% of sessions.
3. **Asia Session High/Low:** range built between 22:00–07:00 GMT; London
   almost always sweeps one side before the real move.
4. **Weekly High/Low:** higher timeframe magnet, usually taken mid-week.

## Why institutions do it

- Institutions cannot fill a $200M position at a single price without
  massive slippage.
- They need *opposing flow* — someone willing to take the other side.
- Stop-loss clusters provide that flow in concentrated form.
- After triggering the stops, the institution reverses and drives price
  in the intended direction.

## Gold-specific notes

- Gold often **double sweeps** — sweep once, then sweep again deeper before
  reversing. SL must sit above the highest wick + buffer.
- The **Judas Swing** (London open spike through Asia high, long upper wick,
  close back inside Asia range) is a classic sweep that hands the rest of the
  day to short sellers.

## Entry framework after a sweep

1. Wait for wick beyond level + close back inside on LTF (M1/M5).
2. Wait for LTF Change of Character (CHoCH) after the sweep.
3. Enter on retest of the LTF order block or fair value gap at the CHoCH.
4. SL just beyond the sweep wick + 0.3–0.5 ATR buffer.
5. TP: opposite end of the recent consolidation range (3:1 to 5:1 R:R).

## Common mistakes

- Entering on the sweep candle itself → get wicked out. Wait for the
  close back inside + CHoCH.
- Ignoring HTF bias → counter-trend sweeps are continuation, not reversal.
- SL too tight → Gold double-sweeps; add buffer above/below the wick.