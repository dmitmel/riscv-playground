# brainfuck.s
# Written in 2019 by Dmytro Meleshko <dmytro.meleshko@gmail.com>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty. You should have
# received a copy of the CC0 Public Domain Dedication along with this software.
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

.data

str_command_nop:        .string "nop"
str_command_move_right: .string "move right"
str_command_move_left:  .string "move left"
str_command_increment:  .string "increment"
str_command_decrement:  .string "decrement"
str_command_print:      .string "print"
str_command_read:       .string "read"
str_command_loop_begin: .string "loop begin"
str_command_loop_end:   .string "loop end"

.text

.global main
main:
  # fn main(argc: i32, argv: [*char]) -> i32
  addi sp, sp, -16
  sd ra, 0(sp)

  li a0, '.'
  call process_command
  li a0, '+'
  call process_command
  li a0, '>'
  call process_command
  li a0, 'a'
  call process_command
  li a0, '/'
  call process_command
  li a0, 'b'
  call process_command

  li a0, 0  # return 0

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

process_command:
  # fn process_command(cmd: char)
  addi sp, sp, -16
  sd ra, 0(sp)

  # let handler: fn() = command_handlers_table[cmd]
  li a1, 8
  mul a0, a0, a1  # $a0 *= sizeof(void*)
  la a1, command_handlers_table
  add a0, a0, a1
  ld a0, 0(a0)

  # handler()
  jalr a0

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

.global command_nop
command_nop:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_nop
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

.global command_move_right
command_move_right:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_move_right
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

.global command_move_left
command_move_left:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_move_left
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

.global command_increment
command_increment:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_increment
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

.global command_decrement
command_decrement:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_decrement
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

.global command_print
command_print:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_print
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

.global command_read
command_read:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_read
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

.global command_loop_begin
command_loop_begin:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_loop_begin
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

.global command_loop_end
command_loop_end:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_loop_end
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret
