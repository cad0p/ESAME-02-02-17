echo off
cls
set path=%path%;C:\Program Files (x86)\Ghdl\bin;C:\Program Files (x86)\Ghdl\gtk\bin;
echo on

ghdl -a ESAME.vhdl
ghdl -e FFD
ghdl -e TOP
ghdl -e TOP_tb
ghdl -r TOP_tb --vcd=out.vcd
gtkwave out.vcd

