# =================================================
# Makefile based Amiga compiler setup.
# (c) Stefan "Bebbo" Franke in 2018
#
# Riding a dead horse...
# =================================================
.SUFFIXES:

# =================================================
# variables
# =================================================
CFLAGS=-Os
CPPFLAGS=-Os
CXXFLAGS=-Os


PREFIX=/opt/amiga
PATH := $(PREFIX)/bin:$(PATH)
SHELL = /bin/bash


# =================================================
# determine exe extension for cygwin
$(eval MYMAKE = $(shell which make) )
$(eval MYMAKEEXE = $(shell which "$(MYMAKE:%=%.exe)") )
EXEEXT=$(MYMAKEEXE:%=.exe)
# =================================================

# =================================================
# help
# =================================================
.PHONY: help
help:
	@echo "make help 			display this help"
	@echo "make all				build and install all"
	@echo "make <target>		builds a target: binutils, gcc, fd2sfd, fd2pragma, ira, sfdc, vbcc"
	@echo "make clean			remove the build folder"
	@echo "make clean-<target>	remove the target's build folder"
	@echo "make clean-prefix	remove all content from the prefix folder"
	@echo "make update			perform git pull for all targets"
	@echo "make update-<target>	perform git pull for the given target"

E=CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)" CXXFLAGS="$(CXXFLAGS)"

# =================================================
# all
# =================================================
.PHONY: all gcc binutils fd2sfd fd2pragma ira sfdc vbcc
all: gcc binutils fd2sfd fd2pragma ira sfdc vbcc
	@echo "built all"

# =================================================
# clean
# =================================================
.PHONY: clean-prefix clean clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vbcc
clean: clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vbcc
	rm -rf build

clean-gcc:
	rm -rf build/gcc

clean-binutils:
	rm -rf build/binutils

clean-fd2sfd:
	rm -rf build/fd2sfd

clean-fd2pragma:
	rm -rf build/fd2pragma

clean-ira:
	rm -rf build/ira

clean-sfdc:
	rm -rf build/sfdc
	
clean-vbcc:
	rm -rf build/vbcc

# clean-prefix drops the files from prefix folder
clean-prefix:
	rm -rf $(PREFIX)/*

# =================================================
# update all projects
# =================================================
.PHONY: update update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vbcc
update: update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vbcc

update-gcc: projects/gcc/configure
	pushd projects/gcc; git pull; popd

update-binutils: projects/binutils/configure
	pushd projects/binutils; git pull; popd

update-fd2fsd: projects/fd2sfd/configure
	pushd projects/fd2sfd; git pull; popd

update-fd2pragma: projects/fd2pragma/makefile
	pushd projects/fd2pragma; git pull; popd

update-ira: projects/ira/Makefile
	pushd projects/ira; git pull; popd

update-sfdc: projects/sfdc/configure
	pushd projects/sfdc; git pull; popd

update-vbcc: projects/vbcc/Makefile
	pushd projects/vbcc; git pull; popd

# =================================================
# gcc
# =================================================
CONFIG_GCC=--prefix=$(PREFIX) --target=m68k-amigaos --enable-languages=c,c++,objc --enable-version-specific-runtime-libs --disable-libssp --disable-nls

GCC_CMD = m68k-amigaos-c++ m68k-amigaos-g++ m68k-amigaos-gcc-6.3.1b m68k-amigaos-gcc-nm \
	m68k-amigaos-gcov m68k-amigaos-gcov-tool m68k-amigaos-cpp m68k-amigaos-gcc m68k-amigaos-gcc-ar \
	m68k-amigaos-gcc-ranlib m68k-amigaos-gcov-dump
GCC = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(GCC_CMD))
GCCP = $(patsubst m68k-amigaos%,$(PREFIX)/bin/\%%$(EXEEXT), $(GCC_CMD))

GCC_DIR = . gcc gcc/c gcc/c-family gcc/cp gcc/objc gcc/config/m68k libiberty libcpp libdecnumber
GCCD = $(patsubst %,projects/gcc/%, $(GCC_DIR))

gcc: $(GCC)
	@echo "built $(GCC)"

$(GCCP): build/gcc/Makefile $(shell find $(GCCD) -maxdepth 1 -type f )
	+pushd build/gcc; make all-gcc;	popd
	+pushd build/gcc; make install-gcc;	popd
	@true

build/gcc/Makefile: projects/gcc/configure
	@mkdir -p build/gcc
	+pushd build/gcc; $(E) $(PWD)/projects/gcc/configure $(CONFIG_GCC); popd

projects/gcc/configure:
	@mkdir -p projects
	pushd projects;	git clone -b gcc-6-branch --depth 1 https://github.com/bebbo/gcc; popd

# =================================================
# binutils
# =================================================
CONFIG_BINUTILS=--prefix=$(PREFIX) --target=m68k-amigaos
BINUTILS_CMD = m68k-amigaos-addr2line m68k-amigaos-ar m68k-amigaos-as m68k-amigaos-c++filt \
	m68k-amigaos-ld m68k-amigaos-nm m68k-amigaos-objcopy m68k-amigaos-objdump m68k-amigaos-ranlib \
	m68k-amigaos-readelf m68k-amigaos-size m68k-amigaos-strings m68k-amigaos-strip
BINUTILS = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(BINUTILS_CMD))
BINUTILSP = $(patsubst m68k-amigaos%,$(PREFIX)/bin/\%%$(EXEEXT), $(BINUTILS_CMD))

BINUTILS_DIR = . bfd gas ld binutils opcodes
BINUTILSD = $(patsubst %,projects/binutils/%, $(BINUTILS_DIR))

binutils: $(BINUTILS)
	@echo "built $(BINUTILS)"

$(BINUTILSP): build/binutils/Makefile $(shell find $(BINUTILSD) -maxdepth 1 -type f)
	touch -d19710101 projects/binutils/binutils/arparse.y
	touch -d19710101 projects/binutils/binutils/arlex.l
	touch -d19710101 projects/binutils/ld/ldgram.y
	+pushd build/binutils; make all install; popd

build/binutils/Makefile: projects/binutils/configure
	@mkdir -p build/binutils
	pushd build/binutils; $(E) $(PWD)/projects/binutils/configure $(CONFIG_BINUTILS); popd

projects/binutils/configure:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/bebbo/amigaos-binutils-2.14 binutils; popd


# =================================================
# fd2sfd
# =================================================
CONFIG_FD2SFD = --prefix=$(PREFIX) --target=m68k-amigaos

fd2sfd: $(PREFIX)/bin/fd2sfd
	@echo "built $(PREFIX)/bin/fd2sfd"

$(PREFIX)/bin/fd2sfd: build/fd2sfd/Makefile $(shell find projects/fd2sfd -type f)
	+pushd build/fd2sfd; make all; popd
	+pushd build/fd2sfd; make install; popd

build/fd2sfd/Makefile: projects/fd2sfd/configure
	@mkdir -p build/fd2sfd
	pushd build/fd2sfd; $(E) $(PWD)/projects/fd2sfd/configure $(CONFIG_FD2SFD); popd

projects/fd2sfd/configure:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/cahirwpz/fd2sfd; popd

# =================================================
# fd2pragma
# =================================================
fd2pragma: $(PREFIX)/bin/fd2pragma
	@echo "built $(PREFIX)/bin/fd2pragma"

$(PREFIX)/bin/fd2pragma: build/fd2pragma/fd2pragma $(shell find projects/fd2pragma -type f)
	install build/fd2pragma/fd2pragma $(PREFIX)/bin/

build/fd2pragma/fd2pragma: projects/fd2pragma/makefile $(shell find projects/fd2pragma -type f)
	@mkdir -p build/fd2pragma
	+pushd projects/fd2pragma; $(CC) -o $(PWD)/$@ $(CFLAGS) fd2pragma.c; popd

projects/fd2pragma/makefile:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/adtools/fd2pragma; popd

# =================================================
# ira
# =================================================
ira: $(PREFIX)/bin/ira
	@echo "built $(PREFIX)/bin/ira"

$(PREFIX)/bin/ira: build/ira/ira $(shell find projects/ira -type f)
	install build/ira/ira $(PREFIX)/bin/

build/ira/ira: projects/ira/Makefile $(shell find projects/ira -type f)
	@mkdir -p build/ira
	+pushd projects/ira; $(CC) -o $(PWD)/$@ $(CFLAGS) ira.c ira_2.c supp.c; popd

projects/ira/Makefile:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/bebbo/ira; popd

# =================================================
# sfdc
# =================================================
CONFIG_SFDC = --prefix=$(PREFIX) --target=m68k-amigaos

sfdc: $(PREFIX)/bin/sfdc
	@echo "built $(PREFIX)/bin/sfdc"

$(PREFIX)/bin/sfdc: build/sfdc/Makefile $(shell find projects/sfdc -type f)
	+pushd build/sfdc; make sfdc; popd
	install build/sfdc/sfdc $(PREFIX)/bin

build/sfdc/Makefile: projects/sfdc/configure
	rsync -aq --progress projects/sfdc build --exclude .git
	pushd build/sfdc; $(E) $(PWD)/build/sfdc/configure $(CONFIG_SFDC); popd

projects/sfdc/configure:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/adtools/sfdc; popd
	
# =================================================
# vbcc
# =================================================
CONFIG_VBCC = --prefix=$(PREFIX) --target=m68k-amigaos
VBCC_CMD = vbccm68k vprof vc
VBCC = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VBCC_CMD))
VBCCP = $(patsubst v%,$(PREFIX)/bin/\%%$(EXEEXT), $(VBCC_CMD))

vbcc: $(VBCC)
	@echo "built $(VBCC)"

$(VBCCP): build/vbcc/Makefile $(shell find projects/vbcc -type f)
	echo 1
	+pushd build/vbcc; TARGET=m68k make bin/dtgen; popd
	+pushd build/vbcc; echo -e "y\\ny\\nsigned char\\ny\\nunsigned char\\nn\\ny\\nsigned short\\nn\\ny\\nunsigned short\\nn\\ny\\nsigned int\\nn\\ny\\nunsigned int\\nn\\ny\\nsigned long long\\nn\\ny\\nunsigned long long\\nn\\ny\\nfloat\\nn\\ny\\ndouble\\n" >c.txt; bin/dtgen machines/m68k/machine.dt machines/m68k/dt.h machines/m68k/dt.c <c.txt; popd	+pushd build/vbcc; TARGET=m68k make; popd
	+pushd build/vbcc; TARGET=m68k make; popd
	+install build/vbcc/bin/v* $(PREFIX)/bin/

build/vbcc/Makefile: projects/vbcc/Makefile
	rsync -aq --progress projects/vbcc build --exclude .git
	mkdir -p build/vbcc/bin

projects/vbcc/Makefile:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/leffmann/vbcc; popd

