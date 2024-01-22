# amiga-gcc       [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=YRRBRLCKDU3H6)

The GNU C Compiler with binutils and other useful tools for cross compiling software for the Commodore Amiga.

This is a Makefile based approach to building the amigaos-toolchain, aiming to reduce its build time.

Currently, these tools are built:

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

# COPYRIGHTS
* amiga-netinclude: 'Roadshow' -- Amiga TCP/IP stack, Copyright © 2001-2016 by Olaf Barthel. Freely Distributable.
* aros-stuff: libpthread, Copyright (C) 2014 Szilard Biro.
* binutils: Free Software Foundation, GNU GENERAL PUBLIC LICENSE V2.
* clib2: Copyright (c) 2002-2015 by Olaf Barthel.
* fd2pragma: Dirk Stoecker, public domain.
* fd2sfd: Martin Blom et al, GNU GENERAL PUBLIC LICENSE V2.
* gcc: Free Software Foundation, GNU GENERAL PUBLIC LICENSE V2.
* ira: Tim Ruehsen, Ilkka Lehtoranta, Frank Wille, Nicolas Bastien. Freeware.
* ixemul: Markus Wild, Rafael W. Luebbert, Leonard Norrgard, Jeff Shepherd, Matthias Fleischer, Hans Verkuil. GNU GENERAL PUBLIC LICENSE V2.
* libdebug: ?, GNU GENERAL PUBLIC LICENSE V2.
* libnix: Matthias Fleischer, Gunther Nikl. Public Domain.
* NDK3.2: Hyperion, unknown license...
* newlib: Free Software Foundation, GNU GENERAL PUBLIC LICENSE V2.
* sfdc: Martin Blom, GNU GENERAL PUBLIC LICENSE V2.
* vasm: copyright in 2002-2022 by Volker Barthelmann, free for non-commercial purposes.
* vbcc: copyright in 1995-2022 by Volker Barthelmann, free for non-commercial purposes.
* vlink: copyright 1995-2022 by Frank Wille, free for non-commercial purposes.

There are also libraries (SDKs) which can be downloaded and installed. These libraries can all be built from source. All of these libraries are provided under their respective licenses.

Various AmigaOS-specific patches have been applied to this version of gcc. None if these changes modify the original copyright in any way. All other changes are published under the terms of the GNU GENERAL PUBLIC LICENSE V2.

## Prerequisites
### Centos
`sudo yum install wget gcc gcc-c++ python git perl-Pod-Simple gperf patch autoconf automake make makedepend bison flex ncurses-devel gmp-devel mpfr-devel libmpc-devel gettext-devel texinfo rsync readline-devel`

### Fedora
`sudo dnf install wget gcc gcc-c++ python git perl-Pod-Simple gperf patch autoconf automake make makedepend bison flex ncurses-devel gmp-devel mpfr-devel libmpc-devel gettext-devel texinfo rsync readline-devel`

### Ubuntu, Debian
`sudo apt install make wget git gcc g++ lhasa libgmp-dev libmpfr-dev libmpc-dev flex bison gettext texinfo ncurses-dev autoconf rsync libreadline-dev`

If building with a normal user, the `PREFIX` directory must be writable (default is `/opt/amiga`). You can add the user to an appropriate group. 

### macOS
Install Homebrew (https://brew.sh/) or any other package manager first. The compiler will be installed together with XCode. Once XCode and Homebrew are up install the required packages:

```
brew install bash wget make lhasa gmp mpfr libmpc flex gettext gnu-sed texinfo gcc@12 make autoconf bison
```

By default macOS uses an outdated version of bash. Therefore, on macOS host always pass the the SHELL=/usr/local/bin/bash parameter (or any other valid path pointing to bash), e.g.:

```
make all SHELL=$(brew --prefix)/bin/bash
```

On macOS it may be also necessary to point to the brew version of gcc make and autoconf, e.g.:

```
CC=gcc-12 CXX=g++-12 gmake all SHELL=$(brew --prefix)/bin/bash
```

**NOTE**

* You might need to use the brew version of make when building your projects (e.g.: `gmake`). Link failures are known to happen with GNU Make 3.81, but to succeed with GNU Make 4.4.1 on the same machine and project
* If you want `m68k-amigaos-gdb` then you have to build it with `gcc`
* The `gdb` build also needs a more recent `bison` version than the one installed
  in macOS. Use the version from Homebrew instead. It's keg only so you need
  to add it to your `PATH` manually:

```
export PATH=$(brew --prefix bison)/bin:$PATH
```
* This version of gcc supports building binaries optimised for the various Motorola 68K series CPUs from the 68000 to the 68060 and also features some optimisations for the Vampire/Apollo 68080.

### macOS on M1
Native builds on M1 Macs are now directly supported.

### Windows with Cygwin
Install cygwin via setup.exe and add wget. Then open cygwin shell and run:

```
wget https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
install apt-cyg /bin
apt-cyg install gcc-core gcc-g++ python git perl-Pod-Simple gperf patch automake make makedepend bison flex libncurses-devel python-devel gettext-devel libgmp-devel libmpc-devel libmpfr-devel rsync
```

### Windows with msys2

Precompiled suite with installer: http://franke.ms/download/setup-amiga-gcc.exe

```
pacman -S git base-devel gcc flex gmp-devel mpc-devel mpfr-devel ncurses-devel rsync autoconf automake
```

Also note that you **MUST** cd into an **absolute path** e.g. `cd /c/msys64/home/test/amiga-gcc/` before running make, or builds may fail, because some files aren't found correctly (that's a msys2 bug).

### Ubuntu running on the Windows 10 Linux subsystem
same as normal ubuntu

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
make drop-prefix	    remove all content from the prefix folder, beware!
make update		        perform git pull for all targets
make update-<target>	perform git pull for the given target
```
display which targets can be build, you'll mostly use
*`make all`
*`make clean`
*`make drop-prefix`

to use NDK3.2 add `NDK=3.2` to the make parameters

## Prefix
The default prefix is `/opt/amiga`. You may specify a different prefix by adding `PREFIX=yourprefix` to make command. E.g.
```
make all PREFIX=/here/or/there
```
The build performs the installation automatically, there is no separate `make install` step. Because of this, you must make sure that the target `PREFIX` directory is writable for the user who is doing the build.
If the `PREFIX` directory points to a directory where the user already has appropriate permissions the below steps can be ommited and the directory will be created by the build process.
```
sudo mkdir /opt/amiga
sudo chgrp users /opt/amiga
sudo chmod 775 /opt/amiga
sudo usermod -a -G users username
```
After adding the user to the group, you may have to logout and login again to apply the changes to your user.

## Building
In most cases you can simply run `sudo make all`. You can use `-j` to speed up the build, adjusting the value of `-j` to the number of cores you wish to use for the build process.

```
make clean
make drop-prefix
time make all -j4
```
The above commands take roughly 10 minutes on my laptop running Ubuntu yet the same commands take forever running cygwin on Windows.

## Kickstart 1.3

If you plan to develop for Kickstart 1.3 you should use `-mcrt=nix13` in your compiler commandline

```
m68k-amigaos-gcc test.cpp -mcrt=nix13
```

The include files for 1.3 - which are picked up by the compiler if `-mcrt=nix13` is used - can be found at `<PREFIX>/m68k-amigaos/ndk13-include` i.E. `/opt/amiga/m68k-amigaos/ndk13-include`

## Libraries/Runtimes

You can select one of the various runtimes. My favorite is `libnix` which is selected by specifying `-noixmeul` or `-mcrt=nix20`. Always specify this as the last parameter and only once. These are the available runtimes:

* nothing specifed: newlib based libraries for Kickstart 2.0+
* `-noixemul` or `-mcrt=nix20`: the libnix libraries for Kickstart 2.0+
* `-mcrt=nix13`: the libnix libraries for Kickstart 1.3
* `-mcrt=clib2`: the clib2 libraries.
* `-mcrt=ixemul`: the ixemul libraries for Kickstart 2.0+, requires an installed `ixemul.library`

## Checking gcc

To check the built version you may consider to run the gcc dejagnu tests. This does not cover everything but it's a start.
The tests are using my improved version of VAMOS (downstream of https://github.com/cnvogelg/amitools) to emulate the Amiga,
and right now not all improvements went back into the upstream.

### Debian / Ubuntu
```
sudo apt install dejagnu
sudo cp baseboards/* /usr/share/dejagnu/baseboards
pip install -U git+https://github.com/bebbo/amitools.git  
make check
```

### macOS
```
brew install dejagnu
cp baseboards/* $(brew --prefix)/opt/dejagnu/share/dejagnu/baseboards
pip install -U  git+https://github.com/bebbo/amitools.git  
make check
```

## Version management
This project does not use git submodules since it's to inconvenient to work with develop and release branches in each module and the main module.

Instead the **Makefile** provides some targets to switch to an older state for all modules.

### Switching amiga-gcc to a given date
Use make to switch all modules to a given date. You may also add the time
```
make v date=2021-04-01
```
### Switching amiga-gcc back to the branches
Run make to switch all modules back to the branch
```
make v
```
### Show the current commit for all submodules
This lists all modules with the last commit. Useful if you switched to a given date to show what's where.
```
make l
```
### Switch a module to a different branch
You can switch modules to different branches. E.g.
```
make branch mod=binutils branch=devel1
```
The default branches and repositories are in the file **default-repos**, the local state is managed in the file **.repos**.

Note that the gcc default branch is now `amiga6` and there is also an `amiga13.1` branch. To switch gcc to a specific branch use
```
make branch branch=amiga13.1 mod=gcc
```
If you start from scratch, switch gcc as soon as possible, e.g.:
```
sudo mkdir -p /opt/amiga13
sudo chown $USER /opt/amiga13
git clone https://github.com/bebbo/amiga-gcc
cd amiga-gcc
export PREFIX=/opt/amiga13
make branch branch=amiga13.1 mod=gcc
make all -j20
```

### Notable branches
* `amiga6`: The default branch providing gcc-6.5.0b with a lot of hacks^^
* `amiga13.1': gcc-13.1.0  supports register parameters
* `amiga13.2': gcc-13.2.0  supports register parameters
* `68080regs`: gcc-6.5.0b supporting the B0-B7/E0-E7 AMMX registers of the Apollo 68080 (experimental)
 

## Fortran support
m68k-amigaos-gfortran is available now too. To build it add `ADDLANG=fortran`:
```
make all -j20 ADDLANG=fortran
```

The example from https://gcc.gnu.org/wiki/GFortranGettingStarted does work, you have to link using gcc:
```
> m68k-amigaos-gfortran -Os fprog.f90 -c
> m68k-amigaos-gcc -Os -noixemul sub.c -c
> m68k-amigaos-gcc fprog.o sub.o  -o fprog -lgfortran -noixemul -lm
> vamos fprog
abcd 5 4711 4712.000000 13 14
```
