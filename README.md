# riscv-playground

> My experiments with [the RISC-V ISA](https://en.wikipedia.org/wiki/RISC-V)

## Requirements

- CMake
- `make`
- `riscv64-linux-gnu-gcc`
- `qemu-riscv64`
- (optional) `riscv64-linux-gnu-gdb`

### Installation on Arch Linux

```bash
sudo pacman -S cmake make qemu{,-arch-extra} riscv64-linux-gnu-{gcc,gdb}
```

## Compiling

```bash
cmake -D CMAKE_BUILD_TYPE=Debug -B build
cmake --build build
```

## Running

```bash
cd build
# Make ensures that the executable has been built:
make run_<executable>
# or:
qemu-riscv64 <executable>
```

## Debugging

```bash
# in both terminals:
cd build

# in the first terminal:
QEMU_GDB=1234 make run_<executable>
# or:
qemu-riscv64 -g 1234 <executable>

# and in the second one:
riscv64-linux-gnu-gdb -ex 'target remote :1234' <executable>
```

## Useful resources

- [Official RISC-V manual](https://content.riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf)
- [RISC-V calling convention](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf)
- [Unofficial RISC-V reference card](https://www.cl.cam.ac.uk/teaching/1617/ECAD+Arch/files/docs/RISCVGreenCardv8-20151013.pdf)
- [Unofficial RISC-V reference card by James Zhu](https://github.com/jameslzhu/riscv-card/blob/master/riscv-card.pdf)
- [RISC-V instruction set reference from rv8](https://rv8.io/isa.html)
- [GNU `as` manual](https://sourceware.org/binutils/docs/as/)
- ["Hello World" tutorial from RARS](https://github.com/TheThirdOne/rars/wiki/Creating-Hello-World)
- [Fundamentals of RISC-V assembly from RARS](https://github.com/TheThirdOne/rars/wiki/Fundementals-of-RISC-V-Assembly)
- [MIPS Assembly/Control Flow Instructions](https://en.wikibooks.org/wiki/MIPS_Assembly/Control_Flow_Instructions)
