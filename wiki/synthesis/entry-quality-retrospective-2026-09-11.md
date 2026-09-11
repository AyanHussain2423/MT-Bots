---
title: Entry Quality Retrospective 2026-09-11
type: synthesis
tags: [analysis, retrospective, entry-quality, gold, breakout, trend-continuation]
date: 2026-09-11
sources: [GOLD_M1_202606020114_202609111852.csv, GoldBreakoutHunter_Zaid_v3.mq5, mt5-history-deals-2026-09-11]
---

# Entry Quality Retrospective — 2026-09-11 (7 gold trades)

Exact reconstruction of every [[GoldBreakoutHunter]] v3.21 entry on 09-11,
computed from the full M1 dataset (101,072 bars, 2026-06-02 → 2026-09-11
18:52 UTC) using the EA's own formulas (Donchian M1-20 over bars 1–20, slope
over bars 21–40, M15 EMA50 with forming-bar close, H1 EMA50, fresh guard).
All deal times are UTC (MT5 history timestamps).

## Reconstruction table

| # | Time (UTC) | Side | Fill | ChanHi | ChanLo | M15 EMA50 | EMA 3-bar | H1 EMA50 | Dist | ProxLo | Entry type | Result |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| #1 | 09-10 21:50 | SELL | 4331.49 | 4338.87 | 4330.04 | 4369.58 | 4374.04 | 4389.91 | −38.09 | 1.45 | trendSell | SL −5.26 |
| #2 | 09-10 22:01 | SELL | 4326.68 | 4338.44 | 4325.62 | 4367.93 | 4372.66 | 4387.47 | −41.25 | 1.06 | trendSell | TP +10.18 |
| #3 | 09-10 23:00 | SELL | 4324.12 | 4327.69 | 4319.84 | 4361.42 | 4366.17 | 4384.90 | −37.30 | 4.28 | trendSell | TP +9.91 |
| #4 | 09-11 01:42 | SELL | 4315.54 | 4321.30 | 4313.43 | 4352.11 | 4356.40 | 4381.87 | −36.57 | 2.11 | trendSell | SL −4.57 |
| #5 | 09-11 02:38 | SELL | 4314.60 | 4320.33 | 4314.46 | 4347.02 | 4350.81 | 4379.35 | −32.42 | 0.14 | trendSell | SL −5.26 |
| #6 | 09-11 06:22 | SELL | 4309.21 | 4326.34 | 4309.14 | 4336.48 | 4338.97 | 4371.01 | −27.27 | 0.07 | trendSell | SL −5.26 |
| #7 | 09-11 16:29 | BUY | 4396.61 | 4396.44 | 4380.37 | 4346.13 | 4340.39 | 4365.19 | +49.97 | 15.73 | channelBuy | SL −5.24 |

Dist = bid − M15 EMA50 (negative = below the EMA). ProxLo = bid − channel
low. All 7 fills fall inside their M1 bar's range in the CSV (feed matches
the broker).

## MFE / MAE analysis

| # | MFE | MAE | Time to exit | Post-exit +30m | Verdict |
|---|---|---|---|---|---|
| #1 | 1.75 | 6.95 | 1.3 min | −13.53 | **Bad entry** — never in favor; SL was a whipsaw (price fell 13.5 pts right after) |
| #2 | 11.28 | 0.35 | 1.8 min | +10.52 | **Good** — textbook continuation, TP in under 2 min |
| #3 | 10.69 | 0.26 | 161 min | +3.98 | **Good** — slow grind, TP eventually hit |
| #4 | 0.82 | 4.23 | 19.9 min | −3.03 | **Bad entry** — never in favor |
| #5 | 3.57 | 5.66 | 23.1 min | +1.59 | **Bad entry** — never in favor |
| #6 | 8.58 | 8.44 | 46.1 min | +12.65 | **Whipsaw** — went 8.6 pts in favor, reversed; SL correct (price rose 12.65 after) |
| #7 | 5.81 | 15.14 | 30 min | −26.99 | **Whipsaw** — went 5.8 in favor, reversed hard; SL correct (price crashed 27 pts after) |

MFE = max favorable excursion (pts), MAE = max adverse excursion (pts).
Post-exit +30m = price change 30 min after the exit (negative = kept falling
for sells).

## Findings

1. **All 6 sells were trend-continuation entries — the channel-break path
   never fired.** Price was always 0.07–4.28 pts **above** the channel low
   (never broke it). This corrects the earlier M15-based classification
   (trades #2/#5/#6 were thought to be channel breaks). In a grind the
   channel low ratchets down with price, so the break never happens — the
   trend path does all the work.
2. **Trend sells entered 27–41 pts below the M15 EMA50, within 5 pts of the
   channel low** — i.e., at the bottom of the recent range, the worst
   short-term price for a sell. Result: 2W/4L = 33.3% win rate = **exactly
   breakeven** for 2:1 RR (the +$0.13 swap on #3 nudges it slightly
   positive).
3. **The 2 winners were the freshest entries** (#2, #3 — right after the
   initial break, MAE < 0.4 pts). The losers were later entries in the same
   grind (#4, #5, #6) or the immediate bounce (#1). Entry quality decays
   with each re-entry into the same move.
4. **#7 was a marginal channel break** — 0.17 pts above the 20-bar high
   after a 50-pt rally (also satisfied trendBuy). Bought the top; the SL was
   correct (price crashed 27 pts after).
5. **The 3/day trend-continuation counter was violated.** #1–#3 used all 3
   trend entries on server day 09-11 (starts 09-10 21:00 UTC). #4–#6 fired
   as trendSell anyway — only possible if the EA was re-attached
   (`g_trendEntriesToday` resets to 0 on re-attach). v3.21 restores
   `g_tradesToday` from history but **not** `g_trendEntriesToday` — residual
   gap.
6. **Cap-bug cost: −$15.76.** If the 4/day cap had held (#1–#4 only): net
   **+$10.39**. The cap-bug trades (#5, #6, #7) all lost. The cap didn't
   just limit risk — it would have blocked the 3 worst trades of the day.

## Verdict

- The **trend-continuation rule** (price within 5 pts of the channel low,
  ≥10 pts from EMA50) is a **breakeven strategy at best** in this sample:
  it sells the bottom of the range and bets on continuation. It works when
  the down-move is fresh and strong (#2, #3), fails when the market is
  grinding or choppy (#4, #5, #6).
- The **channel-break path** is nearly dead in grinds (never fired all day)
  and its one firing (#7) was a marginal break after an extended move — a
  trap.
- **Entry quality ranking**: #2, #3 good (MAE < 0.4 pts); #1, #4, #5 bad
  (never in favor); #6, #7 whipsaws (in favor, then reversed — SLs were
  correct).

## Lessons for the next bot

1. **Don't enter at the channel edge** — the proximity rule (≤5 pts from the
   low) buys the exact spot where bounces start. Enter on continuation
   confirmation instead (e.g., a failed pullback, not the low itself).
2. **First entries after a fresh break are the good ones**; re-entries into
   the same move decay. A "one entry per move" rule or a quality decay
   factor beats unlimited re-entry.
3. **MAE < 1 pt characterizes the good entries** — a filter like "skip if
   price has bounced ≥3 pts in the last N bars" could remove the bad ones.
4. **Marginal breaks after extended moves are traps** — #7 broke the high by
   0.17 pts after a 50-pt rally. Require a minimum break distance or a
   pullback before the break.
5. **Fix the trend-counter reset** — `g_trendEntriesToday` must also be
   restored from history in OnInit (same pattern as `CountTradesToday`).

## Jargon

- **MFE / MAE** — maximum favorable / adverse excursion: how far price went
  in the trade's favor / against it before exit. Entry-quality metric.
- **Whipsaw** — a trade that goes in favor, then reverses to hit the SL.
- **Trend-continuation entry** — entering in the direction of an established
  trend near the channel edge (v3.16+), as opposed to a channel break.
- **Channel break** — price moving beyond the Donchian channel high/low.
- **Proximity** — how close price is to the channel edge (pts).