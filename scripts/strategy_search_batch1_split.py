"""
Split-sample robustness check for Strategy Search Batch 1 provisional GOs.

Contract (wiki/synthesis/strategy-search-batch-1-precommit.md, frozen
2026-09-19): any GO from the batch is PROVISIONAL until it survives a
split-sample robustness check - first half vs second half of the OOS
horizon. Pass rule (stated here BEFORE running, no tuning): each half must
have n >= 30 AND expectancy > 0. If either half fails, the GO is downgraded
to NO-GO (multiple-testing caveat).

Run from repo root:
    python scripts/strategy_search_batch1_split.py --csv raw/history/<file>.csv
"""

import argparse
import os
import sys

import layer3_walkforward as l3
import strategy_search_batch1 as b1

MIN_OOS_TRADES = l3.MIN_OOS_TRADES


def split_half(ts, o, h, l, c):
    """Split M1 arrays into two contiguous halves (first 50% / last 50%)."""
    n = len(ts)
    cut = n // 2
    return ((ts[:cut], o[:cut], h[:cut], l[:cut], c[:cut]),
            (ts[cut:], o[cut:], h[cut:], l[cut:], c[cut:]))


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--csv", default=None)
    args = ap.parse_args(argv)

    csv_path = args.csv
    if not csv_path:
        hist = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "raw", "history")
        files = sorted(f for f in os.listdir(hist) if f.endswith(".csv")) if os.path.isdir(hist) else []
        if not files:
            print("no history CSV found; pass --csv")
            return 1
        csv_path = os.path.join(hist, files[-1])

    print("loading %s ..." % os.path.basename(csv_path))
    ts, o, h, l, c = l3.load_csv(csv_path)
    print("  %d M1 bars | first=%s last=%s" % (len(ts), l3._fmt(ts[0]), l3._fmt(ts[-1])))

    (ts1, o1, h1, l1, c1), (ts2, o2, h2, l2, c2) = split_half(ts, o, h, l, c)
    print("  half1: %d bars ending %s" % (len(ts1), l3._fmt(ts1[-1])))
    print("  half2: %d bars starting %s" % (len(ts2), l3._fmt(ts2[0])))

    # candidates that were GO (provisional) in the batch run
    go_candidates = [
        ("C1 UT Bot trailing stop", b1.c1_ut_bot),
        ("C3 Xaulgnition momentum", b1.c3_xaulgnition),
    ]

    print("")
    print("=== SPLIT-SAMPLE ROBUSTNESS CHECK (pass: n>=30 AND E>0 in BOTH halves) ===")
    print("")
    for name, fn in go_candidates:
        r1 = fn(ts1, o1, h1, l1, c1)
        r2 = fn(ts2, o2, h2, l2, c2)
        ok1 = r1["n"] >= MIN_OOS_TRADES and r1["expectancy"] == r1["expectancy"] and r1["expectancy"] > 0
        ok2 = r2["n"] >= MIN_OOS_TRADES and r2["expectancy"] == r2["expectancy"] and r2["expectancy"] > 0
        verdict = "PASS - GO confirmed" if (ok1 and ok2) else "FAIL - downgraded to NO-GO"
        print("%s" % name)
        print("  half1: n=%4d  E=%+.4f  WR=%.2f%%  %s"
              % (r1["n"], r1["expectancy"], r1["win_rate"] * 100,
                 "ok" if ok1 else "FAIL"))
        print("  half2: n=%4d  E=%+.4f  WR=%.2f%%  %s"
              % (r2["n"], r2["expectancy"], r2["win_rate"] * 100,
                 "ok" if ok2 else "FAIL"))
        print("  => %s" % verdict)
        print("")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())