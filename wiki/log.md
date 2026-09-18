# Trader Knowledge Wiki Log

Append-only, chronological record of everything that happens in the trading
wiki. Newest entries go at the top.

---

## [2026-09-19] build | Layer 3 walk-forward OOS verdict — certified NO-GO (engine + independent audit)

- **Frozen engine re-ran today using the read tool's byte-exact CSV path
  (`scripts/layer3_walkforward.py` on the 744,518-bar
  `xauusd-m1-bid` history)**: **35 OOS trades, OOS expectancy **−4.42
  USD/trade** @ 0.01 lot (spread 0.30 baked in), **win rate 25.71%**, avg
  W/L **1.24** (avg win +12.96 / avg loss −10.44). OOS expectancy < 0 →
  **NO-GO**: stay at **0.01 lots, do NOT size up**; Layer 3 rejects the
  edge as real.
- **Independent audit now certifies the engine's SL/TP resolution**:
  `scripts/layer3_verify_resolution.py` re-resolves every OOS trial with a
  **second, deliberately different resolver** (forward high/low
  first-touch scan, wilder ATR + EMA rebuilt independently from raw M1)
  and compares to the engine's own arrow on the same M15 bar end-ts
  alignment: **80/80 trials, 0 mismatches → ENGINE RESOLUTION OK**. The
  engine's verdict is now backed by two independent resolutions, not just
  its own loop.
- **Honest figures note**: an earlier scratch recall quoted (−1.79/trade,
  37.5% WR, 32 trades); the deterministic FROZEN engine re-run on the
  full CSV gives (−4.42, 25.71%, 35). Direction identical (NO-GO both
  ways); the going-forward reference is the full-CSV engine run above,
  since that is what the frozen config + the audit actually certify.
- **Layer 3 contract honored**: config frozen and pre-committed before
  this run (never tuned on OOS); the 21-month horizon is untouched
  out-of-sample; verdict is an honest **NO-GO** — we do NOT ship the
  winner-take-all flip or size up.

## [2026-09-18] build | Layer 2 MC drawdown — real trade list, per-bot verdicts

- **Pulled full MT5 deal history (10 days) via MCP** → extracted **44 bot
  trades** (magic ≠ 0, profit ≠ 0) into `raw/trades/2026-09-18-bot-trades-mt5.csv`
  (immutable): GBH 29, BBH 9, BSH 2, GHP 3, GBH_old 1.
- **Built `scripts/layer2_mc_drawdown.py`** (10,000 shuffles with
  replacement, start $100, kill switch −$50): max DD, time under water,
  ruin, kill-switch hit rate, final-equity percentiles. Fixed a per-trade
  vs per-sim kill counter bug; added `--bot` filter.
- **Per-bot verdicts (the honest view — never pool bots for Kelly)**:
  - **GBH: FAIL** — 29 trades, 31% WR, RR 1.87, Kelly f* = **−0.058**;
    MC: p95 DD 82.6%, ruin 1.24%, kill switch hit in **28%** of sims.
    The gold bot's realized distribution is not survivable at $100/0.01.
  - **BBH: OK** — 9 trades, 33% WR, RR 1.92, f* = −0.014; MC: p95 DD
    34.4%, 0% ruin, 0% kill hits. Envelope fits the account.
  - **BSH: too few trades** (2, both lost) to judge.
  - **Pooled f\* = +0.04 is a mirage** — GHP (retired, 3 wins +$49.02)
    fakes the edge; live bots are all ≤ 0.
- **Filed [[Layer 2 MC Drawdown]]**: tables, verdicts, and the build
  implications — kill switch is doing real work (28% of GBH sims breach
  −$50), Layer 1 gate confirmed (no bot sizes up), fix path is entry
  quality not sizing, fat-tail refinement (Lévy/tempered-stable) deferred.
- **Next**: Layer 3 walk-forward — needs the 21-month gold CSV re-downloaded
  (temp was wiped; pull M15 via MT5 MCP in chunks or re-export).

---

- **Downloaded 8 verified arxiv PDFs** into `raw/strategy/quant/` (all
  verified %PDF, one re-download after truncation): 2608.23416 (Axiomatic
  Trader, 97pp), 2608.00127 (Drawdown Beyond Brownian, 19pp), 2512.12924
  (Interpretable Hypothesis Trading, 35pp), 2510.15903 (Quantum/Classical ML
  DeFi, 14pp), 2205.00605 (Cluster Regression VI, 19pp), 2604.10758
  (Investing Is Compression, 15pp), 2011.06618 (Drawdown Lévy, 45pp),
  2103.15310 (Tempered Stable Extrema, 31pp).
- **Extracted all 8** with pypdf to `quant-extract\batch2\`; abstracts +
  metadata fetched from arXiv abs pages (authors, dates, journal refs:
  Finance & Stochastics 2022 for 2011.06618, Adv. Appl. Prob. 2023 for
  2103.15310).
- **Ingested 8 per-document pages** with key content + build-plan mapping:
  Axiomatic Trader → S5 robust fractional Kelly = layer 1, S3 purged-block
  CVaR = layer 3; Drawdown Beyond Brownian → layer 2 MC framework with
  non-Gaussian warning; Interpretable Hypothesis Trading → layer 3 template
  (34 rolling periods, honest p=0.34); Quantum/Classical ML → layer 4
  reality check (no quantum edge); Cluster Regression VI → regime-aware
  forecasting; Investing Is Compression → Kelly = money+entropy+divergence;
  Drawdown Lévy + Tempered Stable → layer 2 fat-tail drawdown math.
- **Repo clone-check (GitHub API, 25 catalog repos)**: 23 exist as listed;
  **2 owner corrections** — FinRL_DeepSeek is **benstaf** (331★, paper
  arXiv:2502.07393), quantitative-risk-management is **mcf-long-short**
  (21★). Risk page updated + flagged. Shallow-cloned 6 key repos (all OK):
  kelly-criterion (Python pkg), Garch-Method (method doc), MarketRegimeNet
  (466 files), backtest-engine (pyproject/uv), wf_optim_crypto_analysis (R +
  DVC pipeline), AI-XAUUSD-Trading (108 files).
- **Next**: layer 1 sizing implementation (Kelly gate + ATR sizing formula
  from [[Layer 1 Sizing Design]]) — pending user funding decision; layer 2
  MC resampler on the live trade list.

---

## [2026-09-18] ingest | 2nd catalog pass — user-verified links, 7 topic pages rewritten

- **User supplied a corrected, verified catalog** (7 topics) replacing the
  hallucinated-ID list. Verified against arXiv/websearch:
  - **Confirmed**: 2608.23416 (Axiomatic Trader), 2608.00127 (Drawdown
    Beyond Brownian), 2512.12924 (Interpretable Hypothesis-Driven Trading),
    2510.15903 (Quantum+Classical ML in DeFi), 2205.00605 (Cluster-based
    Regression via Variational Inference), 2604.10758 (Investing Is
    Compression — Kelly = money + entropy + divergence terms).
  - **Corrected IDs**: drawdown-in-Lévy paper is **2011.06618** (not
    2103.14744; Finance & Stochastics 2022, DOI 10.1007/s00780-022-00486-7);
    tempered-stable extrema MC is **2103.15310** (not 2103.15265; Adv. Appl.
    Prob. 2023, DOI 10.1017/apr.2023.1).
  - **Still unconfirmed (flagged)**: 2210.10515 (game-theoretic portfolios),
    2603.xxx (quantum rebalancing), plus ar5iv/scilit/TradingView
    search-title entries.
- **Owner-URL corrections**: SR_Mapping_NN → Mrizalfahlepi, ST-AI-Trading →
  Sahiltheram, market_forecaster → gkeiel, Advanced_AI_ML_Trading_Framework
  → CodingEye, oos-lab → OutOfSampleLab. **Signature Methods in Finance** is
  a real Springer open-access book (10.1007/978-3-031-97239-3); Portfolio
  Theory & Arbitrage → official AMS page (ams.org/books/gsm/214).
- **New high-value finds**: tmr-crypto/wf_optim_crypto_analysis (companion
  repo to our double-OOS paper), JonusNattapong/AI-XAUUSD-Trading
  (gold-specific ML), ProgramComputer/earnings-trade-automation (10% Kelly).
- **Rewrote all 7 topic pages** (kelly-sizing, monte-carlo, walk-forward,
  entry-filters, quant-math, ml-regression, risk) with the verified catalog
  + flagged-correction notes; index updated.
- **Next**: download newly verified PDFs (2608.23416, 2608.00127,
  2512.12924, 2510.15903, 2205.00605, 2604.10758, 2011.06618, 2103.15310)
  per the standing extract-and-ingest pattern, or take up the user's offer
  of abstract/BibTeX fetch or repo clone-check.

---

## [2026-09-18] synthesis | Layer 1 sizing design (Kelly + vol targeting)

- **Started layer 1 of [[Quant Math Build Plan]]** per user directive
  ("then start Layer 1 design"). Inputs: live gold sample (21 trades
  09-09→09-17), 21-month M1 CSV (744,518 bars → 49,636 M15), 5 sizing
  papers.
- **Kelly edge check — negative**: 7W/14L (33.3% WR), realized RR 1.74 →
  f* = p − q/b ≈ **−0.05**. At 33.3% WR the bot needs RR ≥ 2.0 to break
  even; it realized 1.74. Sizing scales edge, it cannot create it → stay
  at 0.01 lots until the v3.27 filtered sample proves f* > 0.
- **Volatility reality check** (CSV): M15 ATR(14) median 5.65 pts, p75
  8.71, p90 12.24. v3.26 SL = 1.5×ATR → **$8.48 median / $13.07 p75 risk
  per trade** = 8.5–13.1% of the $100 account. Only 27.6% of bars fit a
  $5 risk budget; 03-04 UTC vol barely lower (5.22 vs 5.65). D1 ATR p90 =
  $136.69 — the 09-16 crash was a ~1-in-10-day event, not a black swan.
- **Filed [[Layer 1 Sizing Design]]**: the formula to implement (half-Kelly
  × 2% cap, 0.01 floor, SL = 1.5×ATR), the 4-option decision table, and
  the measurement plan (Kelly gate: f* > 0 on ≥ 30 trades, monthly
  recompute).
- **Decision flagged for user**: ATR stop + $100 account are incompatible
  at 0.01 lots — recommendation **C: fund demo to ~$300–500** so 1.5×ATR
  ≈ 2–3% risk; until then 0.01 lots regardless of Kelly.

---

- **User directive**: "i gave u links download and extract and wiki ingest
  and lint" — download the catalog's books/PDFs into `raw/strategy/quant/`,
  extract, ingest each as a wiki source, lint.
- **CRITICAL FINDING — the catalog's arxiv IDs were hallucinated by the
  original web search**: 9 of 10 downloaded papers were unrelated (string
  theory, cosmology, nuclear physics, Alzheimer's, osteoarthritis, contact
  tracing, SnSe, NV-center, math functionals). Verified correct IDs via
  websearch and re-downloaded: **2309.09094** (sizing), **2002.03448**
  (Kelly→Lévy), **2602.10785** (double-OOS walk-forward, arxiv version of
  SSRN 3135062), **1510.05123** (optimal growth; the catalog's UCL link was
  an osteoarthritis paper), **2404.00012** (sentiment risk filter).
  **2104.04041** = CLVSA (real finance LSTM paper, kept under correct name).
- **Fixed the wrong URLs in 5 catalog pages** (kelly-sizing, walk-forward,
  entry-filters, ml-regression, quant-math) with flagged-correction notes;
  non-arxiv items re-pointed: Ritter ML-for-Trading → SSRN 3015609, Večeř
  analytical Kelly → SSRN 5121817, Portfolio Theory & Arbitrage → AMS
  bookstore (Karatzas & Kardaras), Signature Methods → 2207.13136 (closest
  verified match).
- **Downloaded**: 5 verified arxiv PDFs + Sutton & Barto RL 2nd ed (4.1 MB)
  + MIT OCW 15.450 full course site (16.8 MB zip → 33 PDFs). **Not
  obtainable** (documented, not silently dropped): 4 archive.org books
  (lending-restricted 401), CME handbook (IP-blocked), uv.es Monte Carlo
  (404), tradingsystemlab + risktech PDFs (HTML only, no Wayback), SSRN
  papers (bot-blocked, links kept), AMS book + Večeř article (paid).
- **Extracted** all 6 verified papers + Sutton & Barto to
  `C:\Users\ayan\AppData\Local\Temp\opencode\quant-extract\` (pypdf);
  verified MIT lecture topics from PDF page 1s.
- **Ingested 8 per-document source pages**:
  [[Quant Paper — Kelly Sizing 2309.09094]],
  [[Quant Paper — Kelly Lévy 2002.03448]],
  [[Quant Paper — Double-OOS Walk-Forward 2602.10785]],
  [[Quant Paper — Sentiment Risk Filter 2404.00012]],
  [[Quant Paper — Optimal Growth 1510.05123]],
  [[Quant Paper — CLVSA 2104.04041]],
  [[Quant Book — Sutton & Barto RL]],
  [[Quant Course — MIT 15.450 Analytics of Finance]] — each with key
  content, build-plan application, and terminology linked to concept pages.
- **MIT 15.450 lecture map** filed: lec 3 simulation (layer 2), lec 9
  bootstrap (layer 2/3), lec 10 GARCH (layer 1), lec 4–6 dynamic portfolio
  choice (layer 1), lec 7–8 MLE/GMM (layer 3).
- **Next**: layer 1 (Kelly/volatility sizing) design — inputs ready (live
  trade sample + 21-month CSV + the 5 sizing papers).

---

- **User directive**: "wiki all these sources up first, understand, keep
  consistent terminology, constantly update wiki and lint" — the quant math
  catalog for the gold bot build.
- **Ingested 7 source pages** (one per topic, 10 resources each, all URLs
  verified from user's catalog): Kelly/volatility sizing, Monte Carlo
  drawdown, walk-forward framework, entry filters, quant math books/papers,
  ML regression & training, risk management.
- **5 new concept pages** (the terminology anchor): [[Kelly Criterion]],
  [[Volatility Targeting]], [[Monte Carlo Simulation]], [[Walk-Forward Analysis]], [[Overfitting]] — every quant term now has one definition.
- **Filed [[Quant Math Build Plan]]** — the user-approved locked order:
  1) Kelly/volatility sizing, 2) Monte Carlo drawdown, 3) walk-forward
  framework, 4) entry filters. Includes the terminology table (the "same
  terms" contract), data/tooling notes, and status checkboxes.
- **Consistency notes**: VP sweep reframed as the wiki's own [[Overfitting]]
  proof (30 configs, best = noise); v3.27 ATR SL/TP documented as the
  volatility-targeting foundation; 03-04 UTC window analysis cross-linked
  to the regime-gating candidate.
- **Open questions**: user's book/PDF materials for `raw/strategy/` still
  pending — layer 1 design starts once they arrive (or on user approval
  from the live trade sample).

---

- **Ingest**: pulled deals for all three bots (account 169324224, MCP
  09-17 ~21:50 UTC). Gold (magic 20260915): **7 trades, 2W/5L, −$8.79** —
  ALL trend-continuation entries, ALL fired OUTSIDE 03-04 UTC. BTC breakout
  (magic 20260917): **4 trades, 2W/2L, +$5.55** (only profitable bot). BTC
  swing (magic 20260916): **first trades ever** — 2 SELLs 09-17, 1 SL'd
  −$8.02 (ATR SL 798 pts), 1 open. Balance **$71.82** (from $100 reset).
  Filed: [[2026-09-17 Bot Week Session]].
- **Root causes** (filed [[2026-09-17 Loss Causes]]): (1) **v3.25 regressed
  the hour window to `0/0 = all day`** — the wiki never documented v3.25
  (stale 5 days); (2) trend-continuation entries now 4W/9L = 30.8% < 33.3%
  breakeven; (3) $5 SL = 5 pts = inside M15 noise (5 of 7 losers died on
  5–8 pt wiggles); (4) 09-16 21:00 UTC crash (~132 pts in 1h, M15 bars
  4–6× normal range) preceded 3 losing trades; (5) 09-15 21:48 trade risked
  $7.72 not $5 — open question.
- **Build v3.26 gold** (THE FOUR FIXES, per the header plan): (1) hour
  window default restored **3-4 UTC**; (2) **ATR-based SL/TP** default ON
  (SL 1.5× / TP 3.0× M15 ATR(14); fixed $5/$10 via `InpUseATRSL=false`);
  (3) **volatility spike filter** — 30-min entry pause after a closed M15
  bar's range > 3× the 20-bar average; (4) **fresh guard on trend entries**
  (previous M1 bar must close inside the channel). Init print now shows
  version, hour window, SL/TP mode, filter state. **Compiled 0 errors/0
  warnings** (MetaEditor, 636 ms).
- **Wiki sync**: entities updated (gold v3.26 config + week results, BBH
  week results, BSH first trades, XM accounts $71.82), index + log updated.
- **Open questions**: what set the 09-15 21:48 SL at 7.72 pts? Does BSH
  stay on the chart (ATR SL ~$8/loss)? Does 03-04 UTC + channel-break-only
  trade often enough?

---

## [2026-09-12] analysis+build | Hour-window discovery + v3.24/v1.06 hard-cap build

- **Analysis**: volatility/channel-range filter tested on 21 months — **DEAD**
  (negative at every threshold on 20-21 UTC 2025; the edge is the hour, not
  the filter). **03-04 UTC is the ONLY hour window positive in BOTH 2025
  (+0.95) and 2026 (+0.67)**; combined +0.81 (n=9348), 16/21 positive months;
  all-hours expectancy −0.11. The earlier "03-04 fails" was a 6-week regime
  rotation artifact (Sep 2026: 03-04 −1.57 while 20-21 +1.77). Filed:
  [[Hour Window Analysis 2026-09-12]].
- **Cap audit**: gold server day 09-11 = **7 entries** (cap 4) — root cause:
  `InpResetDailyCounters=true` at attach zeroes the counter mid-day. Gold's
  `CountTradesToday()` was actually correct (7); the "(4 trades)" log message
  prints `InpMaxTradesPerDay`, not the counter. BTC: 3 entries in history but
  counter restored 4 — unresolved; diagnostic added.
- **Build v3.24 gold**: `InpStartHourUTC`/`InpEndHourUTC` (default 3-4 UTC),
  daily cap refreshed from history every minute (holds across re-attaches and
  manual resets), limit message printed once/day, trend-entry comments tagged
  (`GBH BUY T`/`GBH SELL T`) + `CountTrendEntriesToday()` restores the 3/day
  trend cap (closes the v3.21 residual gap). Compiled 0/0, deployed.
- **Build v1.06 BTC**: cap refreshed from history every minute, limit message
  once/day, `CountTradesToday(true)` diagnostic at init (prints each counted
  deal — resolves the 4-vs-3 question on next attach). Compiled 0/0, deployed.
- **Account**: bots run on demo **169324224** (XMGlobal-MT5 2) — third
  account, now documented in [[XM Accounts]]. Balance $93.98 (MCP pull
  09-11 ~19:00 UTC).

---

## [2026-09-11] analysis | Entry-quality retrospective — all 7 gold trades reconstructed from M1

- **Method**: full M1 dataset (101,072 bars, 2026-06-02 → 09-11 18:52 UTC,
  user-provided CSV) + v3.21 EA source → exact indicator values at each
  entry (Donchian M1-20, slope 21–40, M15 EMA50, H1 EMA50, fresh guard).
  All deal times UTC; all fills inside their CSV bar ranges (feed matches).
- **Correction**: ALL 6 sells were **trend-continuation entries** — the
  channel-break path never fired (price was always 0.07–4.28 pts ABOVE the
  channel low). Earlier M15-based classification (#2/#5/#6 = channel breaks)
  was wrong.
- **Entry quality**: trend sells entered 27–41 pts below M15 EMA50, within
  5 pts of the channel low = selling the bottom of the range. 2W/4L = 33.3%
  = exactly breakeven at 2:1 RR. Winners (#2, #3) were the freshest entries
  (MAE < 0.4 pts); losers were re-entries into the same grind.
- **#7** was a marginal channel break (0.17 pts above the 20-bar high after
  a 50-pt rally) — bought the top; SL correct (price crashed 27 pts after).
- **Cap-bug cost −$15.76**: if the 4/day cap had held (#1–#4): +$10.39.
  Cap-bug trades #5/#6/#7 all lost. Also found: the 3/day trend-continuation
  counter was violated (#4–#6 fired as trendSell after #1–#3 used all 3) —
  `g_trendEntriesToday` still resets on re-attach (residual gap in v3.21).
- **Filed**: `wiki/synthesis/entry-quality-retrospective-2026-09-11.md`;
  entity page corrected (7 trades, −$5.37, v3.21, cap-bug finding).

---

## [2026-09-11] trade | Gold overnight session (v3.20) — 3 trades, gate verified both ways

- **Trade #3 (01:30)**: SELL 0.01 GOLD @ **4324.12** (SL 4329.20, TP
  4314.20). TP hit 04:11:18 at **4314.21** → **+$9.91** (+$0.13 swap).
  Balance 104.92 → 105.83.
- **Trade #4 (04:12)**: SELL 0.01 GOLD @ **4315.54** (SL 4320.10, TP
  4305.10). SL hit 04:31:55 at **4320.11** → **−$4.57**. Fired **1 minute
  after the trade #3 TP** — the v3.20 "no restriction after TP" working as
  designed.
- **Trade #5 (05:08)**: SELL 0.01 GOLD @ **4314.60** (SL 4319.60, TP
  4304.60). SL hit 05:31:05 at **4319.86** → **−$5.26**. Fired **37 minutes
  after the trade #4 SL** — the stop-out penalty was ON and required a NEW
  channel low before re-entry; price fell to 4314.60 (below the SL-time low
  ~4315) → gate passed → re-entry. The market bounced again anyway — the
  gate did its job (required proof), the trade lost on the bounce.
- **Scoreboard (v3.18+ era, fresh $100)**: 5 trades, 2W/3L — #1 −$5.26, #2
  +$10.18, #3 +$9.91, #4 −$4.57, #5 −$5.26 → **net +$5.13 → balance
  $105.13**. Win rate 40% > 33.3% breakeven for 2:1 RR — net positive as
  designed.
- Gold used **3 of 4 daily trades** (server day); one entry left today.
- Entry types for trades #3–#5 (trend-continuation vs channel break) not
  confirmed — status prints are UI-only, not in the terminal log.

## [2026-09-11] trade | BTC first trade ever (v1.04) — SELL open

- **04:00:01 SELL 0.01 BTCUSD @ 77048.45** (SL 77548.45 = $5, TP 76048.45 =
  $10) — the BTC bot's **first trade** after ~30h attached (v1.00 09-10
  21:35 → v1.04 00:38). Magic 20260917, comment `BBH SELL`.
- **Still open** as of 07:36: price 76905.25 → **+$1.43 floating**. SL/TP
  are 500/1000 points = the fixed $5/$10 (2:1 RR) on BTC.
- BTC used 1 of 4 daily trades.

## [2026-09-11] build | v3.20/v1.04 stop-out penalty gate — time cooldown replaced

- **User question**: "instead of getting blind for 5 minutes dont we have
  other solution for it ?? idk some kind of a gate or flag" — the cooldown
  was a **clock**, not a market signal. After an SL the bot waited blind
  time; after a TP it was punished too (trend confirmed, should re-enter).
- **Fix (v3.20 gold / v1.04 BTC)**: **stop-out penalty flag** replaces the
  cooldown entirely (`InpCooldownMinutes` removed):
  - After an **SL**: same-direction entries blocked until the channel makes
    a **NEW extreme** (new low for sells / new high for buys) — the market
    must prove the bounce failed. No time blindness: waits as long as
    needed, never blocks a fresh opposite signal.
  - After a **TP**: **no restriction** — re-enter on the next signal (bar
    gate + daily limit + kill switch still apply).
  - Detection: `CheckLastExit()` scans history once per minute for the last
    SL/TP deal on our magic (`DEAL_REASON_SL`/`DEAL_REASON_TP`); stores the
    channel extreme at detection (same 20-bar window as entry logic).
    Kill-switch/manual closes (reason ≠ SL/TP) do NOT trigger the penalty.
  - Status print now shows `SLpenalty: ON(SELL)/ON(BUY)/off`.
- **Validated against trade #2**: SELL SL at 00:21 (channel low ~4330.04);
  price made a new low below it before 00:31 → gate would have passed →
  trade #2 (+$10.18) still fires. The gate blocks only repeated sells into
  the same support zone.
- Compiled **0 errors / 0 warnings** both; deployed 00:38 (gold 31,968 B,
  BTC 31,936 B).
- **Action**: remove + re-attach both EAs. Expect `v3.20 initialized` /
  `v1.04 initialized`.

## [2026-09-11] trade | Trade #2 +$10.18 TP win — cooldown fix validated

- **00:31:00 SELL 0.01 GOLD @ 4326.68** (SL 4331.53, TP 4316.53) — fired
  **1 minute after the v3.19 re-attach** (00:30:36). TP hit 00:32:51 at
  **4316.50** → **+$10.18**. Balance 94.74 → **104.92**.
- **The cooldown fix paid for itself immediately**: trade #1 opened 00:20.
  With the old 15-min cooldown the bot was blocked until 00:35 and would
  have **missed this exact winning trade**. The 5-min cooldown let it
  through; the v3.20 gate removes the clock entirely.
- **Scoreboard (v3.18+ era)**: trade #1 SELL 4331.49 → SL −$5.26; trade #2
  SELL 4326.68 → TP +$10.18. **Net +$4.92** — the 2:1 RR working as
  designed (lose $5, win $10, net positive even at 50/50).

## [2026-09-11] fix | v3.19/v1.03 status print before gates + cooldown 15→5

- **Symptom**: after trade #1 (00:20 SELL → SL 00:21:20) the bot went
  **silent** — user: "no new prints". Root cause: the status print sat
  AFTER the cooldown/position/daily gates, so during the 15-min cooldown
  the bot returned early and printed nothing. Looked dead, was waiting.
- **Fix (v3.19 gold / v1.03 BTC)**: status print moved **before all gates**
  — the bot now reports every M1 bar (gold) / M5 bar (BTC) regardless of
  position, cooldown, or daily-limit state. Cooldown default cut 15 → 5 min
  (bar gate + daily limit + kill switch already cover spam).
- Compiled **0 errors / 0 warnings** both; deployed 00:30 (gold 30,440 B,
  BTC 31,308 B).
- **Also confirmed from the terminal log**: EA `Print()` never reaches the
  log file — only terminal-generated lines (loads/removes/trades) do. The
  00:20 SELL and 00:21 SL close ARE in the log; status prints are UI-only.

## [2026-09-11] fix | v3.18/v1.02 raw trend fix — trade #1 −$5.26

- **Root cause found**: v3.17 still showed `TrendCont: false/false` with
  price 42 pts below EMA50 because `bearish`/`bullish` were themselves
  **slope-filtered** (`InpUseEMASlope` ANDed `bearish` with `emaFalling`).
  Slope read RISE on a single M15 bar bounce → bearish = FALSE → trendSell
  never fired. Trend entries now use **raw** price-vs-EMA50
  (`rawBearish = bid < ema50[0]`); channel breaks keep the slope filter.
- **Trade #1 (the proof the fix works)**: 00:20 SELL 0.01 GOLD @ **4331.49**
  (SL 4336.53, TP 4321.53) — all 5 checks green (raw distance 43 pts ≥ 10,
  proximity 1.5 pts ≤ 5, H1 DOWN, channel FALLING, allowance 0/3). SL hit
  00:21:20 at 4336.75 → **−$5.26**. Balance 100.00 → 94.74.
- **Honest read**: the loss is not a code failure — the bot did exactly
  what it was built to do. But the entry was 1.45 pts above the channel low
  (4330.04) = **selling into support**; the trade lasted 80 seconds. That
  entry-quality question is tracked for the 20–30 trade sample, not judged
  on one trade.
- Compiled **0 errors / 0 warnings** both; deployed 00:19 (gold 30,128 B,
  BTC 30,006 B).

## [2026-09-10] build | v3.16 trend-continuation mode (slow-grind fix)

- **Trigger**: gold fell 4359 → 4340 over 2+ hours with the bot watching —
  the Donchian channel low ratchets down with price in a grind, so price
  never "breaks" it. User: "MISSED A GOOD TRADE", "KEEPPPS GOIN LOW".
- **Root cause (verified, no guessing)**: at 21:16 UTC every gate was GREEN
  (EMA50 FALL with the v3.15 3-bar fix, channel FALLING, H1 DOWN, fresh
  breakout TRUE) except one: `bid < lowMin` — bid 4342.30 vs channel low
  4338.55. The bot was armed and 3.75 points from firing. Not a bug — a
  design gap: breakouts don't fire in grinds.
- **Fix (v3.16)**: trend-continuation entries — when the EMA50 is falling
  HARD, enter NEAR the channel low instead of waiting for a break:
  - `InpUseTrendContinuation = true` (master switch)
  - `InpEMASlopeThreshold = 2.0` — EMA50 must decline ≥2 pts over 3 M15
    bars (45 min) = "falling hard"
  - `InpChannelProximity = 5.0` — enter when bid ≤ channel low + 5 pts
  - `InpMaxTrendEntriesPerDay = 3` — cap (total trades still ≤ 4/day)
  - Same filters as channel break (H1 confirm, channel slope), same
    $5 SL / $10 TP. Trend entries counted separately in status print
    (`TrendCont: sell/buy (n/3)`).
- Compiled **0 errors / 0 warnings**, deployed 23:53 (31,118 bytes).
- **Action**: remove + re-attach on GOLD,M15. Expect `v3.16 initialized`.

## [2026-09-10] fix | v3.15 smoothed EMA slope (3-bar comparison)

- **Trigger**: gold kept grinding lower (4359 → 4349) with the EMA50
  actually falling for an hour (4384.13 → 4380.30) — but the bar-to-bar
  slope kept printing RISE, blocking every sell. User: "KEEPPPS GOIN LOW".
- **Fix**: EMA50 slope now compares `ema50[0]` vs `ema50[3]` (3 M15 bars =
  45 min) instead of bar-to-bar. Same protection (no selling into a real
  rising EMA), no one-bar wiggle. With this fix the slope reads FALL and
  the bot sells the next break below the channel low.
- Compiled **0 errors / 0 warnings**, deployed 23:37 (29,490 bytes).
- **Action**: remove + re-attach on GOLD,M15. Expect `v3.15 initialized`.

## [2026-09-10] build | BTCBreakoutHunter_Zaid_v1 — BTC bot that actually trades

- **Trigger**: user frustrated — "build another btc usd one is never trades i
  need one atleewasy". BTCSwingHunter_Zaid_v2 (swing model, ~16 round-trips/
  year) sat for 24h+ with 0 trades. It was working as designed, but the user
  wants a bot that trades.
- **Solution**: port of GoldBreakoutHunter v3.14 to BTCUSD — same proven
  filters, but BTC moves enough that breakouts fire daily:
  - Donchian breakout on **M5 channel** (20 bars = 100 min; M1 too noisy on
    BTC) — `InpChannelTF` input, changeable
  - M15 EMA50 trend + **EMA slope** filter + **H1 confirm** (same as gold)
  - Fixed **$5 SL / $10 TP** (2:1) via tick-value conversion — on BTC that's
    ~500/1000 points (0.6%/1.3% of price)
  - Kill switch +$32/−$50, max 4 trades/day, 15 min cooldown, magic
    **20260917**, comments `BBH BUY`/`BBH SELL`, status print `BBH status`
  - Reopen guard kept (fires only on broker-maintenance gaps; BTC is 24/7)
- Compiled **0 errors / 0 warnings**, deployed 21:35 (28,718 bytes).
- **Action**: remove BTCSwingHunter_Zaid_v2 from the BTCUSD chart, attach
  BTCBreakoutHunter_Zaid_v1. Expect init print `BTCBreakoutHunter v1.00
  initialized... Channel: 20xPERIOD_M5`.

## [2026-09-10] fix | v3.14 fixed $5 SL / $10 TP (2:1)

- **User directive**: "lets do good trades okay 10 doller pl and 5 doller sl
  rr to be 2" — stop loss **$5**, take profit **$10**, RR 2:1.
- **Change**: replaced ATR-based SL/TP (`InpATRPeriod`, `InpATRMultiplier`,
  `InpRR` removed) with fixed money inputs `InpSLMoney = 5.0`,
  `InpTPMoney = 10.0`. $ → price distance via `SYMBOL_TRADE_TICK_VALUE` /
  `SYMBOL_TRADE_TICK_SIZE` × volume, so it stays correct for any symbol/lot.
  Gold 0.01 lot: $1 = 1.00 price move → SL 5.00 / TP 10.00.
- ATR handle/read removed entirely (dead code). Compiled **0 errors / 0
  warnings**, deployed 20:31 (27,720 bytes).
- Kill switch unchanged (+$32 / -$50) — user did not answer the scale
  question; still flagged as 32%/50% of the $100 balance.
- **Action needed**: remove + re-attach EA on GOLD,M15 to load new ex5
  (MT5 caches old builds). Expect init print `v3.14`.

## [2026-09-10] event | demo account reset to $100 — fresh start

- **What happened**: user reset the demo balance to **$100.00** on purpose
  ("to make me feel like if we start thats how it will end or go").
  Deal: `SetCustomBalance -925.71` at 09:43:06 UTC → balance 1025.71 → 100.00.
- **State at reset**: flat, no positions, no pending orders. Terminal had
  restarted 19:36:04 (system shutdown at 09:55:28); both EAs auto-loaded
  19:36:05 — gold **v3.13** (28,044 B) and BTC **v2.01** (23,960 B), both
  latest builds.
- **Implication**: the 4-trade filter sample (1W/3L, -7.38) still stands as
  filter data, but the account history is now clean. Kill-switch limits
  (+$32 / -$50) are now 32% / 50% of the account — flagged to user, their
  call whether to scale.
- **Sample restarts from $100.00.**

## [2026-09-10] fix | v3.13 trend quality — EMA slope + H1 confirm + reopen guard

- **Trigger**: 4 trades under v3.12 filter → 1W/3L, net **-7.38** (balance
  1033.09 → 1025.71). All 4 trades were BUYS into a dead-cat bounce after
  hours of downtrend (4420 → 4389, then bounce to 4420.83):
  - T1 01:02 UTC BUY 4405.75 → SL -3.05 (market-reopen gap fakeout)
  - T2 03:52 UTC BUY 4401.74 → **TP +6.38** (bought start of bounce)
  - T3 04:09 UTC BUY 4417.29 → SL -5.98 (bought top of spike)
  - T4 05:06 UTC BUY 4418.58 → SL -4.73 (bought higher top)
- **Root cause**: EMA50 filter too weak — only checks *price vs EMA50*. A
  bounce above a still-FALLING EMA50 reads as "bullish" → bot buys dead-cat
  bounces. Fresh-breakout guard useless in fast rallies (M1 channel ratchets
  up with price).
- **Fixes (v3.13, same magic 20260915)**:
  1. **EMA slope filter** (`InpUseEMASlope`, on): BUY only if the M15 EMA50
     itself is RISING, SELL only if FALLING. A bounce above a falling EMA is
     not an uptrend. Would have blocked T1, T3, T4 (the 3 losers).
  2. **H1 confirmation** (`InpUseH1Confirm`, on): M15 signal must agree with
     H1 EMA50 trend. Blocks M15 bounces inside an H1 downtrend.
  3. **Post-reopen guard** (`InpReopenGuardMinutes` = 20): detects the daily
     market break (M1 bar gap > 5 min) and pauses entries for 20 min after
     reopen. Blocks gap fakeouts (T1).
- Status print now shows `EMA50: <price> RISE/FALL` and `H1: UP/DOWN` so we
  can see exactly what blocks each entry.
- Compiled **0 errors / 0 warnings**, deployed 09:13 (28,044 bytes).
- **Sample so far**: 4 trades under fixed filter (1W/3L, -7.38). The sample
  is doing its job — it exposed the weak trend filter in 4 trades.

## [2026-09-10] fix | bar-gate robustness — BSH v2.01 + gold v3.12

- **Symptom**: BTCSwingHunter_Zaid_v2 attached ~24h across 5 sessions (09-09
  00:36, 19:43, 23:28; 09-10 00:02) — **0 trades, 0 status prints visible in
  the log file**. User: "it didnt even trade once... thats bad dont you think".
- **Honest answer**: not bad by design — this is a **swing bot** (Paul Wei
  model: ~16 round-trips/year, holds days). A day without a trade is normal.
  Current state (22:10 UTC): H4 trend DOWN (78,388 < H4 EMA50 ~79k), price
  below H1 EMA21, RSI < 55 → waiting for an UP-pullback to H1 EMA21 with
  RSI > 55 to sell. No setup present.
- **Real bug found (both bots)**: `g_lastBarTime` advanced **before** the
  `CopyBuffer` reads. If an indicator read failed on the first tick of a bar
  (common right after attach), the bot returned silently — and the bar gate
  then skipped the **entire bar** (1 hour for BSH, 1 minute for gold). One
  bad tick = one dead bar.
- **Fix (BSH v2.01 + gold v3.12)**: indicator reads moved **before** the bar
  gate — a failed read returns WITHOUT advancing `g_lastBarTime`, so the bot
  retries next tick instead of skipping the bar.
- Compiled **0 errors / 0 warnings** both; deployed 00:45 (BSH 23,930 bytes,
  gold 26,668 bytes).
- **Also confirmed**: EA `Print()` output does **not** reach the log file
  (zero prints from any EA in 2 days of logs, yet visible in the terminal UI
  Experts tab — user pasted the v3.11 init line). Log file only carries
  terminal-generated lines (loads/removes/trades). Verification of EA
  liveness must use the terminal UI Experts tab, not the file.

## [2026-09-10] fix | v3.11 kill-switch/close bug — 2 naked trades + root cause

- **Incident (00:16–00:21 server)**: v3.10's kill switch fired and produced
  **2 naked trades (no SL/TP)** that the user had to close manually:
  - 00:16:45 — kill switch fired → printed `Closed position #2307811010
    result: 10009` (retcode DONE) but **did NOT close it** — instead opened
    **NEW BUY 4408.91** (ticket 2307815810, comment "KillSwitch/Cutoff
    close", **no SL/TP**) — mistake #1
  - 00:20:17 — SELL #2307811010 (v3.00's trade, 4412.07 → TP 4405.81 zone)
    hit TP at 4405.72 → **+$6.35 win** (the "win from 3.0")
  - 00:20:21 — kill switch fired **again** → opened **NEW SELL 4405.67**
    (ticket 2307820670, **no SL/TP**) — mistake #2
  - 00:21:03–04 — user closed both mistakes manually (4407.83 / 4407.23)
    → **−$1.68 / −$2.16**
- **Net**: +$6.35 − $1.68 − $2.16 = **+$2.51** → balance 1030.58 → **1033.09**.
  Account flat.
- **Root cause — 3 bugs in v3.10**:
  1. **`CloseAllPositions()` never set `request.position = ticket`** — in MT5
     a market order without a position reference **opens a NEW position**
     instead of closing. The "close" created naked trades. **Critical.**
  2. **Kill switch counted YESTERDAY's P/L** — `g_dayStart = iTime(PERIOD_D1, 0)`
     uses the D1 bar boundary (00:00 UTC = 21:30 server). v3.10 loaded at
     21:44 UTC (still inside 09-09's D1 bar) → counted 09-09's +$15.31 +
     floating → +$18.47 ≥ +$10 → **fired instantly on load**.
  3. **Kill switch re-fired every tick** — `CheckKillSwitch()` ran *before*
     the `g_dayStopped` guard, so once tripped it fired on every tick,
     opening a new naked trade each time.
- **Fixes (v3.11, same magic 20260915)**:
  1. `request.position = ticket` added to `CloseAllPositions()` — closes now
     actually close.
  2. Day start = **server midnight** (`ServerDayStart()` helper) — kill
     switch counts only today's P/L.
  3. `g_dayStopped` guard moved **before** `CheckKillSwitch()` — fires once
     per day max.
  4. **Kill switch profit target raised to +$32** (user directive; loss
     limit stays −$50).
- Compiled **0 errors / 0 warnings**, deployed to MT5 Experts folder
  (v3.11, 26,592 bytes, 2026-09-10 00:32).
- **Lesson**: a "successful" close retcode (10009) does not mean a position
  closed — verify `request.position` is set and confirm via deal log.

## [2026-09-10] fix | v3.10 trend-filter fix — root cause of counter-trend BUYs

- **Diagnosis**: 3 of 4 morning BUYs hit SL (trades 2/3/5 on 2026-09-09) because
  the EMA50 trend filter ran on **M1** — 50 minutes of noise. In the falling
  market, price kept bouncing above M1 EMA50 for minutes at a time → bot saw
  "bullish" → bought box-top breaks → SL. The M15 trend was DOWN the whole time.
- **Fixes (v3.10, same magic 20260915, same SL/TP/gates)**:
  1. **Trend filter moved to M15** (`InpTrendTF = PERIOD_M15`) — real trend,
     not noise.
  2. **Channel-slope confirmation** — BUY only if the 20-bar channel is
     rising, SELL only if falling (no buying flat/falling channels = no
     buying tops).
  3. **Fresh-breakout guard** — previous M1 bar must close inside the
     channel; no entries when price is already extended/chasing.
  4. Loss-limit default corrected to **−$50** in code (was 5.0; chart input
     had overridden it).
- Compiled **0 errors / 0 warnings**, deployed to MT5 Experts folder
  (v3.10, 26,588 bytes, 2026-09-10 00:13).
- **User directive**: fix v3 itself, do NOT build v4 yet — v4 is a bigger
  thing to find later. v3 keeps collecting trades under the fixed filter.

## [2026-09-09] trade | Small double-fire closed −$3.44 — wrong bot attached

- **Wrong bot attached**: user re-attached **GoldHunterPro Small** (magic
  20260910) at 23:52:33 instead of v3 — Small is the retired bot.
- **Double-fire**: Small fired **2 BUY entries 26s apart** from a single
  instance (stacking bug — no open-position check):
  - BUY 4419.32 (ticket 2307797870, SL 4411.34, TP 4435.34, 23:52:35)
  - BUY 4419.38 (ticket 2307797997, SL 4411.36, TP 4435.36, 23:53:00)
- **Closed manually** 23:55:54–55 server, both at **4417.63** (deals
  #2167391177, #2167391183) → **−$1.69 / −$1.75 = −$3.44 total**.
  Small removed from chart 23:55:51.
- Balance: 1034.02 → **1030.58**. Account flat.
- **Lesson**: Small's stacking bug confirmed (single instance, 2 entries in
  26s). v3 (magic 20260915) is the bot to run; Small stays retired.

## [2026-09-09] trade | Trade #1 closed +$2.69 — scripts removed from charts

- **Scripts removed** (MT5 log): v3 (GOLD,M15) removed 23:36:17,
  BTCSwingHunter v2 (BTCUSD,M15) removed 23:36:19. Agent is sole trader.
- **Trade #1 closed**: BUY 0.01 GOLD 4416.94 (ticket 2307782344, opened
  20:59 UTC) closed **manually** 23:45:36 server at **4419.63** → **+$2.69**
  (deal #2167386144, order #2307794666). Not TP/SL — user pulled out at
  +$2.69, matching the "small profit, pull out" style.
- Balance: 1031.33 → **1034.02**. Account flat.
- **Daily cutoff reached** (23:59 local) — no new trades until next day.
  Day total: +$2.69 (agent-managed portion).

## [2026-09-09] decision | New trading plan — $5 targets, 2:1 RR, agent trades

- **User directive**: "do it now itself start from now" — agent starts
  trading immediately with the new plan.
- **Plan**: 0.01 lots, **target +$5, stop −$2.50** (2:1 RR). Spread on GOLD
  is $0.56/round-trip (11% of target) — profitable even at 50% win rate
  (+$0.69/trade). ~35 trades to net $50 at 60% WR.
- **Why $5 not $2–3**: at $2.50 targets the spread ate 19–28% of the prize
  (breakeven needed ~60% WR at 1:1); at $5 it's 11% and 50% WR is
  profitable.
- **Rules**: one trade at a time, SL/TP always set, kill switch −$50/day,
  daily cutoff 23:59 local, every trade logged.
- **Trade #1**: the open v3 BUY (ticket 2307782344, 4416.94, SL 4414.09,
  TP 4423.09, RR 2.16:1) — taken over as the agent's first trade under the
  plan; fits the $5-target profile (+$6.15).

## [2026-09-09] decision | Agent takes over as trader — scripts removed from charts

- **User directive**: "the scripts wont make trades u will" — the agent
  (via MT5 MCP) is now the **sole trader**. Scripts (GoldBreakoutHunter v3,
  BTCSwingHunter v2, GoldHunterPro Small) removed from MT5 charts by the
  user.
- **Open v3 BUY survives removal** (ticket 2307782344, 4416.94, SL 4414.09,
  TP 4423.09): removing an EA from a chart does not close positions; SL/TP
  already set. Agent manages it to TP/SL as its own trade.
- **Agent takes over risk rules manually**: kill switch (+$10 profit /
  −$50 loss), daily cutoff (23:59 local), SL/TP always set, one trade at a
  time, every trade logged to the wiki.
- `.mq5` sources stay in the repo — strategy logic remains the reference
  for upgrades (v4 trend-continuation entry still on the table).

## [2026-09-09] session | VPS migration + evening trades — v3 +$3.99 day, Small cameo +$16.02

- **VPS migration**: 19:43:29 log shows "use MetaTrader VPS Hosting Service
  to speed up the execution: 2.85 ms via 'VPS London LD6 04' instead of
  204.98 ms". v3 + BTCSwingHunter re-attached 19:43:28. **Bot was offline
  06:31–19:43** — missed the $69 rally (~4357 → 4426).
- **3 new trades after re-attach**:
  - 19:59:59 BUY 4426.31 (v3, SL 4420.08, TP 4438.76) → SL hit 4419.89
    (20:13:32) → **−$6.42** — bought the top of the rally.
  - 21:03:59 BUY 4398.62 (v3, SL 4390.10, TP 4415.59) → TP hit 4415.62
    (22:36:02) → **+$17.00** ✅ — bought the pullback, caught the bounce.
  - 21:57:02 BUY 4401.09 (SL 4393.09, TP 4417.09) → TP hit 4417.11
    (22:36:14) → **+$16.02** ✅ — **NOT v3's**: user loaded GoldHunterPro
    Small (magic 20260910) at 21:57:00 for 34 seconds (removed 21:57:34,
    v3 re-loaded). Small opened it; both positions hit TP 12s apart.
- **v3 day total: +$3.99** (7 trades, 3W/4L, 42.9% win rate; wins
  +$8.36/+$8.13/+$17.00, losses −$5.21/−$2.64/−$3.91/−$6.42, plus early
  −$11.32). Kill switch (+$10 profit target) **not fired** — one more TP
  win would trigger it.
- **Small cameo**: +$16.02 in 34 seconds of life. Recorded on its entity
  page (retired from tracking, but the trade is real).
- **Account day total: +$20.01** (v3 +$3.99 + Small +$16.02).
- Current state: v3 running (re-loaded 21:57:34), flat, waiting. BTC bot:
  0 trades. Both on VPS now.

## [2026-09-09] session | GoldBreakoutHunter v3 — 5 trades, net +$4.73 (2W/3L)

- After the first win (+$8.36 at 01:28:58), v3 kept trading overnight — **4
  more trades, all BUYs** (trend flipped UP above EMA50, box-top breaks):
  - 03:32 BUY 4358.27 (SL 4353.08, TP 4368.65) → SL hit 4353.06 → **−$5.21**
  - 04:30 BUY 4354.31 (SL 4351.67, TP 4360.67) → SL hit 4351.67 → **−$2.64**
  - 06:10 BUY 4349.63 (SL 4345.67, TP 4357.56) → TP hit 4357.76 → **+$8.13** ✅
  - 06:28 BUY 4361.42 (SL 4357.79, TP 4368.76) → SL hit 4357.51 → **−$3.91**
- **Day total: +$4.73 across 5 trades — 2W/3L, 40% win rate.** RR 2.0 →
  breakeven at 33.3% → profitable day. Kill switch (−50) never re-fired;
  magic-20260915 daily P/L ≈ **−$6.59** including the earlier −11.32.
- **Pattern**: 3 of 4 BUYs were counter-trend bounces in a falling market
  (bought box-top breaks while price kept making lower lows) → SL hits. The
  06:10 BUY caught the real bounce → TP. Trend filter worked as designed:
  the SELL (trend DOWN) won; the BUYs (trend UP) mostly lost.
- **Cap note**: 5 trades fired with `MaxTradesPerDay` default 4 — the chart
  input is likely set to 5 (or higher). Bot stopped after trade 5. Flagged
  for the user to verify in EA properties.
- Attribution verified: only v3 (GOLD,M15, loaded 00:36:24) and
  BTCSwingHunter v2 (BTCUSD) were running after 00:36 — all 5 trades are
  v3's (magic 20260915, SL/TP always set, entries at :02 past the minute =
  EA pattern, not manual).

## [2026-09-09] session | GoldBreakoutHunter FIRST LIVE WIN (+$8.36) + manual-trade "flood" false alarm

- **First real breakout trade**: `GoldBreakoutHunter_Zaid_v3` (GOLD,M15)
  sold at **4367.52** (00:50:01) — price broke the 20-bar box bottom
  (4367.58), DistLo went negative (−0.07), trend DOWN. SL 4371.57, TP
  4359.38, breakout level 4367.58.
- **WIN**: closed **01:28:58 at 4359.16** (TP hit, filled better than the
  4359.38 target) → **+$8.36** in ~39 minutes. RR 2.0 reward captured in
  full. First verified live trade for the breakout strategy.
- **"Flood" false alarm**: ~00:22 the user manually traded sell/buy pairs
  (no SL/TP on those orders — bots always set SL/TP, manual trades don't).
  Confirmed manual, not a bot flood. All EA sources re-reviewed and clean:
  v3, BTCSwingHunter_v2, GoldHunterPro Small/Micro, AMNSweepHunter
  Loose/Strict — every one has per-bar gates + position caps. The old flood
  bug is gone.
- **Kill switch fired at −11.32** (00:28:43) — v3 had traded 4× earlier
  (2 sells 00:10 + 2 buys 00:18 from dual M5+M15 instances) and lost.
  Loss limit raised **−$5 → −$50** so the bot could trade the rest of the
  day; recompiled 0 errors, re-attached fresh.
- **Chasing-channel lesson**: at 00:49 the box bottom (4369.14) chased price
  down to 4367.75 as new M1 bars made new lows — price broke the old box
  bottom but the breakout "vanished". In strong trends the 20-bar channel
  follows price; candidate fix = v4 trend-continuation entry (sell on break
  of previous M1 bar's low in a downtrend). Offered, not yet built.
- **BTC bot**: swing design confirmed patient by design (H4 trend + H1
  pullback + RSI, holds days). Status prints once per H1 bar; log file lags
  the Experts tab. No BTC trades yet.
- **Broker-cost analysis**: XM standard account = spread + swap only, no
  commission. Gold 0.01 lot ≈ $0.30–0.50/trade spread (~$36–60/month at
  120 trades); Micro 0.001 lot ≈ $4–6/month. BTC swap ~$0.10–0.20/night
  held — the swing bot's hidden cost.
- **Tracked set decision**: records kept for **GoldBreakoutHunter v3** and
  **BTCSwingHunter v2** only. **GoldHunterPro Small retired** from tracking
  (user: bad logic, bought too much garbage, broke). Entity page flagged.
- **$100-account math**: RR 2.0 needs >33% win rate to break even. Micro on
  $100 ≈ −$10 to +$5/month realistic; 0.01 lot ≈ −$50 to +$50/month before
  spread. Recommendation: Micro + −$5/day kill switch + 2-week live track
  to measure the real win rate before scaling.

## [2026-09-08] incident | GoldBreakoutHunter flood (1156 deals) + v2.00 flood-proof rewrite

- **Incident**: GoldBreakoutHunter flooded the demo account — **1,156 deals**
  in ~30 minutes (order range 2165927xxx → 2165979xxx). Pattern: alternating
  buy/sell pairs every ~200ms at the same prices (buy at ask / sell at bid,
  spread apart), no SL/TP on the flood orders. User had to disable
  auto-trading twice (22:27, 22:55, 23:15) to stop it.
- **Root cause**: the running `.ex5` was a **stale cached build** — MT5 kept
  executing an old in-memory version even after the source was fixed and
  recompiled. The old build had a buy→close→buy loop that burned the spread
  every cycle; when auto-trading was disabled mid-loop it failed with
  **error 10027** (AutoTrading disabled by client) trying to close.
- **Fix 1 (code)**: rewrote `GoldBreakoutHunter_Zaid.mq5` → **v2.00** with
  four hard gates: 1 trade per M1 bar, 15-min cooldown, max 1 concurrent
  position (no hedging), max 4 trades/day. SL/TP always set. Compiled
  0 errors/0 warnings.
- **Fix 2 (deployment)**: renamed the EA to **`GoldBreakoutHunter_Zaid_v2`**
  — a new file name forces MT5 to load fresh code (no cache possible).
  Same for BTC bot → `BTCSwingHunter_Zaid_v2`.
- **Cleanup**: wrote `CloseAllPositions.mq5` script (closes every open
  position on the account, any symbol/magic). Ran on GOLD + BTCUSD charts:
  `0 closed, 0 failed, 0 remaining` — account fully clean.
- **BTC bot visibility**: `BTCSwingHunter_Zaid_v2` now prints a status line
  every H1 bar (`BSH status | H4trend | RSI | price/EMA21 | buySig/sellSig`)
  so we can see what it's waiting for. First status: H4trend DOWN, RSI 46.4,
  price/EMA21 0.9986 — waiting for RSI > 50 for a SELL in the downtrend.
- **Lesson**: recompiling an EA does NOT update a running instance — MT5
  caches the loaded `.ex5` in memory. After any code change, either restart
  MT5 or rename the EA so the new binary is loaded fresh.
- Both v2 bots verified running: `GoldBreakoutHunter v2.00 initialized`
  (GOLD,M5) and `BTCSwingHunter initialized` (BTCUSD,M1). 0 deals since
  re-attach.

## [2026-09-08] build | BTCSwingHunter EA (Paul Wei trade-history analysis)

- Scraped and analyzed **Paul Wei** (`@coolish`, BitMEX Hall of Legends,
  70x BTC return over 3 years) via the public
  `omgbbqhaxx/BTC-Trading-Since-2020` repo (43k+ orders, 173k+ executions).
- Analyzed the last year (2025-04 → 2026-04) of his XBTUSD ledger: 16 round
  trips, **93.8% win rate**, avg +3.68% per trade, holds days (median ~5d),
  balanced long/short, ~97% limit orders building positions.
- Built `BTCSwingHunter_Zaid.mq5` (magic 20260916): H4 EMA50 trend filter +
  H1 EMA21/RSI pullback entry, ATR SL, RR 2.5, trailing stop, kill switch
  (+$50/−$25), 1 concurrent position, 3 new trades/day. No daily cutoff
  (swing trades must be allowed to run for days).
- Fixed enum compile errors (timeframe inputs changed `int` →
  `ENUM_TIMEFRAMES`). Compiled **0 errors / 0 warnings**, deployed to MT5
  Experts.
- Wrote `entities/btcswinghunter.md`; updated `index.md`.
- Also fixed `GoldBreakoutHunter_Zaid.mq5`: removed the once-per-M1-bar gate
  so breakouts are checked on every tick (was missing fast breakouts).
  Recompiled clean, redeployed.

## [2026-09-08] build | GoldBreakoutHunter EA (verified-strategy research)

- Researched the most credible public gold strategies: **Marci Silfrain**
  (world #2 prop-firm leaderboard, verified +1,574% on gold over 3 years,
  trendline-pullback + measured-move) and the **Gold Prop Firm Robot**
  (verified live: 190% growth, 71.7% win rate, 2.47 PF over 16 months,
  breakout style).
- Built `GoldBreakoutHunter_Zaid.mq5` (magic 20260915): Donchian 20-bar
  breakout entry + EMA50 trend filter + ATR-based SL + measured-move TP
  (RR 2.0). Reuses the proven risk scaffolding from the other bots: kill
  switch (+$10/−$5), daily cutoff (23:59 test), 2 trades/day cap.
- Compiled **0 errors / 0 warnings**, deployed to MT5 Experts folder.
- Wrote `entities/goldbreakouthunter.md`; updated `index.md`.
- Context: user asked for a BTC and USD bot built from the "craziest trader"
  found by scraping their last year of trade history; this gold breakout bot
  is the first concrete build from that verified-strategy research.

## [2026-09-08] guide | Setup & Usage page

- Wrote `wiki/setup.md` — full onboarding page: what the repo is (LLM Wiki
  pattern, three layers), prerequisites, first-time setup (clone,
  authenticate via GCM/PAT/SSH, identity), the daily workflow (ingest a
  trade session, query, lint), page conventions, trading data reference
  (CSV columns, accounts, bot), safety rules, troubleshooting.
- Added "Version control rule" to `AGENTS.md`: **commit and push every wiki
  change at least once per day** (human directive).
- Updated `index.md` (new Guides section) and this log.

## [2026-09-08] ingest | First real-account session (GoldHunterPro_Small)

- Migrated the AMN strategy wiki from the local knowledge base
  (`knowledge/wiki/trading/`) into this repo: [[Adeel | AMN Trading]],
  [[Adeel Asghar]], [[AMN Model]], [[Liquidity Sweep]], [[AMN Bot Spec]].
- Wrote `raw/trades/2026-09-08-real-account.csv` — immutable dump of the
  real account (83160890) from `Account_History.csv` (9 deals incl. the
  +$125.43 funding transfer and the Aug 12 +$36.43 manual win).
- Wrote `sources/2026-09-08-real-session.md` — full session ingest: 4
  trades, 2 SL losses (−$8.07, −$8.13), 2 BUYs open at cutoff, err=4752
  failures before algo-trading was enabled, kill switch + 18:30 cutoff
  deployed.
- Wrote `entities/xm-accounts.md` (demo vs real account facts, symbol
  difference GOLD vs Gold.i#, Ultra Low Standard details).
- Wrote `entities/goldhunterpro-small.md` (bot config, entry logic, risk
  model, version history incl. the 18:30 cutoff build).
- Wrote `concepts/kill-switch.md`, `concepts/daily-cutoff.md`,
  `concepts/risk-reward.md` (jargon defined: SL, TP, RR, lot, point, pip,
  spread, margin, equity, floating P/L, magic number).
- Wrote `synthesis/2026-09-08-loss-review.md` — learning analysis: bot
  sold at the bottom of the downtrend (RSI 34.9/34.3 near oversold 30),
  price rallied ~$10 and hit both SLs; bot correctly flipped to BUY above
  EMA50; risk model held; RSI-zone improvement candidate (40–55 sells,
  45–60 buys).
- Updated `index.md` (all categories populated).
- Context: GoldHunterPro_Small went live on the real account today; the
  18:30 local daily cutoff was implemented and deployed (EA reload pending).

## [2026-09-07] ingest | Adeel | AMN Trading (strategy research)

- Researched Adeel Asghar (AMN Trading) — SMC/ICT liquidity-sweep educator.
  Sources: YouTube, Instagram, TikTok, Scribd (AMN Zones Guide, AMN Model
  Strategy Breakdown, AMN Setup Ratings Guide), allpros.io, whop.com,
  amnindicator.com, TradingView "AMN Zones" script.
- Wrote `sources/adeel-amn-trading.md` — full source page (identity, reach,
  core teaching, quotes, key videos, caveats).
- Wrote `entities/adeel-asghar.md` — entity page for the trader.
- Wrote `concepts/amn-model.md` — the AMN 6-step trade-taking process
  (trend → BOS → zone → sweep → first tap → 50% entry) with state machine
  encoding.
- Wrote `concepts/liquidity-sweep.md` — the sweep mechanic, sweep vs BOS
  distinction, four liquidity pools on Gold, entry framework.
- Wrote `synthesis/amn-bot-spec.md` — how to encode the AMN model into MQL5:
  state machine, gates, RR, risk management, session filter, two variants
  (strict 6-gate + loose 4-gate).
- Updated `index.md` (all four categories populated).
- Context: Zaid wants to replicate Adeel's trade-taking style in an EA.
  "The style of trading is what I got interest in." GoldHunterPro was live
  on demo with 2 SELL positions from Sept 7.