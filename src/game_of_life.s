# game_of_life.s
# Written in 2019 by Dmytro Meleshko <dmytro.meleshko@gmail.com>
# To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

.data

/* char* */ printNumFmt: .string "%lu\n"

/* u64 */ grid_width:  .dword 20
/* u64 */ grid_height: .dword 10
/* u8[] */ grid_data: /* = NULL */ .dword 0

.text


.global main
main:
  # i8 main(i8 argc, char* argv[])
  addi sp, sp, -8
  sd ra, 0(sp)

  # srand(time(NULL))
  li a0, 0
  call time
  call srand

  # grid_data = calloc(grid_width * grid_height, sizeof(u8))
  ld t0, grid_width
  ld t1, grid_height
  mul a0, t0, t1
  li a1, 1
  call calloc
  la t0, grid_data
  sd a0, 0(t0)

  # grid_fill_randomly()
  call grid_fill_randomly

  # grid_print()
  call grid_print

  # free(grid_data)
  ld a0, grid_data
  call free

  # return 0
  li a0, 0

  ld ra, 0(sp)
  addi sp, sp, 8
  ret


grid_fill_randomly:
  # void grid_fill_randomly()
  addi sp, sp, -32
  sd ra,  0(sp)
  sd s1,  8(sp)
  sd s2, 16(sp)
  sd s3, 24(sp)

  ld s1, grid_data
  # u64 len = grid_width * grid_height
  ld t0, grid_width
  ld t1, grid_height
  mul s2, t0, t1
  # u64 i = 0
  li s3, 0

  grid_fill_randomly_loop0_start:
    # break if i >= len
    bgeu s3, s2, grid_fill_randomly_loop0_end

    # u8 cell = rand() & 1
    call rand
    andi a0, a0, 1

    # grid[i] = cell
    add t0, s1, s3
    sb a0, 0(t0)

    # i++
    addi s3, s3, 1
    j grid_fill_randomly_loop0_start
  grid_fill_randomly_loop0_end:

  ld ra,  0(sp)
  ld s1,  8(sp)
  ld s2, 16(sp)
  ld s3, 24(sp)
  addi sp, sp, 32
  ret


grid_print:
  # void grid_print()
  addi sp, sp, -48
  sd ra,  0(sp)
  sd s1,  8(sp)
  sd s2, 16(sp)
  sd s3, 24(sp)
  sd s4, 32(sp)
  sd s5, 40(sp)

  ld s1, grid_data
  ld s2, grid_width
  ld s3, grid_height
  # u64 x = 0
  li s4, 0
  # u64 y = 0
  li s5, 0

  grid_print_loop0_start:
    # break if y >= height
    bgeu s5, s3, grid_print_loop0_end

    # x = 0
    li s4, 0

    grid_print_loop1_start:
      # break if x >= width
      bgeu s4, s2, grid_print_loop1_end

      # u8 cell = grid[width * y + x] & 1
      mul t0, s2, s5
      add t0, t0, s4
      add t0, t0, s1
      lb a0, 0(t0)
      andi a0, a0, 1

      # Here I'm using a little trick to avoid branching: first, I multiply cell
      # value by distance from the character # to space (# is located later in
      # the ASCII table than space). Cells can contain either 0 or 1, so the
      # product will either be zero or that distance. Then I add the value of
      # space, so now the sum is the ASCII value of either space or #.
      # putchar(('#' - ' ') * cell + ' ')
      li t0, '#' - ' '
      mul a0, a0, t0
      addi a0, a0, ' '
      call putchar

      # x++
      addi s4, s4, 1
      j grid_print_loop1_start
    grid_print_loop1_end:

    # putchar('\n')
    li a0, '\n'
    call putchar

    # y++
    addi s5, s5, 1
    j grid_print_loop0_start
  grid_print_loop0_end:

  ld ra,  0(sp)
  ld s1,  8(sp)
  ld s2, 16(sp)
  ld s3, 24(sp)
  ld s4, 32(sp)
  ld s5, 40(sp)
  addi sp, sp, 48
  ret
