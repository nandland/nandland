# Memory
Single Port RAM, Dual Port RAM, FIFO.

## Single Port RAM:
Random Access Memory, provide an address to write to or read from. 
Will store data at that address for retreval later. 
Single port can only access 1 location of memory at a time.

## Dual Port RAM
Same as Single Port RAM, but can access two locations of memory at the same time. This is useful for buffers that require writes and reads to occur at the same time. Also, this is used in the FIFO.

## FIFO
First-In-First-Out. Made from a Dual Port RAM that adds features to simplify FIFO creation. Will handle read and write addressing automatically for the user. Also has useful flags such as Empty, Full, Almost Empty, and Almost Full.

### How to Use
This repository can be imported for use in your own projects. I have found success using git subtree.

First navigate to a directory in which to import this repository. Then do:

`git subtree add --prefix memory https://github.com/nandland/memory.git main --squash`

To pull in latest changes:

`git subtree pull --prefix memory https://github.com/nandland/memory.git main --squash`
