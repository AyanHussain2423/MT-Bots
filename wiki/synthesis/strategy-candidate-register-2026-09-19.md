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

## Pending candidates (real, dated, still untested OOS)

These are live ideas with real wiki provenance — but **no frozen OOS verdict
yet**. Listing them here is NOT a GO. Each must earn GO by passing the frozen
harness (above) when **you** (the human) decide it's the one to trial.

| Candidate | Home page | Notes |
|---|---|---|
| Entry-quality gate (magic-reentry decay) | [[Entry Quality Retrospective]] | Skip re-entries into the same move; fresh-break entries only. Dated finding; not yet OOS-verified. |
| Hour-window variants | [[Hour Window Analysis]] | Other UTC hours; not yet OOS-verified (hour 03 currently certified NO-GO). |
| ML / ML-regression entry filter | [[Quant Resources — Entry Filters]] | Needs walk-forward OOS validation per Layer-4 guardrail. |
| Donchian channel-width filter (only trade ≥ spread-wide breaks) | [[Quant Resources — Entry Filters]] | The "marginal break after extended move" trap. |
| Session / regime filter (Livermore state machine) | [[Quant Math Build Plan]] Layer 4 | Regime gating; must show OOS improvement, not just differ. |
| S/R-aware breakout (only break at mapped SR level) | [[Quant Math Build Plan]] Layer 4 | SR-mapped; causal, no lookahead. |
| 2:1 RR cash sizing (TP/SL flip) | [[Quant Resources — Risk]] | Rejected by user directive; re-test only on a new dated hypothesis. |

## What "going forward and developing it" looks like (honestly)

- **Today's state**: every tested layer says **NO-GO** → keep **0.01 lots,
  do NOT size up.** That is the *output of the wiki*, not a mood.
- **Next 1 layer goal**: pick ONE pending candidate, **freeze its config in
  a dated pre-commit page BEFORE running it**, run it on the same frozen
  harness, publish both OOS numbers, verdict GO/NO-GO. Never two candidates
  at once (that's multiple-testing), never tune on OOS.
- **ML is allowed** but ONLY through the same Layer-4 guardrail: walk-forward
  OOS validation first, covariance-frozen config pre-committed.
- **When you supply the PDF / datasheet / CSV for a candidate** — I ingest it
  into `raw/`, freeze a config, and run the honest harness. Until a verdict
  file exists, the candidate stays **pending = UNTESTED**.
