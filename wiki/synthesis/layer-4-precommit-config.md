---
title: Layer 4 Pre-Commit Config — Entry Filter Gate (frozen)
type: synthesis
tags: [quant, layer-4, entry-filter, walk-forward, donchian, precommit, gate]
date: 2026-09-19
sources:
  - synthesis/entry-quality-retrospective-2026-09-11.md
  - synthesis/quant-math-build-plan.md
  - scripts/layer3_walkforward.py
---

# Layer 4 Pre-Commit Config — Entry Filter Gates (FROZEN 2026-09-19)

> [!important] Honor contract
> This config is frozen **BEFORE any Layer-4 OOS number is produced** — the
> same discipline Layer 3 imposed (never look at results with unfrozen
> knobs). The two gates below are derived **only** from the dated, already-documented
> [[Entry Quality Retrospective 2026-09-11]] findings and the Layer-3 frozen
> engine ([[Quant Math Build Plan]]). No threshold here was chosen after any
> Layer-4 run. It changes only with the human.

## Contract

- Reuses the **frozen Layer-3 engine signal path verbatim** (import
  `scripts/layer3_walkforward.py` functions `aggregate`, `ema`,
  `atr_wilder`, `donchian`, `load_csv`; identical EMA50/Donchian-20/ATR(14),
  identical M15+H1 EMA50 trend filter, identical 03:00–03:59 UTC hour window,
  identical SL 1.5·ATR / TP 3.0·ATR, identical spread cost 0.30 USD). The
  filter **only gates** which of those signals become a trade — it never
  re-derives or alters the engine.
- Both gates are **causal at entry**: computed from bars strictly before the
  entry bar. No lookahead, no "pick the good one after seeing the result".
- **Verdict rule (build-plan guardrail)**: the filtered OOS expectancy must
  be **> 0 AND > the unfiltered Layer-3 baseline** (−4.42 USD/trade @ 0.01
  lot). A filter that merely produces *different* trades — or a *better*-looking
  but still negative or sub-baseline set — is **NO-GO**. Go/no-go with `>= 30`
  filtered OOS trades.
- One trial. No "add gates until it improves" (that is multiple testing /
  overfitting — the wiki's own guardrail).

## Gate A — Min-break distance (marginal-break trap)

- **Skip** the breakout entry unless:
  - BUY: `entry − donchian_up(prior-20) >= MIN_BREAK_PTS`
  - SELL: `donchian_dn(prior-20) − entry >= MIN_BREAK_PTS`
- `MIN_BREAK_PTS = 0.30` (== spread). **Rationale (from the dated
  retrospective, not tuned)**: finding #5 ranked the 09-11 16:29 BUY
  (break of only **+0.17 pts** after a 50-pt rally) as a marginal trap, and
  #1/#4/#5 as breaks that "bought the top / the bottom of the range". A
  break narrower than the round-trip cost of the trade itself (spread 0.30)
  can never be in the money enough to cover its border — it is, by
  construction, the documented "marginal break after an extended move". Any
  break < the spread is excluded.

## Gate B — One entry per Donchian-20 channel level (re-entry decay)

- **Skip** a BUY if a BUY was already taken at the SAME 20-bar channel-high
  level (the entry that opened this breakout), and skip a SELL if a SELL was
  already taken at the SAME 20-bar channel-low level.
- A new entry in the same direction requires a **new 20-bar extreme** (the
  channel has re-based to a fresh high/low since the last entry of that
  side) — i.e. the Donchian-20 high/low resets after each taken level.
- **Rationale (dated retrospective, not tuned)**: findings #2/#3 ranked the
  FRESH entries right after the initial break as the good ones, and #4/#5/#6
  as decaying re-entries into the same grind ("entry quality decays with
  each re-entry into the same move"). The retrospective's own fix: **"one
  entry per move ... beats unlimited re-entry."**

## Guardrail reminder

- Layer 1 (Kelly f*) inputs remain Layer-3 OOS stats only. If Layer 4 stays
  NO-GO, stay at **0.01 lots, no sizing up** (negative edge ⇒ f* = 0).
- The 21-month horizon is one contiguous out-of-sample bench; nothing ships
  without Layer 3's WFO discipline already satisfied.
