///
/// \package crunch
///
/// \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
/// \date 5. 6. 2026
/// \brief Portable C++ implementation of the "CrunchCode" cruncher: an RLE
///        pre-pass plus a static frequency-rank entropy code, for memory blocks.
///
/// (C) Copyright 2026 R-SYS s.r.o
/// All rights reserved.
///

#pragma once

#include <cstdint>
#include <cstddef>
#include <vector>

namespace crunch {

/// Algorithm recovered from the foreign SAM "CrunchCode" packer (&8000):
///   1. RLE pre-pass: an escape byte (the least-frequent value) introduces runs.
///   2. Frequency-rank entropy code (the exact, distinctive part): byte values
///      are ranked by frequency (most frequent = rank 0). Each byte is written
///      as a 2-bit CLASS prefix + index/raw bits:
///        class 0 (00) + 2 bits -> rank 0..3
///        class 1 (01) + 4 bits -> rank 4..19
///        class 2 (10) + 6 bits -> rank 20..83
///        class 3 (11) + 8 bits -> raw byte (not in the top-84 ranks)
///      so frequent bytes get 4-bit codes, rarer ones 6/8-bit, the rest 10-bit.
///
/// This is a clean, forward, self-consistent model (encoder+decoder round-trip).
/// The entropy-code fields match CrunchCode exactly; the RLE pre-pass and the
/// container header are a clean equivalent (the SAM original integrates the two
/// stages with its own in-memory token layout). Not bit-identical to the
/// original's output (no packed sample was available to diff).

constexpr int MAX_RANKS = 84;   ///< bytes beyond the 84 most-frequent use the raw escape
constexpr int MIN_RUN   = 4;    ///< RLE encodes runs of >= 4 equal bytes

/// \brief Compress a memory block (RLE pre-pass + frequency-rank code).
std::vector<std::uint8_t> compress(const std::uint8_t* data, std::size_t size);

/// \brief Decompress a block produced by compress().
/// \throws std::runtime_error on a truncated / malformed stream.
std::vector<std::uint8_t> decompress(const std::uint8_t* data, std::size_t size);

inline std::vector<std::uint8_t> compress(const std::vector<std::uint8_t>& in)
{
    return compress(in.data(), in.size());
}
inline std::vector<std::uint8_t> decompress(const std::vector<std::uint8_t>& in)
{
    return decompress(in.data(), in.size());
}

} // namespace crunch
