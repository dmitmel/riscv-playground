# brainfuck.s
# Written in 2019 by Dmytro Meleshko <dmytro.meleshko@gmail.com>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty. You should have
# received a copy of the CC0 Public Domain Dedication along with this software.
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

.data

hello_world: .string "hello world\n"

.text

.global main
main:
  # fn main(argc: i32, argv: [*char]) -> i32
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, hello_world
  call printf

  li a0, 0  # return 0

  ld ra, 0(sp)
  addi sp, sp, 16
  ret
