---
title: Quant Resources — Kelly & Volatility Sizing
type: source
tags: [quant, position-sizing, kelly, volatility, sources]
date: 2026-09-18
sources:
  - https://github.com/lu8848/MarketRegimeNet
  - https://github.com/Tanakazvaks/Automated-AI-stock-Trading-System
  - https://github.com/Miles-Deutscher/Garch-Method
  - https://github.com/deltaray-io/kelly-criterion
  - https://www.quantinsti.com/blog/risk-constrained-kelly-criterion
  - https://arxiv.org/abs/2309.09094
  - https://arxiv.org/abs/2002.03448
  - https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5121817
  - https://arxiv.org/abs/1510.05123
  - https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3771333
---

# Quant Resources — Kelly Criterion & Volatility Targeting (sizing)

User-curated catalog (2026-09-18) for **layer 1 of the build plan**:
replacing the bots' fixed 0.01 lots with edge/volatility-based sizing.
Terminology anchored in [[Kelly Criterion]] and [[Volatility Targeting]].

> [!warning] Flagged correction (2026-09-18)
> The catalog's arxiv IDs were hallucinated by the original web search.
> Verified replacements: #6 → 2309.09094, #7 → 2002.03448, #8 → Večeř
> (SSRN 5121817, journal article — not on arxiv), #9 → 1510.05123 (the
> UCL link was an unrelated osteoarthritis paper). Full text of each is
> ingested in the per-document pages under [[Quant Paper — Kelly Sizing 2309.09094]].

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [MarketRegimeNet](https://github.com/lu8848/MarketRegimeNet) | GitHub | Regime detection (trend/range/vol) — could gate sizing by regime |
| 2 | [Automated-AI-stock-Trading-System](https://github.com/Tanakazvaks/Automated-AI-stock-Trading-System) | GitHub | End-to-end pipeline reference (signals → sizing → execution) |
| 3 | [Garch-Method](https://github.com/Miles-Deutscher/Garch-Method) | GitHub | GARCH(1,1) volatility forecasting — the "forecast vol" input to [[Volatility Targeting]] |
| 4 | [deltaray-io/kelly-criterion](https://github.com/deltaray-io/kelly-criterion) | GitHub | Kelly implementation reference (fractional Kelly) |
| 5 | [Risk-Constrained Kelly Criterion](https://www.quantinsti.com/blog/risk-constrained-kelly-criterion) | Blog | Kelly with drawdown constraints — bridges to [[Monte Carlo Simulation]] |
| 6 | [Sizing Strategies for Algorithmic Trading in Volatile Markets](https://arxiv.org/abs/2309.09094) | Paper | Academic sizing comparison in volatile markets |
| 7 | [Kelly Criterion: Random Walk to Lévy Processes](https://arxiv.org/abs/2002.03448) | Paper | Kelly math for fat-tailed (Lévy) returns — gold's crash regime |
| 8 | [Analytical solution for Kelly's criterion for multiple outcomes (Večeř)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5121817) | Paper | Kelly for multi-outcome bets (beyond binary win/loss) |
| 9 | [Optimal growth trajectories with finite carrying capacity](https://arxiv.org/abs/1510.05123) | Paper | Growth-optimal sizing with account limits |
| 10 | [Sizing the risk: Kelly, VIX, and hybrid approaches in put-writing](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3771333) | Paper | Kelly vs VIX-based sizing — hybrid approaches |

## What to extract (for our bots)

- **GARCH(1,1) on gold M15** — forecast next-bar volatility from the 21-month
  CSV; compare against ATR(14) as the forecast-vol input.
- **Fractional Kelly from live stats** — WR ≈ 40%, RR 2:1 → f\* = 0.10 →
  half-Kelly = 5% risk/trade ≈ current $5 SL on $100. Verify with the
  drawdown distribution from [[Monte Carlo Simulation]].
- **Risk-constrained Kelly** — the constraint (max drawdown) is the bridge
  between layer 1 and layer 2 of [[Quant Math Build Plan]].

## Related

- [[Kelly Criterion]], [[Volatility Targeting]], [[Quant Math Build Plan]],
  [[Risk Reward]]