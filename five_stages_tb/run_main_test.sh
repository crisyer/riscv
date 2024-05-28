#!/bin/bash
if [ ! -d "./output" ]; then
    mkdir output;
fi

if [ ! -d "./vcd" ]; then
    mkdir vcd;
fi

/home/adam/software/elf/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc -nostdlib -fno-builtin -march=rv32g -mabi=ilp32 -g -Wall main.c -o main.elf -T script.ld
/home/adam/software/elf/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-objdump -d main.elf > main.txt

python filter.py 

echo "== Main Test =============" &&
iverilog -g2005-sv -I ../five_stages/ -o output/tb_cpu.vvp tb_cpu.v && vvp output/tb_cpu.vvp &&
echo "DONE!" || echo "An error occured!";