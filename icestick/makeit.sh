#!/usr/bin/bash
# from Bruno Levy's basic serial example
# https://github.com/BrunoLevy/learn-fpga/tree/master/Basic/ICESTICK/Serial

PROJECTNAME=top
VERILOGS="pkg_strings.sv $PROJECTNAME.sv uart.v strings.v"
yosys -q -p "synth_ice40 -top $PROJECTNAME -json $PROJECTNAME.json" $VERILOGS || exit
nextpnr-ice40 --log $PROJECTNAME.log --json $PROJECTNAME.json --pcf $PROJECTNAME.pcf --asc $PROJECTNAME.asc --freq 12 --hx1k --package tq144 || exit
grep -A 6 'utilisation' $PROJECTNAME.log
icepack $PROJECTNAME.asc $PROJECTNAME.bin || exit
iceprog $PROJECTNAME.bin || exit
echo DONE.




