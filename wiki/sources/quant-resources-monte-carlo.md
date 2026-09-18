---
title: Quant Resources — Monte Carlo Drawdown
type: source
tags: [quant, monte-carlo, drawdown, risk-management, sources]
date: 2026-09-18
sources:
  - https://github.com/MalfiRG/MonteForex
  - https://github.com/Leotaby/alpha-engine
  - https://github.com/JordiCorbilla/RiskOptima
  - https://github.com/JordiCorbilla/efficient-frontier-monte-carlo-portfolio-optimization
  - https://www.risktech.com.au/sites/default/files/Monte%20Carlo%20Simulation.pdf
  - https://www.oreilly.com/library/view/python-for-finance/9781492024323/
  - https://www.sciencedirect.com/science/article/abs/pii/S0378437118311478
  - https://www.uv.es/~amat/pdf/2017_montecarlo.pdf
  - https://github.com/robert-hannah/fractal_visual_tools
  - https://www.investopedia.com/articles/trading/08/monte-carlo-simulation.asp
---

# Quant Resources — Monte Carlo Drawdown Simulation

User-curated catalog (2026-09-18) for **layer 2 of the build plan**:
estimating the worst realistic drawdown of the bots' trade sequences.
Terminology anchored in [[Monte Carlo Simulation]].

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [MonteForex](https://github.com/MalfiRG/MonteForex) | GitHub | Forex-focused Monte Carlo — `MonteCarloSimulation.py` resamples trade lists |
| 2 | [alpha-engine](https://github.com/Leotaby/alpha-engine) | GitHub | Backtest engine with Monte Carlo drawdown analysis |
| 3 | [RiskOptima](https://github.com/JordiCorbilla/RiskOptima) | GitHub | Risk optimization with Monte Carlo |
| 4 | [efficient-frontier-monte-carlo-portfolio-optimization](https://github.com/JordiCorbilla/efficient-frontier-monte-carlo-portfolio-optimization) | GitHub | MC portfolio optimization reference |
| 5 | [Monte Carlo Simulation (Mark Johnson)](https://www.risktech.com.au/sites/default/files/Monte%20Carlo%20Simulation.pdf) | PDF | Technical intro to MC simulation |
| 6 | [Python For Finance (Yves Hilpisch)](https://www.oreilly.com/library/view/python-for-finance/9781492024323/) | Book | MC + financial Python patterns (the code we will adapt) |
| 7 | [Monte Carlo method in stock trading research](https://www.sciencedirect.com/science/article/abs/pii/S0378437118311478) | Paper | MC applied to trading-strategy evaluation |
| 8 | [Simulación de Monte Carlo para evaluación de riesgo de estrategias de trading](https://www.uv.es/~amat/pdf/2017_montecarlo.pdf) | PDF | MC risk evaluation of trading strategies (R) |
| 9 | [Backtest Result Visualiser (fractal_visual_tools)](https://github.com/robert-hannah/fractal_visual_tools) | GitHub | Visualizing backtest/MC results |
| 10 | [Monte Carlo Simulation in Trading (Investopedia)](https://www.investopedia.com/articles/trading/08/monte-carlo-simulation.asp) | Article | Plain-language MC for trading |

## What to extract (for our bots)

- **Resample the real trade list** (gold + BTC bots, ~30+ trades since
  09-10) — 1,000–10,000 shuffles → 95th-percentile max drawdown and longest
  losing streak. These numbers set the [[Kill Switch]] limits and the
  fractional-Kelly size in [[Quant Math Build Plan]].
- **MonteForex's resampling approach** is the closest match to our data
  (list of real trades, not parametric).

## Related

- [[Monte Carlo Simulation]], [[Quant Math Build Plan]], [[Kill Switch]],
  [[Kelly Criterion]]