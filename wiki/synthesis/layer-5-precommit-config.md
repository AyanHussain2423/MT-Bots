---
title: Layer 5 Pre-Commit Config — Retest-Confirmed Breakout Gate (frozen)
type: synthesis
tags: [quant, layer-5, retest, breakout, walk-forward, donchian, precommit, gate]
date: 2026-09-19
sources:
  - synthesis/entry-quality-retrospective-2026-09-11.md
  - synthesis/strategy-candidate-register-2026-09-19.md
  - sources/strategy-resource-pack-2026-09-19.md
  - scripts/layer3_walkforward.py
---

# Layer 5 Pre-Commit Config — Retest-Confirmed Breakout Gate (FROZEN 2026-09-19)

> [!important] Honor contract
> This config is frozen **BEFORE any Layer-5 OOS number is produced** — the
> same discipline Layers 3 and 4 imposed (never look at results with unfrozen
> knobs). The gate below is derived **only** from the dated, already-documented
> findings and the Layer-3 frozen engine ([[Quant Math Build Plan]]). No
> threshold here was chosen after any Layer-5 run. It changes only with the
> human.

## Contract

- Reuses the **frozen Layer-3 engine signal path verbatim** (import
  `scripts/layer3_walkforward.py` functions `aggregate`, `ema`,
  `atr_wilder`, `donchian`, `load_csv`; identical EMA50/Donchian-20/ATR(14),
  identical M15+H1 EMA50 trend filter, identical 03:00–03:59 UTC hour window,
  identical SL 1.5·ATR / TP 3.0·ATR, identical spread cost 0.30 USD). The
  filter **only gates** which of those signals become a trade — it never
  re-derives or alters the engine.
- The gate is **causal at entry**: computed from bars strictly before the
  entry bar. No lookahead, no "pick the good one after seeing the result".
- **Verdict rule (build-plan guardrail)**: the filtered OOS expectancy must
  be **> 0 AND > the unfiltered Layer-3 baseline** (−4.42 USD/trade @ 0.01
  lot). A filter that merely produces *different* trades — or a *better*-looking
  but still negative or sub-baseline set — is **NO-GO**. Go/no-go with `>= 30`
  filtered OOS trades.
- One trial. No "add gates until it improves" (that is multiple testing /
  overfitting — the wiki's own guardrail).

## Why this candidate (dated evidence, not tuned)

- Layer 4's Gate B ("one entry per Donchian-20 level") already tested the
  *fresh-break-only* idea: it collapsed the OOS sample to 9 trades and was
  certified **NO-GO** (−4.76). The *opposite* hypothesis is still untested:
  the **retest** — price breaks a level, pulls back to it, then re-breaks.
- The [[Strategy Resource Pack 2026-09-19]] retest statistics (1,446-signal
  study: **75.5% of breakouts fail to reach target**; losers die ~2h median
  vs winners ~11h) and the AdTurtle exclusion-zone finding both say the
  *virgin* break is the failure mode and the **retest is the confirmation**.
- So Layer 5 tests: **only trade breakouts that are re-breaks after a
  retest of the same level** (break → retest → re-break). This is the
  documented "fresh-break/retest" candidate from the register — one gate,
  one trial.

## Gate C — Retest-confirmed breakout (break → retest → re-break)

- A BUY at bar `i` (close > Donchian-20 up, level `L = don_up[i]`) is kept
  **only if** there exists a prior bar `j` in `[i − RETEST_LOOKBACK, i)` such
  that:
  1. **Prior break**: `close[j] > don_up[j]` (price broke the then-current
     Donchian-20 up level at `j`), AND
  2. **Same level**: `|don_up[j] − L| <= RETEST_TOL` (the prior break was at
     the same level, within tolerance), AND
  3. **Retest**: `min(low[j+1 .. i−1]) <= L + RETEST_TOL` (after the prior
     break, price pulled back to within tolerance of the level).
- SELL is symmetric: prior `close[j] < don_dn[j]`, `|don_dn[j] − L| <=
  RETEST_TOL`, `max(high[j+1 .. i−1]) >= L − RETEST_TOL`.
- If no such `j` exists, the break is a **virgin break** → **skip** (the
  documented failure mode).

### Frozen parameters (principled, NOT tuned)

| Param | Value | Rationale |
|---|---|---|
| `RETEST_TOL` | `1.0 × ATR(14) M15` at the entry bar | Same volatility family as the engine's own SL (1.5·ATR) / TP (3.0·ATR); a retest means price came back within one ATR of the level |
| `RETEST_LOOKBACK` | `96` M15 bars (24 h) | The engine fires once per day (03:00 UTC window); a retest within the same 24 h cycle is "the same move" |

## Guardrail reminder

- Layer 1 (Kelly f*) inputs remain Layer-3 OOS stats only. If Layer 5 stays
  NO-GO, stay at **0.01 lots, no sizing up** (negative edge ⇒ f* = 0).
- The 21-month horizon is one contiguous out-of-sample bench; nothing ships
  without Layer 3's WFO discipline already satisfied.
- No-drift audit is baked into the harness: the gate-OFF pass must reproduce
  the certified Layer-3 baseline (35 OOS trades, −4.42/trade, 25.71% WR)
  with 0 PnL mismatches, or the Layer-5 verdict is void.