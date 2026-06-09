# skomp — free C++ (de)compressor (SKOMP algorithm family)

A small, portable, dependency-free C++17 implementation of the **SKOMP**
compression algorithm (previous-byte RLE + LZSS-style control bit stream),
working on **memory blocks**. It compresses and decompresses with the same
algorithm and round-trips with itself.

It is **algorithmically equivalent** to the SAM Coupe `SKOMP1.BIN` screen
compressor but uses its own clean stream layout — it is *not* bit-compatible with
the original SAM depacker. See [`../SKOMP1.md`](../SKOMP1.md) for the on-target
format and the algorithm background.

## Files
- `skomp_codec.h` / `skomp_codec.cpp` — SKOMP screen RLE (`skomp::compress`/`decompress`).
- `skomp_tool.cpp` — SKOMP CLI + self-test (`./skomp t`).
- `implode_codec.h` / `implode_codec.cpp` — **IMPLODE LZ77** (RUMSOFT TURBO IMPLODER
  token format: 0x03 marker, 3-byte match, len 3–33, dist 1–2048). See `../IMPLO1.md §6a`.
- `implode_tool.cpp` — IMPLODE CLI + self-test (`./implode t`).
- `shrink_codec.h` / `shrink_codec.cpp` — **SHRINK** (PackBits-style RLE; the
  IMPLODER's other method: control byte `count=(B&0x7F)+1`, bit7=repeat/literal).
  See `../IMPLO1.md §3.1`.
- `shrink_tool.cpp` — SHRINK CLI + self-test (`./shrink t`).
- `crunch_codec.h` / `crunch_codec.cpp` — **CrunchCode** (foreign): RLE pre-pass +
  static **frequency-rank** entropy code (2-bit class prefix: rank 0-3 / 4-19 /
  20-83 / raw-escape). See `../CrunchCode.md`.
- `crunch_tool.cpp` — CrunchCode CLI + self-test (`./crunch t`).
- `CMakeLists.txt` — builds `skomp`, `implode`, `shrink` and `crunch`.

`shrink` + `implode` are the TURBO IMPLODER's two methods (Mode 3 = SHRINK then
IMPLODE). `crunch` is the unrelated foreign CrunchCode (the only one here that is
a statistical/entropy coder rather than RLE/LZ — it wins on skewed data like text).

## Build
```bash
# CMake (clang)
CC=clang CXX=clang++ cmake -S . -B build && cmake --build build

# or directly
clang++ -std=c++17 -O2 skomp_codec.cpp skomp_tool.cpp -o skomp
```

## Use
```bash
./skomp c input.bin output.skz   # compress a memory block (file)
./skomp d output.skz restored    # decompress
./skomp t                        # round-trip self-test
```

## API
```cpp
#include "skomp_codec.h"
std::vector<uint8_t> packed   = skomp::compress(block);     // vector or (ptr,size)
std::vector<uint8_t> restored = skomp::decompress(packed);
// restored == block
```

## Stream format
LZSS-style framing: one flag byte per 8 tokens (bits MSB first).
- bit `1` → **literal**: one new byte follows; becomes the predictor.
- bit `0` → **run**: one length byte `L` (1..255) follows; the previous byte is
  repeated `L` more times.

The first token is always a literal. Runs longer than 255 split into multiple run
tokens. Best on flat/striped data (screens); incompressible data expands by ~1/8
(one flag bit per byte), exactly as the original scheme does.
