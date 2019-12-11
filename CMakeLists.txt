cmake_minimum_required(VERSION 3.0)

set(CMAKE_TOOLCHAIN_FILE riscv64-linux-gnu.toolchain.cmake)
project(riscv-playground ASM)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")

add_executable(factorial src/factorial.s)
