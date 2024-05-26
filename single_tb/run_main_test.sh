#!/bin/bash
if [ ! -d "./output" ]; then
    mkdir output;
fi

echo "== Main Test =============" &&
iverilog -g2005-sv -I ../single_32/ -o output/tb_cpu tb_cpu.v && vvp output/tb_cpu &&
echo "DONE!" || echo "An error occured!";