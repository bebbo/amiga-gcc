# =================================================
# Makefile based Amiga compiler setup.
# (c) Stefan "Bebbo" Franke in 2018
#
# Riding a dead horse...
# =================================================
include disable_implicite_rules.mk
# =================================================
# variables
# =================================================
PREFIX ?= /opt/amiga
SHELL = /bin/bash

GCC_GIT ?= https://github.com/bebbo/gcc
GCC_BRANCH ?= gcc-6-branch
GCC_VERSION ?= $(shell cat 2>/dev/null projects/gcc/gcc/BASE-VER)

BINUTILS_GIT ?= https://github.com/bebbo/binutils-gdb
BINUTILS_BRANCH ?= amiga

CFLAGS?=-Os
CPPFLAGS=$(CFLAGS)
CXXFLAGS=$(CFLAGS)
TARGET_C_FLAGS?=-Os -g -fomit-frame-pointer

E=CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)" CXXFLAGS="$(CXXFLAGS)" LIBCFLAGS_FOR_TARGET="$(TARGET_C_FLAGS)"

#LOG = >& $(PWD)/x.log || tail -n 999 $(PWD)/x.log

# =================================================
# determine exe extension for cygwin
$(eval MYMAKE = $(shell which make) )
$(eval MYMAKEEXE = $(shell which "$(MYMAKE:%=%.exe)" 2>/dev/null) )
EXEEXT=$(MYMAKEEXE:%=.exe)

UNAME_S := $(shell uname -s)

# Files for GMP, MPC and MPFR

GMP = gmp-6.1.2
GMPFILE = $(GMP).tar.bz2
MPC = mpc-1.0.3
MPCFILE = $(MPC).tar.gz
MPFR = mpfr-3.1.6
MPFRFILE = $(MPFR).tar.bz2

DETECTED_CC = $(CC)
ifeq ($(CC),cc)
DETECTED_VERSION =  $(shell $(CC) -v |& grep version)
ifneq ($(findstring clang,$(DETECTED_VERSION)),)
DETECTED_CC = clang
endif
ifneq ($(findstring gcc,$(DETECTED_VERSION)),)
DETECTED_CC = gcc
endif
endif

USED_CC_VERSION = $(shell $(DETECTED_CC) -v |& grep Target)
BUILD_TARGET=unix
ifneq ($(findstring msys,$(USED_CC_VERSION)),)
BUILD_TARGET=msys
  else
  ifneq ($(findstring mingw,$(USED_CC_VERSION)),)
BUILD_TARGET=msys
  endif
endif

PREFIX_TARGET = $(PREFIX)
ifneq ($(findstring :,$(PREFIX)),)
# Under mingw convert paths such as c:/gcc to /c/gcc
# Quotes added to work around a broken pipe error when running under MinGW
PREFIX_SUB = "/$(subst \,/,$(subst :,,$(PREFIX)))"
PREFIX_PATH = $(subst ",,$(PREFIX_SUB))
else
PREFIX_PATH = $(PREFIX)
endif

export PATH := $(PREFIX_PATH)/bin:$(PATH)

# =================================================

.PHONY: x
x:
	@if [ "$(sdk)" == "" ]; then \
		$(MAKE) help; \
	else \
		$(MAKE) sdk; \
	fi

# =================================================
# help
# =================================================
.PHONY: help
help:
	@echo "make help            display this help"
	@echo "make info            print prefix and other flags"
	@echo "make all             build and install all"
	@echo "make <target>        builds a target: binutils, gcc, fd2sfd, fd2pragma, ira, sfdc, vasm, vbcc, vlink, libnix, ixemul, libgcc, clib2, libdebug, libSDL12, ndk, ndk13"
	@echo "make clean           remove the build folder"
	@echo "make clean-<target>	remove the target's build folder"
	@echo "make clean-prefix    remove all content from the prefix folder"
	@echo "make update          perform git pull for all targets"
	@echo "make update-<target> perform git pull for the given target"
	@echo "make sdk=<sdk>       install the sdk <sdk>"
	@echo "make all-sdk         install all sdks"
	@echo "make info			display some info"

# =================================================
# all
# =================================================
ifeq ($(BUILD_TARGET),msys)
.PHONY: install-dll
all: install-dll
endif

.PHONY: all gcc binutils fd2sfd fd2pragma ira sfdc vasm vbcc vlink libnix ixemul libgcc clib2 libdebug libSDL12 ndk ndk13
all: gcc binutils fd2sfd fd2pragma ira sfdc vbcc vasm vlink libnix ixemul libgcc clib2 libdebug libSDL12 ndk ndk13

# =================================================
# clean
# =================================================
ifeq ($(BUILD_TARGET),msys)
.PHONY: clean-gmp clean-mpc clean-mpfr
clean: clean-gmp clean-mpc clean-mpfr
endif

.PHONY: clean-prefix clean clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vasm clean-vbcc clean-vlink clean-libnix clean-ixemul clean-libgcc clean-clib2 clean-libdebug clean-libSDL12 clean-newlib clean-ndk
clean: clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vasm clean-vbcc clean-vlink clean-libnix clean-ixemul clean-clib2 clean-libdebug clean-libSDL12 clean-newlib clean-ndk clean-gmp clean-mpc clean-mpfr
	rm -rf build

clean-gcc:
	rm -rf build/gcc

clean-gmp:
	rm -rf projects/gcc/gmp

clean-mpc:
	rm -rf projects/gcc/mpc

clean-mpfr:
	rm -rf projects/gcc/mpfr

clean-libgcc:
	rm -rf build/gcc/m68k-amigaos
	rm build/gcc/_libgcc_done

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

clean-vasm:
	rm -rf build/vasm

clean-vbcc:
	rm -rf build/vbcc

clean-vlink:
	rm -rf build/vlink

clean-ndk:
	rm -rf build/ndk-include

clean-libnix:
	rm -rf build/libnix
	
clean-ixemul:
	rm -rf build/ixemul
	
clean-clib2:
	rm -rf build/clib2

clean-libdebug:
	rm -rf build/libdebug

clean-libSDL12:
	rm -rf build/libSDL12

clean-newlib:
	rm -rf build/newlib

# clean-prefix drops the files from prefix folder
clean-prefix:
	rm -rf $(PREFIX_PATH)/bin
	rm -rf $(PREFIX_PATH)/libexec
	rm -rf $(PREFIX_PATH)/lib/gcc
	rm -rf $(PREFIX_PATH)/m68k-amigaos
	mkdir -p $(PREFIX_PATH)/bin

# =================================================
# update all projects
# =================================================
ifeq ($(BUILD_TARGET),msys)
.PHONY: update-gmp update-mpc update-mpfr
update: update-gmp update-mpc update-mpfr
endif

.PHONY: update update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vasm update-vbcc update-vlink update-libnix update-ixemul update-clib2 update-libdebug update-libSDL12 update-ndk update-newlib update-netinclude
update: update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vasm update-vbcc update-vlink update-libnix update-ixemul update-clib2 update-libdebug update-libSDL12 update-ndk update-newlib update-netinclude

update-gcc: projects/gcc/configure
	cd projects/gcc && export DEPTH=16; while true; do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH && break; export DEPTH=$$(($$DEPTH+$$DEPTH));done
	GCC_VERSION=$(shell cat 2>/dev/null projects/gcc/gcc/BASE-VER)

update-binutils: projects/binutils/configure
	a=($$(cd projects/binutils && git remote -v | grep origin | grep '(fetch)')); echo $${a[1]} ; \
	if [[ "$${a[1]}" != "$(BINUTILS_GIT)" ]]; then \
	  rm -rf projects/binutils; \
	  $(MAKE) projects/binutils/configure; \
	  $(MAKE) clean-binutils; \
	fi
	cd projects/binutils && export DEPTH=16; while true; do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH && break; export DEPTH=$$(($$DEPTH+$$DEPTH));done

update-fd2sfd: projects/fd2sfd/configure
	cd projects/fd2sfd && git pull

update-fd2pragma: projects/fd2pragma/makefile
	cd projects/fd2pragma && git pull

update-ira: projects/ira/Makefile
	cd projects/ira && git pull

update-sfdc: projects/sfdc/configure
	cd projects/sfdc && git pull

update-vasm: projects/vasm/Makefile
	cd projects/vasm && git pull

update-vbcc: projects/vbcc/Makefile
	cd projects/vbcc && git pull

update-vlink: projects/vlink/Makefile
	cd projects/vlink && git pull

update-libnix: projects/libnix/configure
	cd projects/libnix && git pull
	
update-ixemul: projects/ixemul/configure
	cd projects/ixemul && git pull

update-clib2: projects/clib2/LICENSE
	cd projects/clib2 && git pull

update-libdebug: projects/libdebug/configure
	cd projects/libdebug && git pull

update-libSDL12: projects/libSDL12/Makefile.bax
	cd projects/libSDL12 && git pull

update-ndk: projects/NDK_3.9.info

update-newlib: projects/newlib-cygwin/newlib/configure
	cd projects/newlib-cygwin && git pull

update-netinclude: projects/amiga-netinclude/README.md
	cd projects/amiga-netinclude && git pull

ifeq ($(BUILD_TARGET),msys)
update-gmp:
	@mkdir -p download
	@mkdir -p projects
	if [ -a download/$(GMPFILE) ]; \
	then rm -rf projects/$(GMP); rm -rf projects/gcc/gmp; \
	else cd download && wget ftp://ftp.gnu.org/gnu/gmp/$(GMPFILE); \
	fi;
	cd projects && tar xf ../download/$(GMPFILE)
	
update-mpc:
	@mkdir -p download
	@mkdir -p projects
	if [ -a download/$(MPCFILE) ]; \
	then rm -rf projcts/$(MPC); rm -rf projects/gcc/mpc; \
	else cd download && wget ftp://ftp.gnu.org/gnu/mpc/$(MPCFILE); \
	fi;
	cd projects && tar xf ../download/$(MPCFILE)

update-mpfr:
	@mkdir -p download
	@mkdir -p projects
	if [ -a download/$(MPFRFILE) ]; \
	then rm -rf projects/$(MPFR); rm -rf projects/gcc/mpfr; \
	else cd download && wget ftp://ftp.gnu.org/gnu/mpfr/$(MPFRFILE); \
	fi;
	cd projects && tar xf ../download/$(MPFRFILE)
endif

status-all:
	GCC_VERSION=$(shell cat 2>/dev/null projects/gcc/gcc/BASE-VER)
# =================================================
# B I N
# =================================================
	
# =================================================
# gcc
# =================================================
CONFIG_GCC=--prefix=$(PREFIX_TARGET) --target=m68k-amigaos --enable-languages=c,c++,objc --enable-version-specific-runtime-libs --disable-libssp --disable-nls \
	--with-headers=$(PWD)/projects/newlib-cygwin/newlib/libc/sys/amigaos/include/ --disable-shared --src=../../projects/gcc


GCC_CMD = m68k-amigaos-c++ m68k-amigaos-g++ m68k-amigaos-gcc-$(GCC_VERSION) m68k-amigaos-gcc-nm \
	m68k-amigaos-gcov m68k-amigaos-gcov-tool m68k-amigaos-cpp m68k-amigaos-gcc m68k-amigaos-gcc-ar \
	m68k-amigaos-gcc-ranlib m68k-amigaos-gcov-dump
GCC = $(patsubst %,$(PREFIX_PATH)/bin/%$(EXEEXT), $(GCC_CMD))

GCC_DIR = . gcc gcc/c gcc/c-family gcc/cp gcc/objc gcc/config/m68k libiberty libcpp libdecnumber
GCCD = $(patsubst %,projects/gcc/%, $(GCC_DIR))

gcc: build/gcc/_done

build/gcc/_done: build/gcc/Makefile $(shell find 2>/dev/null $(GCCD) -maxdepth 1 -type f )
	$(MAKE) -C build/gcc all-gcc $(LOG)
	$(MAKE) -C build/gcc install-gcc $(LOG)
	echo "done" >$@
	@echo "built $(GCC)"

build/gcc/Makefile: projects/gcc/configure build/binutils/_done
	@mkdir -p build/gcc
ifeq ($(BUILD_TARGET),msys)
	@mkdir -p projects/gcc/gmp
	@mkdir -p projects/gcc/mpc
	@mkdir -p projects/gcc/mpfr
	rsync -a projects/$(GMP)/* projects/gcc/gmp
	rsync -a projects/$(MPC)/* projects/gcc/mpc
	rsync -a projects/$(MPFR)/* projects/gcc/mpfr
endif	
#	if [ "$(UNAME_S)" == "Darwin" ]; then cd build/gcc && contrib/download_prerequisites; fi
	cd build/gcc && $(E) $(PWD)/projects/gcc/configure $(CONFIG_GCC) $(LOG)

projects/gcc/configure:
	@mkdir -p projects
	cd projects &&	git clone -b $(GCC_BRANCH) --depth 16 https://github.com/bebbo/gcc

# =================================================
# binutils
# =================================================
CONFIG_BINUTILS=--prefix=$(PREFIX_TARGET) --target=m68k-amigaos --disable-plugins --disable-werror
BINUTILS_CMD = m68k-amigaos-addr2line m68k-amigaos-ar m68k-amigaos-as m68k-amigaos-c++filt \
	m68k-amigaos-ld m68k-amigaos-nm m68k-amigaos-objcopy m68k-amigaos-objdump m68k-amigaos-ranlib \
	m68k-amigaos-readelf m68k-amigaos-size m68k-amigaos-strings m68k-amigaos-strip
BINUTILS = $(patsubst %,$(PREFIX_PATH)/bin/%$(EXEEXT), $(BINUTILS_CMD))

BINUTILS_DIR = . bfd gas ld binutils opcodes
BINUTILSD = $(patsubst %,projects/binutils/%, $(BINUTILS_DIR))

ifeq ($(findstring clang,$(CC)),)
ALL_GDB = all-gdb
INSTALL_GDB = install-gdb
endif

binutils: build/binutils/_done

build/binutils/_done: build/binutils/gas/Makefile $(shell find 2>/dev/null projects/binutils -not \( -path projects/binutils/.git -prune \) -type f)
	touch -t 0001010000 projects/binutils/binutils/arparse.y
	touch -t 0001010000 projects/binutils/binutils/arlex.l
	touch -t 0001010000 projects/binutils/ld/ldgram.y
	$(MAKE) -C build/binutils all-gas all-binutils all-ld $(ALL_GDB) $(LOG)
	$(MAKE) -C build/binutils install-gas install-binutils install-ld $(INSTALL_GDB) $(LOG)
	echo "done" >$@
	echo "build $(BINUTILS)"

build/binutils/gas/Makefile: projects/binutils/configure
	@mkdir -p build/binutils
	cd build/binutils && $(E) $(PWD)/projects/binutils/configure $(CONFIG_BINUTILS) $(LOG)

projects/binutils/configure:
	@mkdir -p projects
	cd projects &&	git clone -b $(BINUTILS_BRANCH) --depth 16 $(BINUTILS_GIT) binutils


# =================================================
# fd2sfd
# =================================================
CONFIG_FD2SFD = --prefix=$(PREFIX_TARGET) --target=m68k-amigaos

fd2sfd: build/fd2sfd/_done

build/fd2sfd/_done: $(PREFIX_PATH)/bin/fd2sfd
	@echo "built $(PREFIX_PATH)/bin/fd2sfd"
	@echo "done" >$@

$(PREFIX_PATH)/bin/fd2sfd: build/fd2sfd/Makefile $(shell find 2>/dev/null projects/fd2sfd -not \( -path projects/fd2sfd/.git -prune \) -type f)
	$(MAKE) -C build/fd2sfd all $(LOG)
	mkdir -p $(PREFIX_PATH)/bin/
	$(MAKE) -C build/fd2sfd install $(LOG)
build/fd2sfd/Makefile: projects/fd2sfd/configure
	@mkdir -p build/fd2sfd
	cd build/fd2sfd && $(E) $(PWD)/projects/fd2sfd/configure $(CONFIG_FD2SFD) $(LOG)

projects/fd2sfd/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/cahirwpz/fd2sfd
	for i in $$(find patches/fd2sfd/ -type f); \
	do if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "projects/$${j%.diff}" "$$i"; fi ; done

# =================================================
# fd2pragma
# =================================================
fd2pragma: build/fd2pragma/_done

build/fd2pragma/_done: $(PREFIX_PATH)/bin/fd2pragma
	@echo "built $(PREFIX_PATH)/bin/fd2pragma"
	@echo "done" >$@

$(PREFIX_PATH)/bin/fd2pragma: build/fd2pragma/fd2pragma
	mkdir -p $(PREFIX_PATH)/bin/
	install build/fd2pragma/fd2pragma $(PREFIX_PATH)/bin/

build/fd2pragma/fd2pragma: projects/fd2pragma/makefile $(shell find 2>/dev/null projects/fd2pragma -not \( -path projects/fd2pragma/.git -prune \) -type f)
	@mkdir -p build/fd2pragma
	cd projects/fd2pragma && $(CC) -o $(PWD)/$@ $(CFLAGS) fd2pragma.c

projects/fd2pragma/makefile:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/adtools/fd2pragma

# =================================================
# ira
# =================================================
ira: build/ira/_done

build/ira/_done: $(PREFIX_PATH)/bin/ira
	@echo "built $(PREFIX_PATH)/bin/ira"
	@echo "done" >$@

$(PREFIX_PATH)/bin/ira: build/ira/ira
	mkdir -p $(PREFIX_PATH)/bin/
	install build/ira/ira $(PREFIX_PATH)/bin/

build/ira/ira: projects/ira/Makefile $(shell find 2>/dev/null projects/ira -not \( -path projects/ira/.git -prune \) -type f)
	@mkdir -p build/ira
	cd projects/ira && $(CC) -o $(PWD)/$@ $(CFLAGS) *.c -std=c99

projects/ira/Makefile:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/ira

# =================================================
# sfdc
# =================================================
CONFIG_SFDC = --prefix=$(PREFIX_PATH) --target=m68k-amigaos

sfdc: build/sfdc/_done

build/sfdc/_done: $(PREFIX_PATH)/bin/sfdc
	@echo "built $(PREFIX_PATH)/bin/sfdc"
	@echo "done" >$@

$(PREFIX_PATH)/bin/sfdc: build/sfdc/Makefile $(shell find 2>/dev/null projects/sfdc -not \( -path projects/sfdc/.git -prune \)  -type f)
	$(MAKE) -C build/sfdc sfdc $(LOG)
	mkdir -p $(PREFIX_PATH)/bin/
	install build/sfdc/sfdc $(PREFIX_PATH)/bin

build/sfdc/Makefile: projects/sfdc/configure
	rsync -a projects/sfdc build --exclude .git
	cd build/sfdc && $(E) $(PWD)/build/sfdc/configure $(CONFIG_SFDC) $(LOG)

projects/sfdc/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/adtools/sfdc
	for i in $$(find patches/sfdc/ -type f); \
	do if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "projects/$${j%.diff}" "$$i"; fi ; done

# =================================================
# vasm
# =================================================
VASM_CMD = vasmm68k_mot
VASM = $(patsubst %,$(PREFIX_PATH)/bin/%$(EXEEXT), $(VASM_CMD))

vasm: build/vasm/_done

build/vasm/_done: build/vasm/Makefile $(shell find 2>/dev/null projects/vasm -not \( -path projects/vasm/.git -prune \) -type f)
	$(MAKE) -C build/vasm CPU=m68k SYNTAX=mot $(LOG)
	mkdir -p $(PREFIX_PATH)/bin/
	install build/vasm/vasmm68k_mot $(PREFIX_PATH)/bin/
	install build/vasm/vobjdump $(PREFIX_PATH)/bin/
	cp patches/vc.config build/vasm/vc.config
	sed -e "s|PREFIX_PATH|$(PREFIX_PATH)|g" -i.bak build/vasm/vc.config
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/etc/
	install build/vasm/vc.config $(PREFIX_PATH)/bin/
	@echo "done" >$@
	@echo "built $(vasm)"

build/vasm/Makefile: projects/vasm/Makefile
	rsync -a projects/vasm build --exclude .git

projects/vasm/Makefile:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/leffmann/vasm

# =================================================
# vbcc
# =================================================
VBCC_CMD = vbccm68k vprof vc
VBCC = $(patsubst %,$(PREFIX_PATH)/bin/%$(EXEEXT), $(VBCC_CMD))

vbcc: build/vbcc/_done

build/vbcc/_done: build/vbcc/Makefile $(shell find 2>/dev/null projects/vbcc -not \( -path projects/vbcc/.git -prune \) -type f)
	cd build/vbcc && TARGET=m68k $(MAKE) bin/dtgen $(LOG)
	cd build/vbcc && echo -e "y\\ny\\nsigned char\\ny\\nunsigned char\\nn\\ny\\nsigned short\\nn\\ny\\nunsigned short\\nn\\ny\\nsigned int\\nn\\ny\\nunsigned int\\nn\\ny\\nsigned long long\\nn\\ny\\nunsigned long long\\nn\\ny\\nfloat\\nn\\ny\\ndouble\\n" >c.txt; bin/dtgen machines/m68k/machine.dt machines/m68k/dt.h machines/m68k/dt.c <c.txt
	cd build/vbcc && TARGET=m68k $(MAKE) $(LOG)
	mkdir -p $(PREFIX_PATH)/bin/
	rm -rf build/vbcc/bin/*.dSYM
	install build/vbcc/bin/v* $(PREFIX_PATH)/bin/
	@echo "done" >$@
	@echo "built $(VBCC)"

build/vbcc/Makefile: projects/vbcc/Makefile
	rsync -a projects/vbcc build --exclude .git
	mkdir -p build/vbcc/bin

projects/vbcc/Makefile:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/leffmann/vbcc

# =================================================
# vlink
# =================================================
VLINK_CMD = vlink
VLINK = $(patsubst %,$(PREFIX_PATH)/bin/%$(EXEEXT), $(VLINK_CMD))

vlink: build/vlink/_done

build/vlink/_done: build/vlink/Makefile $(shell find 2>/dev/null projects/vlink -not \( -path projects/vlink/.git -prune \) -type f)
	cd build/vlink && TARGET=m68k $(MAKE) $(LOG)
	mkdir -p $(PREFIX_PATH)/bin/
	install build/vlink/vlink $(PREFIX_PATH)/bin/
	@echo "done" >$@
	@echo "built $(VLINK)"

build/vlink/Makefile: projects/vlink/Makefile
	rsync -a projects/vlink build --exclude .git

projects/vlink/Makefile:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/leffmann/vlink

# =================================================
# L I B R A R I E S
# =================================================
# =================================================
# NDK - no git
# =================================================

NDK_INCLUDE = $(shell find 2>/dev/null projects/NDK_3.9/Include/include_h -type f)
NDK_INCLUDE_SFD = $(shell find 2>/dev/null projects/NDK_3.9/Include/sfd -type f -name *.sfd)
NDK_INCLUDE_INLINE = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX_PATH)/m68k-amigaos/ndk-include/inline/%.h,$(NDK_INCLUDE_SFD))
NDK_INCLUDE_LVO    = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX_PATH)/m68k-amigaos/ndk-include/lvo/%_lib.i,$(NDK_INCLUDE_SFD))
NDK_INCLUDE_PROTO  = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX_PATH)/m68k-amigaos/ndk-include/proto/%.h,$(NDK_INCLUDE_SFD))
SYS_INCLUDE2 = $(filter-out $(NDK_INCLUDE_PROTO),$(patsubst projects/NDK_3.9/Include/include_h/%,$(PREFIX_PATH)/m68k-amigaos/ndk-include/%, $(NDK_INCLUDE)))

.PHONY: ndk-inline ndk-lvo ndk-proto

ndk: build/ndk-include/_ndk 

build/ndk-include/_ndk: build/ndk-include/_ndk0 $(NDK_INCLUDE_INLINE) $(NDK_INCLUDE_LVO) $(NDK_INCLUDE_PROTO) projects/fd2sfd/configure projects/fd2pragma/makefile
	mkdir -p build/ndk-include/
	echo "done" >$@

build/ndk-include/_ndk0: projects/NDK_3.9.info $(NDK_INCLUDE)
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk-include
	rsync -a $(PWD)/projects/NDK_3.9/Include/include_h/* $(PREFIX_PATH)/m68k-amigaos/ndk-include --exclude proto
	rsync -a $(PWD)/projects/NDK_3.9/Include/include_i/* $(PREFIX_PATH)/m68k-amigaos/ndk-include
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk/lib
	rsync -a $(PWD)/projects/NDK_3.9/Include/fd $(PREFIX_PATH)/m68k-amigaos/ndk/lib
	rsync -a $(PWD)/projects/NDK_3.9/Include/sfd $(PREFIX_PATH)/m68k-amigaos/ndk/lib
	rsync -a $(PWD)/projects/NDK_3.9/Include/linker_libs $(PREFIX_PATH)/m68k-amigaos/ndk/lib
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk-include/proto
	cp -p projects/NDK_3.9/Include/include_h/proto/alib.h $(PREFIX_PATH)/m68k-amigaos/ndk-include/proto
	cp -p projects/NDK_3.9/Include/include_h/proto/cardres.h $(PREFIX_PATH)/m68k-amigaos/ndk-include/proto
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk-include/inline
	cp -p projects/fd2sfd/cross/share/m68k-amigaos/alib.h $(PREFIX_PATH)/m68k-amigaos/ndk-include/inline
	cp -p projects/fd2pragma/Include/inline/stubs.h $(PREFIX_PATH)/m68k-amigaos/ndk-include/inline
	cp -p projects/fd2pragma/Include/inline/macros.h $(PREFIX_PATH)/m68k-amigaos/ndk-include/inline
	mkdir -p build/ndk-include/
	echo "done" >$@

ndk-inline: $(NDK_INCLUDE_INLINE) sfdc build/ndk-include/_inline 
$(NDK_INCLUDE_INLINE): $(PREFIX_PATH)/bin/sfdc $(NDK_INCLUDE_SFD) build/ndk-include/_inline build/ndk-include/_lvo build/ndk-include/_proto build/ndk-include/_ndk0
	sfdc --target=m68k-amigaos --mode=macros --output=$@ $(patsubst $(PREFIX_PATH)/m68k-amigaos/ndk-include/inline/%.h,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@)

ndk-lvo: $(NDK_INCLUDE_LVO) sfdc
$(NDK_INCLUDE_LVO): $(PREFIX_PATH)/bin/sfdc $(NDK_INCLUDE_SFD) build/ndk-include/_lvo build/ndk-include/_ndk0
	sfdc --target=m68k-amigaos --mode=lvo --output=$@ $(patsubst $(PREFIX_PATH)/m68k-amigaos/ndk-include/lvo/%_lib.i,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@)

ndk-proto: $(NDK_INCLUDE_PROTO) sfdc
$(NDK_INCLUDE_PROTO): $(PREFIX_PATH)/bin/sfdc $(NDK_INCLUDE_SFD)	build/ndk-include/_proto build/ndk-include/_ndk0
	sfdc --target=m68k-amigaos --mode=proto --output=$@ $(patsubst $(PREFIX_PATH)/m68k-amigaos/ndk-include/proto/%.h,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@)

build/ndk-include/_inline:
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk-include/inline
	mkdir -p build/ndk-include/
	echo "done" >$@

build/ndk-include/_lvo:
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk-include/lvo
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk13-include/lvo
	mkdir -p build/ndk-include/
	echo "done" >$@

build/ndk-include/_proto:
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk-include/proto
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk13-include/proto
	mkdir -p build/ndk-include/
	echo "done" >$@

projects/NDK_3.9.info: download/NDK39.lha $(shell find 2>/dev/null patches/NDK_3.9/ -type f)
	mkdir -p projects
	mkdir -p build
	if [ ! -e "$$(which lha)" ]; then cd build && rm -rf lha; git clone https://github.com/jca02266/lha; cd lha; aclocal; autoheader; automake -a; autoconf; ./configure; make all; mkdir -p $(PREFIX_PATH)/bin/; install src/lha$(EXEEXT) $(PREFIX_PATH)/bin/lha$(EXEEXT); fi
	cd projects && lha xf ../download/NDK39.lha
	touch -t 0001010000 download/NDK39.lha
	for i in $$(find patches/NDK_3.9/ -type f); \
	do if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "projects/$${j%.diff}" "$$i"; \
		else cp -pv "$$i" "projects/$${i:8}"; fi ; done
	touch projects/NDK_3.9.info

download/NDK39.lha:
	mkdir -p download
	cd download && wget http://www.haage-partner.de/download/AmigaOS/NDK39.lha


# =================================================
# NDK1.3 - emulated from NDK
# =================================================

ndk13: build/ndk-include/_ndk13

build/ndk-include/_ndk13: build/ndk-include/_ndk
	while read p; do mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk13-include/$$(dirname $$p); cp $(PREFIX_PATH)/m68k-amigaos/ndk-include/$$p $(PREFIX_PATH)/m68k-amigaos/ndk13-include/$$p; done < patches/ndk13/hfiles
	while read p; do \
	  mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk13-include/$$(dirname $$p); \
	  if grep V36 $(PREFIX_PATH)/m68k-amigaos/ndk-include/$$p; then \
	  LC_CTYPE=C sed -n -e '/#ifndef  CLIB/,/V36/p' $(PREFIX_PATH)/m68k-amigaos/ndk-include/$$p >$(PREFIX_PATH)/m68k-amigaos/ndk13-include/$$p; \
	  echo -e "#ifdef __cplusplus\n}\n#endif /* __cplusplus */\n#endif" >>$(PREFIX_PATH)/m68k-amigaos/ndk13-include/$$p; \
	  else cp $(PREFIX_PATH)/m68k-amigaos/ndk-include/$$p $(PREFIX_PATH)/m68k-amigaos/ndk13-include/$$p; fi \
	done < patches/ndk13/chfiles
	while read p; do mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk13-include/$$(dirname $$p); echo "" >$(PREFIX_PATH)/m68k-amigaos/ndk13-include/$$p; done < patches/ndk13/ehfiles
	echo '#undef	EXECNAME' > $(PREFIX_PATH)/m68k-amigaos/ndk13-include/exec/execname.h
	echo '#define	EXECNAME	"exec.library"' >> $(PREFIX_PATH)/m68k-amigaos/ndk13-include/exec/execname.h
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk/lib/fd13
	while read p; do LC_CTYPE=C sed -n -e '/##base/,/V36/P'  $(PREFIX_PATH)/m68k-amigaos/ndk/lib/fd/$$p >$(PREFIX_PATH)/m68k-amigaos/ndk/lib/fd13/$$p; done < patches/ndk13/fdfiles
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk/lib/sfd13
	for i in $(PREFIX_PATH)/m68k-amigaos/ndk/lib/fd13/*; do fd2sfd $$i $(PREFIX_PATH)/m68k-amigaos/ndk13-include/clib/$$(basename $$i _lib.fd)_protos.h > $(PREFIX_PATH)/m68k-amigaos/ndk/lib/sfd13/$$(basename $$i .fd).sfd; done
	for i in $(PREFIX_PATH)/m68k-amigaos/ndk/lib/sfd13/*; do \
	  sfdc --target=m68k-amigaos --mode=macros --output=$(PREFIX_PATH)/m68k-amigaos/ndk13-include/inline/$$(basename $$i _lib.sfd).h $$i; \
	  sfdc --target=m68k-amigaos --mode=proto --output=$(PREFIX_PATH)/m68k-amigaos/ndk13-include/proto/$$(basename $$i _lib.sfd).h $$i; \
	done
	echo "done" >$@

# =================================================
# netinclude
# =================================================
build/_netinclude: projects/amiga-netinclude/README.md build/ndk-include/_ndk $(shell find 2>/dev/null projects/amiga-netinclude/include -type f)
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/ndk-include
	rsync -a $(PWD)/projects/amiga-netinclude/include/* $(PREFIX_PATH)/m68k-amigaos/ndk-include
	echo "done" >$@

projects/amiga-netinclude/README.md: 
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/amiga-netinclude

# =================================================
# libamiga
# =================================================
LIBAMIGA=$(PREFIX_PATH)/m68k-amigaos/lib/libamiga.a $(PREFIX_PATH)/m68k-amigaos/lib/libb/libamiga.a

libamiga: $(LIBAMIGA)
	@echo "built $(LIBAMIGA)"

$(LIBAMIGA):
	mkdir -p $(@D)
	cp -p $(patsubst $(PREFIX_PATH)/m68k-amigaos/%,%,$@) $(@D)

# =================================================
# libnix
# =================================================

CONFIG_LIBNIX = --prefix=$(PREFIX_TARGET)/m68k-amigaos/libnix --target=m68k-amigaos --host=m68k-amigaos

LIBNIX_SRC = $(shell find 2>/dev/null projects/libnix -not \( -path projects/libnix/.git -prune \) -not \( -path projects/libnix/sources/stubs/libbases -prune \) -not \( -path projects/libnix/sources/stubs/libnames -prune \) -type f)

libnix: build/libnix/_done

build/libnix/_done: build/libnix/Makefile
	$(MAKE) -C build/libnix $(LOG)
	$(MAKE) -C build/libnix install $(LOG)
	cd build/newlib/complex && $(PREFIX_PATH)/bin/m68k-amigaos-ar rcs $(PREFIX_PATH)/m68k-amigaos/libnix/lib/libm.a $(COMPLEX_FILES)
	cd build/newlib/complex/libb && $(PREFIX_PATH)/bin/m68k-amigaos-ar rcs $(PREFIX_PATH)/m68k-amigaos/libnix/lib/libb/libm.a $(COMPLEX_FILES)
	cd build/newlib/complex/libm020 && $(PREFIX_PATH)/bin/m68k-amigaos-ar rcs $(PREFIX_PATH)/m68k-amigaos/libnix/lib/libm020/libm.a $(COMPLEX_FILES)
	cd build/newlib/complex/libm020/libb && $(PREFIX_PATH)/bin/m68k-amigaos-ar rcs $(PREFIX_PATH)/m68k-amigaos/libnix/lib/libm020/libb/libm.a $(COMPLEX_FILES)
	cd build/newlib/complex/libm020/libb32 && $(PREFIX_PATH)/bin/m68k-amigaos-ar rcs $(PREFIX_PATH)/m68k-amigaos/libnix/lib/libm020/libb32/libm.a $(COMPLEX_FILES)
	@echo "done" >$@
	@echo "built $(LIBNIX)"
		
build/libnix/Makefile: build/newlib/_done build/ndk-include/_ndk build/ndk-include/_ndk13 build/_netinclude build/binutils/_done build/gcc/_done projects/libnix/configure projects/libnix/Makefile.in $(LIBAMIGA) $(LIBNIX_SRC) 
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/libnix/lib/libnix 
	mkdir -p build/libnix
	echo 'void foo(){}' > build/libnix/x.c
	if [ ! -e $(PREFIX_PATH)/m68k-amigaos/lib/libstubs.a ]; then $(PREFIX_PATH)/bin/m68k-amigaos-ar r $(PREFIX_PATH)/m68k-amigaos/lib/libstubs.a; fi
	mkdir -p $(PREFIX_PATH)/lib/gcc/m68k-amigaos/$(GCC_VERSION)
	if [ ! -e $(PREFIX_PATH)/lib/gcc/m68k-amigaos/$(GCC_VERSION)/libgcc.a ]; then $(PREFIX_PATH)/bin/m68k-amigaos-ar r $(PREFIX_PATH)/lib/gcc/m68k-amigaos/$(GCC_VERSION)/libgcc.a; fi
	cd build/libnix && CFLAGS="$(TARGET_C_FLAGS)" AR=m68k-amigaos-ar AS=m68k-amigaos-as CC=m68k-amigaos-gcc $(A) $(PWD)/projects/libnix/configure $(CONFIG_LIBNIX) $(LOG)
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/libnix/include/
	rsync -a projects/libnix/sources/headers/* $(PREFIX_PATH)/m68k-amigaos/libnix/include/
	touch build/libnix/Makefile
	
projects/libnix/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/libnix

# =================================================
# gcc libs
# =================================================
LIBGCCS_NAMES=libgcov.a libstdc++.a libsupc++.a
LIBGCCS= $(patsubst %,$(PREFIX_PATH)/lib/gcc/m68k-amigaos/$(GCC_VERSION)/%,$(LIBGCCS_NAMES))

libgcc: build/gcc/_libgcc_done

build/gcc/_libgcc_done: build/libnix/_done $(LIBAMIGA)
	$(MAKE) -C build/gcc all-target $(LOG)
	$(MAKE) -C build/gcc install-target $(LOG)
	echo "done" >$@
	echo "$(LIBGCCS)"

# =================================================
# clib2
# =================================================

clib2: build/clib2/_done

build/clib2/_done: projects/clib2/LICENSE $(shell find 2>/dev/null projects/clib2 -not \( -path projects/clib2/.git -prune \) -type f) build/libnix/Makefile $(LIBAMIGA)
	mkdir -p build/clib2/
	rsync -a projects/clib2/library/* build/clib2
	cd build/clib2 && find * -name lib\*.a -delete
	$(MAKE) -C build/clib2 -f GNUmakefile.68k $(LOG)
	mkdir -p $(PREFIX_PATH)/m68k-amigaos/clib2
	rsync -a build/clib2/include $(PREFIX_PATH)/m68k-amigaos/clib2
	rsync -a build/clib2/lib $(PREFIX_PATH)/m68k-amigaos/clib2
	cd build/newlib/complex && $(PREFIX_PATH)/bin/m68k-amigaos-ar rcs $(PREFIX_PATH)/m68k-amigaos/clib2/lib/libm.a $(COMPLEX_FILES)
	cd build/newlib/complex/libb && $(PREFIX_PATH)/bin/m68k-amigaos-ar rcs $(PREFIX_PATH)/m68k-amigaos/clib2/lib/libb/libm.a $(COMPLEX_FILES)
	cd build/newlib/complex/libm020 && $(PREFIX_PATH)/bin/m68k-amigaos-ar rcs $(PREFIX_PATH)/m68k-amigaos/clib2/lib/libm020/libm.a $(COMPLEX_FILES)
	cd build/newlib/complex/libm020/libb && $(PREFIX_PATH)/bin/m68k-amigaos-ar rcs $(PREFIX_PATH)/m68k-amigaos/clib2/lib/libm020/libb/libm.a $(COMPLEX_FILES)
	cd build/newlib/complex/libm020/libb32 && $(PREFIX_PATH)/bin/m68k-amigaos-ar rcs $(PREFIX_PATH)/m68k-amigaos/clib2/lib/libm020/libb32/libm.a $(COMPLEX_FILES)
	echo "done" >$@	

projects/clib2/LICENSE:
	@mkdir -p projects
	cd projects && git clone -b master --depth 4 https://github.com/bebbo/clib2

# =================================================
# libdebug
# =================================================
CONFIG_LIBDEBUG = --prefix=$(PREFIX_TARGET) --target=m68k-amigaos --host=m68k-amigaos

libdebug: build/libdebug/_done

build/libdebug/_done: build/libdebug/Makefile
	$(MAKE) -C build/libdebug $(LOG)
	cp build/libdebug/libdebug.a $(PREFIX_PATH)/m68k-amigaos/lib/
	echo "done" >$@

build/libdebug/Makefile: build/libnix/_done projects/libdebug/configure $(shell find 2>/dev/null projects/libdebug -not \( -path projects/libdebug/.git -prune \) -type f)
	mkdir -p build/libdebug
	cd build/libdebug && CFLAGS="$(TARGET_C_FLAGS)" $(PWD)/projects/libdebug/configure $(CONFIG_LIBDEBUG) $(LOG)

projects/libdebug/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/libdebug
	touch -t 0001010000 projects/libdebug/configure.ac

# =================================================
# libsdl
# =================================================
CONFIG_LIBSDL12 = PREFX=$(PREFIX_PATH) PREF=$(PREFIX_PATH)

libSDL12: build/libSDL12/_done

build/libSDL12/_done: build/libSDL12/Makefile.bax
	$(MAKE) sdk=ahi $(LOG)
	$(MAKE) sdk=cgx $(LOG)
	cd build/libSDL12 && CFLAGS="$(TARGET_C_FLAGS)" $(MAKE) -f Makefile.bax $(CONFIG_LIBSDL12) $(LOG)
	cp build/libSDL12/libSDL.a $(PREFIX_PATH)/m68k-amigaos/lib/
	mkdir -p $(PREFIX_PATH)/include/GL
	mkdir -p $(PREFIX_PATH)/include/SDL
	rsync -a build/libSDL12/include/GL/*.i $(PREFIX_PATH)/include/GL/
	rsync -a build/libSDL12/include/GL/*.h $(PREFIX_PATH)/include/GL/
	rsync -a build/libSDL12/include/SDL/*.h $(PREFIX_PATH)/include/SDL/
	echo "done" >$@

build/libSDL12/Makefile.bax: build/libnix/_done projects/libSDL12/Makefile.bax $(shell find 2>/dev/null projects/libSDL12 -not \( -path projects/libSDL12/.git -prune \) -type f)
	mkdir -p build/libSDL12
	rsync -a projects/libSDL12/* build/libSDL12
	touch build/libSDL12/Makefile.bax

projects/libSDL12/Makefile.bax:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4  https://github.com/AmigaPorts/libSDL12


# =================================================
# newlib
# =================================================
NEWLIB_CONFIG = CC=m68k-amigaos-gcc
NEWLIB_FILES = $(shell find 2>/dev/null projects/newlib-cygwin/newlib -type f)

.PHONY: newlib
newlib: build/newlib/_done

COMPLEX_FILES = lib_a-cabs.o   lib_a-cacosf.o   lib_a-cacosl.o  lib_a-casin.o    lib_a-casinhl.o  lib_a-catanh.o   lib_a-ccos.o    lib_a-ccoshl.o        lib_a-cephes_subrl.o  lib_a-cimag.o   lib_a-clog10.o   lib_a-conj.o   lib_a-cpowf.o   lib_a-cprojl.o  lib_a-csin.o    lib_a-csinhl.o  lib_a-csqrtl.o  lib_a-ctanhf.o \
	lib_a-cabsf.o  lib_a-cacosh.o   lib_a-carg.o    lib_a-casinf.o   lib_a-casinl.o   lib_a-catanhf.o  lib_a-ccosf.o   lib_a-ccosl.o         lib_a-cexp.o          lib_a-cimagf.o  lib_a-clog10f.o  lib_a-conjf.o  lib_a-cpowl.o   lib_a-creal.o   lib_a-csinf.o   lib_a-csinl.o   lib_a-ctan.o    lib_a-ctanhl.o \
	lib_a-cabsl.o  lib_a-cacoshf.o  lib_a-cargf.o   lib_a-casinh.o   lib_a-catan.o    lib_a-catanhl.o  lib_a-ccosh.o   lib_a-cephes_subr.o   lib_a-cexpf.o         lib_a-cimagl.o  lib_a-clogf.o    lib_a-conjl.o  lib_a-cproj.o   lib_a-crealf.o  lib_a-csinh.o   lib_a-csqrt.o   lib_a-ctanf.o   lib_a-ctanl.o \
	lib_a-cacos.o  lib_a-cacoshl.o  lib_a-cargl.o   lib_a-casinhf.o  lib_a-catanf.o   lib_a-catanl.o   lib_a-ccoshf.o  lib_a-cephes_subrf.o  lib_a-cexpl.o         lib_a-clog.o    lib_a-clogl.o    lib_a-cpow.o   lib_a-cprojf.o  lib_a-creall.o  lib_a-csinhf.o  lib_a-csqrtf.o  lib_a-ctanh.o 

build/newlib/_done: build/newlib/newlib/libc.a 
	echo "done" >$@

build/newlib/newlib/libc.a: build/newlib/newlib/Makefile build/ndk-include/_ndk $(NEWLIB_FILES)
	$(MAKE) -C build/newlib/newlib $(LOG)
	$(MAKE) -C build/newlib/newlib install $(LOG)
	mkdir -p build/newlib/complex
	cd build/newlib/complex && $(PREFIX_PATH)/bin/m68k-amigaos-ar x $(PREFIX_PATH)/m68k-amigaos/lib/libm.a $(COMPLEX_FILES)
	mkdir -p build/newlib/complex/libb
	cd build/newlib/complex/libb && $(PREFIX_PATH)/bin/m68k-amigaos-ar x $(PREFIX_PATH)/m68k-amigaos/lib/libb/libm.a $(COMPLEX_FILES)
	mkdir -p build/newlib/complex/libm020
	cd build/newlib/complex/libm020 && $(PREFIX_PATH)/bin/m68k-amigaos-ar x $(PREFIX_PATH)/m68k-amigaos/lib/libm020/libm.a $(COMPLEX_FILES)
	mkdir -p build/newlib/complex/libm020/libb
	cd build/newlib/complex/libm020/libb && $(PREFIX_PATH)/bin/m68k-amigaos-ar x $(PREFIX_PATH)/m68k-amigaos/lib/libm020/libb/libm.a $(COMPLEX_FILES)
	mkdir -p build/newlib/complex/libm020/libb32
	cd build/newlib/complex/libm020/libb32 && $(PREFIX_PATH)/bin/m68k-amigaos-ar x $(PREFIX_PATH)/m68k-amigaos/lib/libm020/libb32/libm.a $(COMPLEX_FILES)
	touch $@

ifeq (,$(wildcard build/gcc/_done))
build/newlib/newlib/Makefile: build/gcc/_done
endif

build/newlib/newlib/Makefile: projects/newlib-cygwin/configure  
	mkdir -p build/newlib/newlib
	cd build/newlib/newlib && $(NEWLIB_CONFIG) CFLAGS="$(TARGET_C_FLAGS)" ../../../projects/newlib-cygwin/newlib/configure --host=m68k-amigaos --prefix=$(PREFIX_TARGET) $(LOG)

projects/newlib-cygwin/newlib/configure: 
	@mkdir -p projects
	cd projects &&	git clone -b amiga --depth 4  https://github.com/bebbo/newlib-cygwin

# =================================================
# ixemul
# =================================================
projects/ixemul/configure:
	@mkdir -p projects
	cd projects &&	git clone https://github.com/bebbo/ixemul

# =================================================
# sdk installation
# =================================================
.PHONY: sdk all-sdk
sdk: libnix
	@$(PWD)/sdk/install install $(sdk) $(PREFIX_PATH)

SDKS0=$(shell find sdk/*.sdk)
SDKS=$(patsubst sdk/%.sdk,%,$(SDKS0))
.PHONY: $(SDKS)
all-sdk: $(SDKS)

$(SDKS): libnix
	$(MAKE) sdk=$@ $(LOG)

# =================================================
# Copy needed dll files
# =================================================

ifeq ($(BUILD_TARGET),msys)
ifneq ($(findstring MINGW32,$(UNAME_S)),)
MINGW_PATH = /mingw32
else
MINGW_PATH = /mingw64
endif
endif

install-dll: build/_installdll_done

build/_installdll_done: build/newlib/_done
ifeq ($(BUILD_TARGET),msys)
	rsync $(MINGW_PATH)/bin/libwinpthread-1.dll $(PREFIX_PATH)/bin
	rsync $(MINGW_PATH)/bin/libwinpthread-1.dll $(PREFIX_PATH)/libexec/gcc/m68k-elf/$(GCC_VERSION)
	rsync $(MINGW_PATH)/bin/libwinpthread-1.dll $(PREFIX_PATH)/m68k-elf/bin
	rsync $(MINGW_PATH)/bin/libintl-8.dll $(PREFIX_PATH)/bin
	rsync $(MINGW_PATH)/bin/libintl-8.dll $(PREFIX_PATH)/libexec/gcc/m68k-elf/$(GCC_VERSION)
	rsync $(MINGW_PATH)/bin/libintl-8.dll $(PREFIX_PATH)/m68k-elf/bin
	rsync $(MINGW_PATH)/bin/libiconv-2.dll $(PREFIX_PATH)/bin
	rsync $(MINGW_PATH)/bin/libiconv-2.dll $(PREFIX_PATH)/libexec/gcc/m68k-elf/$(GCC_VERSION)
	rsync $(MINGW_PATH)/bin/libiconv-2.dll $(PREFIX_PATH)/m68k-elf/bin
	rsync $(MINGW_PATH)/bin/libgcc_s_dw2-1.dll $(PREFIX_PATH)/bin
	rsync $(MINGW_PATH)/bin/libgcc_s_dw2-1.dll $(PREFIX_PATH)/libexec/gcc/m68k-elf/$(GCC_VERSION)
	rsync $(MINGW_PATH)/bin/libgcc_s_dw2-1.dll $(PREFIX_PATH)/m68k-elf/bin
endif
	echo "done" >$@
	touch $@

# =================================================
# info
# =================================================
.PHONY: info v
info:
	@echo $@ $(UNAME_S)
	@echo CC = $(DETECTED_CC) $(USED_CC_VERSION)
	@echo PREFIX=$(PREFIX)
	@echo GCC_GIT=$(GCC_GIT)
	@echo GCC_BRANCH=$(GCC_BRANCH)
	@echo GCC_VERSION=$(GCC_VERSION)
	@echo CFLAGS=$(CFLAGS)
	@echo TARGET_C_FLAGS=$(TARGET_C_FLAGS)
	@echo BINUTILS_GIT=$(BINUTILS_GIT)
	@echo BINUTILS_BRANCH=$(BINUTILS_BRANCH)

v:
	@for i in projects/* ; do cd $$i 2>/dev/null && echo $$i && (git log -n1 | grep commit) && cd ../..; done
	@echo "." && git log -n1 | grep commit
