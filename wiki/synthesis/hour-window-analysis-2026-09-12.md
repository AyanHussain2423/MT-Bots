---
title: Hour Window Analysis 2026-09-12
type: synthesis
tags: [analysis, gold, backtest, hour-window, volatility]
date: 2026-09-12
sources: [xauusd-m1-bid-2025-2026-utc.csv, gold_21m.py, gold_0304.py, vol_filter.py, window_compare.py]
---

# Hour Window Analysis (2026-09-12)

Which hour of the day should the gold breakout bot trade? Answered with 21
months of real M1 data (744,518 bars, 2025-01-01 → 2026-09-11 UTC).

## Verdict

**03-04 UTC is the only hour window positive in BOTH regimes** (2025 calm,
2026 volatile):

| Window (UTC) | 2025 | 2026 | Combined | Positive months |
|---|---|---|---|---|
| **03-04** | **+0.95** (10/12) | **+0.67** (6/9) | **+0.81** (n=9348) | **16/21** |
| 20-21 | −0.33 (6/12) | +0.40 (5/9) | −0.03 | 11/21 |
| All hours | — | — | −0.11 | — |

Expectancy per trade, same strategy spec (M15 EMA50 + H1 EMA50, 20-bar
Donchian, trend-continuation entries, TP 10 / SL 5 pts, spread 0.30).

## The volatility filter is dead

Tested a channel-range filter (only trade when the 20-bar M1 range is within
a threshold) on the 20-21 UTC window — the candidate fix for its losing
2025. Result: **negative at every threshold** (−0.31 to −1.42; only at ≥20
pts +0.54 but n=92). The filter cannot rescue a window that loses in calm
markets; the edge is the hour, not the filter.

## Why the earlier "03-04 fails" result was wrong

gold_0304.py used a short window (TRAIN Jun 2–Jul 31, TEST Aug 1–Sep 11
2026) and showed TEST −0.34. That was a **regime rotation artifact**: the
two windows alternate. September 2026: 03-04 −1.57 while 20-21 +1.77. Over
21 months, 03-04 is positive in both years; 20-21 only in 2026.

## Month-by-month (03-04 UTC)

Strong months: Jan25 +2.00, Feb25 +3.13, Apr25 +1.59, Nov25 +0.90, Dec25
+2.71, Jan26 +2.62, Jun26 +0.93, Jul26 +1.85. Mild negatives: Jun25 −0.82,
Oct25 −0.43, Mar26 −0.31, Apr26 −0.77, Sep26 −1.57.

## Action

[[GoldBreakoutHunter]] v3.24 adds `InpStartHourUTC`/`InpEndHourUTC`
(default 3-4 UTC). Optional second instance at 20-21 UTC for
diversification — the windows alternate regimes, so a 2-instance setup
smooths the rotation.

## Jargon

- **Expectancy** — average P/L per trade in points.
- **Regime** — the prevailing volatility/trend character of the market
  (2025 calm: median M1 range 0.51 pts; 2026 volatile: 1.61 pts).