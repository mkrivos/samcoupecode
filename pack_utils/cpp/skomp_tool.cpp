///
/// \package skomp
///
/// \author Marian Krivos <marian.krivos@rsys.sk> a Claude Code
/// \date 5. 6. 2026
/// \brief CLI for the SKOMP-family codec: pack/unpack files and a round-trip self-test.
///
/// (C) Copyright 2026 R-SYS s.r.o
/// All rights reserved.
///

#include "skomp_codec.h"

#include <cstdint>
#include <cstdio>
#include <fstream>
#include <iostream>
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

void writeFile(const std::string& path, const std::vector<std::uint8_t>& data)
{
    std::ofstream f(path, std::ios::binary);
    if (!f)
        throw std::runtime_error("cannot open output: " + path);
    if (!data.empty())
        f.write(reinterpret_cast<const char*>(data.data()),
                static_cast<std::streamsize>(data.size()));
}

int roundTrip(const std::string& name, const std::vector<std::uint8_t>& in)
{
    const auto packed = skomp::compress(in);
    const auto back = skomp::decompress(packed);
    const bool ok = (back == in);
    const double ratio = in.empty() ? 0.0
                                    : 100.0 * static_cast<double>(packed.size())
                                          / static_cast<double>(in.size());
    std::printf("  %-22s in=%7zu  packed=%7zu  (%5.1f%%)  %s\n",
                name.c_str(), in.size(), packed.size(), ratio,
                ok ? "OK" : "*** MISMATCH ***");
    return ok ? 0 : 1;
}

int selfTest()
{
    int fails = 0;
    std::printf("SKOMP codec self-test (round-trip):\n");

    fails += roundTrip("empty", {});
    fails += roundTrip("single byte", {0x42});

    {
        std::vector<std::uint8_t> v(10000, 0x00); // one very long run (>255)
        fails += roundTrip("all zeros 10k", v);
    }
    {
        std::vector<std::uint8_t> v;
        for (int i = 0; i < 10000; ++i)
            v.push_back(static_cast<std::uint8_t>(i & 1 ? 0xFF : 0x00)); // worst case
        fails += roundTrip("alternating 10k", v);
    }
    {
        std::vector<std::uint8_t> v;
        std::uint32_t s = 12345;
        for (int i = 0; i < 10000; ++i)
        {
            s = s * 1103515245u + 12345u; // LCG, deterministic pseudo-random
            v.push_back(static_cast<std::uint8_t>(s >> 16));
        }
        fails += roundTrip("pseudo-random 10k", v);
    }
    {
        // screen-like: runs of equal bytes with occasional changes
        std::vector<std::uint8_t> v;
        std::uint32_t s = 777;
        while (v.size() < 24576)
        {
            s = s * 1103515245u + 12345u;
            std::uint8_t val = static_cast<std::uint8_t>(s >> 24);
            std::size_t run = 1 + ((s >> 8) % 40);
            v.insert(v.end(), run, val);
        }
        v.resize(24576);
        fails += roundTrip("screen-like 24k", v);
    }

    std::printf("%s\n", fails == 0 ? "ALL TESTS PASSED" : "SOME TESTS FAILED");
    return fails == 0 ? 0 : 1;
}

void usage(const char* argv0)
{
    std::fprintf(stderr,
                 "Usage:\n"
                 "  %s c <in> <out>   compress a memory block (file)\n"
                 "  %s d <in> <out>   decompress\n"
                 "  %s t              run the round-trip self-test\n",
                 argv0, argv0, argv0);
}

} // namespace

int main(int argc, char** argv)
{
    try
    {
        if (argc >= 2 && std::string(argv[1]) == "t")
            return selfTest();

        if (argc == 4 && std::string(argv[1]) == "c")
        {
            const auto in = readFile(argv[2]);
            const auto out = skomp::compress(in);
            writeFile(argv[3], out);
            std::printf("compressed %zu -> %zu bytes\n", in.size(), out.size());
            return 0;
        }

        if (argc == 4 && std::string(argv[1]) == "d")
        {
            const auto in = readFile(argv[2]);
            const auto out = skomp::decompress(in);
            writeFile(argv[3], out);
            std::printf("decompressed %zu -> %zu bytes\n", in.size(), out.size());
            return 0;
        }

        usage(argv[0]);
        return 2;
    }
    catch (const std::exception& e)
    {
        std::fprintf(stderr, "error: %s\n", e.what());
        return 1;
    }
}
