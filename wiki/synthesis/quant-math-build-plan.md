---
title: Quant Math Build Plan
type: synthesis
tags: [quant, build-plan, kelly, monte-carlo, walk-forward, entry-filters]
date: 2026-09-18
sources:
  - sources/quant-resources-kelly-sizing
  - sources/quant-resources-monte-carlo
  - sources/quant-resources-walk-forward
  - sources/quant-resources-entry-filters
  - sources/quant-resources-quant-math
  - sources/quant-resources-ml-regression
  - sources/quant-resources-risk
---

# Quant Math Build Plan — the four layers

User-approved build order (2026-09-18) for adding quantitative math to the
gold breakout bot (and the other bots). **Order is locked**: sizing →
drawdown → walk-forward → entry filters. Each layer is only as good as the
one before it, and every layer must respect the [[Overfitting]] lesson from
the VP sweep.

## The four layers

### Layer 1 — Kelly / volatility sizing (replaces fixed 0.01 lots)

- **Goal**: risk a constant, edge-derived fraction of equity per trade
  instead of a fixed lot.
- **Inputs**: win rate, average win/loss ([[Risk Reward]]), forecast
  volatility (ATR(14) today; GARCH(1,1) candidate from
  [[Quant Resources — Kelly & Volatility Sizing]]).
- **Method**: fractional Kelly (25–50% of f\*) combined with
  [[Volatility Targeting]] — size = target risk ÷ (forecast vol × SL
  distance). v3.27's ATR SL/TP already gives the SL distance.
- **Current baseline**: 0.01 lot, $5 SL on $100 = 5% risk/trade ≈ half-Kelly
  for a 40% WR / 2:1 RR edge. The math should confirm or correct this.
- **Guardrail**: Kelly inputs come from OOS stats only (layer 3), never
  from in-sample backtests.

### Layer 2 — Monte Carlo drawdown (sets the risk limits)

- **Goal**: the worst realistic drawdown and losing streak for the trade
  sequence — the numbers the [[Kill Switch]] and sizing must survive.
- **Method**: resample the real trade list (gold + BTC, ~30+ trades since
  09-10) 1,000–10,000× → 95th-percentile max drawdown, longest losing
  streak (see [[Monte Carlo Simulation]] and
  [[Quant Resources — Monte Carlo Drawdown]]).
- **Output**: e.g. "95% of runs never exceed −$X" → kill-switch loss limit
  and per-trade risk cap derived from it, not guessed.
- **Guardrail**: Monte Carlo quantifies variance of a given strategy; it
  does NOT fix overfitting (that is layer 3's job).

### Layer 3 — Walk-forward framework (honest OOS testing)

- **Goal**: no parameter choice ever sees the answer again. The VP sweep
  (~30 configs on 21 months, "best" = noise) is the cautionary tale.
- **Method**: rolling train/test windows on the 21-month gold M1 CSV
  ([[Walk-Forward Analysis]], [[Quant Resources — Walk-Forward Framework]]);
  double-OOS for anything we ship. OOS expectancy per trade is the go/no-go
  number.
- **Output**: the OOS WR/RR that feeds layer 1's Kelly, and the OOS trade
  list that feeds layer 2's Monte Carlo.
- **Guardrail**: pre-commit the configs BEFORE looking at results; penalize
  the number of trials (deflated Sharpe).

### Layer 4 — Entry filters (only after 1–3 are solid)

- **Goal**: gate entries by regime / support-resistance / sentiment.
- **Candidates**: SR mapping (XGBoost-style, see
  [[Quant Resources — Entry Filters]]), Livermore-style regime state
  machine, two-filter framework (trend + entry filter).
- **Guardrail**: the VP sweep proved filters can zero out ALL trades — any
  filter must show OOS improvement over no-filter, not just different
  trades. ML models ([[Quant Resources — ML Regression & Training]]) must
  pass walk-forward validation before live use.

## Terminology anchor (the "same terms" contract)

| Term | Definition | Page |
|------|-----------|------|
| Edge | Positive expected value per trade (WR × avg win − loss rate × avg loss) | [[Risk Reward]] |
| Win rate (WR) | Fraction of trades that hit TP | [[Risk Reward]] |
| R/R (reward:risk) | Average win ÷ average loss | [[Risk Reward]] |
| Kelly fraction (f\*) | Optimal fraction of equity to risk per trade | [[Kelly Criterion]] |
| Fractional Kelly | Using 25–50% of f\* | [[Kelly Criterion]] |
| Forecast volatility | Predicted future vol (ATR, GARCH, EWMA) | [[Volatility Targeting]] |
| Target volatility | The fixed vol level you size to | [[Volatility Targeting]] |
| Max drawdown | Largest peak-to-trough equity decline | [[Monte Carlo Simulation]] |
| Losing streak | Consecutive losing trades | [[Monte Carlo Simulation]] |
| In-sample (IS) | Data used to fit/choose parameters | [[Walk-Forward Analysis]] |
| Out-of-sample (OOS) | Data held back from fitting; the honest test | [[Walk-Forward Analysis]] |
| Walk-forward optimization (WFO) | Rolling train/test parameter testing | [[Walk-Forward Analysis]] |
| Multiple testing | Trying many configs on one dataset | [[Overfitting]] |
| Deflated Sharpe | Sharpe adjusted for number of trials | [[Overfitting]] |

## Data & tooling

- **Data**: `xauusd-m1-bid-2025-2026-utc.csv` (21 months M1; no volume
  column — bar range is the volume proxy). Backtest engine must replicate
  the EA's `simulate()` exactly (M1 touch-first, SL-priority, spread 0.30
  on SELL only, 480-bar cap).
- **Live trades**: terminal logs + MCP deals (account 169324224) — the
  real-trade list for Monte Carlo.
- **Libraries to evaluate**: pyalloq / quanteval (WFA), MonteForex
  (resampling), Riskfolio-Lib (risk measures), Garch-Method (vol forecast).

## Status

- [x] Resource catalog ingested (7 source pages, 2026-09-18)
- [ ] Layer 1: Kelly/volatility sizing design (needs OOS stats from layer 3
      or live sample; user materials in `raw/strategy/` pending)
- [ ] Layer 2: Monte Carlo on real trade list
- [ ] Layer 3: WFO framework on 21-month CSV
- [ ] Layer 4: entry filter candidates (SR mapping, regime gating)

## Related

- [[Overfitting]], [[2026-09-17 Loss Causes]], [[Hour Window Analysis 2026-09-12]], [[Kill Switch]], [[Risk Reward]]