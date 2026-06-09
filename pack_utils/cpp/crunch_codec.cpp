///
/// \package crunch
///
/// \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
/// \date 5. 6. 2026
/// \brief CrunchCode codec implementation: RLE pre-pass + frequency-rank code.
///
/// (C) Copyright 2026 R-SYS s.r.o
/// All rights reserved.
///

#include "crunch_codec.h"

#include <algorithm>
#include <array>
#include <numeric>
#include <stdexcept>

namespace crunch {

namespace {

//--------------------------------------------------------------------- bit I/O
class BitWriter {
public:
    explicit BitWriter(std::vector<std::uint8_t>& out) : out_(out) {}
    void put(std::uint32_t value, int bits)         // LSB first
    {
        for (int i = 0; i < bits; ++i) {
            cur_ |= static_cast<std::uint8_t>(((value >> i) & 1) << nbits_);
            if (++nbits_ == 8) { out_.push_back(cur_); cur_ = 0; nbits_ = 0; }
        }
    }
    void flush() { if (nbits_) { out_.push_back(cur_); cur_ = 0; nbits_ = 0; } }
private:
    std::vector<std::uint8_t>& out_;
    std::uint8_t cur_ = 0;
    int nbits_ = 0;
};

class BitReader {
public:
    BitReader(const std::uint8_t* p, std::size_t n) : p_(p), n_(n) {}
    std::uint32_t get(int bits)                     // LSB first
    {
        std::uint32_t v = 0;
        for (int i = 0; i < bits; ++i) {
            if (nbits_ == 0) {
                if (pos_ >= n_) throw std::runtime_error("crunch: bitstream underrun");
                cur_ = p_[pos_++]; nbits_ = 8;
            }
            v |= static_cast<std::uint32_t>(cur_ & 1) << i;
            cur_ >>= 1; --nbits_;
        }
        return v;
    }
private:
    const std::uint8_t* p_;
    std::size_t n_, pos_ = 0;
    std::uint8_t cur_ = 0;
    int nbits_ = 0;
};

//---------------------------------------------------------------- little stage helpers
std::uint8_t least_frequent_byte(const std::uint8_t* d, std::size_t n)
{
    std::array<std::size_t, 256> freq{};
    for (std::size_t i = 0; i < n; ++i) ++freq[d[i]];
    return static_cast<std::uint8_t>(
        std::min_element(freq.begin(), freq.end()) - freq.begin());
}

/// RLE pre-pass. Escape E introduces runs:  E,0 = literal E ;
/// E,count,value = `value` repeated `count` times (count 1..255, used for >=4).
std::vector<std::uint8_t> rle_pack(const std::uint8_t* d, std::size_t n, std::uint8_t esc)
{
    std::vector<std::uint8_t> out;
    std::size_t i = 0;
    while (i < n) {
        std::uint8_t b = d[i];
        std::size_t run = 1;
        while (i + run < n && d[i + run] == b) ++run;
        if (b == esc) {                              // escape the escape byte itself
            for (std::size_t k = 0; k < run; ++k) { out.push_back(esc); out.push_back(0); }
        } else if (run >= static_cast<std::size_t>(MIN_RUN)) {
            for (std::size_t left = run; left > 0; ) {     // E, count, value  (chunks of 255)
                std::size_t c = std::min<std::size_t>(left, 255);
                out.push_back(esc); out.push_back(static_cast<std::uint8_t>(c)); out.push_back(b);
                left -= c;
            }
        } else {
            for (std::size_t k = 0; k < run; ++k) out.push_back(b);   // short run -> literals
        }
        i += run;
    }
    return out;
}

std::vector<std::uint8_t> rle_unpack(const std::vector<std::uint8_t>& s, std::uint8_t esc)
{
    std::vector<std::uint8_t> out;
    std::size_t p = 0;
    while (p < s.size()) {
        std::uint8_t b = s[p++];
        if (b != esc) { out.push_back(b); continue; }
        if (p >= s.size()) throw std::runtime_error("crunch: truncated RLE escape");
        std::uint8_t c = s[p++];
        if (c == 0) { out.push_back(esc); continue; }       // literal escape byte
        if (p >= s.size()) throw std::runtime_error("crunch: truncated RLE run");
        std::uint8_t v = s[p++];
        out.insert(out.end(), static_cast<std::size_t>(c), v);
    }
    return out;
}

} // namespace

std::vector<std::uint8_t> compress(const std::uint8_t* data, std::size_t size)
{
    std::vector<std::uint8_t> out;
    if (size == 0) return out;

    const std::uint8_t esc = least_frequent_byte(data, size);
    const std::vector<std::uint8_t> rle = rle_pack(data, size, esc);

    // frequency rank of the RLE stream (most frequent = rank 0)
    std::array<std::size_t, 256> freq{};
    for (std::uint8_t b : rle) ++freq[b];
    std::array<int, 256> order;
    std::iota(order.begin(), order.end(), 0);
    std::stable_sort(order.begin(), order.end(),
                     [&](int a, int b) { return freq[a] > freq[b]; });
    int nranks = 0;
    for (int i = 0; i < 256 && i < MAX_RANKS; ++i) {
        if (freq[order[i]] == 0) break;
        ++nranks;
    }
    std::array<int, 256> rank;
    rank.fill(-1);
    for (int r = 0; r < nranks; ++r) rank[order[r]] = r;

    // header: rle_len(4 LE) | escape(1) | nranks(1) | rank table bytes
    std::uint32_t rl = static_cast<std::uint32_t>(rle.size());
    out.push_back(rl & 0xFF); out.push_back((rl >> 8) & 0xFF);
    out.push_back((rl >> 16) & 0xFF); out.push_back((rl >> 24) & 0xFF);
    out.push_back(esc);
    out.push_back(static_cast<std::uint8_t>(nranks));
    for (int r = 0; r < nranks; ++r) out.push_back(static_cast<std::uint8_t>(order[r]));

    BitWriter bw(out);
    for (std::uint8_t b : rle) {
        int r = rank[b];
        if (r >= 0 && r <= 3)        { bw.put(0, 2); bw.put(r, 2); }
        else if (r >= 4 && r <= 19)  { bw.put(1, 2); bw.put(r - 4, 4); }
        else if (r >= 20 && r <= 83) { bw.put(2, 2); bw.put(r - 20, 6); }
        else                         { bw.put(3, 2); bw.put(b, 8); }
    }
    bw.flush();
    return out;
}

std::vector<std::uint8_t> decompress(const std::uint8_t* data, std::size_t size)
{
    if (size == 0) return {};
    if (size < 6) throw std::runtime_error("crunch: header too short");

    std::size_t p = 0;
    std::uint32_t rle_len = static_cast<std::uint32_t>(data[0]) | (data[1] << 8) |
                            (data[2] << 16) | (static_cast<std::uint32_t>(data[3]) << 24);
    std::uint8_t esc = data[4];
    int nranks = data[5];
    p = 6;
    if (p + static_cast<std::size_t>(nranks) > size)
        throw std::runtime_error("crunch: truncated rank table");
    std::vector<std::uint8_t> table(data + p, data + p + nranks);
    p += nranks;

    BitReader br(data + p, size - p);
    std::vector<std::uint8_t> rle;
    rle.reserve(rle_len);
    for (std::uint32_t i = 0; i < rle_len; ++i) {
        std::uint32_t cls = br.get(2);
        int idx;
        std::uint8_t b;
        switch (cls) {
            case 0: idx = static_cast<int>(br.get(2));        b = table.at(idx); break;
            case 1: idx = static_cast<int>(br.get(4)) + 4;    b = table.at(idx); break;
            case 2: idx = static_cast<int>(br.get(6)) + 20;   b = table.at(idx); break;
            default: b = static_cast<std::uint8_t>(br.get(8));               break;
        }
        rle.push_back(b);
    }
    return rle_unpack(rle, esc);
}

} // namespace crunch
