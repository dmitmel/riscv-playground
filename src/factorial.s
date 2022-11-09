# vim:ft=riscv:
# factorial.s
# Written in 2019 by Dmytro Meleshko <dmytro.meleshko@gmail.com>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty. You should have
# received a copy of the CC0 Public Domain Dedication along with this software.
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

.data

printNumFmt:
  .string "%lu\n"

.text

.global main
main:
  addi sp, sp, -16
  sd ra, 0(sp)

  # u64 n = 13
  li t0, 13
  sd t0, 8(sp)

  # printf(printNumFmt, n)
  la a0, printNumFmt
  mv a1, t0
  call printf

  # n = factorial(n)
  ld a0, 8(sp)
  call factorial

  # printf(printNumFmt, n)
  mv a1, a0
  la a0, printNumFmt
  call printf

  # return 0
  li a0, 0

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

factorial:
  # parameters:
  #   a0 - u64 n
  # returned value in a0
  addi sp, sp, -8
  sd ra, 0(sp)

  li t0, 1  # u64 result = 1
  li t1, 1  # u64 one = 1
  factorial_loop_start:
    bgeu t1, a0, factorial_loop_end  # goto factorial_loop_end if n <= one
    mul t0, t0, a0                   # result *= n
    addi a0, a0, -1                  # n -= 1
    j factorial_loop_start
  factorial_loop_end:
  mv a0, t0

  ld ra, 0(sp)
  addi sp, sp, 8
  ret
