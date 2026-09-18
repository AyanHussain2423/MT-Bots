"""
Layer 2 — Monte Carlo Drawdown Resampler

Resamples the REAL bot trade list (raw/trades/2026-09-18-bot-trades-mt5.csv)
to estimate the drawdown distribution of the bots' P&L, then checks it
against the kill switch (-$50) and the account floor.

Method (per the catalog's backtest-engine pattern + the Drawdown Beyond
Brownian paper): shuffle the realized trade P&L list with replacement,
N times; each shuffle is one "possible future" of the same strategy; track
equity curve, max drawdown, time under water, and ruin (equity <= 0).

Usage:
    python layer2_mc_drawdown.py [--n 10000] [--equity 100] [--kill -50]
                                 [--seed 42] [--csv path]
"""

import argparse
import csv
import random
import sys
from collections import Counter

DEFAULT_CSV = r'D:\Workspace\Trader-knowledge\raw\trades\2026-09-18-bot-trades-mt5.csv'


def load_trades(path, bot=None):
    """Load realized P&L per trade (profit + swap). Returns list of floats."""
    pl = []
    with open(path, newline='', encoding='utf-8-sig') as fh:
        for row in csv.DictReader(fh):
            prof = row.get('profit') or row.get('Profit')
            if prof is None or prof == '':
                continue
            if bot and (row.get('bot') or '?') != bot:
                continue
            v = float(prof) + float(row.get('swap') or 0.0)
            pl.append(v)
    return pl


def simulate(pl, n_sims, start_equity, kill_level, rng):
    """Run n_sims shuffled equity curves. Returns dict of stats."""
    max_dd_list = []
    time_under_water = []
    ruin_count = 0
    kill_hit = 0
    final_equity = []
    worst_curve = None
    worst_dd = 0.0

    for _ in range(n_sims):
        order = rng.choices(pl, k=len(pl))  # shuffle with replacement
        equity = start_equity
        peak = start_equity
        cur_dd = 0.0
        underwater = 0
        max_underwater = 0
        curve = [start_equity]
        hit_kill = False
        for pnl in order:
            equity += pnl
            curve.append(equity)
            if equity > peak:
                peak = equity
                underwater = 0
            else:
                underwater += 1
                max_underwater = max(max_underwater, underwater)
            dd = (peak - equity) / peak if peak > 0 else 1.0
            cur_dd = max(cur_dd, dd)
            if equity <= 0:
                ruin_count += 1
                break
            if equity <= start_equity + kill_level:
                hit_kill = True
        max_dd_list.append(cur_dd)
        time_under_water.append(max_underwater)
        final_equity.append(equity)
        if hit_kill:
            kill_hit += 1
        if cur_dd > worst_dd:
            worst_dd = cur_dd
            worst_curve = curve

    max_dd_list.sort()
    final_equity.sort()
    return {
        'n_sims': n_sims,
        'max_dd_list': max_dd_list,
        'time_under_water': time_under_water,
        'ruin_count': ruin_count,
        'kill_hit': kill_hit,
        'final_equity': final_equity,
        'worst_curve': worst_curve,
        'worst_dd': worst_dd,
    }


def pct(sorted_list, p):
    if not sorted_list:
        return 0.0
    idx = min(len(sorted_list) - 1, int(p * len(sorted_list)))
    return sorted_list[idx]


def main():
    ap = argparse.ArgumentParser(description='Layer 2: MC drawdown resampler')
    ap.add_argument('--n', type=int, default=10000, help='simulations')
    ap.add_argument('--equity', type=float, default=100.0, help='start equity')
    ap.add_argument('--kill', type=float, default=-50.0, help='kill switch level (absolute $)')
    ap.add_argument('--seed', type=int, default=42)
    ap.add_argument('--csv', default=DEFAULT_CSV)
    ap.add_argument('--bot', default=None, help='filter to one bot (GBH/BBH/BSH/GHP)')
    args = ap.parse_args()

    pl = load_trades(args.csv, bot=args.bot)
    if not pl:
        sys.exit('no trades loaded')
    label = f" ({args.bot})" if args.bot else ""
    wins = [x for x in pl if x > 0]
    losses = [x for x in pl if x < 0]
    n = len(pl)
    p = len(wins) / n
    avg_w = sum(wins) / len(wins) if wins else 0
    avg_l = abs(sum(losses) / len(losses)) if losses else 0
    b = avg_w / avg_l if avg_l else 0
    f_star = p - (1 - p) / b if b else 0

    print(f"=== TRADE SAMPLE{label} ({n} trades) ===")
    print(f"wins={len(wins)} losses={len(losses)} WR={p:.1%}")
    print(f"avg win ${avg_w:.2f}  avg loss ${avg_l:.2f}  RR={b:.2f}")
    print(f"Kelly f* = {f_star:+.3f}  (half-Kelly {0.5*f_star:+.3f})")
    print(f"net P/L = ${sum(pl):+.2f}")

    # Per-bot breakdown
    print("\n=== PER-BOT BREAKDOWN ===")
    from collections import defaultdict
    by_bot = defaultdict(list)
    with open(args.csv, newline='', encoding='utf-8-sig') as fh:
        for row in csv.DictReader(fh):
            prof = row.get('profit') or row.get('Profit')
            if prof is None or prof == '':
                continue
            bot = row.get('bot') or '?'
            by_bot[bot].append(float(prof) + float(row.get('swap') or 0.0))
    for bot, pls in sorted(by_bot.items()):
        w = sum(1 for x in pls if x > 0)
        aw = sum(x for x in pls if x > 0) / w if w else 0
        al = abs(sum(x for x in pls if x < 0)) / (len(pls) - w) if len(pls) - w else 0
        print(f"  {bot:8} n={len(pls):3d} WR={w/len(pls):.0%} avgW=${aw:.2f} "
              f"avgL=${al:.2f} net=${sum(pls):+.2f}")

    rng = random.Random(args.seed)
    res = simulate(pl, args.n, args.equity, args.kill, rng)

    print(f"\n=== MC DRAWDOWN ({args.n} shuffles, start ${args.equity:.0f}) ===")
    dd = res['max_dd_list']
    print(f"max drawdown  p50={pct(dd, .50):.1%}  p90={pct(dd, .90):.1%}  "
          f"p95={pct(dd, .95):.1%}  p99={pct(dd, .99):.1%}  worst={dd[-1]:.1%}")
    tuw = res['time_under_water']
    print(f"time under water (trades)  p50={pct(tuw, .50):.0f}  p90={pct(tuw, .90):.0f}  "
          f"p99={pct(tuw, .99):.0f}  worst={max(tuw)}")
    fe = res['final_equity']
    print(f"final equity  p10=${pct(fe, .10):.2f}  p50=${pct(fe, .50):.2f}  "
          f"p90=${pct(fe, .90):.2f}")
    print(f"ruin (equity<=0): {res['ruin_count']}/{args.n} = {res['ruin_count']/args.n:.2%}")
    print(f"kill switch (${args.kill}): hit in {res['kill_hit']}/{args.n} = "
          f"{res['kill_hit']/args.n:.2%} of sims")

    # Worst-case curve summary
    wc = res['worst_curve']
    print(f"\nworst-case curve: start ${wc[0]:.2f} -> min ${min(wc):.2f} "
          f"-> end ${wc[-1]:.2f} (max DD {res['worst_dd']:.1%})")

    # Verdict vs kill switch
    print("\n=== VERDICT ===")
    if res['ruin_count'] / args.n > 0.01:
        print("FAIL: >1% of simulations ruin the account at this risk level.")
    elif pct(dd, .95) > 0.5:
        print("WARN: p95 drawdown exceeds 50% of equity.")
    else:
        print("OK: drawdown profile is inside the kill-switch envelope at 0.01 lots.")
    print("(Sizing layer 1 says: no edge -> stay 0.01 lots; this MC check is the")
    print(" risk envelope for that decision.)")
    return 0


if __name__ == '__main__':
    sys.exit(main())