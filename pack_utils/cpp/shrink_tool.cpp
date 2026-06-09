///
/// \package shrink
///
/// \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
/// \date 5. 6. 2026
/// \brief CLI + round-trip self-test for the SHRINK (PackBits RLE) codec.
///
/// (C) Copyright 2026 R-SYS s.r.o
/// All rights reserved.
///

#include "shrink_codec.h"

#include <cstdint>
#include <cstdio>
#include <fstream>
#include <string>
#include <vector>

namespace {

std::vector<std::uint8_t> readFile(const std::string& path)
{
    std::ifstream f(path, std::ios::binary);
    if (!f)
        throw std::runtime_error("cannot open input: " + path);
    return std::vector<std::uint8_t>((std::istreambuf_iterator<char>(f)),
                                     std::istreambuf_iterator<char>());
}

void writeFile(const std::string& path, const std::vector<std::uint8_t>& d)
{
    std::ofstream f(path, std::ios::binary);
    if (!f)
        throw std::runtime_error("cannot open output: " + path);
    if (!d.empty())
        f.write(reinterpret_cast<const char*>(d.data()),
                static_cast<std::streamsize>(d.size()));
}

int roundTrip(const std::string& name, const std::vector<std::uint8_t>& in)
{
    auto packed = shrink::compress(in);
    auto back = shrink::decompress(packed);
    bool ok = (back == in);
    double r = in.empty() ? 0.0 : 100.0 * packed.size() / in.size();
    std::printf("  %-22s in=%7zu packed=%7zu (%5.1f%%)  %s\n",
                name.c_str(), in.size(), packed.size(), r,
                ok ? "OK" : "*** MISMATCH ***");
    return ok ? 0 : 1;
}

int selfTest()
{
    int fails = 0;
    std::printf("SHRINK (PackBits RLE) codec self-test (round-trip):\n");
    fails += roundTrip("empty", {});
    fails += roundTrip("single byte", {0x42});
    fails += roundTrip("short run x3", {7, 7, 7});           // < MIN_RUN -> literal
    fails += roundTrip("run x4", {7, 7, 7, 7});              // -> repeat
    {
        std::vector<std::uint8_t> v(10000, 0x00);            // one long run (>128)
        fails += roundTrip("all zeros 10k", v);
    }
    {
        std::vector<std::uint8_t> v;
        std::uint32_t s = 1;                                 // incompressible
        for (int i = 0; i < 8000; ++i) { s = s * 1103515245u + 12345u; v.push_back((std::uint8_t)(s >> 16)); }
        fails += roundTrip("pseudo-random 8k", v);
    }
    {
        // screen-like: runs of equal bytes with occasional change
        std::vector<std::uint8_t> v; std::uint32_t s = 7;
        while (v.size() < 24576) {
            s = s * 1103515245u + 12345u;
            std::size_t run = 1 + ((s >> 8) % 40);
            v.insert(v.end(), run, (std::uint8_t)(s >> 24));
        }
        v.resize(24576);
        fails += roundTrip("screen-like 24k", v);
    }
    std::printf("%s\n", fails == 0 ? "ALL TESTS PASSED" : "SOME TESTS FAILED");
    return fails == 0 ? 0 : 1;
}

void usage(const char* a0)
{
    std::fprintf(stderr,
                 "Usage:\n"
                 "  %s c <in> <out>   SHRINK-compress a memory block (file)\n"
                 "  %s d <in> <out>   decompress\n"
                 "  %s t              round-trip self-test\n", a0, a0, a0);
}

} // namespace

int main(int argc, char** argv)
{
    try {
        if (argc >= 2 && std::string(argv[1]) == "t")
            return selfTest();
        if (argc == 4 && std::string(argv[1]) == "c") {
            auto in = readFile(argv[2]);
            auto out = shrink::compress(in);
            writeFile(argv[3], out);
            std::printf("compressed %zu -> %zu bytes\n", in.size(), out.size());
            return 0;
        }
        if (argc == 4 && std::string(argv[1]) == "d") {
            auto in = readFile(argv[2]);
            auto out = shrink::decompress(in);
            writeFile(argv[3], out);
            std::printf("decompressed %zu -> %zu bytes\n", in.size(), out.size());
            return 0;
        }
        usage(argv[0]);
        return 2;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "error: %s\n", e.what());
        return 1;
    }
}
