#!/usr/bin/env python3
"""Strip z80dasm auto address + hex/ascii dumps from comments of an annotated
listing, keeping only human explanatory text. Standing project rule: final .asm
listings never carry per-instruction addresses or opcode bytes in comments.

Usage:  python3 strip_listing.py FILE.asm   (edits in place)

What it does, per line:
  * drops z80dasm banner ('; z80dasm', '; command line:') and '; BLOCK ...' lines
  * for an instruction's trailing comment of the form ';<4hex><spaces><hex bytes>
    [<ascii dump>|<text>]', removes the address and the hex-pair tokens; keeps a
    trailing comment only if real explanatory text remains (a token >=2 chars)
  * leaves full-line banner/documentation comments untouched
Comments never affect assembled bytes, so this is byte-safe (verify with make).
"""
import re
import sys

HEX2 = re.compile(r'^[0-9a-f]{2}$')
ADDR = re.compile(r'^\s*([0-9a-f]{4})\b(.*)$')


def clean_comment(code, comment):
    m = ADDR.match(comment)
    if not m:
        return code.rstrip() + " ;" + comment      # not an addr/hex comment: keep
    toks = m.group(2).split()
    i = 0
    while i < len(toks) and HEX2.match(toks[i]):     # drop leading hex byte tokens
        i += 1
    remain = toks[i:]
    if any(len(t) >= 2 for t in remain):             # real text survives -> keep it
        return code.rstrip() + "\t\t; " + " ".join(remain)
    return code.rstrip()                             # ascii dump only -> drop comment


def strip(path):
    with open(path) as f:
        lines = f.read().split("\n")
    out = []
    for line in lines:
        s = line.strip()
        if s.startswith("; z80dasm") or s.startswith("; command line:") or s.startswith("; BLOCK '"):
            continue
        if s.startswith(";"):                        # full-line banner / doc comment
            out.append(line)
            continue
        if ";" in line:                              # operands never contain ';'
            idx = line.index(";")
            out.append(clean_comment(line[:idx], line[idx + 1:]))
        else:
            out.append(line.rstrip())
    with open(path, "w") as f:
        f.write("\n".join(out) + "\n")
    print("stripped", path, "->", len(out), "lines")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: strip_listing.py FILE.asm")
    strip(sys.argv[1])
