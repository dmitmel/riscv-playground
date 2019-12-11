.data

printNumFmt:
  .string "%d\n"

.text

.global main
main:
  addi sp, sp, -16
  sd ra, 0(sp)

  # u64 n = 5
  li t0, 5
  sd t0, 8(sp)

  # printf(printNumFmt, 13)
  la a0, printNumFmt
  mv a1, t0
  call printf

  # factorial(n)
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
  #   a0 - n
  # returned value in a0
  addi sp, sp, -8
  sd ra, 0(sp)

  addi t0, zero, 1  # result
  addi t1, zero, 1  # constant 1
  factorial_loop_start:
    bgeu t1, a0, factorial_loop_end  # goto factorial_loop_end if $a0 <= 1
    mul t0, t0, a0                   # $t0 *= $a0
    addi a0, a0, -1                  # a0 -= 1
    j factorial_loop_start
  factorial_loop_end:
  mv a0, t0

  ld ra, 0(sp)
  addi sp, sp, 8
  ret
