# bus16
Interfaces to a 16-bit wide bus, local to the FPGA.
Code in both VHDL and Verilog.

### How to Use
This repository can be imported for use in your own projects. I have found success using git subtree.

First navigate to a directory in which to import this repository. Then do:

`git subtree add --prefix bus16 https://github.com/nandland/bus16.git main --squash`

To pull in latest changes:

`git subtree pull --prefix bus16 https://github.com/nandland/bus16.git main --squash`
