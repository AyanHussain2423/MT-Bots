---
title: Layer 2 MC Drawdown
type: synthesis
tags: [quant, monte-carlo, drawdown, risk, layer-2, analysis]
date: 2026-09-18
sources:
  - raw/trades/2026-09-18-bot-trades-mt5.csv
  - sources/quant-paper-drawdown-beyond-brownian-2608.00127
  - sources/quant-paper-drawdown-levy-2011.06618
  - sources/quant-paper-tempered-stable-extrema-2103.15310
  - concepts/monte-carlo-simulation
  - concepts/kill-switch
---

# Layer 2 — Monte Carlo Drawdown of the Real Trade List

First MC pass on the **real MT5 deal history** (44 bot trades, 09-08 →
09-18, pulled via MCP 2026-09-18). Script: `scripts/layer2_mc_drawdown.py`
(10,000 shuffles with replacement, start $100, kill switch −$50).

## The honest sample: per-bot, not pooled

| Bot | n | WR | avgW | avgL | RR | Kelly f* | net |
|-----|---|----|------|------|----|----------|-----|
| GBH (gold) | 29 | 31% | $9.62 | $5.14 | 1.87 | **−0.058** | −$16.11 |
| BBH (BTC breakout) | 9 | 33% | $8.60 | $4.48 | 1.92 | −0.014 | −$1.09 |
| BSH (BTC swing) | 2 | 0% | — | $7.31 | — | — | −$14.63 |
| GHP (retired) | 3 | 100% | $16.34 | — | — | — | +$49.02 |
| GBH_old | 1 | 100% | $0.58 | — | — | — | +$0.58 |
| **Pooled** | 44 | 36% | $10.12 | $5.15 | 1.97 | +0.040 | +$17.77 |

> [!warning] Pooled Kelly is misleading
> The pooled sample shows f\* = +0.04 (positive!) — but that edge comes
> entirely from **GHP, a retired bot** (3 wins, +$49). The live bots have
> **no positive edge**: GBH f\* = −0.058, BBH f\* = −0.014. Never pool bots
> for Kelly; size per bot.

## MC drawdown results (10,000 shuffles, $100 start)

| Metric | GBH | BBH |
|--------|-----|-----|
| max DD p50 | 40.0% | 15.8% |
| max DD p90 | 72.4% | 30.5% |
| max DD p95 | 82.6% | 34.4% |
| max DD p99 | 100.8% | 42.7% |
| ruin (equity ≤ 0) | **1.24%** | 0.00% |
| kill switch (−$50) hit | **28.0%** | 0.00% |
| final equity p10 / p50 / p90 | $36 / $83 / $134 | $73 / $99 / $125 |

## Verdict

- **GBH: FAIL.** 1.24% of simulations ruin the account; 28% hit the −$50
  kill switch; p95 drawdown is 82.6%. At $100 equity with 0.01 lots, the
  gold bot's realized trade distribution is **not survivable** — this is the
  MC confirmation of the Layer 1 finding ([[Layer 1 Sizing Design]]): the
  sample has no edge AND the risk envelope is too wide for the account.
- **BBH: OK.** 0% ruin, 0% kill-switch hits, p95 DD 34.4%. The BTC breakout
  bot's envelope fits the account — consistent with it being the only bot
  that made money this week (+$5.55, 2:1 RR working).
- **BSH: too few trades** (2) to judge; both lost. Needs the sample to grow.

## What this means for the build

1. **The kill switch is doing real work.** 28% of GBH simulations breach
   −$50 — the switch ([[Kill Switch]]: +$32/−$50 daily) is what separates
   "bad week" from "blown account". Keep it.
2. **Layer 1 gate confirmed**: no bot qualifies to size up (f\* ≤ 0 on all
   live bots). 0.01 lots stays.
3. **The fix path is entry quality, not sizing** — v3.26/v3.27 (03-04 UTC
   window, ATR SL/TP, spike filter, fresh guard) target the failure modes;
   the MC envelope only improves once the filtered sample replaces this one.
4. **Fat-tail caveat**: this resampler shuffles *realized* trades (the
   honest, non-parametric approach per
   [[Quant Paper — Drawdown Beyond Brownian 2608.00127]]). The
   Lévy/tempered-stable papers
   ([[Quant Paper — Drawdown Lévy 2011.06618]],
   [[Quant Paper — Tempered Stable Extrema 2103.15310]]) matter when we
   model *unrealized* tail risk (e.g. the 09-16 crash) — a later refinement.

## Next

- Re-run monthly with the v3.27 filtered sample; the go/no-go is: GBH
  f\* > 0 on ≥ 30 trades AND p95 DD < 50% at the chosen risk.
- Layer 3 (walk-forward) needs the 21-month gold CSV re-downloaded (temp
  was wiped) — pull M15 bars via MT5 MCP in chunks, or re-export from the
  terminal.

## Related

- [[Layer 1 Sizing Design]], [[Monte Carlo Simulation]], [[Kill Switch]],
  [[Quant Math Build Plan]], [[2026-09-17 Loss Causes]],
  [[Quant Paper — Drawdown Beyond Brownian 2608.00127]]