# brainfuck.s
# Written in 2019-2021 by Dmytro Meleshko <dmytro.meleshko@gmail.com>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty. You should have
# received a copy of the CC0 Public Domain Dedication along with this software.
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

.data

/*   *u8 */ program_memory_ptr:   /* = NULL */ .dword 0
/* usize */ program_head_address: /* = 0    */ .dword 0

/* *char */ program_text:                /* = NULL */ .dword 0
/* usize */ program_len:                 /* = 0    */ .dword 0
/* usize */ program_current_instruction: /* = 0    */ .dword 0

.section .rodata

/* usize */ PROGRAM_MEMORY_LEN: .dword 30000

str_usage: .string "usage: %s [code]\n"

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
  addi sp, sp, -32
  sd ra,  0(sp)
  sd s1,  8(sp)
  sd s2, 16(sp)
  sd s3, 24(sp)

  # if argc != 2
  li t0, 2
  beq a0, t0, main_if_not_argc_end
  main_if_not_argc:

    # printf(str_usage, argv[0])
    ld a1, 0(a1)
    la a0, str_usage
    call printf

    li a0, 1   # return 1
    j main_end

  main_if_not_argc_end:

  # program_text = argv[1]
  ld s1, 8(a1)
  la a0, program_text
  sd s1, 0(a0)

  # program_len = strlen(program_text)
  mv a0, s1
  call strlen
  la t0, program_len
  sd a0, 0(t0)
  mv s2, a0

  # program_memory_ptr = malloc(PROGRAM_MEMORY_LEN)
  ld a0, PROGRAM_MEMORY_LEN
  call malloc
  la t0, program_memory_ptr
  sd a0, 0(t0)

  # $s1 and $s2 have already been assigned
  li s3, 0  # let i: u64 = 0
  main_for_i_start:
    # break if i >= len
    bgeu s3, s2, main_for_i_end

    # process_command(program_text[i])
    add t0, s1, s3
    lbu a0, 0(t0)
    call process_command

    addi s3, s3, 1  # i += 1
    j main_for_i_start
  main_for_i_end:

  # free(program_memory_ptr)
  ld a0, program_memory_ptr
  call free

  li a0, 0  # return 0

  main_end:
    ld ra,  0(sp)
    ld s1,  8(sp)
    ld s2, 16(sp)
    ld s3, 24(sp)
    addi sp, sp, 32
    ret

process_command:
  # fn process_command(cmd: char)
  addi sp, sp, -16
  sd ra, 0(sp)

  # machinery to utilize the jumptable
  la t0, process_command_jumptable_start
  slli a0, a0, 1
  add t0, t0, a0                        # $t0 = jumptable_start + $a0 * 2
  la ra, process_command_jumptable_end  # setup the return pointer
  jr t0                                 # execute the jump!

  process_command_jumptable_start:
    .rept 0x2A - 0x00 + 1
    j command_nop
    .endr
    j command_increment   # 0x2B
    j command_read        # 0x2C
    j command_decrement   # 0x2D
    j command_print       # 0x2E
    .rept 0x3B - 0x2F + 1
    j command_nop
    .endr
    j command_move_left   # 0x3C
    j command_nop
    j command_move_right  # 0x3E
    .rept 0x5A - 0x3F + 1
    j command_nop
    .endr
    j command_loop_begin  # 0x5B
    j command_nop
    j command_loop_end    # 0x5D
    .rept 0xFF - 0x5E + 1
    j command_nop
    .endr
  process_command_jumptable_end:

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_nop:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_nop
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_move_right:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_move_right
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_move_left:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_move_left
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_increment:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_increment
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_decrement:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_decrement
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_print:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_print
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_read:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_read
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_loop_begin:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_loop_begin
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_loop_end:
  addi sp, sp, -16
  sd ra, 0(sp)

  la a0, str_command_loop_end
  call puts

  ld ra, 0(sp)
  addi sp, sp, 16
  ret
