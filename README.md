<h1 align="center">samcoupecode</h1>

<p align="center">
  <em>Z80 assembler source code for SAM Coupé development tools —<br/>
  plus a reverse-engineering study of the SAM Coupé compression utilities.</em>
</p>

---

An archive of **SAM Coupé** (Z80) source code: monitors/debuggers, editors, a
C compiler and graphics/screen libraries — mostly by **RUMSOFT (Marián Krivoš),
1993–1995** — together with [**`pack_utils/`**](pack_utils/), a reverse-engineering
study of the SAM Coupé *arch-pack* compression / archiving tools.

## Contents

### Development-tool sources (`*.z80`)

Plain-text **Z80 assembler source listings** (CRLF), as assembled on the SAM Coupé.

| File | Tool / title | Notes |
|------|--------------|-------|
| [`devast40.z80`](devast40.z80) | **DEWAST 40** — monitor / debugger | RUMSOFT, Dec 1993 (low-memory build) |
| [`devast++.z80`](devast++.z80) | **DEWAST ++** — monitor / debugger | RUMSOFT (enhanced build) |
| [`edipro.z80`](edipro.z80) | **EDI-PRO v1.56** — editor | RUMSOFT, 1994–1995 |
| [`sam_vision_20.z80`](sam_vision_20.z80) | **SAM Vision** — Graphics Interface 2.1 | RUMSOFT, 1993–1995; "version for C compiler" |
| [`screen_routines.z80`](screen_routines.z80) | **Screen / character routines** | font, cursor, scroll, CLS (`ORG &E000`) |
| [`small_c_compiler.z80`](small_c_compiler.z80) | **Small-C compiler** | C compiler source |
| [`small_c_ide.z80`](small_c_ide.z80) | **"C" Compiler v4.11** | RUMSOFT, 1994–1995 |
| [`zeus_assembler.z80`](zeus_assembler.z80) | **Zeus** — Z80 assembler | token-based Z80 assembler source |

> The `.z80` extension here denotes **assembler source files** (not Z80 emulator
> snapshots). They build on the original hardware/toolchain.

### [`pack_utils/`](pack_utils/) — reverse engineering

Byte-exact, annotated disassemblies and documentation of the 1993 SAM Coupé
*arch-pack* compression / archiving utilities (ARCHIV, UNPAK, IMPLODER,
SKOMP1, LIB, …), plus portable **C++17** reimplementations of their compression
algorithms (SKOMP, SHRINK, IMPLODE, CrunchCode). Every disassembly reassembles
to a **byte-identical** copy of the original (verified round-trip).

→ [`pack_utils/README.md`](pack_utils/README.md) &nbsp;·&nbsp; [🇸🇰 Slovensky](pack_utils/README.sk.md)

## About the SAM Coupé

The **SAM Coupé** (MGT / SAM Computers, 1989) is a British 8-bit home computer
built around a **6 MHz Z80B** with 256 KB+ of paged RAM and an enhanced ZX
Spectrum–compatible display. The sources here target its paged memory model and
MGT / SAMDOS disk system.

## Authorship & licence

Source code is © **RUMSOFT (Marián Krivoš)** and the respective original authors
(Zeus and Small-C are SAM Coupé adaptations of pre-existing tools). Published for
**preservation and study**. The reverse-engineering work under `pack_utils/` is
MIT-licensed — see [`pack_utils/LICENSE`](pack_utils/LICENSE).
