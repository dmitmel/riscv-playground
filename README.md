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
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=Debug ..
make
```

## Running

```bash
qemu-riscv64 path/to/executable
```

## Debugging

```bash
# in one terminal:
qemu-riscv64 -g 1234 path/to/executable

# and in another one:
riscv64-linux-gnu-gdb -ex 'target remote :1234' path/to/executable
```

## Useful resources

- [Official RISC-V manual](https://content.riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf)
- [RISC-V Calling Convention](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf)
- [Unofficial RISC-V reference card](https://www.cl.cam.ac.uk/teaching/1617/ECAD+Arch/files/docs/RISCVGreenCardv8-20151013.pdf)
- [Unofficial RISC-V reference card by James Zhu](https://github.com/jameslzhu/riscv-card/blob/master/riscv-card.pdf)
- [RISC-V instruction set reference from rv8](https://rv8.io/isa.html)
- [GNU `as` manual](https://sourceware.org/binutils/docs/as/)
- ["Hello World" tutorial from RARS](https://github.com/TheThirdOne/rars/wiki/Creating-Hello-World)
- [Fundamentals of RISC-V assembly from RARS](https://github.com/TheThirdOne/rars/wiki/Fundementals-of-RISC-V-Assembly)
