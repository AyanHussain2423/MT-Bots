---
title: Quant Resources — Risk Management
type: source
tags: [quant, risk-management, var, drawdown, sources]
date: 2026-09-18
sources:
  - https://github.com/prashant-fintech/risklab
  - https://github.com/Cpy0114/Market-Risk-Quant-Portfolio
  - https://github.com/GraceLTQ/portfolio-risk-analytics
  - https://github.com/benstaff/FinRL_DeepSeek
  - https://github.com/Osj1614/dualrssm
  - https://github.com/liangdabiao/autogen-financial-analysis
  - https://www.tradingview.com/support/solutions/43000561800-risk-management/
  - https://www.cmegroup.com/education/files/risk-management-handbook.pdf
  - https://github.com/mvxddd/quantitative-risk-management
---

# Quant Resources — Risk Management

User-curated catalog, **2nd verified pass (2026-09-18)** — risk controls
for the bots (drawdown limits, VaR, kill switch). Terminology anchored in
[[Risk Reward]] and [[Kill Switch]].

> [!warning] Verification notes (2nd pass)
> - Added: FinRL_DeepSeek, dualrssm (self-supervised risk factor model),
>   autogen-financial-analysis.
> - CME handbook PDF remains IP-blocked from our network (see the
>   2026-09-18 log entry).

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [RiskLab](https://github.com/prashant-fintech/risklab) | GitHub | VaR, CVaR, stress testing — the risk toolkit |
| 2 | [Market-Risk-Quant-Portfolio](https://github.com/Cpy0114/Market-Risk-Quant-Portfolio) | GitHub | Market risk quant portfolio — VaR/CVaR implementations |
| 3 | [portfolio-risk-analytics](https://github.com/GraceLTQ/portfolio-risk-analytics) | GitHub | Portfolio risk analytics — drawdown and tail metrics |
| 4 | [FinRL_DeepSeek](https://github.com/benstaff/FinRL_DeepSeek) | GitHub | FinRL + DeepSeek — RL risk-aware trading agents |
| 5 | [dualrssm (self-supervised risk factor model)](https://github.com/Osj1614/dualrssm) | GitHub | Self-supervised dual RSSM — risk factor extraction |
| 6 | [autogen-financial-analysis](https://github.com/liangdabiao/autogen-financial-analysis) | GitHub | AutoGen multi-agent financial analysis |
| 7 | [Risk Management Handbook (TradingView)](https://www.tradingview.com/support/solutions/43000561800-risk-management/) | Docs | Risk management best practices |
| 8 | [Risk Management Handbook (CME)](https://www.cmegroup.com/education/files/risk-management-handbook.pdf) | PDF | CME risk handbook (IP-blocked for us) |
| 9 | [quantitative-risk-management](https://github.com/mvxddd/quantitative-risk-management) | GitHub | Quant risk management — VaR, ES, backtesting |

## What to extract (for our bots)

- **VaR/CVaR on the trade P&L** — daily VaR from the 21-month CSV; the
  [[Kill Switch]] limits should be set from the MC drawdown layer, not
  hand-picked.
- **RiskLab / Market-Risk-Quant-Portfolio** — reference implementations
  for the risk metrics we compute in Python.
- **dualrssm** — self-supervised risk factors: candidate for the regime
  input to sizing (layer 1) without labeled data.

## Related

- [[Risk Reward]], [[Kill Switch]], [[Monte Carlo Simulation]],
  [[Quant Math Build Plan]], [[Layer 1 Sizing Design]]