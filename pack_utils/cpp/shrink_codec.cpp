///
/// \package shrink
///
/// \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
/// \date 5. 6. 2026
/// \brief SHRINK (PackBits RLE) encoder/decoder implementation (see shrink_codec.h).
///
/// (C) Copyright 2026 R-SYS s.r.o
/// All rights reserved.
///

#include "shrink_codec.h"

#include <stdexcept>

namespace shrink {

namespace {

/// Flush a pending literal run as one or more LITERAL tokens (max 128 each).
void flush_literals(std::vector<std::uint8_t>& out,
                    const std::uint8_t* lit, std::size_t n)
{
    std::size_t i = 0;
    while (i < n) {
        std::size_t c = (n - i < MAX_COUNT) ? (n - i) : MAX_COUNT;
        out.push_back(static_cast<std::uint8_t>(c - 1));   // bit7=0 -> literal
        out.insert(out.end(), lit + i, lit + i + c);
        i += c;
    }
}

} // namespace

std::vector<std::uint8_t> compress(const std::uint8_t* data, std::size_t size)
{
    std::vector<std::uint8_t> out;
    std::vector<std::uint8_t> lit;             // pending literal bytes
    std::size_t i = 0;
    while (i < size) {
        // measure the run of equal bytes starting at i
        std::size_t run = 1;
        while (i + run < size && data[i + run] == data[i])
            ++run;

        if (run >= static_cast<std::size_t>(MIN_RUN)) {
            flush_literals(out, lit.data(), lit.size());
            lit.clear();
            std::size_t left = run;
            while (left > 0) {                 // REPEAT tokens, max 128 each
                std::size_t c = (left < MAX_COUNT) ? left : MAX_COUNT;
                out.push_back(static_cast<std::uint8_t>(0x80 | (c - 1)));
                out.push_back(data[i]);
                left -= c;
            }
            i += run;
        } else {
            for (std::size_t k = 0; k < run; ++k)
                lit.push_back(data[i + k]);
            i += run;
        }
    }
    flush_literals(out, lit.data(), lit.size());
    return out;
}

std::vector<std::uint8_t> decompress(const std::uint8_t* data, std::size_t size)
{
    std::vector<std::uint8_t> out;
    std::size_t p = 0;
    while (p < size) {
        std::uint8_t b = data[p++];
        int count = (b & 0x7F) + 1;
        if (b & 0x80) {                        // REPEAT
            if (p >= size)
                throw std::runtime_error("shrink: truncated repeat token");
            std::uint8_t v = data[p++];
            out.insert(out.end(), static_cast<std::size_t>(count), v);
        } else {                               // LITERAL run
            if (p + count > size)
                throw std::runtime_error("shrink: truncated literal run");
            out.insert(out.end(), data + p, data + p + count);
            p += count;
        }
    }
    return out;
}

} // namespace shrink
