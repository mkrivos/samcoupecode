# SAM Coupé arch-pack utilities — reverzné inžinierstvo

*[🇬🇧 English](README.md) · 🇸🇰 Slovensky*

Bajtovo presné, anotované disassembly a ľudská dokumentácia k sade
**SAM Coupé** (Z80, stránkovaná pamäť) utilít na **kompresiu súborov /
archiváciu**, plus prenositeľné C++17 reimplementácie ich kompresných
algoritmov.

Nástroje pochádzajú z `arch-pack_utils.mgt`, MGT disk imageu distribuovaného
v roku 1993. Každá Z80 binárka je tu postupne reverzne spracovaná do:

- **bajtovo presného** anotovaného disassembly (`NAME.asm`), ktoré sa spätne
  preloží na identickú binárku (overený round-trip — viď [Verifikácia](#verifikácia)),
- podporných vstupov pre z80dasm (`NAME.blk`, `NAME.z80sym`),
- ľudskej dokumentácie (`NAME.md` a slovenskej `NAME.sk.md`, kde existuje),
- detokenizovaného výpisu (`NAME.bas`), ak je nástroj v SAM BASICu.

> Kanonickým výstupom je vždy **bajtovo presné `.asm`**. Ghidra pseudo-C a iné
> generované pomôcky nie sú verzované (viď `.gitignore`).

---

## Pôvod a kontext

Balík zostavil a stručne zdokumentoval *„MAT of ESI"* (Toruń, Poľsko, december
1993) a dodal s ním tri textové poznámky — zachované tu:

- `arch-pack_utils_info.txt` — používateľský popis každého nástroja.
- `arch-pack_utils_note.txt` — autorove poznámky (príbeh self-extraktu / MGT flagov).
- `UTILS.TXT` — doplnkové poznámky.

Samotné kompresné enginy pochádzajú od viacerých autorov (viď
[Autorstvo a licencia](#autorstvo-a-licencia)). Hlavný archivátor **ARCHIV** je
od **Mariána Krivoša (RUMSOFT, 1993)** — autora tohto repozitára.

---

## Inventár a stav

Súbory `*.BIN` sú orezané Z80 telá kódu; súbory s holým menom
(`ARCHIV`, `IMPLODER`, …) sú úplné SAM CODE/BASIC súbory (s hlavičkou).

| Binárka       | Vstup        | Load   | Nástroj / účel                                    | Autor               | Stav |
|---------------|--------------|--------|---------------------------------------------------|---------------------|------|
| `SKOMP1.BIN`  | `JP &400C`   | &4000  | Kompresor obrazovky                               | RUMSOFT             | **hotové** — `.asm` / `.md` / `.sk.md` |
| `ARCHIV.BIN`  | `JR &6D1E`   | &6D00  | DISK ARCHIVE v2.0 (menu archivátor)               | M. Krivoš / RUMSOFT | bajtovo presné `.asm` + doc |
| `IMPLO1.BIN`  | `JP &43FB`   | &4000  | TURBO IMPLODER v1.0                               | RUMSOFT & SAPOSOFT  | bajtovo presné `.asm` + `IMPLO1.md` |
| `UNPAK .BIN`  | `JP &414D`   | &4100  | UNPACK ARCHIVE 2.0 (inverzia ARCHIV)              | RUMSOFT             | bajtovo presné `.asm` + `UNPAK.md` |
| `COMPRES`     | `JP &A023`   | &A000  | kompresný engine LIB                              | SAPOSOFT            | bajtovo presné `COMPRES.asm` |
| `DEC`         | (relokátor)  | &8000  | samorelokujúci depacker stub LIB (367 B)          | SAPOSOFT            | bajtovo presné `DEC.asm` |
| `Lib v21`     | SAM BASIC    | —      | „Library" v2.1 správca súborov                    | S. Grodkowski       | `Lib v21.bas` + `LIB.md` |
| `PASS`        | SAM BASIC    | —      | loader password-garblera                          | —                   | `PASS.bas` |
| `PASS1`       | `DI …`       | ?      | Z80 rutina password-garblera (86 B)               | —                   | TODO |
| `SCREENCOM1`  | SAM BASIC    | —      | loader kompresora obrazovky (riadi SKOMP1)        | —                   | `SCREENCOM1.bas` |
| `CrunchCode`  | `JP &800E`   | &8000  | **cudzí** cruncher (RLE + frekvenčno-rank kód)    | neznámy             | bajtovo presné `CrunchCode.asm` + `CrunchCode.md` |
| `MDOS23`      | —            | —      | MasterDOS (tretia strana; len kontext)            | autori MasterDOS    | zachované, neanalyzované |

---

## Kompresné algoritmy (rekonštruované)

Čítaj **dekodér**, nie packer — depacker úplne a jednoznačne definuje každý
on-wire formát. Rekonštruované formáty:

- **SKOMP** — RLE oproti predošlému bajtu s LZSS-štýl flag bajtom (1 flag bit
  na token, 8 tokenov na flag bajt). Najlepšie na plochých/pruhovaných dátach
  obrazovky. Viď `SKOMP1.md`.
- **SHRINK** — PackBits-štýl RLE: riadiaci bajt `count = (B & 0x7F) + 1`,
  bit 7 = repeat/literal. Mód 1 IMPLODERu. Viď `IMPLO1.md §3.1`.
- **IMPLODE** — LZ77/LZSS: marker zhody `0x03`, 3-bajtový match token,
  `len 3..33`, `dist 1..2048`. Mód 2 IMPLODERu (mód 3 = SHRINK potom
  IMPLODE). Viď `IMPLO1.md §6a`.
- **CrunchCode** — RLE predspracovanie + statický **frekvenčno-rank entropický
  kód** (2-bitový prefix triedy: rank 0–3 / 4–19 / 20–83 / 8-bitový raw escape).
  Jediný štatistický koder sady — vyhráva na zošikmených dátach (text). Viď
  `CrunchCode.md §3.1`.

---

## C++ reimplementácie (`cpp/`)

Prenositeľné, bezzávislostné **C++17** kodeky operujúce nad pamäťovými blokmi —
algoritmicky ekvivalentné originálom (každý round-trippuje sám so sebou; nie sú
bitovo kompatibilné so SAM streamami, ak nie je uvedené inak). Štyri kodeky:
`skomp`, `shrink`, `implode`, `crunch`, každý s CLI a `t` self-testom.

```bash
cd cpp
CC=clang CXX=clang++ cmake -S . -B build && cmake --build build
./build/skomp t      # round-trip self-test (tiež: shrink / implode / crunch)
```

API, rozloženia streamov a poznámky k jednotlivým kodekom viď
[`cpp/README.md`](cpp/README.md).

---

## Toolchain

| Nástroj   | Účel                                                  |
|-----------|-------------------------------------------------------|
| `z80dasm` | Disassembler (1.1.6) — block-def + symbol súbory      |
| `z80asm`  | Assembler (z88dk / InterLogic) — `-b` zostaví `.bin`  |
| `make`    | Riadi assemble + **verify** round-trip                |
| `ghidra`  | Dekompilátor do pseudo-C (12.1, Z80 modul) — len pomôcka |

Štandardné volanie disassembly:

```bash
z80dasm -a -t -l -u -g <ORG> -b NAME.blk -S NAME.z80sym NAME.BIN -o NAME.gen.asm
```

### Pomocné skripty

| Skript             | Účel                                                              |
|--------------------|-------------------------------------------------------------------|
| `loadaddr.py`      | Odhad ORG: entry vektor + self-store + zhlukovanie cieľov volaní  |
| `ngram_dup.py`     | % zdieľaného kódu medzi dvomi binárkami cez 16-gramy              |
| `strip_listing.py` | Odstráni auto adresy+hex z komentárov `.asm`, ponechá prózu       |
| `sambas2txt.py`    | Detokenizuje SAM BASIC → ASCII výpis                              |
| `ghidra_decompile.java` | Headless Ghidra post-script → `NAME.ghidra.c`                |

---

## Verifikácia

Každé `.asm` sa spätne preloží na bajtovo identickú kópiu pôvodnej binárky. Robí
to generický `Makefile` (`NAME=` vyberá rutinu):

```bash
make NAME=SKOMP1 verify      # assemble SKOMP1.asm -> SKOMP1.bin, cmp vs SKOMP1.BIN
make NAME=ARCHIV verify
```

Meno súboru s medzerou (`UNPAK .BIN`) alebo bez prípony `.BIN` (`DEC`, `COMPRES`)
obchádza formu `NAME=` — assembluj a `cmp` priamo s explicitným ORG, napr.:

```bash
z80asm -b -o=/tmp/u.bin UNPAK.asm && cmp /tmp/u.bin "UNPAK .BIN"
```

---

## Metodika

`CLAUDE.md` dokumentuje úplný opakovateľný workflow (inšpekcia → disassemble →
nájdenie hraníc → anotácia → **verify round-trip** → dokumentácia) a zbierku
taktík reverzného inžinierstva (nájdenie load adresy, rozpoznanie triedy
algoritmu zo signatúrnych opkódov, práca so samomodifikujúcim sa /
relokujúcim kódom atď.). Je priložený ako záznam metodiky.

---

## Autorstvo a licencia

Toto je projekt zmiešaného pôvodu — preservácia + reverzné inžinierstvo:

- **Reverzno-inžinierska práca** (`*.asm`, `*.blk`, `*.z80sym`, `*.md`,
  `*.sk.md`, `*.bas`, skripty, `Makefile` a `cpp/`) je od **Mariána Krivoša**
  (s Claude Code) a je vydaná pod licenciou **MIT** — viď [`LICENSE`](LICENSE).
- **Pôvodné binárky z roku 1993 a disk image** ostávajú vlastníctvom svojich
  autorov a sú priložené len na **zachovanie a štúdium**:
  - RUMSOFT — ARCHIV, UNPAK, IMPLODER (čiastočne), SKOMP1
  - SAPOSOFT / S. Grodkowski — LIB, COMPRES, DEC, IMPLODER (čiastočne)
  - `CrunchCode` — neznámy autor tretej strany (nesúvisí so zvyškom)
  - `MDOS23` — **MasterDOS**, komerčný softvér tretej strany, ponechaný len
    ako kontext disk imageu

Ak ste držiteľom práv a chcete súbor odstrániť, založte prosím issue.

---

## Kredity

- Reverzné inžinierstvo & C++ porty: **Marián Krivoš** (RUMSOFT) s Claude Code.
- Pôvodné utility: RUMSOFT, SAPOSOFT (S. Grodkowski) a ďalší (1993).
- Zostavenie balíka & pôvodné poznámky: *MAT of ESI* (Toruń, 1993).
