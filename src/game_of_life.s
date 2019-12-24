# game_of_life.s
# Written in 2019 by Dmytro Meleshko <dmytro.meleshko@gmail.com>
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty. You should have
# received a copy of the CC0 Public Domain Dedication along with this software.
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

.data

/* char* */ STR_FMT_GENERATION: .string "generation #%lu:\n"
# UTF-8 representation of two FULL BLOCK (U+2588) unicode characters
# https://www.fileformat.info/info/unicode/char/2588/index.htm
/* char* */ STR_CELL_ALIVE: .string "\xE2\x96\x88\xE2\x96\x88"
/* char* */ STR_CELL_DEAD:  .string "  "

/* u64 */ grid_width:  .dword 32
/* u64 */ grid_height: .dword 32
/* [u8] */ grid_data:      /* = NULL */ .dword 0
/* [u8] */ grid_next_data: /* = NULL */ .dword 0

/* u64 */ NEXT_GENERATION_SLEEP_TIME: .dword 200 * 1000 /* microseconds */

.text

.global main
main:
  # fn main(argc: i32, argv: [char*]) -> i32
  addi sp, sp, -16
  sd ra, 0(sp)
  sd s1, 8(sp)

  # srand(time(NULL))
  li a0, 0
  call time
  call srand

  # grid_alloc_data_unsafe(&grid_data)
  la a0, grid_data
  call grid_alloc_data_unsafe
  # grid_alloc_data_unsafe(&grid_next_data)
  la a0, grid_next_data
  call grid_alloc_data_unsafe

  # printf(STR_FMT_GENERATION, 0)
  la a0, STR_FMT_GENERATION
  la a1, 0
  call printf

  li a0, 2
  li a1, 1
  li a2, 1
  call grid_set
  li a0, 3
  li a1, 2
  li a2, 1
  call grid_set
  li a0, 1
  li a1, 3
  li a2, 1
  call grid_set
  li a0, 2
  li a1, 3
  li a2, 1
  call grid_set
  li a0, 3
  li a1, 3
  li a2, 1
  call grid_set
  # call grid_fill_randomly
  call grid_print

  # putchar('\n')
  li a0, '\n'
  call putchar

  li s1, 1  # let gen_index: u64 = 1
  main_loop_start:

    # printf(STR_FMT_GENERATION, gen_index)
    la a0, STR_FMT_GENERATION
    mv a1, s1
    call printf

    call grid_next_generation
    call grid_swap
    call grid_print

    # putchar('\n')
    li a0, '\n'
    call putchar

    # usleep(NEXT_GENERATION_SLEEP_TIME)
    # NOTE: usleep is deprectated, I might update this to use nanosleep in the
    #       future. Here is an example of a function that sleeps for requested
    #       time in milliseconds: https://stackoverflow.com/a/1157217/12005228
    ld a0, NEXT_GENERATION_SLEEP_TIME
    call usleep

    addi s1, s1, 1
    j main_loop_start
  main_loop_end:

  # free(grid_data)
  ld a0, grid_data
  call free
  # free(grid_next_data)
  ld a0, grid_next_data
  call free

  li a0, 0  # return 0

  ld ra, 0(sp)
  ld s1, 8(sp)
  addi sp, sp, 16
  ret


grid_alloc_data_unsafe:
  # fn grid_alloc_data_unsafe(dest_data: [u8]*)
  addi sp, sp, -16
  sd ra, 0(sp)

  sd a0, 8(sp)

  # let data: [u8] = malloc(grid_width * grid_height * sizeof(u8))
  ld t0, grid_width
  ld t1, grid_height
  mul a0, t0, t1
  call malloc

  # *dest_data = data
  ld t0, 8(sp)
  sd a0, 0(t0)

  ld ra, 0(sp)
  addi sp, sp, 16
  ret


grid_swap:
  # fn grid_swap()
  addi sp, sp, -16
  sd ra, 0(sp)

  # grid_data, grid_next_data = grid_next_data, grid_data
  ld t0, grid_data
  ld t1, grid_next_data
  la t2, grid_next_data
  sd t0, 0(t2)
  la t2, grid_data
  sd t1, 0(t2)

  ld ra, 0(sp)
  addi sp, sp, 16
  ret


grid_fill_randomly:
  # fn grid_fill_randomly()
  addi sp, sp, -32
  sd ra,  0(sp)
  sd s1,  8(sp)
  sd s2, 16(sp)
  sd s3, 24(sp)

  ld s1, grid_data
  # let len: u64 = grid_width * grid_height
  ld t0, grid_width
  ld t1, grid_height
  mul s2, t0, t1
  li s3, 0  # let i: u64 = 0

  grid_fill_randomly_loop_start:
    # break if i >= len
    bgeu s3, s2, grid_fill_randomly_loop_end

    # let cell: u8 = rand() & 1
    call rand
    andi a0, a0, 1

    # grid_data[i] = cell
    add t0, s1, s3
    sb a0, 0(t0)

    addi s3, s3, 1  # i += 1
    j grid_fill_randomly_loop_start
  grid_fill_randomly_loop_end:

  ld ra,  0(sp)
  ld s1,  8(sp)
  ld s2, 16(sp)
  ld s3, 24(sp)
  addi sp, sp, 32
  ret


grid_print:
  # fn grid_print()
  addi sp, sp, -64
  sd ra,  0(sp)
  sd s1,  8(sp)
  sd s2, 16(sp)
  sd s3, 24(sp)
  sd s4, 32(sp)
  sd s5, 40(sp)

  ld s1, grid_data    # let cell_ptr: u8* = grid_data
  ld s2, grid_width
  ld s3, grid_height
  li s4, 0            # let x: u64 = 0
  li s5, 0            # let y: u64 = 0

  grid_print_for_x_start:
    # break if y >= grid_height
    bgeu s5, s3, grid_print_for_x_end

    li s4, 0  # x = 0

    grid_print_for_y_start:
      # break if x >= grid_width
      bgeu s4, s2, grid_print_for_y_end

      # let cell: u8 = *cell_ptr & 1
      lb t0, 0(s1)
      andi t0, t0, 1

      # use an `if` shorthand here to save some instructions
      # let s: char* = STR_CELL_DEAD
      la a0, STR_CELL_DEAD
      # if (t0 != 0) s = STR_CELL_ALIVE
      beqz t0, grid_print_if_end
      la a0, STR_CELL_ALIVE
      grid_print_if_end:
      # fputs(s, stdout)
      ld a1, stdout
      call fputs

      addi s1, s1, 1  # cell_ptr += 1
      addi s4, s4, 1  # x += 1
      j grid_print_for_y_start
    grid_print_for_y_end:

    # putchar('\n')
    li a0, '\n'
    call putchar

    addi s5, s5, 1  # y += 1
    j grid_print_for_x_start
  grid_print_for_x_end:

  ld ra,  0(sp)
  ld s1,  8(sp)
  ld s2, 16(sp)
  ld s3, 24(sp)
  ld s4, 32(sp)
  ld s5, 40(sp)
  addi sp, sp, 64
  ret


grid_next_generation:
  # fn grid_next_generation()
  addi sp, sp, -64
  sd ra,  0(sp)
  sd s1,  8(sp)
  sd s2, 16(sp)
  sd s3, 24(sp)
  sd s4, 32(sp)
  sd s5, 40(sp)
  sd s6, 48(sp)

  ld s1, grid_data       # let cell_ptr: u8* = grid_data
  ld s2, grid_width
  ld s3, grid_height
  li s4, 0               # let x: u64 = 0
  li s5, 0               # let y: u64 = 0
  ld s6, grid_next_data  # let next_cell_ptr: u8* = grid_next_data

  grid_next_generation_for_x_start:
    # break if y >= grid_height
    bgeu s5, s3, grid_next_generation_for_x_end

    li s4, 0  # x = 0

    grid_next_generation_for_y_start:
      # break if x >= grid_width
      bgeu s4, s2, grid_next_generation_for_y_end

      # let n: u8 = grid_count_alive_neighbors(x, y)
      mv a0, s4
      mv a1, s5
      call grid_count_alive_neighbors

      # let cell: u8 = *cell_ptr & 1
      lb t0, 0(s1)
      andi t0, t0, 1

      # let next_cell: u8 = if cell != 0 {
      #   if n == 2 || n == 3 { 1 } else { 0 }
      # } else {
      #   if n == 3 { 1 } else { 0 }
      # }
      #

      beqz t0, grid_next_generation_if_cell_dead
      grid_next_generation_if_cell_alive:

        li t2, 2
        beq a0, t2, grid_next_generation_set_cell_alive
        li t2, 3
        beq a0, t2, grid_next_generation_set_cell_alive
        j grid_next_generation_set_cell_dead

      grid_next_generation_if_cell_dead:

        li t2, 3
        beq a0, t2, grid_next_generation_set_cell_alive
        j grid_next_generation_set_cell_dead

      grid_next_generation_set_cell_alive:
        li t1, 1
        j grid_next_generation_if_end

      grid_next_generation_set_cell_dead:
        li t1, 0

      grid_next_generation_if_end:

      # *next_cell_ptr = cell
      sb t1, 0(s6)

      addi s1, s1, 1  # cell_ptr += 1
      addi s6, s6, 1  # next_cell_ptr += 1
      addi s4, s4, 1  # x += 1
      j grid_next_generation_for_y_start
    grid_next_generation_for_y_end:

    addi s5, s5, 1  # y += 1
    j grid_next_generation_for_x_start
  grid_next_generation_for_x_end:

  ld ra,  0(sp)
  ld s1,  8(sp)
  ld s2, 16(sp)
  ld s3, 24(sp)
  ld s4, 32(sp)
  ld s5, 40(sp)
  ld s6, 48(sp)
  addi sp, sp, 64
  ret


grid_get:
  # fn grid_get(i64 x, i64 y) -> u8
  addi sp, sp, -16
  sd ra, 0(sp)

  # let cell_ptr: u8* = grid_get_ptr(x, y)
  call grid_get_ptr

  # return 0 if cell_ptr == NULL
  beqz a0, grid_get_end

  # return *cell_ptr & 1
  lb a0, 0(a0)
  andi a0, a0, 1

  grid_get_end:
    ld ra, 0(sp)
    addi sp, sp, 16
    ret


grid_set:
  # fn grid_set(i64 x, i64 y, u8 value)
  addi sp, sp, -16
  sd ra, 0(sp)
  sb a2, 8(sp)

  # let cell_ptr: u8* = grid_get_ptr(x, y)
  call grid_get_ptr

  # return if cell_ptr == NULL
  beqz a0, grid_set_end

  # *cell_ptr = value & 1
  lb t0, 8(sp)
  andi t0, t0, 1
  sb t0, 0(a0)

  grid_set_end:
    ld ra, 0(sp)
    addi sp, sp, 16
    ret

grid_get_ptr:
  # fn grid_get_ptr(i64 x, i64 y) -> u8*
  addi sp, sp, -32
  sd ra,  0(sp)
  sd a0,  8(sp)
  sd a1, 16(sp)

  # return 0 if grid_check_signed_coordinates(x, y) == 0
  call grid_check_signed_coordinates
  beqz a0, grid_get_ptr_end

  ld a0,  8(sp)
  ld a1, 16(sp)

  # return grid_data + (grid_width * y + x)
  ld t0, grid_width
  mul t0, t0, a1
  add a0, t0, a0
  ld t0, grid_data
  add a0, a0, t0

  grid_get_ptr_end:
    ld ra, 0(sp)
    addi sp, sp, 32
    ret


grid_check_signed_coordinates:
  # fn grid_check_signed_coordinates(x: i64, y: i64) -> u8

  # return if x < 0 || y < 0 || x >= grid_width || y >= grid_height { 0 } else { 1 }
  blt a0, zero, grid_check_signed_coordinates_out_of_bounds
  blt a1, zero, grid_check_signed_coordinates_out_of_bounds
  ld t0, grid_height
  bge a1, t0, grid_check_signed_coordinates_out_of_bounds
  ld t0, grid_width
  bge a0, t0, grid_check_signed_coordinates_out_of_bounds

  li a0, 1
  ret

  grid_check_signed_coordinates_out_of_bounds:
    li a0, 0
    ret


grid_count_alive_neighbors:
  # fn grid_count_alive_neighbors(x: u64, y: u64) -> u8
  addi sp, sp, -32
  sd ra,  0(sp)
  sd s1,  8(sp)
  sd s2, 16(sp)
  sd s3, 24(sp)

  mv s1, a0
  mv s2, a1
  li s3, 0   # let n: u8 = 0

  #                                                 # relative coordinates
  addi s2, s2, -1                        # y -= 1   # (-1;  0)
  call grid_count_alive_neighbors_check
  addi s1, s1, 1                         # x += 1   # (-1;  1)
  call grid_count_alive_neighbors_check
  addi s2, s2, 1                         # y += 1   # ( 0;  1)
  call grid_count_alive_neighbors_check
  addi s2, s2, 1                         # y += 1   # ( 1;  1)
  call grid_count_alive_neighbors_check
  addi s1, s1, -1                        # x -= 1   # ( 1;  0)
  call grid_count_alive_neighbors_check
  addi s1, s1, -1                        # x -= 1   # ( 1; -1)
  call grid_count_alive_neighbors_check
  addi s2, s2, -1                        # y -= 1   # ( 0; -1)
  call grid_count_alive_neighbors_check
  addi s2, s2, -1                        # y -= 1   # (-1; -1)
  call grid_count_alive_neighbors_check

  # return n
  mv a0, s3

  ld ra,  0(sp)
  ld s1,  8(sp)
  ld s2, 16(sp)
  ld s3, 24(sp)
  addi sp, sp, 32
  ret

  # n += grid_get(x, y)
  grid_count_alive_neighbors_check:
    addi sp, sp, -16
    sd ra, 0(sp)

    mv a0, s1
    mv a1, s2
    call grid_get
    add s3, s3, a0

    ld ra, 0(sp)
    addi sp, sp, 16
    ret
