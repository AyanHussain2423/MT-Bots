---
title: Strategy Search Batch 1 — 7 Frozen Candidate Configs (pre-registered)
type: synthesis
tags: [quant, strategy-search, precommit, walk-forward, batch, OOS]
date: 2026-09-19
sources:
  - https://www.mql5.com/en/market/product/191118   (UT Bot M15, public Pine logic)
  - https://www.mql5.com/en/blogs/post/767519        (session range breakout blog)
  - https://ctrader.com/products/5239                 (Xaulgnition long-only momentum)
  - https://github.com/Rithick574/XAUUSD-bot-forex    (EMA cross + ADX)
  - https://www.mql5.com/en/market/product/181238     (BB Return mean reversion)
  - https://github.com/rchoosak/backtrader-pullback-window-xauusd (pullback-window)
  - https://github.com/vaughanf1/GoldQuant            (liquidity sweep V1)
  - scripts/layer3_walkforward.py
---

# Strategy Search Batch 1 — 7 Frozen Candidate Configs (FROZEN 2026-09-19)

> [!important] Honor contract
> All 7 configs below are frozen **BEFORE any of their OOS numbers exist** —
> the same discipline Layers 3–5 imposed. This is a **pre-registered batch
> search** (user directive 2026-09-19: "go through github / websites, make
> it, test, find one — keep finding"). Every config is derived ONLY from the
> cited public source's documented logic. **No parameter here was chosen
> after any run on our data, and none may be tuned after results.** Each
> candidate is a distinct strategy family — not parameter variations of one
> idea. It changes only with the human.

## Contract (same guardrail as every layer)

- All candidates run on the **same frozen 744,518-bar M1 bid history**
  (`raw/history/xauusd-m1-bid-2025-01-01-2026-09-11T18-20.csv`), aggregated
  M1→M15 with the frozen engine's own `aggregate()`; spread cost **0.30 USD**
  deducted per trade; SL/TP resolved forward on closed bars only (no
  lookahead, no open-trade credit).
- **Verdict rule**: a candidate is **GO** only if OOS `n >= 30` trades AND
  OOS expectancy `> 0` AND `> the Layer-3 baseline (−4.42)`. Everything else
  is **NO-GO** → stay 0.01 lots.
- **Multiple-testing honesty**: 7 pre-registered trials inflate the chance
  of a lucky GO. If any candidate passes, it is reported WITH that caveat
  and must survive a split-sample robustness check (first half vs second
  half of OOS) before being called real.
- One run per candidate. No "add filters until it improves".

## Candidate 1 — UT Bot ATR trailing stop (trend-following, always-in-market)

Source: public Pine "UT Bot Alerts" (Yo_adriiiiaan / HPotter), MT5 validation
writeup (mql5.com product 191118). The writeup's own honest findings: M15 is
the robust plateau (PF 1.82, +16.06/trade, 150 trades over 7.5 months);
M1 loses; the edge lives in the **trailing stop**, not fixed TP.

- Timeframe M15. Wilder ATR(10) (our `atr_wilder` IS Wilder RMA).
- `KEY_VALUE = 4.5`, `ATR_PERIOD = 10` (centre of the documented robust
  plateau 3.0–6.0 × 5–28).
- Trailing stop per the public Pine logic (close vs stop, ratchet up/down).
- Position: always in the market; **reverse on the opposite signal**
  (close crosses the trailing stop). No fixed TP, no broker stop at the
  trailing level (documented: broker stops destroy 45% of the edge).
- Entry/exit at signal-bar close. Final open position at end-of-data is
  dropped (no lookahead credit).
- No weekend flattening (our M1 history is the raw feed; keep it simple).

## Candidate 2 — Session range breakout (Asian range → London open)

Source: mql5.com blog 767519 (live $310→$851 account, conservative config
PF 1.61, 59 trades, session 03:00–08:00).

- Range window: M15 bars ending **03:00–07:59 UTC** (Asian session) →
  range high/low from those bars only (causal: fully known before trading).
- Trade window: bars ending **08:00–20:59 UTC** (London + NY).
- Entry: **first** bar in the trade window whose close breaks the range
  (close > range high → BUY; close < range low → SELL). One trade per day.
- SL = 1.5·ATR(14), TP = 3.0·ATR(14) (engine-consistent), spread 0.30.

## Candidate 3 — Xaulgnition long-only momentum (US session)

Source: cTrader product 5239 (XAUUSD M15, Aug 2023–Aug 2026: 431 trades,
WR 55.9%, PF 1.27, DD 4.51%).

- Timeframe M15. Long-only. Trend EMA **198**.
- US session: bars ending **13:00–20:59 UTC**. **No Fridays** (weekend
  exposure guard).
- Entry (all on the same bar): close > EMA198 AND bullish candle with
  body ≥ ATR(14) AND close in upper half of the bar's range AND close >
  previous bar's high.
- SL = 3.7·ATR(14), TP = 3.9·ATR(14), **time exit after 24 h (96 M15
  bars)** if neither hit. One position at a time.

## Candidate 4 — EMA crossover + ADX trend filter

Source: github.com/Rithick574/XAUUSD-bot-forex (EMA cross confirmed by ADX,
ATR SL/TP).

- Timeframe M15. EMA fast **20**, slow **50**. ADX(14) Wilder.
- Entry: EMA20 crosses EMA50 AND ADX(14) > **25** → BUY (up-cross) /
  SELL (down-cross). Entries only when flat.
- Exit: SL = 1.5·ATR(14), TP = 3.0·ATR(14) (engine-consistent). (Early
  close on opposite cross is NOT modelled in this frozen trial — SL/TP
  only; documented simplification.)

## Candidate 5 — Bollinger mean reversion (BB return + RSI)

Source: mql5.com product 181238 "BB Return" (gold mean reversion with
filters — bands alone are not enough).

- Timeframe M15. Bollinger(20, 2.0), RSI(14) Wilder.
- Entry: close < lower band AND RSI < **30** → BUY (fade); close > upper
  band AND RSI > **70** → SELL (fade).
- SL = 1.5·ATR(14), TP = 1.5·ATR(14) (1:1 — mean reversion targets the
  mean, not a 2R extension).

## Candidate 6 — Pullback-window breakout (volatility expansion)

Source: github.com/rchoosak/backtrader-pullback-window-xauusd (5y: PF 1.64,
WR 55.43%, 175 trades; EMA basket + pullback + window breakout).

- Timeframe M15. Trend: EMA14 vs EMA24.
- Bullish: EMA14 > EMA24 → wait for a pullback of **1–3 consecutive
  counter-trend (red) candles** → entry when close breaks above the
  pullback window's high. Bearish symmetric (green candles, break below
  window low).
- SL = 2.5·ATR(14), TP = 12.0·ATR(14) (documented repo values).

## Candidate 7 — Liquidity sweep (SMC wick-through + close-back)

Source: github.com/vaughanf1/GoldQuant V1 (swing 3-bar, wick-through +
close-back sweep, 2.0R, London/NY sessions).

- Timeframe M15. Swing high = max(high[i-1], high[i-2]); swing low =
  min(low[i-1], low[i-2]) (causal, 2-bar lookback).
- SELL: bar wicks ABOVE swing high (high > SH) but closes back below
  (close < SH) — buy-side liquidity sweep. BUY symmetric (low < SL, close
  > SL).
- Session: bars ending **07:00–20:59 UTC** (London/NY).
- SL = 1.5·ATR(14), TP = 3.0·ATR(14), spread 0.30.

## Guardrail reminder

- Layer 1 (Kelly f*) inputs remain Layer-3 OOS stats only. Every NO-GO
  keeps the bot at **0.01 lots, no sizing up**.
- A GO from this batch is provisional until the split-sample robustness
  check passes (multiple-testing caveat above).
- The 21-month horizon is one contiguous out-of-sample bench; nothing ships
  without Layer-3 WFO discipline already satisfied.