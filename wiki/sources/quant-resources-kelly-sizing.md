---
title: Quant Resources — Kelly & Volatility Sizing
type: source
tags: [quant, position-sizing, kelly, volatility, sources]
date: 2026-09-18
sources:
  - https://github.com/lu8848/MarketRegimeNet
  - https://github.com/Miles-Deutscher/Garch-Method
  - https://github.com/deltaray-io/kelly-criterion
  - https://github.com/ProgramComputer/earnings-trade-automation
  - https://browse-export.arxiv.org/pdf/2608.23416
  - https://arxiv.org/pdf/2604.10758
---

# Quant Resources — Kelly Criterion & Volatility Targeting (sizing)

User-curated catalog, **2nd verified pass (2026-09-18)** — layer 1 of the
build plan: replacing the bots' fixed 0.01 lots with edge/volatility-based
sizing. Terminology anchored in [[Kelly Criterion]] and
[[Volatility Targeting]]. Design pass filed in [[Layer 1 Sizing Design]].

> [!warning] Verification notes (2nd pass)
> - Confirmed on arXiv: **2608.23416** (Axiomatic Trader), **2604.10758**
>   (Investing Is Compression — Kelly factors into money/entropy/divergence
>   terms).
> - **Unconfirmed IDs** (search title on arXiv): Meta-CTA Kelly paper
>   (ar5iv), Beating the Best Constant Rebalancing Portfolio (scilit),
>   Game-Theoretic Optimal Portfolios **2210.10515** (xxx.itp.ac.cn mirror),
>   Volatility Targeting: Single Asset (TradingView search).
> - The previously-downloaded sizing papers are ingested per-document:
>   [[Quant Paper — Kelly Sizing 2309.09094]], [[Quant Paper — Kelly Lévy 2002.03448]],
>   [[Quant Paper — Optimal Growth 1510.05123]], and the
>   Večeř analytical-Kelly article (SSRN 5121817).

## Resources

| # | Resource | Type | What it gives us |
|---|----------|------|------------------|
| 1 | [MarketRegimeNet](https://github.com/lu8848/MarketRegimeNet) | GitHub | Kelly sizing + ML ensemble — regime detection (trend/range/vol) gates sizing |
| 2 | [Garch-Method](https://github.com/Miles-Deutscher/Garch-Method) | GitHub | Walk-forward GARCH volatility targeting — the "forecast vol" input to [[Volatility Targeting]] |
| 3 | [kelly-criterion (deltaray-io)](https://github.com/deltaray-io/kelly-criterion) | GitHub | Kelly implementation reference (fractional Kelly) |
| 4 | [earnings-trade-automation](https://github.com/ProgramComputer/earnings-trade-automation) | GitHub | Working example of **10% Kelly fraction** sizing in a live automation |
| 5 | [The Axiomatic Trader](https://browse-export.arxiv.org/pdf/2608.23416) | Paper | Robust Kelly + information budgets — sizing under model uncertainty |
| 6 | [Meta-CTA Trading Strategies based on Kelly Criterion](https://ar5iv.labs.arxiv.org/html/) | Paper (ar5iv) | Kelly applied to meta-CTA strategy allocation (search title) |
| 7 | [Beating the Best Constant Rebalancing Portfolio](https://www.scilit.com/publications/) | Paper | Kelly generalization — universal-portfolio style bounds (search title) |
| 8 | [Game-Theoretic Optimal Portfolios in Continuous Time](https://xxx.itp.ac.cn/abs/2210.10515) | Paper | Kelly rule in continuous-time game-theoretic portfolios (ID unconfirmed) |
| 9 | [Investing Is Compression](https://arxiv.org/pdf/2604.10758) | Paper | Kelly = money + entropy + divergence terms — investing as compression |
| 10 | [Volatility Targeting: Single Asset (BackQuant)](https://il.tradingview.com/script/) | TradingView | Open-source single-asset vol targeting script (search) |

## What to extract (for our bots)

- **GARCH(1,1) on gold M15** — forecast next-bar volatility from the
  21-month CSV; compare against ATR(14) as the forecast-vol input (the
  CSV analysis in [[Layer 1 Sizing Design]] shows ATR median 5.65 pts).
- **Fractional Kelly from live stats** — WR ≈ 33%, RR 1.74 → f\* ≤ 0 →
  **no edge to size up**; the sizing formula (half-Kelly × 2% cap, 0.01
  floor) is specified in [[Layer 1 Sizing Design]].
- **10% Kelly fraction** (earnings-trade-automation) — a concrete
  conservative-Kelly implementation pattern to copy.
- **Investing Is Compression** — the divergence-term framing: sizing error
  is measured in bits; minimizes the same objective our log-utility
  optimizer uses.

## Related

- [[Kelly Criterion]], [[Volatility Targeting]], [[Layer 1 Sizing Design]],
  [[Quant Math Build Plan]], [[Risk Reward]]