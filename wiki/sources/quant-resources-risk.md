---
title: Quant Resources — Risk Management
type: source
tags: [quant, risk-management, portfolio, sources]
date: 2026-09-18
sources:
  - https://github.com/dcajasn/Riskfolio-Lib
  - https://github.com/domokane/FinancePy
  - https://github.com/Cpy0114/Market-Risk-Quant-Portfolio
  - https://github.com/prashant-fintech/risklab
  - https://github.com/GraceLTQ/portfolio-risk-analytics
  - https://github.com/husaam-atq/volatility-risk-forecasting-platform
  - https://www.tradingview.com/education/risk-management/
  - https://www.cmegroup.com/education/files/futures-options-risk-management.pdf
  - https://www.researchgate.net/publication/336943480_Trading_risk_management_and_support_systems
  - https://github.com/mvxddd/quantitative-risk-management
---

# Quant Resources — Risk Management

User-curated catalog (2026-09-18) — the risk layer that ties the whole
[[Quant Math Build Plan]] together (sizing, drawdown, kill switch).

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [Riskfolio-Lib](https://github.com/dcajasn/Riskfolio-Lib) | GitHub | Portfolio optimization + risk measures (CVaR, drawdown) |
| 2 | [FinancePy](https://github.com/domokane/FinancePy) | GitHub | Full finance library (pricing, risk) |
| 3 | [Market-Risk-Quant-Portfolio](https://github.com/Cpy0114/Market-Risk-Quant-Portfolio) | GitHub | Market risk quant portfolio |
| 4 | [RiskLab](https://github.com/prashant-fintech/risklab) | GitHub | Risk analytics lab |
| 5 | [portfolio-risk-analytics](https://github.com/GraceLTQ/portfolio-risk-analytics) | GitHub | Portfolio risk analytics |
| 6 | [volatility-risk-forecasting-platform](https://github.com/husaam-atq/volatility-risk-forecasting-platform) | GitHub | Vol/risk forecasting platform |
| 7 | [Risk Management Handbook (TradingView)](https://www.tradingview.com/education/risk-management/) | Article | Practical risk management education |
| 8 | [Futures, Options and Risk Management (CME)](https://www.cmegroup.com/education/files/futures-options-risk-management.pdf) | PDF | Institutional risk management |
| 9 | [Trading risk management and support systems](https://www.researchgate.net/publication/336943480_Trading_risk_management_and_support_systems) | Paper | Risk management systems research |
| 10 | [quantitative-risk-management](https://github.com/mvxddd/quantitative-risk-management) | GitHub | Quant risk management project |

## What to extract (for our bots)

- **Risk measures**: CVaR / max-drawdown measures from Riskfolio-Lib —
  the vocabulary for the [[Kill Switch]] and sizing limits.
- **Volatility forecasting platform** — complements GARCH (see
  [[Quant Resources — Kelly & Volatility Sizing]]) for the sizing input.
- **Account-level view**: our three bots share one $100 demo account —
  portfolio-style risk (combined drawdown, not per-bot) is the correct
  frame; this is the "combined −$20.10 since 09-10" lesson from
  [[2026-09-17 Bot Week Session]].

## Related

- [[Quant Math Build Plan]], [[Kill Switch]], [[Risk Reward]],
  [[Monte Carlo Simulation]]