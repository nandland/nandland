# UART
UART in Verilog and VHDL
UART is Universal Synchronous Receiver/Transmitter. Basically a very simple way to exchange data between two devices.
This repo has UART implementations in both VHDL and Verilog for your use. 
Instantiate just the RX, TX, or Both. 
Verilog only: Contains ability to interface to registers within the FPGA.


### How to Use
This repository can be imported for use in your own projects. I have found success using git subtree.

First navigate to a directory in which to import this repository. Then do:

`git subtree add --prefix uart https://github.com/nandland/uart.git main --squash`

To pull in latest changes:

`git subtree pull --prefix uart https://github.com/nandland/uart.git main --squash`
