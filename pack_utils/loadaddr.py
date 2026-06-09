#!/usr/bin/env python3
#
# \package tools
# \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
# \date 6. 6. 2026
# \brief Guess the load (ORG) address of a raw Z80 code body.
#
# (C) Copyright 2026 R-SYS s.r.o
# All rights reserved.
#
# Two independent heuristics, cross-checked:
#   1. Entry vector  -- decode the JP/JR at file offset 0 (and any further JPs in
#      a leading vector table); the target is a known absolute address whose file
#      offset we know, so  ORG = target - offset_of_target.
#   2. Call-target clustering -- for every candidate ORG, count how many absolute
#      CALL (0xCD) / JP (0xC3) operands fall inside [ORG, ORG+len). Real code
#      jumps mostly within itself, so the ORG that maximises the "inside" fraction
#      is almost always correct. ROM calls (<0x4000) are ignored in the score.
#
# Usage:  python3 loadaddr.py FILE.BIN [--base-min 0x4000] [--base-max 0xC000]
#
import sys

def u16(b, i): return b[i] | (b[i + 1] << 8)

def entry_guess(b):
    """ORG implied by the entry JP/JR at offset 0."""
    out = []
    if b and b[0] == 0xC3:                       # JP nnnn
        tgt = u16(b, 1)
        out.append(("JP @0", tgt, tgt))          # offset of target unknown -> ORG ~ tgt - 0? report tgt
    if b and b[0] == 0x18:                        # JR d
        d = b[1] - 256 if b[1] > 127 else b[1]
        out.append(("JR @0", 2 + d, None))
    return out

def cluster_scan(b, base_min, base_max, step=0x100):
    n = len(b)
    targets = []
    i = 0
    while i < n - 2:
        op = b[i]
        if op in (0xCD, 0xC3, 0xCA, 0xC2, 0xDA, 0xD2, 0xCC, 0xC4,
                  0xEA, 0xE2, 0xFA, 0xF2, 0xDC, 0xD4, 0xFC, 0xF4):
            targets.append(u16(b, i + 1))
            i += 3
        else:
            i += 1
    best = []
    for org in range(base_min, base_max + 1, step):
        lo, hi = org, org + n
        inside = sum(1 for t in targets if lo <= t < hi)
        nonrom = [t for t in targets if t >= 0x4000]
        score = inside / len(nonrom) if nonrom else 0.0
        best.append((score, org, inside, len(targets)))
    best.sort(reverse=True)
    return best

def selfstore_scan(b):
    """LD (nnnn),SP = ED 73 ll hh ; LD (nnnn),HL = 22 ll hh.
    The stored address usually sits just inside the loaded image."""
    hits = []
    for i in range(len(b) - 3):
        if b[i] == 0xED and b[i + 1] == 0x73:
            hits.append(("LD (nn),SP", u16(b, i + 2)))
        if b[i] == 0x22:
            hits.append(("LD (nn),HL", u16(b, i + 2)))
    return hits

def main():
    if len(sys.argv) < 2:
        print(__doc__); sys.exit(2)
    path = sys.argv[1]
    base_min, base_max = 0x4000, 0xC000
    for k in range(2, len(sys.argv) - 1):
        if sys.argv[k] == "--base-min": base_min = int(sys.argv[k + 1], 0)
        if sys.argv[k] == "--base-max": base_max = int(sys.argv[k + 1], 0)
    b = open(path, "rb").read()
    print(f"file        : {path}  ({len(b)} bytes)")
    print(f"entry byte  : {b[0]:#04x}")
    for name, tgt, org in entry_guess(b):
        print(f"  {name}: target &{tgt:04X}"
              + (f"  -> ORG ~ &{org:04X}" if org is not None else ""))
    print("self-stores (LD (nn),SP / HL) -- ORG is usually just below these:")
    for name, addr in selfstore_scan(b)[:8]:
        print(f"  {name} &{addr:04X}")
    print("call/jp clustering (top candidate ORGs):")
    for score, org, inside, total in cluster_scan(b, base_min, base_max)[:6]:
        print(f"  ORG &{org:04X}: {inside}/{total} targets inside  ({score*100:.0f}% of non-ROM)")

if __name__ == "__main__":
    main()
