///
/// \package skomp
///
/// \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
/// \date 5. 6. 2026
/// \brief Free, portable C++ implementation of the SKOMP compression family
///        (previous-byte RLE + control bit stream) for memory blocks.
///
/// (C) Copyright 2026 R-SYS s.r.o
/// All rights reserved.
///

#pragma once

#include <cstdint>
#include <cstddef>
#include <vector>

namespace skomp {

/// \brief Compress a raw memory block.
///
/// Algorithm (same family as the SAM Coupe SKOMP v2.0 screen compressor):
/// a control bit stream (LZSS-style framing, one flag byte per 8 tokens, MSB
/// first) drives a "previous byte" RLE:
///   * bit = 1  -> literal: one new byte follows; it becomes the "previous".
///   * bit = 0  -> run:     one length byte L (1..255) follows; the previous
///                          byte is repeated L more times.
/// The first token is always a literal (there is no "previous" yet). Runs longer
/// than 255 are split into several run tokens.
///
/// NOTE: this is algorithmically equivalent to SKOMP but uses its own, clean,
/// self-consistent stream layout. It is NOT bit-compatible with the original SAM
/// depacker (see SKOMP1.md for the on-target format). The codec round-trips with
/// itself: decompress(compress(x)) == x for any input.
///
/// \param data pointer to the input block (may be null iff size == 0)
/// \param size number of input bytes
/// \return compressed block (empty input -> empty output)
std::vector<std::uint8_t> compress(const std::uint8_t* data, std::size_t size);

/// \brief Decompress a block produced by compress().
/// \throws std::runtime_error on a truncated / malformed stream.
std::vector<std::uint8_t> decompress(const std::uint8_t* data, std::size_t size);

/// \brief Convenience overloads operating on std::vector blocks.
inline std::vector<std::uint8_t> compress(const std::vector<std::uint8_t>& in)
{
    return compress(in.data(), in.size());
}

inline std::vector<std::uint8_t> decompress(const std::vector<std::uint8_t>& in)
{
    return decompress(in.data(), in.size());
}

} // namespace skomp
