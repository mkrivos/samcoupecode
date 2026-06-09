///
/// \package skomp
///
/// \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
/// \date 5. 6. 2026
/// \brief Implementation of the SKOMP-family (de)compressor for memory blocks.
///
/// (C) Copyright 2026 R-SYS s.r.o
/// All rights reserved.
///

#include "skomp_codec.h"

#include <stdexcept>

namespace skomp {

namespace {

constexpr std::size_t kMaxRun = 255; ///< max repeats encodable in one run token

/// Helper that emits the LZSS-style control bit stream: a flag byte is inserted
/// before every group of 8 tokens, bits filled MSB first. The payload bytes of a
/// token are appended immediately after setting its bit, so a group is laid out
/// as [flag][payloads of its up-to-8 tokens].
class BitPacker
{
public:
    explicit BitPacker(std::vector<std::uint8_t>& out) : out_(out) {}

    /// Begin a new token; \p one selects literal (true) or run (false).
    void bit(bool one)
    {
        if (tokenInGroup_ == 8)
        {
            flagIndex_ = out_.size();
            out_.push_back(0);
            tokenInGroup_ = 0;
        }
        if (one)
            out_[flagIndex_] |= static_cast<std::uint8_t>(0x80u >> tokenInGroup_);
        ++tokenInGroup_;
    }

private:
    std::vector<std::uint8_t>& out_;
    std::size_t flagIndex_ = 0;
    int tokenInGroup_ = 8; ///< forces a fresh flag byte on the first token
};

} // namespace

std::vector<std::uint8_t> compress(const std::uint8_t* data, std::size_t size)
{
    std::vector<std::uint8_t> out;
    if (size == 0)
        return out;

    out.reserve(size / 2 + 16);
    BitPacker packer(out);

    std::uint8_t prev = 0;
    bool havePrev = false;
    std::size_t i = 0;

    while (i < size)
    {
        if (havePrev && data[i] == prev)
        {
            // Run: count consecutive bytes equal to prev, capped per token.
            std::size_t run = 0;
            while (i < size && data[i] == prev && run < kMaxRun)
            {
                ++run;
                ++i;
            }
            packer.bit(false);
            out.push_back(static_cast<std::uint8_t>(run));
        }
        else
        {
            // Literal: a new byte that becomes the predictor.
            packer.bit(true);
            out.push_back(data[i]);
            prev = data[i];
            havePrev = true;
            ++i;
        }
    }

    return out;
}

std::vector<std::uint8_t> decompress(const std::uint8_t* data, std::size_t size)
{
    std::vector<std::uint8_t> out;
    if (size == 0)
        return out;

    std::uint8_t prev = 0;
    bool havePrev = false;
    std::uint8_t flag = 0;
    int tokenInGroup = 8; // forces reading a flag byte on the first token
    std::size_t p = 0;

    while (p < size)
    {
        if (tokenInGroup == 8)
        {
            flag = data[p++];
            tokenInGroup = 0;
            if (p >= size)
                throw std::runtime_error("skomp: truncated stream (flag without tokens)");
        }

        const bool one = (flag & static_cast<std::uint8_t>(0x80u >> tokenInGroup)) != 0;
        ++tokenInGroup;

        if (one)
        {
            // Literal byte.
            const std::uint8_t b = data[p++];
            out.push_back(b);
            prev = b;
            havePrev = true;
        }
        else
        {
            // Run of the previous byte.
            const std::uint8_t run = data[p++];
            if (!havePrev)
                throw std::runtime_error("skomp: malformed stream (run before any literal)");
            out.insert(out.end(), run, prev);
        }
    }

    return out;
}

} // namespace skomp
