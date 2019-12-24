typedef unsigned char u8;
typedef unsigned long u64;
typedef signed long i64;

extern u8 grid_get(i64 x, i64 y);

u8 grid_count_alive_neighbors(u64 x, u64 y) {
  // clang-format off
  return
    grid_get(x    , y - 1) +  // top
    grid_get(x + 1, y - 1) +  // top right
    grid_get(x + 1, y    ) +  // right
    grid_get(x + 1, y + 1) +  // bottom right
    grid_get(x    , y + 1) +  // bottom
    grid_get(x - 1, y + 1) +  // bottom left
    grid_get(x - 1, y    ) +  // left
    grid_get(x - 1, y - 1)    // top left
    ;
  // clang-format on
}
