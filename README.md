# amiga-gcc
The GNU C-Compiler with Binutils and other useful tools for cross development

This is a Makefile based approach to build the same files as in the old amigaos-toolchain to reduce the build time.

Right now these tools are build:
* binutils
* gcc with libs for C/C++/ObjC
* fd2sfd
* fd2pragma
* ira
* sfdc
* vbcc
* vlink
* libnix
* ixemul (not really, but the headers are used)
# Short Guide
## Prerequisites
### Ubuntu
`sudo apt install make git gcc g++ lhasa libgmp-dev libmpfr-dev libmpc-dev flex gettext`
## Howto Clone and Download All You Need
```
git clone https://github.com/bebbo/amiga-gcc
cd amiga-gcc
make update
```

## Overview
```
make help
```
yields:
```
make help 		        display this help
make all 		          build and install all
make <target>		      builds a target: binutils, gcc, fd2sfd, fd2pragma, ira, sfdc, vbcc, vlink, libnix, ixemul, libgcc
make clean		        remove the build folder
make clean-<target>	  remove the target's build folder
make clean-prefix	    remove all content from the prefix folder
make update		        perform git pull for all targets
make update-<target>	perform git pull for the given target
```
display which targets can be build, you'll mostly use
*`make all`
*`make clean`
*`make clean-prefx`
## Prefix
The default prefix is `/opt/amiga`. You may specify a different prefix by adding `PREFIX=yourprefix` to make command. E.g.
```
make all PREFIX=/here/or/there
```
## Building
Simply run `make all`. Also add -j to speedup the build.

```
make clean
make clean-prefix
date; make all -j3 >&b.log; date
```
takes roughly 10 minutes on my laptop running ubuntu.
