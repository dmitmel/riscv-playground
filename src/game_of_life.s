# game_of_life.s
# Written in 2019 by Dmytro Meleshko <dmytro.meleshko@gmail.com>
# To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

.data

/* char* */ printNumFmt: .string "%lu\n"

/* u64 */ grid_width:  .dword 20
/* u64 */ grid_height: .dword 10
/* [u8] */ grid_data:      /* = NULL */ .dword 0
/* [u8] */ grid_next_data: /* = NULL */ .dword 0

.text


.global main
main:
  # fn main(argc: i32, argv: [char*]) -> i32
  addi sp, sp, -8
  sd ra, 0(sp)

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

  # grid_fill_randomly()
  call grid_fill_randomly

  # grid_print()
  call grid_print

  # free(grid_data)
  ld a0, grid_data
  call free
  # free(grid_next_data)
  ld a0, grid_next_data
  call free

  # return 0
  li a0, 0

  ld ra, 0(sp)
  addi sp, sp, 8
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
  addi sp, sp, -8
  sd ra, 0(sp)

  # grid_data, grid_next_data = grid_next_data, grid_data
  ld t0, grid_data
  ld t1, grid_next_data
  la t2, grid_next_data
  sd t0, 0(t2)
  la t2, grid_data
  sd t1, 0(t2)

  ld ra, 0(sp)
  addi sp, sp, 8
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
  # let i: u64 = 0
  li s3, 0

  grid_fill_randomly_loop0_start:
    # break if i >= len
    bgeu s3, s2, grid_fill_randomly_loop0_end

    # let cell: u8 = rand() & 1
    call rand
    andi a0, a0, 1

    # grid_data[i] = cell
    add t0, s1, s3
    sb a0, 0(t0)

    # i += 1
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
  # fn grid_print()
  addi sp, sp, -48
  sd ra,  0(sp)
  sd s1,  8(sp)
  sd s2, 16(sp)
  sd s3, 24(sp)
  sd s4, 32(sp)
  sd s5, 40(sp)

  # let cell_ptr: u8* = grid_data
  ld s1, grid_data
  ld s2, grid_width
  ld s3, grid_height
  # let x: u64 = 0
  li s4, 0
  # let y: u64 = 0
  li s5, 0

  grid_print_loop0_start:
    # break if y >= grid_height
    bgeu s5, s3, grid_print_loop0_end

    # x = 0
    li s4, 0

    grid_print_loop1_start:
      # break if x >= grid_width
      bgeu s4, s2, grid_print_loop1_end

      # let cell: u8 = *cell_ptr & 1
      lb a0, 0(s1)
      andi a0, a0, 1

      # cell_ptr += 1
      addi s1, s1, 1

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

      # x += 1
      addi s4, s4, 1
      j grid_print_loop1_start
    grid_print_loop1_end:

    # putchar('\n')
    li a0, '\n'
    call putchar

    # y += 1
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
