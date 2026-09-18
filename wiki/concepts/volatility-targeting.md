---
title: Volatility Targeting
type: concept
tags: [quant, position-sizing, volatility, atr]
date: 2026-09-18
sources: [sources/quant-resources-kelly-sizing]
---

# Volatility Targeting — size by risk, not by edge

The sizing school that keeps **risk per trade constant** by scaling position
size inversely with forecast volatility:

```
size = target_risk / (forecast_volatility × distance_to_SL)
```

or in its pure form: `size ∝ target_vol / forecast_vol`.

## Why it matters for the bots

Gold's M15 ATR swings between quiet and explosive regimes (see the 09-16
~132-pt crash). A fixed 0.01 lot risks $5 in quiet times and $15+ in
volatile ones. Volatility targeting smooths that: smaller size when ATR is
wide, larger when it is tight.

## Relationship to v3.27

v3.27 already uses **ATR-based SL/TP** (SL = 1.5× M15 ATR(14), TP = 3.0×).
Volatility targeting is the natural next step: keep the ATR SL/TP, but scale
the **lot** so the dollar risk per trade is constant (e.g. always risk $5 →
lot = $5 ÷ (1.5×ATR × $1/pt)).

## Related

- [[Kelly Criterion]] — the edge-based alternative; the two can combine
  (Kelly for the fraction, volatility targeting for the risk unit).
- [[Risk Reward]] — ATR SL/TP is documented there.
- [[Quant Math Build Plan]] — layer 1 of the build order.

## Jargon

- **Forecast volatility** — predicted future vol (ATR, GARCH, EWMA).
- **Target volatility** — the fixed vol level you size to.
- **GARCH(1,1)** — autoregressive volatility model (see
  [[Quant Math Build Plan]]).
- **EWMA** — exponentially weighted moving average (vol estimate).