# OpenHT-testbench
FPGA testbench for the OpenHT
- Get the image for Pynq Z2 (from http://www.pynq.io/board.html) and load it into a SD card
- Connect and boot Z2 board, add access to 192.168.2.0/24 network subnet on your PC
- Load the content of the pynq-z2 directory into /home/xilinx on the board (using SSH/SMB/whatever)
- Go to 192.168.2.99 (login xilinx, pass xilinx)
- Enjoy

If you need more observability, in pynq-z2/openht, the bitfile and ltx file are available for the AMD/Xilinx hardware manager to see what's going on.

After a new synthesis, launch prepare_bitstream.sh.
To get back all your hard work, launch get_from_pynq.sh before comitting

