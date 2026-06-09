#!/usr/bin/env python3
#
# \package tools
# \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
# \date 6. 6. 2026
# \brief Measure shared code between two raw binaries via byte n-gram overlap.
#
# (C) Copyright 2026 R-SYS s.r.o
# All rights reserved.
#
# Answers "is engine B just a copy of engine A?" without disassembling either.
# Builds the set of length-N byte windows of each file and reports the Jaccard /
# containment overlap. ~0% => independent implementations (worth analysing both);
# high % => one is a copy/relocation of the other (analyse once, note the alias).
#
# n-grams are alignment-independent, so they survive a different ORG / minor
# patching. Use a window (default 16) long enough that random collisions are
# negligible but short enough to survive small edits.
#
# Usage:  python3 ngram_dup.py A.BIN B.BIN [N]
#
import sys

def grams(b, n):
    return {bytes(b[i:i + n]) for i in range(len(b) - n + 1)}

def main():
    if len(sys.argv) < 3:
        print(__doc__); sys.exit(2)
    n = int(sys.argv[3]) if len(sys.argv) > 3 else 16
    a = open(sys.argv[1], "rb").read()
    b = open(sys.argv[2], "rb").read()
    ga, gb = grams(a, n), grams(b, n)
    inter = len(ga & gb)
    union = len(ga | gb)
    jacc = 100.0 * inter / union if union else 0.0
    ca = 100.0 * inter / len(ga) if ga else 0.0
    cb = 100.0 * inter / len(gb) if gb else 0.0
    print(f"A: {sys.argv[1]}  {len(a)} B, {len(ga)} {n}-grams")
    print(f"B: {sys.argv[2]}  {len(b)} B, {len(gb)} {n}-grams")
    print(f"shared {n}-grams : {inter}")
    print(f"Jaccard overlap : {jacc:.1f}%")
    print(f"of A in B       : {ca:.1f}%   (how much of A is reused in B)")
    print(f"of B in A       : {cb:.1f}%")
    verdict = ("independent implementations" if jacc < 5 else
               "substantial shared code -- likely copy/relocation" if jacc > 40 else
               "partial overlap -- shared helpers, distinct cores")
    print(f"verdict         : {verdict}")

if __name__ == "__main__":
    main()
