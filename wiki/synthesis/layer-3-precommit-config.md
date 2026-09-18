
## Layer 3 pre-commit config (frozen BEFORE any OOS result)

- Window: 2025-01-01 00:00 UTC -> 2026-09-11 18:20 UTC (744,518 M1 bid bars)
- Universe: XAUUSD (GOLD) M1 bid, CSVs timestamped in true UTC
- Strategy: M15 bar = 15 aggregated M1 bars; H1 = 60 M1 bars
  - Trend filter (must agree): M15 EMA50 and H1 EMA50, seeded SMA50
  - Entry: Donchian-20 breakout (prior 20-bar high/low) in trend direction
  - Continuation-only: breakout must be in same direction as M15+H1 EMA alignment
  - Hour window: 03:00-03:59 UTC only (matches hour-window synthesis)
  - SL = 1.5 x ATR(14) M15 pts; TP = 3.0 x ATR(14) pts (1:2 R:R)
  - Cost: spread 0.30 USD baked into each trade
- Walk-forward: rolling train/test. Each test window trades only on signal
  computed from data strictly BEFORE the test (EMA/Donchian/ATR are causal,
  no lookahead). Minimum carry-over warmup = 60 H1 bars.
- Output (the go/no-go numbers):
  - OOS expectancy per trade (expectancy = avg P&L per trade including spread)
  - OOS win rate + RR (feeds Layer 1 Kelly)
  - OOS trade count (feeds Layer 2 MC resampler; Layer 1 size gate needs >= 30)
- Guardrails:
  - No in-sample tuning, no filtering by "best" after seeing results
  - Config was frozen above BEFORE any OOS number was produced
  - Any ship decision: OOS expectancy > 0 on >= 30 OOS trades; penalize trials (deflated Sharpe)

Frozen: 2026-09-19 (before running layer3)