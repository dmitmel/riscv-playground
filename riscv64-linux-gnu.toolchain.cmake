set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR riscv64)

set(toolchain_target ${CMAKE_SYSTEM_PROCESSOR}-linux-gnu)

set(toolchain_gcc "${toolchain_target}-gcc")
find_program(toolchain_gcc_path "${toolchain_gcc}" DOC "Path to ${toolchain_gcc} program executable.")
if(NOT toolchain_gcc_path)
  message(FATAL_ERROR "unable to find ${toolchain_gcc}")
endif()
get_filename_component(toolchain_gcc_path "${toolchain_gcc_path}" REALPATH)
message(STATUS "Found toolchain GCC: ${toolchain_gcc_path}")
get_filename_component(toolchain_root "${toolchain_gcc_path}" DIRECTORY)
message(STATUS "Found toolchain root: ${toolchain_root}")

set(tool_prefix "${toolchain_root}/${toolchain_target}-")
set(CMAKE_C_COMPILER   "${tool_prefix}gcc")
set(CMAKE_CXX_COMPILER "${tool_prefix}g++")
set(CMAKE_ASM_COMPILER "${tool_prefix}gcc")
