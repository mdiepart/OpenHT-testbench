#!/bin/bash

rm bitstream/*
cp ./vivado/OpenHT_testbench/OpenHT_testbench.runs/impl_1/testbench_wrapper.bit bitstream/openht.bit
cp ./vivado/OpenHT_testbench/OpenHT_testbench.runs/impl_1/testbench_wrapper.ltx bitstream/openht.ltx
cp ./vivado/OpenHT_testbench/OpenHT_testbench.gen/sources_1/bd/testbench/hw_handoff/testbench.hwh bitstream/openht.hwh
#cp ./vivado/OpenHT_testbench/testbench_wrapper.xsa bitstream/openht.xsa

scp -r bitstream/* xilinx@192.168.2.99:/home/xilinx/jupyter_notebooks/openht
