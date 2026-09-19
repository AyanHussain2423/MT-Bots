---
title: Strategy Resource Pack — verified links for the 6 pending candidates
type: source
tags: [resources, ML-filter, S-R-breakout, regime-filter, donchian, retest, kelly, GARCH]
date: 2026-09-19
sources:
  - sources/quant-resources-walk-forward.md
  - sources/quant-resources-entry-filters.md
  - sources/quant-resources-risk.md
  - sources/quant-resources-ml-regression.md
---

# Strategy Resource Pack — verified links for the 6 pending candidates

Compiled 2026-09-19 from live web searches. Every link below was returned
by a search this session (verified to exist); the "user-pasted" section at
the end lists resources from the user's own search summary that could not be
independently verified here. House rule still applies: a resource is a
**candidate input**, not a GO — each strategy must still pass the frozen
walk-forward OOS harness before it ships.

## 1. ML Entry Filter (XGBoost / LightGBM gatekeeper)

1. **Volatility-Gated Signal Generation (XGBoost/LightGBM + gate)** — JETIR
   paper, two-stage framework with volatility gate, walk-forward tested on 5
   cryptos. https://www.jetir.org/papers/JETIR2603852.pdf
2. **Signal Prediction in Cryptocurrency Tradeoperations (XGBoost/LightGBM,
   PCA + Bayesian tuning)** — SSRN. https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4062476
3. **Real-Time AI-Driven Cross-Market Trading System (XGBoost-LightGBM
   ensemble)** — IEEE 2026. https://doi.org/10.1109/iatmsi68868.2026.11465675
4. **QUANTA: Regime-Filtered Hybrid Trading Agent (LSTM vs LightGBM)** —
   TechRxiv 2026, ADX/EMA regime gate before ML inference.
   https://doi.org/10.36227/techrxiv.177127422.27849343/v1
5. **Multi-Class Trading Signals for Bitcoin (XGBoost vs LightGBM vs RF)** —
   ISD 2025 camera-ready PDF. https://isd2025.fon.bg.ac.rs/wp-content/uploads/ISD_2025_camera_ready_87.pdf
6. **Hybrid ML Framework for Crypto Trade Setup Screening (SMC features +
   ADX regime filter + LightGBM)** — IRJMETS PDF.
   https://www.irjmets.com/upload_newfiles/irjmets80400375699/paper_file/irjmets80400375699.pdf
7. **Signal Quality Gate with LightGBM (production write-up, TimeSeriesSplit,
   error-open gate)** — AlgoKing blog. https://algos.pro/posts/2026-05-01-april-closed-signal-quality-gate-lightgbm/
8. **Regime-Aware LightGBM with Walk-Forward Validation + Deflated Sharpe** —
   Electronics (MDPI) 2026. https://doi.org/10.3390/electronics15061334
9. **Python-HFT-Engine (XGBoost/LightGBM/CatBoost/RF + stacking meta-learner)**
   — GitHub (user-pasted, unverified). https://github.com/jatin711-debug/Python-HFT-Engine
10. **AI-Trading-Bot (ensembled classifiers + calibrated probabilities +
    Kelly sizing)** — GitHub (user-pasted, unverified).
    https://github.com/Aadityavarier/AI-Trading-Bot

## 2. S/R-Aware Breakout (SR mapping)

1. **An Optimal Stopping Problem Modeling Technical Analysis (S/R line)** —
   arXiv 1707.05253. https://arxiv.org/pdf/1707.05253
2. **Optimal Prediction of Resistance and Support Levels (CEV processes)** —
   arXiv 2607.08531. https://arxiv.org/abs/2607.08531v1
3. **Optimal Prediction of Resistance and Support Levels (Peskir, full PDF)** —
   https://personalpages.manchester.ac.uk/staff/goran.peskir/levels.pdf
4. **The Support and Resistance Line Method: An Analysis via Optimal
   Stopping** — Finance and Stochastics (Springer) 2026.
   https://link.springer.com/article/10.1007/s00780-026-00596-6
5. **Mathematical Model for Resistance and Optimal Strategy** — arXiv
   0812.3027. https://arxiv.org/pdf/0812.3027
6. **Optimal Stopping Problems with Regime Switching (viscosity solution)** —
   arXiv 1404.3372. https://ar5iv.labs.arxiv.org/html/1404.3372
7. **A Finite Time Horizon Optimal Stopping Problem with Regime Switching** —
   SIAM. https://epubs.siam.org/doi/10.1137/080739550
8. **Robust Optimal Stopping with Regime Switching** — arXiv 2411.06522.
   https://doi.org/10.48550/arxiv.2411.06522
9. **stockalgo/stolgo (price-action API: pa.resistance, pa.support,
   look-ahead-safe backtesting)** — GitHub (user-pasted, unverified).
   https://github.com/stockalgo/stolgo
10. **Effectiveness of technical trading rules in cryptocurrency markets
    (S/R + range breakout on BTC high-frequency)** — ScienceDirect
    (user-pasted, unverified).

## 3. Session / Regime Filter (Livermore-style)

1. **STRATA Market State Framework (stateful regime estimation, hard-rule
   guard)** — GitHub. https://github.com/rafaelsistems/strata-market
2. **ItsSawhill/market-regime-detection (KMeans + HMM, walk-forward
   retraining, macro signals)** — GitHub.
   https://github.com/ItsSawhill/market-regime-detection
3. **Sakeeb91/market-regime-detection (HMM + GMM + change point, walk-forward
   validation)** — GitHub. https://github.com/Sakeeb91/market-regime-detection
4. **Sakeeb91/regime-detection-strategy (GMM/HMM/DTW, regime transition
   prediction)** — GitHub. https://github.com/Sakeeb91/regime-detection-strategy
5. **QuantTradingOS/Market-Regime-Agent (deterministic, signal-based
   classification)** — GitHub. https://github.com/QuantTradingOS/Market-Regime-Agent
6. **moh1tt/RegimeSense (5-feature Gaussian HMM, soft allocation across
   strategy pool)** — GitHub. https://github.com/moh1tt/RegimeSense
7. **Regime-Volatility-Arbitrage-Engine regime_filter.py (2-state G-HMM,
   Baum-Welch, Viterbi, forward-filtered causal signal)** — GitHub.
   https://github.com/philipcardozo/Regime-Volatility-Arbitrage-Engine/blob/main/regime_filter.py
8. **hidden-regime/hidden-regime (pipeline-based HMM regime detection,
   temporal isolation)** — GitHub. https://github.com/hidden-regime/hidden-regime
9. **0x596173736972/MarketRegimeTrader (HMM + genetic programming + TDA +
   walk-forward)** — GitHub. https://github.com/0x596173736972/MarketRegimeTrader
10. **shortthirdman/Market-Regime-Detection (HMM + backtrader)** — GitHub.
    https://github.com/shortthirdman/Market-Regime-Detection
11. **livermore/signals.py (Livermore state machine: Direction → Location →
    Confirmation, no look-ahead)** — HuggingFace (user-pasted, unverified).

## 4. Donchian Channel-Width Filter (squeeze / breakout)

1. **Testing a Price Breakout Strategy Using Donchian Channels (SAFEX,
   Turtle-method replication, 3 systems)** — UCT thesis 2016.
   http://hdl.handle.net/11427/21754
2. **Do Turtles Have Fat Tails? Donchian Channels and Turtle Trading: The
   Case of Soybeans** — Journal of Finance Issues 2008.
   https://doi.org/10.58886/jfi.v6i1.2421
3. **Do Turtles Have Fat Tails? (journal landing page)** —
   https://jfi-aof.org/index.php/jfi/article/view/2421
4. **Research on Parameter Optimization of the Turtle Trading System
   (China's stock index futures; false-breakout cost analysis)** —
   https://www.dissertationtopic.net/doc/2247658
5. **Gate Research: Turtle Trading Rules + AdTurtle (exclusion zone after
   stop-out — directly relevant to re-entry filtering)** —
   https://www.gate.com/research/article/gate-research-turtle-trading-rules-classic-system-with-annual-returns-up-to-62-71
6. **Donchian Turtle Trading Strategy Backtest (Fractiz; entry/exit channel
   asymmetry, honest about whipsaw)** — https://www.fractiz.com/strategies/donchian-turtle/
7. **stockalgo/stolgo (pa.donchian_high(20) / pa.donchian_low(20))** — GitHub
   (user-pasted, unverified). https://github.com/stockalgo/stolgo
8. **Doctoral thesis (UCM): Donchian breakout with SMA20/SMA60 confirmation**
   — (user-pasted, unverified).
9. **Dissertation (Fenix): Donchian channel formulas + channel width as
   volatility monitor** — (user-pasted, unverified).

## 5. Fresh-Break Only (smart re-entry / retest)

1. **BOF — Breakout Failure in Financial Markets (VRZ, mathematical model of
   failed breakouts, expectancy formula)** — Academia.edu.
   https://www.academia.edu/145520250/BOF_Breakout_Failure_in_Financial_Markets_A_Behavioural_and_Structural_Analysis_Using_Visible_Reversal_Zones_VRZ
2. **The Breakout Retest: A Tighter Entry With a Real Tradeoff (Bulkowski
   data: throwbacks ~58%, clean vs deep retest)** — DayTradingToolkit.
   https://daytradingtoolkit.com/strategies/breakout-retest-trading-strategy
3. **Initial Balance Retest: Continue or Reverse? (NQ & ES, 12 years of
   1-min bars, causal retest stats, crossover ~1.4/1.5)** —
   https://tradingstats.net/initial-balance-retest-statistics/
4. **The Statistical Edge of the Failed Breakout (retest confirmation,
   ~65% of intraday resistance breaches fail)** — Finexus.
   https://api.finexus.net/api/news/events/e41b3122-4afc-4584-9ffa-a8e4e34eb6bc/html
5. **Retest in Trading: What 1,446 Breakouts Say About Waiting (losers die
   in 2h median, winners take 11h; 75.5% fail to reach target)** —
   https://www.breakoutalerts.io/blog/retest-in-trading
6. **Breakouts and False Breakouts: Entries, Retests, and Failure Traps
   (Osler order-clustering research, execution-style tradeoffs)** —
   https://sudoall.com/chart-patterns-breakouts-and-false-breakouts/
7. **Break and Retest Strategy Explained (confirmation methods, stop
   placement)** — Prometheus Markets.
   https://www.prometheus-markets.com/analysis-education/break-and-retest-strategy-trading-breakouts-with-confirmation/
8. **False Breakouts: Why They Happen and How to Trade Them (50–70% of
   intraday breakouts fail; failure rate by timeframe)** —
   https://fortraders.com/blog/false-breakouts-why-they-happen-how-to-trade
9. **AdTurtle exclusion zone (no immediate re-entry after stop-out; price
   must break ±Y×ATR beyond prior stop)** — see #5 in section 4.
10. **VSE thesis: breakout strategies in hypothesized optimal environments
    failed, possibly due to false breakouts** — (user-pasted, unverified).

## 6. Volatility Scaling (Kelly + GARCH)

1. **Conformal Kelly: Conformal Prediction Intervals as the Scale in
   Fractional Kelly Position Sizing** — arXiv 2608.01494.
   https://arxiv.org/pdf/2608.01494
2. **Kelly with Options: robust to estimation risk (binomial market)** —
   arXiv 2508.18868. https://arxiv.org/pdf/2508.18868
3. **Kelly rule under stochastic clocks (Variance Gamma; Kelly too
   aggressive outside normality)** — arXiv 2603.13632.
   https://arxiv.org/pdf/2603.13632
4. **Optimal Betting: Beyond the Long-Term Growth (asymptotic variance,
   fractional Kelly via CLT risk measures)** — arXiv 2503.17927.
   https://arxiv.org/html/2503.17927
5. **Awareness of Crash Risk Improves Kelly Strategies (efficient crashes
   model)** — arXiv 2004.09368. https://arxiv.org/pdf/2004.09368
6. **Generalized Framework for Applying the Kelly Criterion to Stock
   Markets (matrix-inversion Kelly)** — arXiv 1806.05293.
   https://ar5iv.labs.arxiv.org/html/1806.05293
7. **Efficient Multivariate Kelly Optimization Reveals Sigmoidal Scaling
   Laws** — arXiv 2604.24723. https://arxiv.org/html/2604.24723v1
8. **Methodology Using Nonlinear Regression Models with Kelly Criterion
   (Kelly + GARCH/GJR-GARCH on S&P 500 1950–2011)** — Portfolio Management
   Research (user-pasted, unverified).
9. **Leverage Trading Strategy of the Kelly Criterion (full vs fractional
   Kelly, EGARCH)** — NDLTD (user-pasted, unverified).
10. **GARCH script (arch library: fetch returns, forecast vol, adjust Kelly
    sizing)** — GitHub (user-pasted, unverified).

## Key insight carried forward

The backtested Livermore result (PF 0.64 default → ~1.02 with a stricter
volume surge filter) is the cautionary tale for ALL six candidates: a
"logical" strategy with default parameters has no edge. The Layer-4 ML
filter's most likely value is **removing marginal trades**, not finding new
ones — and every candidate still must pass the frozen walk-forward OOS
harness (≥30 trades, OOS expectancy > 0 AND > no-filter baseline) before it
can be called GO.