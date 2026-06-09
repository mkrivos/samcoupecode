///
/// \package implode
///
/// \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
/// \date 5. 6. 2026
/// \brief Portable C++ implementation of RUMSOFT TURBO IMPLODER's LZ77 token
///        format (the IMPLODE method), encoder and decoder, for memory blocks.
///
/// (C) Copyright 2026 R-SYS s.r.o
/// All rights reserved.
///

#pragma once

#include <cstdint>
#include <cstddef>
#include <vector>

namespace implode {

/// Parameters of the IMPLODE LZ77 format, as recovered from the depacker
/// (implode_fin @ &4911 -> the stub run at &4C00 in IMPLO1.BIN):
///   * MIN_MATCH = 3, MAX_MATCH = 33   (length-2 stored in 5 bits)
///   * MAX_DIST  = 2048                (distance-1 stored in 11 bits: 3+8)
constexpr int MIN_MATCH = 3;
constexpr int MAX_MATCH = 33;
constexpr int MAX_DIST  = 2048;
constexpr std::uint8_t MARK = 0x03;     ///< match-escape marker byte

/// Token stream (this forward model; the SAM original decodes it backward,
/// in place):
///   * a literal byte != 0x03                      -> itself
///   * a literal byte == 0x03                      -> 0x03, 0x00
///   * a match (len in 3..33, dist in 1..2048)     -> 0x03, mid, dist_lo
///       mid     = ((len-2) << 3) | dist_hi   (mid != 0, since len>=3)
///       dist_hi = (dist-1) >> 8              (0..7)
///       dist_lo = (dist-1) & 0xFF
///   decode: len = (mid>>3)+2 ; dist = ((dist_hi<<8)|dist_lo)+1

/// \brief Compress a memory block with the IMPLODE LZ77 method (greedy).
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

} // namespace implode
