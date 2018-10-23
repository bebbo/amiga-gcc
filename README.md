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
### Centos
`sudo yum install gcc gcc-c++ python git perl-Pod-Simple gperf patch autoconf automake make makedepend bison flex ncurses-devel gmp-devel mpfr-devel libmpc-devel gettext-devel texinfo`
### Ubuntu
`sudo apt install make git gcc g++ lhasa libgmp-dev libmpfr-dev libmpc-dev flex bison gettext texinfo ncurses-dev`
### macOS
Install Homebrew (https://brew.sh/) or any other package manager first. The compiler will be installed together with XCode. Once XCode and Homebrew are up install the required packages:

`brew install bash make lhasa gmp mpfr mpc flex gettext texinfo`

By default macOS uses an outdated version of bash. Therefore, on macOS host always pass the the SHELL=/usr/local/bin/bash parameter (or any other valid path pointing to bash), e.g.:
```
make all SHELL=/usr/local/bin/bash
```
On macOS it may be also necessary to point to the correct compiler version (there is a gcc wrapper for clang, which can produce compile errors!), e.g.:
```
CC=clang CXX=clang++ make all SHELL=/usr/local/bin/bash
```

**ALSO NOTE** If you want `m68k-amigaos-gdb` then you have to build it with `gcc`

### Windows with Cygwin
Install cygwin via setup.exe and add wget. Then open cygwin shell and run:

```
wget https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
install apt-cyg /bin
apt-cyg install gcc-core gcc-g++ python git perl-Pod-Simple gperf patch automake make makedepend bison flex libncurses-devel python-devel gettext-devel libgmp-devel libmpc-devel libmpfr-devel
```

### Windows with msys2
```
pacman -S git base-devel gcc flex gmp-devel mpc-devel mpfr-devel ncurses-devel
```

### Ubuntu running on the Windows 10 Linux subsystem
tbd

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
takes roughly 10 minutes on my laptop running ubuntu. takes forever running cygwin on windows^^.
