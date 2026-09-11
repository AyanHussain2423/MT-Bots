---
title: BTCSwingHunter
type: entity
tags: [trading, ea, mql5, btc, bitcoin, swing, bot]
date: 2026-09-08
sources: [github-omgbbqhaxx-btc-trading-since-2020]
---

# BTCSwingHunter

A demo-account Expert Advisor (EA) for BTC/USD built from the **public trade
history of Paul Wei** (`@coolish`), a BitMEX Hall of Legends trader with a
**70x Bitcoin return over 3 years**. His full 2020–2026 execution ledger is
mirrored publicly in the `omgbbqhaxx/BTC-Trading-Since-2020` GitHub repo
(43k+ orders, 173k+ execution rows).

Source: `D:\Workspace\Trader-knowledge\BTCSwingHunter_Zaid.mq5` (also
deployed to the MT5 Experts folder).

## What the analysis found (last year of Paul Wei's trades)

Scraped and analyzed the last year (2025-04 → 2026-04) of his public BitMEX
XBTUSD execution ledger:

| Metric | Value |
|---|---|
| Trades (executions) | 3,336 |
| Unique orders | 837 |
| Reconstructed round trips | 16 |
| Win rate (by price) | **93.8%** (15/16) |
| Avg move per trade | **+3.68%** |
| Median move | +4.52% |
| Max win | +7.73% |
| Only loss | −3.85% |
| Holding time | median ~5 days, up to 47 days |
| Direction | 8 long / 8 short (balanced) |
| Order style | ~97% limit orders, many small orders (10k–50k contracts) to build positions |

**Key insight:** This is a **swing/position trader**, not a scalper. He
builds positions with many small limit orders, holds for **days**, uses
tight risk management, and takes **3–7% moves** with a very high win rate.
The edge comes from patient limit-order accumulation and letting winners run.

## Configuration (as deployed 2026-09-08, v2.00)

| Setting | Value |
|---|---|
| Magic number | **20260916** |
| Symbol | BTCUSD (attach to BTCUSD chart) |
| Lot | 0.01 |
| Trend filter | H4 EMA50 |
| Entry | H1 EMA21 + RSI(14) pullback |
| SL | max(2.0 × ATR(14), 100 points) |
| TP | 2.5 × SL distance (RR 2.5) |
| Max concurrent positions | 1 |
| Max new trades/day | 3 |
| Kill switch | +$50 profit / −$25 loss |
| Trailing stop | 2.0 × ATR (optional, on by default) |

> [!note] v2.00 changes (2026-09-08)
> - **Looser entries**: RSI pullback threshold 45 → 50 (BUY), overbought
>   55 → 50 (SELL); price proximity to H1 EMA21 widened 0.2% → 0.5%.
> - **Status prints**: prints `BSH status | H4trend | RSI | price/EMA21 |
>   buySig/sellSig` every H1 bar so we can see what it's waiting for.
> - Deployed under a new file name (`BTCSwingHunter_Zaid_v2`) to avoid the
>   MT5 stale-`.ex5` cache problem that caused the gold bot flood.

## Strategy logic

- **Trend filter (H4)**: only BUY above H4 EMA50, only SELL below H4 EMA50.
- **Pullback entry (H1)**: in an uptrend, BUY when price pulls back to the
  H1 EMA21 and RSI is not overbought (< 50). In a downtrend, SELL when price
  rallies to H1 EMA21 and RSI is not oversold (> 50).
- **Swing holding**: no intraday bar limit — positions are held for days,
  managed by SL/TP and an optional trailing stop.
- **No daily cutoff** that force-closes positions (that would kill swing
  trades). Instead, a kill switch guards daily P/L.

## Risk model

- 0.01 lot on BTCUSD.
- ATR-based SL ≈ **2–4% risk**; TP ≈ **5–10% reward** (RR 2.5).
- [[Kill Switch]]: daily P/L guard — closes all and stops the day at
  **+$50 profit** or **−$25 loss**.
- **1 concurrent position**, **3 new trades/day** max.

## Live results

| Date | Trade | Entry | SL | TP | Exit | Result |
|---|---|---|---|---|---|---|
| — | none yet | — | — | — | — | 0 trades as of 2026-09-09 |

No trades yet — swing bot waiting for its pullback setup (H4 trend + H1
EMA21 pullback + RSI). Status prints once per H1 bar:
`BSH status | H4trend | RSI | price/EMA21 | buySig/sellSig`. Patient by
design: Paul Wei's style holds days and trades rarely.

> [!note] Replaced on the chart 2026-09-10
> The user wanted a BTC bot that actually trades ("build another btc usd one
> is never trades i need one atleewasy"). [[BTCBreakoutHunter]] (breakout
> style, trades daily) replaced this bot on the BTCUSD chart. This page is
> kept as the record of the Paul Wei swing research — the model itself is
> sound, just too patient for the user's current goal.

## Version history

| Date | Change |
|---|---|
| 2026-09-08 | Created from Paul Wei's public BitMEX trade-history analysis. Compiled 0 errors/0 warnings, deployed to MT5 Experts. |
| 2026-09-08 | **v2.00**: looser entries (RSI 45→50 / 55→50, proximity 0.2%→0.5%), H1-bar status prints, redeployed as `BTCSwingHunter_Zaid_v2`. |

## Related

- [[GoldBreakoutHunter]] — the gold breakout bot (different style).
- [[GoldHunterPro Small]] — the gold M1 scalper.
- [[Risk Reward]] — RR sizing used here.

## Jargon

- **Swing trading** — holding positions for days to weeks to capture a
  larger move, vs scalping (minutes).
- **Limit order** — an order to buy/sell at a specified price or better;
  used to get favorable entries.
- **Donchian / channel** — highest high / lowest low over N bars.
- **EA / Expert Advisor** — an MQL5 program that automates trading.
- **Magic number** — numeric tag on orders so the EA only manages its own
  trades.
- **ATR** — Average True Range (14), a volatility measure.
- **RR** — risk:reward ratio (see [[Risk Reward]]).
