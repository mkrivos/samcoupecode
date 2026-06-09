///
/// \package implode
///
/// \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
/// \date 5. 6. 2026
/// \brief IMPLODE LZ77 encoder/decoder implementation (see implode_codec.h).
///
/// (C) Copyright 2026 R-SYS s.r.o
/// All rights reserved.
///

#include "implode_codec.h"

#include <algorithm>
#include <stdexcept>
#include <unordered_map>

namespace implode {

namespace {

/// Emit a literal byte, escaping the marker value 0x03 as {0x03,0x00}.
void put_literal(std::vector<std::uint8_t>& out, std::uint8_t b)
{
    out.push_back(b);
    if (b == MARK)
        out.push_back(0x00);            // mid==0 -> "not a match", literal 0x03
}

/// Emit a (length,distance) match token: 0x03, mid, dist_lo.
void put_match(std::vector<std::uint8_t>& out, int len, int dist)
{
    const int df = dist - 1;            // distance field 0..2047
    const std::uint8_t mid = static_cast<std::uint8_t>(((len - 2) << 3) | (df >> 8));
    out.push_back(MARK);
    out.push_back(mid);                 // mid != 0 because len >= 3
    out.push_back(static_cast<std::uint8_t>(df & 0xFF));
}

inline std::uint32_t key3(const std::uint8_t* p)
{
    return static_cast<std::uint32_t>(p[0]) | (p[1] << 8) | (p[2] << 16);
}

} // namespace

std::vector<std::uint8_t> compress(const std::uint8_t* data, std::size_t size)
{
    std::vector<std::uint8_t> out;
    if (size == 0)
        return out;
    out.reserve(size);

    // 3-byte hash -> recent positions (most recent at the back).
    std::unordered_map<std::uint32_t, std::vector<std::size_t>> chains;
    const int MAX_CANDIDATES = 256;     // bound the search effort

    std::size_t i = 0;
    while (i < size) {
        int best_len = 0;
        std::size_t best_pos = 0;
        if (i + MIN_MATCH <= size) {
            auto it = chains.find(key3(data + i));
            if (it != chains.end()) {
                const auto& v = it->second;
                int tried = 0;
                for (auto rit = v.rbegin(); rit != v.rend() && tried < MAX_CANDIDATES; ++rit, ++tried) {
                    std::size_t j = *rit;
                    if (i - j > static_cast<std::size_t>(MAX_DIST))
                        break;          // older entries are even farther -> stop
                    int len = 0;
                    int maxlen = static_cast<int>(std::min<std::size_t>(MAX_MATCH, size - i));
                    while (len < maxlen && data[j + len] == data[i + len])
                        ++len;
                    if (len > best_len) {
                        best_len = len;
                        best_pos = j;
                        if (len == MAX_MATCH)
                            break;
                    }
                }
            }
        }

        std::size_t advance;
        if (best_len >= MIN_MATCH) {
            put_match(out, best_len, static_cast<int>(i - best_pos));
            advance = static_cast<std::size_t>(best_len);
        } else {
            put_literal(out, data[i]);
            advance = 1;
        }
        // index every position we pass (so later matches can reference them)
        std::size_t end = i + advance;
        for (; i < end && i + MIN_MATCH <= size; ++i)
            chains[key3(data + i)].push_back(i);
        i = end;
    }
    return out;
}

std::vector<std::uint8_t> decompress(const std::uint8_t* data, std::size_t size)
{
    std::vector<std::uint8_t> out;
    std::size_t p = 0;
    while (p < size) {
        std::uint8_t x = data[p++];
        if (x != MARK) {                // plain literal
            out.push_back(x);
            continue;
        }
        if (p >= size)
            throw std::runtime_error("implode: truncated after marker");
        std::uint8_t mid = data[p++];
        if (mid == 0x00) {              // escaped literal 0x03
            out.push_back(MARK);
            continue;
        }
        if (p >= size)
            throw std::runtime_error("implode: truncated match token");
        std::uint8_t dist_lo = data[p++];
        int len = (mid >> 3) + 2;
        int dist = (((mid & 0x07) << 8) | dist_lo) + 1;
        if (static_cast<std::size_t>(dist) > out.size())
            throw std::runtime_error("implode: match distance before start");
        std::size_t src = out.size() - static_cast<std::size_t>(dist);
        for (int k = 0; k < len; ++k)   // byte-wise copy (handles overlap)
            out.push_back(out[src + k]);
    }
    return out;
}

} // namespace implode
