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

/*  *char */ program_optimized:          /* = NULL */ .dword 0
/* *usize */ program_optimizations_meta: /* = NULL */ .dword 0
/*  usize */ program_optimized_len:      /* = 0    */ .dword 0

.section .rodata

/* usize */ PROGRAM_MEMORY_LEN: .dword 30000

str_usage:         .string "usage: %s [code]\n"
str_syntax_error:  .string "syntax error\n"
str_pointer_error: .string "pointer error\n"
str_print_addr:    .string "%p\n"

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

  # program_optimized = malloc(sizeof(char) * program_len)
  mv a0, s2
  call malloc
  la t0, program_optimized
  sd a0, 0(t0)

  # program_optimizations_meta = malloc(sizeof(isize) * program_len)
  slli a0, s2, 3
  call malloc
  la t0, program_optimizations_meta
  sd a0, 0(t0)

  # analyze_program()
  call analyze_program

  # program_memory_ptr = calloc(PROGRAM_MEMORY_LEN, 1)
  ld a0, PROGRAM_MEMORY_LEN
  li a1, 1
  call calloc
  la t0, program_memory_ptr
  sd a0, 0(t0)

  ld s1, program_optimized
  ld s2, program_optimized_len
  la s3, program_curr_char
  main_for_i_start:
    # break if program_curr_char >= program_optimized_len
    ld t0, 0(s3)
    bgeu t0, s2, main_for_i_end

    # process_command(program_optimized[program_curr_char])
    add t0, s1, t0
    lbu a0, 0(t0)
    call process_command

    # program_curr_char += 1
    ld t0, 0(s3)
    addi t0, t0, 1
    sd t0, 0(s3)
    j main_for_i_start
  main_for_i_end:

  # free(program_optimized)
  ld a0, program_optimized
  call free

  # free(program_optimizations_meta)
  ld a0, program_optimizations_meta
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
  addi sp, sp, -96
  sd ra,   0(sp)
  sd s1,   8(sp)  # program_text
  sd s2,  16(sp)  # program_len
  sd s3,  24(sp)  # src_idx
  sd s4,  32(sp)  # jump_stack_cap
  sd s5,  40(sp)  # jump_stack_len
  sd s6,  48(sp)  # jump_stack
  sd s7,  56(sp)  # chr
  sd s8,  64(sp)  # program_optimized
  sd s9,  72(sp)  # program_optimizations_meta
  sd s10, 80(sp)  # opt_idx

  ld s1, program_text
  ld s2, program_len
  ld s8, program_optimized
  ld s9, program_optimizations_meta

  # memset(program_optimizations_meta, 0xff, sizeof(isize) * program_len)
  mv a0, s9
  li a1, 0xff
  slli a2, s2, 3
  call memset

  la s10, program_optimized_len # let opt_idx = &program_optimized_len

  # *opt_idx = 0
  li t0, 0
  sd t0, 0(s10)

  # the default value of jump stack's capacity may be arbitrary
  li s4, 8  # let jump_stack_cap: usize = 8
  li s5, 0  # let jump_stack_len: usize = 0

  # let jump_stack: *usize = malloc(sizeof(usize) * jump_stack_cap)
  slli a0, s4, 3
  call malloc
  mv s6, a0

  li s3, 0  # let src_idx: usize = 0
  analyze_program_for_i:
    # break if src_idx >= program_len
    bgeu s3, s2, analyze_program_for_i_end

    # let chr: char = program_text[src_idx]
    add t0, s1, s3
    lbu s7, 0(t0)

    # this will come in handy later
    # let repeat_increment: isize = 1
    li t2, 1

    li t0, '['
    beq s7, t0, analyze_program_if_loop_begin     # goto loop_begin if chr == '['
    li t0, ']'
    beq s7, t0, analyze_program_if_loop_end       # goto loop_end if chr == ']'
    li t0, '+'
    beq s7, t0, analyze_program_if_stackable      # goto stackable if chr == '+'
    li t0, '-'
    beq s7, t0, analyze_program_if_stackable_rev  # goto stackable_rev if chr == '-'
    li t0, '<'
    beq s7, t0, analyze_program_if_stackable_rev  # goto stackable_rev if chr == '<'
    li t0, '>'
    beq s7, t0, analyze_program_if_stackable      # goto stackable if chr == '>'
    li t0, '.'
    beq s7, t0, analyze_program_if_end            # goto end if chr == '.'
    li t0, ','
    beq s7, t0, analyze_program_if_end            # goto end if chr == ','

    j analyze_program_for_i_continue              # else continue

    # case '['
    analyze_program_if_loop_begin:

      # if jump_stack_len >= jump_stack_cap
      bltu s5, s4, analyze_program_if_loop_begin_if_end
      analyze_program_if_loop_begin_if:

        slli s4, s4, 1  # jump_stack_cap *= 2

        # jump_stack = realloc(jump_stack, sizeof(usize) * jump_stack_cap)
        mv a0, s6
        slli a1, s4, 3
        call realloc
        mv s6, a0

      analyze_program_if_loop_begin_if_end:

      # jump_stack[jump_stack_len] = *opt_idx
      slli t0, s5, 3
      add t0, s6, t0
      ld t1, 0(s10)
      sd t1, 0(t0)

      addi s5, s5, 1  # jump_stack_len += 1

      j analyze_program_if_end

    # case ']'
    analyze_program_if_loop_end:

      # syntax_error() if jump_stack_len <= 0
      bgeu zero, s5, analyze_program_call_syntax_error

      addi s5, s5, -1  # jump_stack_len -= 1

      # let jump_index: usize = jump_stack[jump_stack_len]
      slli t0, s5, 3
      add t0, s6, t0
      ld t1, 0(t0)

      # $t2 = *opt_idx
      ld t2, 0(s10)

      # program_optimizations_meta[*opt_idx] = jump_index as isize
      slli t0, t2, 3
      add t0, s9, t0
      sd t1, 0(t0)

      # program_optimizations_meta[jump_index] = *opt_idx as isize
      slli t0, t1, 3
      add t0, s9, t0
      sd t2, 0(t0)

      j analyze_program_if_end

    # case '-'
    # case '<'
    analyze_program_if_stackable_rev:

      li t2, -1  # repeat_increment = -1

      # fallthrough

    # case '+'
    # case '>'
    analyze_program_if_stackable:

      mv t1, t2   # let repeats: isize = repeat_increment
      analyze_program_if_stackable_for_j:
        addi s3, s3, 1                                       # src_idx += 1
        bgeu s3, s2, analyze_program_if_stackable_for_j_end  # break if src_idx >= program_len

        # let next_chr: char = program_text[src_idx]
        add t0, s1, s3
        lbu t0, 0(t0)

        bne t0, s7, analyze_program_if_stackable_for_j_end  # break if next_chr != chr
        add t1, t1, t2                                      # repeats += repeat_increment

        j analyze_program_if_stackable_for_j
      analyze_program_if_stackable_for_j_end:

      addi s3, s3, -1  # src_idx -= 1

      # program_optimizations_meta[*opt_idx] = repeats
      ld t2, 0(s10)
      slli t0, t2, 3
      add t0, s9, t0
      sd t1, 0(t0)

    analyze_program_if_end:

    # program_optimized[*opt_idx] = chr
    ld t1, 0(s10)
    add t0, s8, t1
    sb s7, 0(t0)

    # *opt_idx += 1
    addi t1, t1, 1
    sd t1, 0(s10)

  analyze_program_for_i_continue:
    addi s3, s3, 1  # src_idx += 1
    j analyze_program_for_i
  analyze_program_for_i_end:

  # free(jump_stack)
  mv a0, s6
  call free

  ld ra,   0(sp)
  ld s1,   8(sp)
  ld s2,  16(sp)
  ld s3,  24(sp)
  ld s4,  32(sp)
  ld s5,  40(sp)
  ld s6,  48(sp)
  ld s7,  56(sp)
  ld s8,  64(sp)
  ld s9,  72(sp)
  ld s10, 80(sp)
  addi sp, sp, 96
  ret

  analyze_program_call_syntax_error:
    call syntax_error


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
    j command_add         # 0x2B '+'
    j command_read        # 0x2C ','
    j command_add         # 0x2D '-'
    j command_print       # 0x2E '.'
    .rept '<' - '.' - 1
    j command_nop
    .endr
    j command_move        # 0x3C '<'
    j command_nop
    j command_move        # 0x3E '>'
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

command_move:
  # fn command_move()

  # let value: isize = program_optimizations_meta[program_curr_char]
  ld t2, program_optimizations_meta
  ld t3, program_curr_char
  slli t3, t3, 3
  add t2, t2, t3
  ld t2, 0(t2)

  # let new_addr: isize = program_head_addr as isize + value
  la t0, program_head_addr
  ld t1, 0(t0)
  add t1, t1, t2

  blt t1, zero, command_move_call_pointer_error  # pointer_error() if new_addr < 0
  ld t2, PROGRAM_MEMORY_LEN
  bge t1, t2, command_move_call_pointer_error    # pointer_error() if new_addr >= PROGRAM_MEMORY_LEN

  # program_head_addr = new_addr as usize
  sd t1, 0(t0)

  ret

  command_move_call_pointer_error:
    call pointer_error


command_add:
  # fn command_add()

  # let cell_ptr: *u8 = &program_memory_ptr[program_head_addr]
  ld t0, program_memory_ptr
  ld t1, program_head_addr
  add t0, t0, t1

  # let value: isize = program_optimizations_meta[program_curr_char]
  ld t2, program_optimizations_meta
  ld t3, program_curr_char
  slli t3, t3, 3
  add t2, t2, t3
  ld t2, 0(t2)

  # *cell_ptr += value as isize as u8
  lbu t1, 0(t0)
  add t1, t1, t2
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
  # program_curr_char = program_optimizations_meta[program_curr_char] as usize
  ld t0, program_optimizations_meta
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

pointer_error:
  # fn pointer_error() -> never
  addi sp, sp, -16
  sd ra, 0(sp)

  # printf(str_pointer_error)
  la a0, str_pointer_error
  call printf

  # exit(3)
  li a0, 3
  call exit

  ld ra, 0(sp)
  addi sp, sp, 16
  ret
