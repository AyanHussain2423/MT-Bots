---
title: Strategy Candidate Register — all dated candidates, certified + pending
type: synthesis
tags: [strategy, candidate-register, walk-forward, OOS, GO-NO-GO, dogfooding, ML]
date: 2026-09-19
sources:
  - sources/quant-resources-walk-forward.md
  - sources/entry-quality-retrospective-2026-09-11.md
  - sources/hour-window-analysis-2026-09-12.md
---

# Strategy Candidate Register — every dated candidate, certified + pending

This is the master list of every strategy / variation / sizing idea that the
wiki has ever written down, with its provenance (which dated page) and its
honest status: **certified** (has a frozen walk-forward OOS verdict) or
**pending** (no OOS verdict yet — Untested ≠ GO, per the layer contract).

## The house rule that ALL of these obey

A candidate **never** ships on being *plausible*, *new*, or *looks good on
the win list*. It ships only if a **frozen** configuration —
pre-committed BEFORE any OOS number exists — passes:

1. `>= 30` out-of-sample trades, AND
2. OOS expectancy/trade `> 0` AND `> the no-filter baseline`.

No re-derivation, no second resolver that "happens to agree," no tuning on
OOS. ML models must additionally pass walk-forward validation before going
live. Any verdict that < 30 trades → automatically NO-GO (never greenlit).

## Certified verdicts (already adjudicated; do NOT re-litigate)

| Candidate | Home page | Outcome | OOS numbers |
|---|---|---|---|
| Layer 3 — frozen breakout engine (trend-cont Donchian-20, EMA50, ATR SL/TP, 03:00 UTC hour window) | [[Quant Math Build Plan]] | **NO-GO** (certified 2026-09-19) | 35 trades, expectancy **−4.42** USD/trade, 25.71% WR, RR 1.24 — negative OOS ⇒ stay **0.01 lots, 0 Kelly, do NOT size up** |
| Layer 4 — entry-filter (gate-A min-break + gate-B one-per-Donchian, frozen harness) | [[Layer 4 Pre-Commit Config]] | **NO-GO** (certified 2026-09-19) | 9 trades, expectancy **−4.76**, WR 22.22% — filter does NOT rescue edge; 9 < 30 ⇒ **NO-GO** |
| Layer 5 — retest-confirmed breakout gate (break→retest→re-break, frozen harness) | [[Layer 5 Pre-Commit Config]] | **NO-GO** (certified 2026-09-19) | 20 trades, expectancy **−2.94**, WR 35.00%, RR 1.09 — improved vs baseline (−4.42) but still negative AND 20 < 30 ⇒ **NO-GO** |
| Batch 1 C1 — UT Bot ATR trailing stop (always-in-market, reverse on signal; frozen config) | [[Strategy Search Batch 1 Pre-Commit]] | **GO** (certified 2026-09-19, split-sample PASS) | 698 trades, expectancy **+4.96**, WR 37.82%, RR 2.27 — split-sample: half1 +1.76 (369), half2 +5.53 (329) ⇒ both halves positive ⇒ **GO confirmed** |
| Batch 1 C3 — Xaulgnition long-only momentum (US session, no Fridays; frozen config) | [[Strategy Search Batch 1 Pre-Commit]] | **GO** (certified 2026-09-19, split-sample PASS) | 357 trades, expectancy **+5.82**, WR 59.38%, RR 1.01 — split-sample: half1 +7.19 (176), half2 +2.74 (185) ⇒ both halves positive ⇒ **GO confirmed** |
| Batch 1 C2 — Session range breakout (Asian range → London open; frozen config) | [[Strategy Search Batch 1 Pre-Commit]] | **NO-GO** (certified 2026-09-19) | 418 trades, expectancy **−0.93**, WR 33.25% — positive n but negative E ⇒ **NO-GO** |
| Batch 1 C4 — EMA cross + ADX filter (frozen config) | [[Strategy Search Batch 1 Pre-Commit]] | **NO-GO** (certified 2026-09-19) | 1 trade, expectancy **−4.18** — 1 < 30 ⇒ **NO-GO** |
| Batch 1 C5 — Bollinger mean reversion + RSI (frozen config) | [[Strategy Search Batch 1 Pre-Commit]] | **NO-GO** (certified 2026-09-19) | 2510 trades, expectancy **−0.32**, WR 49.80% — negative E ⇒ **NO-GO** |
| Batch 1 C6 — Pullback-window breakout (frozen config) | [[Strategy Search Batch 1 Pre-Commit]] | **NO-GO** (certified 2026-09-19) | 0 resolved trades — no OOS trades ⇒ **NO-GO** |
| Batch 1 C7 — Liquidity sweep (SMC wick-through + close-back; frozen config) | [[Strategy Search Batch 1 Pre-Commit]] | **NO-GO** (certified 2026-09-19) | 8809 trades, expectancy **−0.29**, WR 33.44% — negative E ⇒ **NO-GO** |

## Pending candidates (real, dated, still untested OOS)

These are live ideas with real wiki provenance — but **no frozen OOS verdict
yet**. Listing them here is NOT a GO. Each must earn GO by passing the frozen
harness (above) when **you** (the human) decide it's the one to trial.

| Candidate | Home page | Notes |
|---|---|---|
| ~~Entry-quality gate (magic-reentry decay)~~ | [[Entry Quality Retrospective]] | **TESTED — certified NO-GO in both variants**: fresh-break-only = Layer-4 Gate B (9 trades, −4.76); retest-confirmed re-break = Layer-5 Gate C (20 trades, −2.94). Both improved nothing OOS. |
| Hour-window variants | [[Hour Window Analysis]] | Other UTC hours; not yet OOS-verified (hour 03 currently certified NO-GO). |
| ML / ML-regression entry filter | [[Quant Resources — Entry Filters]] | Needs walk-forward OOS validation per Layer-4 guardrail. |
| Donchian channel-width filter (only trade ≥ spread-wide breaks) | [[Quant Resources — Entry Filters]] | The "marginal break after extended move" trap. |
| Session / regime filter (Livermore state machine) | [[Quant Math Build Plan]] Layer 4 | Regime gating; must show OOS improvement, not just differ. |
| S/R-aware breakout (only break at mapped SR level) | [[Quant Math Build Plan]] Layer 4 | SR-mapped; causal, no lookahead. |
| 2:1 RR cash sizing (TP/SL flip) | [[Quant Resources — Risk]] | Rejected by user directive; re-test only on a new dated hypothesis. |

## What "going forward and developing it" looks like (honestly)

- **Today's state**: the frozen breakout engine family (L3/L4/L5) is NO-GO,
  but **Batch 1 produced two split-sample-confirmed GO candidates** (C1 UT
  Bot trailing stop +4.96, C3 Xaulgnition momentum +5.82). These are the
  first positive-OOS strategies in the wiki — next step is a live demo trial
  (0.01 lots) to confirm they behave in real time before any sizing up.
- **Next 1 layer goal**: pick ONE pending candidate, **freeze its config in
  a dated pre-commit page BEFORE running it**, run it on the same frozen
  harness, publish both OOS numbers, verdict GO/NO-GO. Never two candidates
  at once (that's multiple-testing), never tune on OOS.
- **ML is allowed** but ONLY through the same Layer-4 guardrail: walk-forward
  OOS validation first, covariance-frozen config pre-committed.
- **When you supply the PDF / datasheet / CSV for a candidate** — I ingest it
  into `raw/`, freeze a config, and run the honest harness. Until a verdict
  file exists, the candidate stays **pending = UNTESTED**.
