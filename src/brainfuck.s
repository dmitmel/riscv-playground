# brainfuck.s
# Written in 2019-2021 by Dmytro Meleshko <dmytro.meleshko@gmail.com>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty. You should have
# received a copy of the CC0 Public Domain Dedication along with this software.
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

# Probably the slowest brainfuck interpreter in existance.

.data

/*    *u8 */ program_memory_ptr: /* = NULL */ .dword 0
/*  usize */ program_head_addr:  /* = 0    */ .dword 0

/*  *char */ program_text:       /* = NULL */ .dword 0
/*  usize */ program_len:        /* = 0    */ .dword 0
/*  usize */ program_curr_char:  /* = 0    */ .dword 0

/* *usize */ program_loop_jumps: /* = NULL */ .dword 0

.section .rodata

/* usize */ PROGRAM_MEMORY_LEN: .dword 30000

str_usage:        .string "usage: %s [code]\n"
str_syntax_error: .string "syntax error\n"

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

  # program_loop_jumps = malloc(sizeof(size_t) * program_len)
  slli a0, s2, 3
  call malloc
  la t0, program_loop_jumps
  sd a0, 0(t0)

  # analyze_program()
  call analyze_program

  # program_memory_ptr = calloc(PROGRAM_MEMORY_LEN, 1)
  ld a0, PROGRAM_MEMORY_LEN
  li a1, 1
  call calloc
  la t0, program_memory_ptr
  sd a0, 0(t0)

  # $s1 and $s2 have already been assigned
  la s3, program_curr_char
  main_for_i_start:
    # break if program_curr_char >= program_len
    ld t0, 0(s3)
    bgeu t0, s2, main_for_i_end

    # process_command(program_text[program_curr_char])
    add t0, s1, t0
    lbu a0, 0(t0)
    call process_command

    # program_curr_char += 1
    ld t0, 0(s3)
    addi t0, t0, 1
    sd t0, 0(s3)
    j main_for_i_start
  main_for_i_end:

  # free(program_loop_jumps)
  ld a0, program_loop_jumps
  call free

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

analyze_program:
  # fn analyze_program()
  addi sp, sp, -80
  sd ra,  0(sp)
  sd s1,  8(sp)  # program_text
  sd s2, 16(sp)  # program_len
  sd s3, 24(sp)  # i
  sd s4, 32(sp)  # jump_stack_cap
  sd s5, 40(sp)  # jump_stack_len
  sd s6, 48(sp)  # jump_stack
  sd s7, 56(sp)  # chr
  sd s8, 64(sp)  # jump_index
  sd s9, 72(sp)  # program_loop_jumps

  ld s1, program_text
  ld s2, program_len
  ld s9, program_loop_jumps

  # memset(program_loop_jumps, 0xff, sizeof(size_t) * program_len)
  mv a0, s9
  li a1, 0xff
  slli a2, s2, 3
  call memset

  # the default value of jump stack's capacity may be arbitrary
  li s4, 8  # let jump_stack_cap: usize = 8
  li s5, 0  # let jump_stack_len: usize = 0

  # let jump_stack: *usize = malloc(sizeof(usize) * jump_stack_cap)
  slli a0, s4, 3
  call malloc
  mv s6, a0

  li s3, 0  # let i: usize = 0
  analyze_program_for_i:
    # break if i >= program_len
    bgeu s3, s2, analyze_program_for_i_end

    # let chr: char = program_text[i]
    add t0, s1, s3
    lbu s7, 0(t0)

    li t0, '['
    beq s7, t0, analyze_program_if_loop_begin  # goto loop_begin if chr == '['
    li t0, ']'
    beq s7, t0, analyze_program_if_loop_end    # goto loop_end if chr == ']'
    j analyze_program_if_end

    # if chr == '['
    analyze_program_if_loop_begin:

      # if jump_stack_len >= jump_stack_cap
      bltu s5, s4, analyze_program_if_loop_begin_if_end
      analyze_program_if_loop_begin_if:

        slli s4, s4, 1  # jump_stack_cap *= 2

        # jump_stack = realloc(jump_stack, sizeof(size_t) * jump_stack_cap)
        mv a0, s6
        slli a1, s4, 3
        call realloc
        mv s6, a0

      analyze_program_if_loop_begin_if_end:

      # jump_stack[jump_stack_len] = i
      slli t0, s5, 3
      add t0, s6, t0
      sd s3, 0(t0)

      addi s5, s5, 1  # jump_stack_len += 1

      j analyze_program_if_end

    # if chr == ']'
    analyze_program_if_loop_end:

      # syntax_error() if jump_stack_len <= 0
      bgeu zero, s5, syntax_error

      addi s5, s5, -1  # jump_stack_len -= 1

      # let jump_index: usize = jump_stack[jump_stack_len]
      slli t0, s5, 3
      add t0, s6, t0
      ld s8, 0(t0)

      # program_loop_jumps[i] = jump_index
      slli t0, s3, 3
      add t0, s9, t0
      sd s8, 0(t0)

      # program_loop_jumps[jump_index] = i
      slli t0, s8, 3
      add t0, s9, t0
      sd s3, 0(t0)

    analyze_program_if_end:

    addi s3, s3, 1  # i += 1
    j analyze_program_for_i
  analyze_program_for_i_end:

  # free(jump_stack)
  mv a0, s6
  call free

  ld ra,  0(sp)
  ld s1,  8(sp)
  ld s2, 16(sp)
  ld s3, 24(sp)
  ld s4, 32(sp)
  ld s5, 40(sp)
  ld s6, 48(sp)
  ld s7, 56(sp)
  ld s8, 64(sp)
  ld s9, 72(sp)
  addi sp, sp, 80
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
    .rept '+' - 0x00
    j command_nop
    .endr
    j command_increment   # 0x2B '+'
    j command_read        # 0x2C ','
    j command_decrement   # 0x2D '-'
    j command_print       # 0x2E '.'
    .rept '<' - '.' - 1
    j command_nop
    .endr
    j command_move_left   # 0x3C '<'
    j command_nop
    j command_move_right  # 0x3E '>'
    .rept '[' - '>' - 1
    j command_nop
    .endr
    j command_loop_begin  # 0x5B '['
    j command_nop
    j command_loop_end    # 0x5D ']'
    .rept 0x100 - ']' - 1
    j command_nop
    .endr
  process_command_jumptable_end:

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_nop:
  # fn command_nop()

  ret

command_move_right:
  # fn command_move_right()

  la t0, program_head_addr
  ld t1, 0(t0)
  ld t2, PROGRAM_MEMORY_LEN

  # goto wraparound if program_head_addr >= PROGRAM_MEMORY_LEN - 1
  addi t2, t2, -1
  bgeu t1, t2, command_move_right_wraparound

  # program_head_addr += 1
  addi t1, t1, 1
  sd t1, 0(t0)

  ret

  command_move_right_wraparound:
    # program_head_addr = 0
    li t1, 0
    sd t1, 0(t0)

    ret

command_move_left:
  # fn command_move_left()

  la t0, program_head_addr
  ld t1, 0(t0)

  # goto wraparound if program_head_addr <= 0
  li t2, 0
  bgeu t2, t1, command_move_left_wraparound

  # program_head_addr -= 1
  addi t1, t1, -1
  sd t1, 0(t0)

  ret

  command_move_left_wraparound:
    # program_head_addr = PROGRAM_MEMORY_LEN - 1
    ld t1, PROGRAM_MEMORY_LEN
    addi t1, t1, -1
    sd t1, 0(t0)

    ret

command_increment:
  # fn command_increment()

  # let cell_ptr: *u8 = &program_memory_ptr[program_head_addr]
  ld t0, program_memory_ptr
  ld t1, program_head_addr
  add t0, t0, t1

  # *cell_ptr += 1
  lbu t1, 0(t0)
  addi t1, t1, 1
  sb t1, 0(t0)

  ret

command_decrement:
  # fn command_decrement()

  # let cell_ptr: *u8 = &program_memory_ptr[program_head_addr]
  ld t0, program_memory_ptr
  ld t1, program_head_addr
  add t0, t0, t1

  # *cell_ptr -= 1
  lbu t1, 0(t0)
  addi t1, t1, -1
  sb t1, 0(t0)

  ret

command_print:
  # fn command_print()
  addi sp, sp, -16
  sd ra, 0(sp)

  # putchar(program_memory_ptr[program_head_addr])
  ld t0, program_memory_ptr
  ld t1, program_head_addr
  add t0, t0, t1
  lbu a0, 0(t0)
  call putchar

  # fflush(stdout)
  ld a0, stdout
  call fflush

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_read:
  # fn command_read()
  addi sp, sp, -16
  sd ra, 0(sp)

  # program_memory_ptr[program_head_addr] = getchar()
  call getchar
  bge a0, zero, command_read_no_eof
  li a0, 0  # on EOF
  command_read_no_eof:

  ld t0, program_memory_ptr
  ld t1, program_head_addr
  add t0, t0, t1
  sb a0, 0(t0)

  ld ra, 0(sp)
  addi sp, sp, 16
  ret

command_loop_begin:
  # fn command_loop_begin()

  # return if program_memory_ptr[program_head_addr] != 0
  ld t0, program_memory_ptr
  ld t1, program_head_addr
  add t0, t0, t1
  lbu t1, 0(t0)
  bnez t1, command_loop_common_end

  j command_loop_common

command_loop_end:
  # fn command_loop_end()

  # return if program_memory_ptr[program_head_addr] == 0
  ld t0, program_memory_ptr
  ld t1, program_head_addr
  add t0, t0, t1
  lbu t1, 0(t0)
  beqz t1, command_loop_common_end

command_loop_common:
  # program_curr_char = program_loop_jumps[program_curr_char]
  ld t0, program_loop_jumps
  la t2, program_curr_char
  ld t1, 0(t2)
  slli t1, t1, 3
  add t0, t0, t1
  ld t0, 0(t0)
  sd t0, 0(t2)
command_loop_common_end:
  ret

syntax_error:
  # fn syntax_error() -> never
  addi sp, sp, -16
  sd ra, 0(sp)

  # printf(str_syntax_error)
  la a0, str_syntax_error
  call printf

  # exit(2)
  li a0, 2
  call exit

  ld ra, 0(sp)
  addi sp, sp, 16
  ret
