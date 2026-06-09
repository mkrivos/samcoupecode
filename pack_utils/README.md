# SAM Coupé arch-pack utilities — reverse engineering

*🇬🇧 English · [🇸🇰 Slovensky](README.sk.md)*

Byte-exact, annotated disassemblies and human documentation for a set of
**SAM Coupé** (Z80, paged memory) file-compression / archiving utilities, plus
portable C++17 reimplementations of their compression algorithms.

The tools originate from `arch-pack_utils.mgt`, an MGT disk image distributed in
1993. Each Z80 binary here is reverse-engineered one by one into:

- a **byte-exact** annotated disassembly (`NAME.asm`) that reassembles to an
  identical binary (verified round-trip — see [Verification](#verification)),
- supporting z80dasm inputs (`NAME.blk`, `NAME.z80sym`),
- human documentation (`NAME.md`, and Slovak `NAME.sk.md` where present),
- where the tool is SAM BASIC, a detokenised listing (`NAME.bas`).

> The canonical deliverable is always the **byte-exact `.asm`**. Ghidra pseudo-C
> and other generated aids are not tracked (see `.gitignore`).

---

## Background & provenance

The package was assembled and lightly documented by *"MAT of ESI"* (Toruń,
Poland, December 1993) and shipped with three plain-text notes — preserved here:

- `arch-pack_utils_info.txt` — user-level description of every tool.
- `arch-pack_utils_note.txt` — author notes (the self-extract / MGT-flags story).
- `UTILS.TXT` — extra notes.

The compression engines themselves come from several authors (see
[Authorship & licensing](#authorship--licensing)). The headline archiver
**ARCHIV** is by **Marián Krivoš (RUMSOFT, 1993)** — the author of this
repository.

---

## Inventory & status

The `*.BIN` files are the stripped Z80 code bodies; the plain-named files
(`ARCHIV`, `IMPLODER`, …) are the full SAM CODE/BASIC files (with header).

| Binary        | Entry        | Load   | Tool / purpose                                   | Author              | Status |
|---------------|--------------|--------|--------------------------------------------------|---------------------|--------|
| `SKOMP1.BIN`  | `JP &400C`   | &4000  | Screen compressor                                | RUMSOFT             | **done** — `.asm` / `.md` / `.sk.md` |
| `ARCHIV.BIN`  | `JR &6D1E`   | &6D00  | DISK ARCHIVE v2.0 (menu archiver)                | M. Krivoš / RUMSOFT | byte-exact `.asm` + doc |
| `IMPLO1.BIN`  | `JP &43FB`   | &4000  | TURBO IMPLODER v1.0                              | RUMSOFT & SAPOSOFT  | byte-exact `.asm` + `IMPLO1.md` |
| `UNPAK .BIN`  | `JP &414D`   | &4100  | UNPACK ARCHIVE 2.0 (inverse of ARCHIV)           | RUMSOFT             | byte-exact `.asm` + `UNPAK.md` |
| `COMPRES`     | `JP &A023`   | &A000  | LIB compressor engine                            | SAPOSOFT            | byte-exact `COMPRES.asm` |
| `DEC`         | (relocator)  | &8000  | LIB self-relocating depacker stub (367 B)        | SAPOSOFT            | byte-exact `DEC.asm` |
| `Lib v21`     | SAM BASIC    | —      | "Library" v2.1 file librarian                    | S. Grodkowski       | `Lib v21.bas` + `LIB.md` |
| `PASS`        | SAM BASIC    | —      | password-garbler loader                          | —                   | `PASS.bas` |
| `PASS1`       | `DI …`       | ?      | password-garbler Z80 routine (86 B)              | —                   | TODO |
| `SCREENCOM1`  | SAM BASIC    | —      | screen-compressor loader (drives SKOMP1)         | —                   | `SCREENCOM1.bas` |
| `CrunchCode`  | `JP &800E`   | &8000  | **foreign** cruncher (RLE + frequency-rank code) | unknown             | byte-exact `CrunchCode.asm` + `CrunchCode.md` |
| `MDOS23`      | —            | —      | MasterDOS (third-party; context only)            | MasterDOS authors   | preserved, not analysed |

---

## Compression algorithms (recovered)

Read the **decoder**, not the packer — the depacker fully and unambiguously
defines each on-wire format. The recovered formats:

- **SKOMP** — previous-byte RLE with an LZSS-style flag byte (1 flag bit per
  token, 8 tokens per flag byte). Best on flat/striped screen data. See
  `SKOMP1.md`.
- **SHRINK** — PackBits-style RLE: control byte `count = (B & 0x7F) + 1`,
  bit 7 = repeat/literal. The IMPLODER's mode 1. See `IMPLO1.md §3.1`.
- **IMPLODE** — LZ77/LZSS: `0x03` match marker, 3-byte match token,
  `len 3..33`, `dist 1..2048`. The IMPLODER's mode 2 (mode 3 = SHRINK then
  IMPLODE). See `IMPLO1.md §6a`.
- **CrunchCode** — RLE pre-pass + a static **frequency-rank entropy code**
  (2-bit class prefix: rank 0–3 / 4–19 / 20–83 / 8-bit raw escape). The only
  statistical coder of the set — wins on skewed data (text). See
  `CrunchCode.md §3.1`.

---

## C++ reimplementations (`cpp/`)

Portable, dependency-free **C++17** codecs operating on memory blocks —
algorithmically equivalent to the originals (each round-trips with itself; not
bit-compatible with the SAM streams unless noted). Four codecs: `skomp`,
`shrink`, `implode`, `crunch`, each with a CLI and a `t` self-test.

```bash
cd cpp
CC=clang CXX=clang++ cmake -S . -B build && cmake --build build
./build/skomp t      # round-trip self-test (also: shrink / implode / crunch)
```

See [`cpp/README.md`](cpp/README.md) for the API, stream layouts and per-codec
notes.

---

## Toolchain

| Tool      | Purpose                                            |
|-----------|----------------------------------------------------|
| `z80dasm` | Disassembler (1.1.6) — block-def + symbol files    |
| `z80asm`  | Assembler (z88dk / InterLogic) — `-b` builds `.bin` |
| `make`    | Drives assemble + **verify** round-trip            |
| `ghidra`  | Decompiler to pseudo-C (12.1, Z80 module) — aid only |

Standard disassembly invocation:

```bash
z80dasm -a -t -l -u -g <ORG> -b NAME.blk -S NAME.z80sym NAME.BIN -o NAME.gen.asm
```

### Helper scripts

| Script             | Purpose                                                       |
|--------------------|---------------------------------------------------------------|
| `loadaddr.py`      | Guess ORG: entry vector + self-store + call-target clustering |
| `ngram_dup.py`     | Shared-code % between two binaries via 16-grams               |
| `strip_listing.py` | Drop auto address+hex from `.asm` comments, keep prose        |
| `sambas2txt.py`    | Detokenise SAM BASIC → ASCII listing                          |
| `ghidra_decompile.java` | Headless Ghidra post-script → `NAME.ghidra.c`            |

---

## Verification

Every `.asm` reassembles to a byte-identical copy of the original binary. The
generic `Makefile` does this (`NAME=` selects the routine):

```bash
make NAME=SKOMP1 verify      # assemble SKOMP1.asm -> SKOMP1.bin, cmp vs SKOMP1.BIN
make NAME=ARCHIV verify
```

A filename with a space (`UNPAK .BIN`) or no `.BIN` extension (`DEC`, `COMPRES`)
bypasses the `NAME=` form — assemble and `cmp` directly with an explicit ORG, e.g.:

```bash
z80asm -b -o=/tmp/u.bin UNPAK.asm && cmp /tmp/u.bin "UNPAK .BIN"
```

---

## Methodology

`CLAUDE.md` documents the full repeatable workflow (inspect → disassemble →
find boundaries → annotate → **verify round-trip** → document) and a cookbook of
reverse-engineering tactics (finding the load address, recognising the algorithm
class from signature opcodes, handling self-modifying / relocating code, etc.).
It is included as a methodology record.

---

## Authorship & licensing

This is a mixed-provenance preservation + reverse-engineering project:

- **Reverse-engineering work** (`*.asm`, `*.blk`, `*.z80sym`, `*.md`, `*.sk.md`,
  `*.bas`, the scripts, the `Makefile`, and `cpp/`) is by **Marián Krivoš** (with
  Claude Code) and is released under the **MIT License** — see [`LICENSE`](LICENSE).
- **Original 1993 binaries and the disk image** remain the property of their
  respective authors and are included for **preservation and study only**:
  - RUMSOFT — ARCHIV, UNPAK, IMPLODER (part), SKOMP1
  - SAPOSOFT / S. Grodkowski — LIB, COMPRES, DEC, IMPLODER (part)
  - `CrunchCode` — unknown third-party author (unrelated to the rest)
  - `MDOS23` — **MasterDOS**, third-party commercial software, kept only as
    disk-image context

If you are a rights holder and want a file removed, please open an issue.

---

## Credits

- Reverse engineering & C++ ports: **Marián Krivoš** (RUMSOFT) with Claude Code.
- Original utilities: RUMSOFT, SAPOSOFT (S. Grodkowski), and others (1993).
- Package collection & original notes: *MAT of ESI* (Toruń, 1993).
