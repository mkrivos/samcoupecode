///
/// \package shrink
///
/// \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
/// \date 5. 6. 2026
/// \brief Portable C++ implementation of RUMSOFT TURBO IMPLODER's SHRINK method
///        (PackBits-style RLE), encoder and decoder, for memory blocks.
///
/// (C) Copyright 2026 R-SYS s.r.o
/// All rights reserved.
///

#pragma once

#include <cstdint>
#include <cstddef>
#include <vector>

namespace shrink {

/// SHRINK token format, recovered from the depacker (the stub relocated to
/// &4C00 by `shrink`/`shrink_core`, decode loop at l46aeh). It is a PackBits
/// variant — a control byte then data:
///   control B:  count = (B & 0x7F) + 1   (1 .. 128)
///     bit7 = 1  -> REPEAT : one value byte follows, output it `count` times
///     bit7 = 0  -> LITERAL: `count` bytes follow, output them verbatim
/// No escaping is needed (the format is positional). Decoding runs until the
/// input is consumed. The SAM original stores this backward for in-place
/// decompression; this is a clean forward model with identical token fields.
constexpr int MIN_RUN  = 4;     ///< runs of >=4 equal bytes become REPEAT (as shrink_scan)
constexpr int MAX_COUNT = 128;  ///< max bytes per token ((B&0x7F)+1)

/// \brief Compress a memory block with the SHRINK (PackBits RLE) method.
std::vector<std::uint8_t> compress(const std::uint8_t* data, std::size_t size);

/// \brief Decompress a block produced by compress().
/// \throws std::runtime_error on a truncated stream.
std::vector<std::uint8_t> decompress(const std::uint8_t* data, std::size_t size);

inline std::vector<std::uint8_t> compress(const std::vector<std::uint8_t>& in)
{
    return compress(in.data(), in.size());
}
inline std::vector<std::uint8_t> decompress(const std::vector<std::uint8_t>& in)
{
    return decompress(in.data(), in.size());
}

} // namespace shrink
