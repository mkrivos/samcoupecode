cmake_minimum_required(VERSION 3.16)
project(sampack_codecs CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# SKOMP screen RLE (previous-byte RLE + control bit stream)
add_library(skomp_codec STATIC skomp_codec.cpp)
target_include_directories(skomp_codec PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_executable(skomp skomp_tool.cpp)
target_link_libraries(skomp PRIVATE skomp_codec)

# IMPLODE LZ77 (RUMSOFT TURBO IMPLODER token format)
add_library(implode_codec STATIC implode_codec.cpp)
target_include_directories(implode_codec PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_executable(implode implode_tool.cpp)
target_link_libraries(implode PRIVATE implode_codec)

# SHRINK (PackBits-style RLE) — the IMPLODER's other method
add_library(shrink_codec STATIC shrink_codec.cpp)
target_include_directories(shrink_codec PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_executable(shrink shrink_tool.cpp)
target_link_libraries(shrink PRIVATE shrink_codec)

# CrunchCode (foreign): RLE pre-pass + static frequency-rank entropy code
add_library(crunch_codec STATIC crunch_codec.cpp)
target_include_directories(crunch_codec PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_executable(crunch crunch_tool.cpp)
target_link_libraries(crunch PRIVATE crunch_codec)

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    foreach(t skomp_codec skomp implode_codec implode shrink_codec shrink crunch_codec crunch)
        target_compile_options(${t} PRIVATE -Wall -Wextra -Wpedantic)
    endforeach()
endif()
