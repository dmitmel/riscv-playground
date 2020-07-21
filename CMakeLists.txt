cmake_minimum_required(VERSION 3.0)

set(CMAKE_TOOLCHAIN_FILE riscv64-linux-gnu.toolchain.cmake)
project(riscv-playground ASM)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")

set(qemu "qemu-${CMAKE_SYSTEM_PROCESSOR}")
find_program(qemu_path "${qemu}" DOC "Path to ${qemu} program executable.")
if(NOT qemu_path)
  message(WARNING "unable to find ${qemu}, run_* targets will be disabled")
endif()
message(STATUS "Found QEMU: ${qemu_path}")

function(my_add_executable name)
  add_executable("${name}" ${ARGN})
  if (qemu_path)
    add_custom_target("run_${name}"
      COMMAND "${qemu_path}" "${name}"
      DEPENDS "${name}"
      USES_TERMINAL
    )
  endif()
endfunction()

my_add_executable(factorial src/factorial.s)
my_add_executable(game_of_life src/game_of_life.s)
my_add_executable(brainfuck src/brainfuck.s)
