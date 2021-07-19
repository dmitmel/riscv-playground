#!/usr/bin/env python3

import sys
from typing import Dict, List, Tuple


def main(argv: List[str]) -> int:

  code: str = sys.stdin.read()

  print(".data")
  print()
  print(".text")
  print()
  print(".global main")
  print()
  print("bf_getchar:")
  print("  addi sp, sp, -16")
  print("  sd ra, 0(sp)")
  print()
  print("  call getchar")
  print("  bge a0, zero, bf_getchar_end")
  print("  li a0, 0")
  print("  bf_getchar_end:")
  print()
  print("  ld ra, 0(sp)")
  print("  addi sp, sp, 16")
  print("  ret")
  print()
  print("bf_putchar:")
  print("  addi sp, sp, -16")
  print("  sd ra, 0(sp)")
  print()
  print("  call putchar")
  print("  ld a0, stdout")
  print("  call fflush")
  print()
  print("  ld ra, 0(sp)")
  print("  addi sp, sp, 16")
  print("  ret")
  print()
  print("main:")
  print("  addi sp, sp, -16")
  print("  sd ra,  0(sp)")
  print("  sd s1,  8(sp)")
  print()
  print("  li a0, 30000")
  print("  li a1, 1")
  print("  call calloc")
  print("  mv s1, a0")

  code = "".join(c for c in code if c in "+,-.<>[]")
  code = code.replace("[-]", "Z")
  code = code.replace("[+]", "Z")

  code_rle: List[Tuple[str, int]] = []
  prev_c: str = ""
  c_repeats: int = 0
  for i, c in enumerate(code):
    if c != prev_c and prev_c != "":
      if prev_c in "+-<>":
        code_rle.append((prev_c, c_repeats))
      else:
        code_rle.extend((prev_c, 1) for _ in range(c_repeats))
      c_repeats = 0
    c_repeats += 1
    prev_c = c
  if prev_c != "":
    code_rle.append((prev_c, c_repeats))

  jump_stack: List[int] = []
  loop_jumps: Dict[int, int] = {}
  for i, (c, _) in enumerate(code_rle):
    if c == "[":
      jump_stack.append(i)
    elif c == "]":
      if len(jump_stack) == 0:
        raise Exception("Unexpected closing bracket")
      j = jump_stack.pop()
      loop_jumps[i] = j
      loop_jumps[j] = i
  if len(jump_stack) != 0:
    raise Exception("Unclosed bracket")

  for i, (c, cr) in enumerate(code_rle):

    def emit_addi(reg: str, n: int) -> None:
      if -(1 << 11) <= n < (1 << 11):
        print("  addi {}, {}, {}".format(reg, reg, n))
      else:
        print("  li t1, {}".format(n))
        print("  add {}, {}, t1".format(reg, reg))

    if c == "+":
      print("  lbu t0, 0(s1)")
      emit_addi("t0", cr)
      print("  sb t0, 0(s1)")

    elif c == ",":
      print("  call bf_getchar")
      print("  sb a0, 0(s1)")

    elif c == "-":
      print("  lbu t0, 0(s1)")
      emit_addi("t0", -cr)
      print("  sb t0, 0(s1)")

    elif c == ".":
      print("  lbu a0, 0(s1)")
      print("  call bf_putchar")

    elif c == "<":
      emit_addi("s1", -cr * 8)

    elif c == ">":
      emit_addi("s1", cr * 8)

    elif c == "[":
      print("bf_loop_{}_start:".format(i))
      print("  lbu t0, 0(s1)")
      print("  beq t0, zero, bf_loop_{}_end".format(loop_jumps[i]))

    elif c == "]":
      print("  j bf_loop_{}_start".format(loop_jumps[i]))
      print("bf_loop_{}_end:".format(i))

    elif c == "Z":
      print("  li t0, 0")
      print("  sb t0, 0(s1)")

  print()
  print("  ld ra,  0(sp)")
  print("  ld s1,  8(sp)")
  print("  addi sp, sp, 16")
  print("  ret")

  return 0


if __name__ == "__main__":
  sys.exit(main(sys.argv))
