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
SHELL = /bin/bash

PREFIX ?= /opt/amiga
export PATH := $(PREFIX)/bin:$(PATH)

UNAME_S := $(shell uname -s)
BUILD := build-$(UNAME_S)
__BUILDDIR := $(shell mkdir -p $(BUILD))
__PROJECTDIR := $(shell mkdir -p projects)
__DOWNLOADDIR := $(shell mkdir -p download)

GCC_VERSION ?= $(shell cat 2>/dev/null projects/gcc/gcc/BASE-VER)

BINUTILS_BRANCH := amiga
GCC_BRANCH := gcc-6-branch
NEWLIB_BRANCH := amiga

GIT_AMIGA_NETINCLUDE := https://github.com/bebbo/amiga-netinclude
GIT_BINUTILS         := https://github.com/bebbo/binutils-gdb
GIT_CLIB2            := https://github.com/bebbo/clib2
GIT_FD2PRAGMA        := https://github.com/bebbo/fd2pragma
GIT_FD2SFD           := https://github.com/cahirwpz/fd2sfd
GIT_GCC              := https://github.com/bebbo/gcc
GIT_IRA              := https://github.com/bebbo/ira
GIT_IXEMUL           := https://github.com/bebbo/ixemul
GIT_LHA              := https://github.com/jca02266/lha
GIT_LIBDEBUG         := https://github.com/bebbo/libdebug
GIT_LIBNIX           := https://github.com/bebbo/libnix
GIT_LIBSDL12         := https://github.com/AmigaPorts/libSDL12
GIT_NEWLIB_CYGWIN    := https://github.com/bebbo/newlib-cygwin
GIT_SFDC             := https://github.com/bebbo/sfdc
GIT_VASM             := https://github.com/mheyer32/vasm
GIT_VBCC             := https://github.com/bebbo/vbcc
GIT_VLINK            := https://github.com/mheyer32/vlink
GIT_AROSSTUFF        := https://github.com/bebbo/aros-stuff

ifeq ($(NDK),3.2)
NDK_URL              := http://aminet.net/dev/misc/NDK3.2R3.lha
NDK_ARC_NAME         := NDK3.2R3
NDK_FOLDER_NAME      := NDK3.2
NDK_FOLDER_NAME_H    := NDK3.2/Include_H
NDK_FOLDER_NAME_I    := NDK3.2/Include_I
NDK_FOLDER_NAME_FD   := NDK3.2/FD
NDK_FOLDER_NAME_SFD  := NDK3.2/SFD
NDK_FOLDER_NAME_LIBS := NDK3.2/lib
else
NDK_URL         := http://www.haage-partner.de/download/AmigaOS/NDK3.9.lha
NDK_ARC_NAME    := NDK39
NDK_FOLDER_NAME := NDK_3.9/Include
NDK_FOLDER_NAME_H    := NDK_3.9/Include/include_h
NDK_FOLDER_NAME_I    := NDK_3.9/Include/include_i
NDK_FOLDER_NAME_FD   := NDK_3.9/Include/fd
NDK_FOLDER_NAME_SFD  := NDK_3.9/Include/sfd
NDK_FOLDER_NAME_LIBS := NDK_3.9/Include/linker_libs
endif

CFLAGS ?= -Os
CXXFLAGS ?= $(CFLAGS)
CFLAGS_FOR_TARGET ?= 
CXXFLAGS_FOR_TARGET ?= $(CFLAGS_FOR_TARGET) -fno-exceptions -fno-rtti

E:=CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" CFLAGS_FOR_BUILD="$(CFLAGS)" CXXFLAGS_FOR_BUILD="$(CXXFLAGS)"  CFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)" CXXFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)"

THREADS ?= no

# =================================================
# determine exe extension for cygwin
$(eval MYMAKE = $(shell which make 2>/dev/null) )
$(eval MYMAKEEXE = $(shell which "$(MYMAKE:%=%.exe)" 2>/dev/null) )
EXEEXT:=$(MYMAKEEXE:%=.exe)

# Files for GMP, MPC and MPFR

GMP := gmp-6.1.2
GMPFILE := $(GMP).tar.bz2
MPC := mpc-1.0.3
MPCFILE := $(MPC).tar.gz
MPFR := mpfr-3.1.6
MPFRFILE := $(MPFR).tar.bz2

# =================================================
# pretty output ^^
# =================================================
TEEEE := >&

ifeq ($(sdk),)
__LINIT := $(shell rm .state 2>/dev/null)
endif

$(eval has_flock = $(shell which flock 2>/dev/null))
ifeq ($(has_flock),)
FLOCK := echo >/dev/null
else
FLOCK := $(has_flock)
endif

L0 = @__p=
L00 = __p=
ifeq ($(verbose),)
L1 = ; ($(FLOCK) 200; echo -e \\033[33m$$__p...\\033[0m >>.state; echo -ne \\033[33m$$__p...\\033[0m ) 200>.lock; mkdir -p log; __l="log/$$__p.log" ; (
L2 = )$(TEEEE) "$$__l"; __r=$$?; ($(FLOCK) 200; if (( $$__r > 0 )); then \
  echo -e \\n\\033[K\\033[31m$$__p...failed\\033[0m; \
   sed -n '1,/\*\*\*/p' "$$__l" | tail -n 100; \
  echo -e \\033[31m$$__p...failed\\033[0m; \
  echo -e use \\033[1mless \"$$__l\"\\033[0m to view the full log and search for \*\*\*; \
  else echo -e \\n\\033[K\\033[32m$$__p...done\\033[0m; fi \
  ;grep -v "$$__p" .state >.state0 2>/dev/null; mv .state0 .state ;echo -n $$(cat .state | paste -sd " " -); ) 200>.lock; [[ $$__r -gt 0 ]] && exit $$__r; echo -n ""
else
L1 = ;
L2 = ;
endif

UPDATE = __x=
ANDPULL = ;__y=$$(git branch | grep '*' | cut -b3-);echo setting remote origin from $$(git remote get-url origin) to $$__x using branch $$__y;\
	git remote remove origin; \
	git remote add origin $$__x; \
	git remote set-branches origin $$__y;\
	git pull

# =================================================

.PHONY: x init
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
	@echo "make help		display this help"
	@echo "make info		print prefix and other flags"
	@echo "make all 		build and install all"
	@echo "make min 		build and install the minimal to use gcc"
	@echo "make <target>		builds a target: binutils, gcc, gprof, fd2sfd, fd2pragma, ira, sfdc, vasm, vbcc, vlink, libnix, ixemul, libgcc, clib2, libdebug, libSDL12, libpthread, ndk, ndk13"
	@echo "make clean		remove the build folder"
	@echo "make clean-<target>	remove the target's build folder"
	@echo "make clean-prefix	remove all content from the prefix folder"
	@echo "make update		perform git pull for all targets"
	@echo "make update-<target>	perform git pull for the given target"
	@echo "make sdk=<sdk>		install the sdk <sdk>"
	@echo "make all-sdk		install all sdks"
	@echo "make info		display some info"
	@echo "make l   		print the last log entry for each project"
	@echo "make b   		print the branch for each project"
	@echo "make r   		print the remote for each project"
	@echo "make v date=<date>	checkout all projects for a given date"
	@echo ""
	@echo "the optional parameter THREADS=posix will build it with thread support"

# =================================================
# all
# =================================================
.PHONY: all gcc gdb gprof binutils fd2sfd fd2pragma ira sfdc vasm vbcc vlink libnix ixemul libgcc clib2 libdebug libSDL12 libpthread ndk ndk13 min
all: gcc binutils gdb gprof fd2sfd fd2pragma ira sfdc vbcc vasm vlink libnix ixemul libgcc clib2 libdebug libpthread libSDL12 ndk ndk13

min: binutils gcc gdb gprof libnix libgcc

# =================================================
# clean
# =================================================
ifneq ($(OWNMPC),)
.PHONY: clean-gmp clean-mpc clean-mpfr
clean: clean-gmp clean-mpc clean-mpfr
endif

.PHONY: clean-prefix clean clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vasm clean-vbcc clean-vlink clean-libnix clean-ixemul clean-libgcc clean-clib2 clean-libdebug clean-libSDL12 clean-libpthread clean-newlib clean-ndk
clean: clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vasm clean-vbcc clean-vlink clean-libnix clean-ixemul clean-clib2 clean-libdebug clean-libSDL12 clean-libpthread clean-newlib clean-ndk clean-gmp clean-mpc clean-mpfr
	rm -rf $(BUILD)
	rm -rf *.log
	mkdir -p $(BUILD)

clean-gcc:
	rm -rf $(BUILD)/gcc

clean-gmp:
	rm -rf projects/gcc/gmp

clean-mpc:
	rm -rf projects/gcc/mpc

clean-mpfr:
	rm -rf projects/gcc/mpfr

clean-libgcc:
	rm -rf $(BUILD)/gcc/m68k-amigaos
	rm -rf $(BUILD)/gcc/_libgcc_done

clean-binutils:
	rm -rf $(BUILD)/binutils

clean-gprof:
	rm -rf $(BUILD)/binutils/gprof

clean-fd2sfd:
	rm -rf $(BUILD)/fd2sfd

clean-fd2pragma:
	rm -rf $(BUILD)/fd2pragma

clean-ira:
	rm -rf $(BUILD)/ira

clean-sfdc:
	rm -rf $(BUILD)/sfdc

clean-vasm:
	rm -rf $(BUILD)/vasm

clean-vbcc:
	rm -rf $(BUILD)/vbcc

clean-vlink:
	rm -rf $(BUILD)/vlink

clean-ndk:
	rm -rf $(BUILD)/ndk*

clean-libnix:
	rm -rf $(BUILD)/libnix

clean-ixemul:
	rm -rf $(BUILD)/ixemul

clean-clib2:
	rm -rf $(BUILD)/clib2

clean-libdebug:
	rm -rf $(BUILD)/libdebug

clean-libSDL12:
	rm -rf $(BUILD)/libSDL12

clean-libpthread:
	rm -rf $(BUILD)/libpthread

clean-newlib:
	rm -rf $(BUILD)/newlib

# clean-prefix drops the files from prefix folder
clean-prefix:
	rm -rf $(PREFIX)/bin
	rm -rf $(PREFIX)/etc
	rm -rf $(PREFIX)/info
	rm -rf $(PREFIX)/libexec
	rm -rf $(PREFIX)/lib/gcc
	rm -rf $(PREFIX)/m68k-amigaos
	rm -rf $(PREFIX)/man
	rm -rf $(PREFIX)/share
	@mkdir -p $(PREFIX)/bin

# =================================================
# update all projects
# =================================================

.PHONY: update update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vasm update-vbcc update-vlink update-libnix update-ixemul update-clib2 update-libdebug update-libSDL12 update-libpthread update-ndk update-newlib update-netinclude
update: update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vasm update-vbcc update-vlink update-libnix update-ixemul update-clib2 update-libdebug update-libSDL12 update-libpthread update-ndk update-newlib update-netinclude

update-gcc: projects/gcc/configure
	@cd projects/gcc && git pull || (export DEPTH=16; while true; do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH && break; export DEPTH=$$(($$DEPTH+$$DEPTH));done)

update-binutils: projects/binutils/configure
	@cd projects/binutils && git pull || (export DEPTH=16; while true; do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH && break; export DEPTH=$$(($$DEPTH+$$DEPTH));done)

update-fd2sfd: projects/fd2sfd/configure
	@cd projects/fd2sfd && git pull

update-fd2pragma: projects/fd2pragma/makefile
	@cd projects/fd2pragma && git pull

update-ira: projects/ira/Makefile
	@cd projects/ira && git pull

update-sfdc: projects/sfdc/configure
	@cd projects/sfdc && git pull

update-vasm: projects/vasm/Makefile
	@cd projects/vasm && git pull

update-vbcc: projects/vbcc/Makefile
	@cd projects/vbcc && git pull

update-vlink: projects/vlink/Makefile
	@cd projects/vlink && git pull

update-libnix: projects/libnix/Makefile.gcc6
	@cd projects/libnix && git pull

update-ixemul: projects/ixemul/configure
	@cd projects/ixemul && git pull

update-clib2: projects/clib2/LICENSE
	@cd projects/clib2 && git pull

update-libdebug: projects/libdebug/configure
	@cd projects/libdebug && git pull

update-libSDL12: projects/libSDL12/Makefile
	@cd projects/libSDL12 && git pull

update-libpthread: projects/aros-stuff/pthreads/Makefile
	@cd projects/aros-stuff && git pull

update-ndk: download/$(NDK_ARC_NAME).lha
	make projects/$(NDK_FOLDER_NAME).info

update-newlib: projects/newlib-cygwin/newlib/configure
	@cd projects/newlib-cygwin && git pull

update-netinclude: projects/amiga-netinclude/README.md
	@cd projects/amiga-netinclude && git pull

update-gmp:
	if [ -a download/$(GMPFILE) ]; \
	then rm -rf projects/$(GMP); rm -rf projects/gcc/gmp; \
	else cd download && wget ftp://ftp.gnu.org/gnu/gmp/$(GMPFILE); \
	fi;
	@cd projects && tar xf ../download/$(GMPFILE)

update-mpc:
	if [ -a download/$(MPCFILE) ]; \
	then rm -rf projcts/$(MPC); rm -rf projects/gcc/mpc; \
	else cd download && wget ftp://ftp.gnu.org/gnu/mpc/$(MPCFILE); \
	fi;
	@cd projects && tar xf ../download/$(MPCFILE)

update-mpfr:
	if [ -a download/$(MPFRFILE) ]; \
	then rm -rf projects/$(MPFR); rm -rf projects/gcc/mpfr; \
	else cd download && wget ftp://ftp.gnu.org/gnu/mpfr/$(MPFRFILE); \
	fi;
	@cd projects && tar xf ../download/$(MPFRFILE)

# =================================================
# B I N
# =================================================

# =================================================
# binutils
# =================================================
CONFIG_BINUTILS :=--prefix=$(PREFIX) --target=m68k-amigaos --disable-plugins --disable-werror --enable-tui --disable-nls
BINUTILS_CMD := m68k-amigaos-addr2line m68k-amigaos-ar m68k-amigaos-as m68k-amigaos-c++filt \
	m68k-amigaos-ld m68k-amigaos-nm m68k-amigaos-objcopy m68k-amigaos-objdump m68k-amigaos-ranlib \
	m68k-amigaos-readelf m68k-amigaos-size m68k-amigaos-strings m68k-amigaos-strip
BINUTILS := $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(BINUTILS_CMD))

BINUTILS_DIR := . bfd gas ld binutils opcodes
BINUTILSD := $(patsubst %,projects/binutils/%, $(BINUTILS_DIR))

ALL_GDB := all-gdb
INSTALL_GDB := install-gdb

binutils: $(BUILD)/binutils/_done

$(BUILD)/binutils/_done: $(BUILD)/binutils/Makefile $(shell find 2>/dev/null projects/binutils -not \( -path projects/binutils/.git -prune \) -not \( -path projects/binutils/gprof -prune \) -type f)
	@touch -t 0001010000 projects/binutils/binutils/arparse.y
	@touch -t 0001010000 projects/binutils/binutils/arlex.l
	@touch -t 0001010000 projects/binutils/ld/ldgram.y
	@touch -t 0001010000 projects/binutils/intl/plural.y
	$(L0)"make binutils bfd"$(L1)$(MAKE) -C $(BUILD)/binutils all-bfd $(L2)
	$(L0)"make binutils gas"$(L1)$(MAKE) -C $(BUILD)/binutils all-gas $(L2)
	$(L0)"make binutils binutils"$(L1)$(MAKE) -C $(BUILD)/binutils all-binutils $(L2)
	$(L0)"make binutils ld"$(L1)$(MAKE) -C $(BUILD)/binutils all-ld $(L2)
	$(L0)"install binutils"$(L1)$(MAKE) -C $(BUILD)/binutils install-gas install-binutils install-ld $(L2)
	@echo "done" >$@

$(BUILD)/binutils/Makefile: projects/binutils/configure
	@mkdir -p $(BUILD)/binutils
	$(L0)"configure binutils"$(L1) cd $(BUILD)/binutils && $(E) $(PWD)/projects/binutils/configure $(CONFIG_BINUTILS) $(L2)


projects/binutils/configure:
	@cd projects &&	git clone -b $(BINUTILS_BRANCH) --depth 16 $(GIT_BINUTILS) binutils

# =================================================
# gdb
# =================================================

gdb: $(BUILD)/binutils/_gdb

$(BUILD)/binutils/_gdb: $(BUILD)/binutils/_done
	$(L0)"make binutils configure gdb"$(L1)$(MAKE) -C $(BUILD)/binutils configure-gdb $(L2)
	$(L0)"make binutils gdb libs"$(L1)$(MAKE) -C $(BUILD)/binutils/gdb all-lib $(L2)
	$(L0)"make binutils gdb"$(L1)$(MAKE) -C $(BUILD)/binutils $(ALL_GDB) $(L2)
	$(L0)"install binutils gdb"$(L1)$(MAKE) -C $(BUILD)/binutils install-gas install-binutils install-ld $(INSTALL_GDB) $(L2)
	@echo "done" >$@

	
# =================================================
# gprof
# =================================================
CONFIG_GRPOF := --prefix=$(PREFIX) --target=m68k-amigaos --disable-werror

gprof: $(BUILD)/binutils/_gprof

$(BUILD)/binutils/_gprof: $(BUILD)/binutils/gprof/Makefile $(shell find 2>/dev/null projects/binutils/gprof -type f)
	$(L0)"make gprof"$(L1)$(MAKE) -C $(BUILD)/binutils/gprof all $(L2)
	$(L0)"install gprof"$(L1)$(MAKE) -C $(BUILD)/binutils/gprof install $(L2)
	@echo "done" >$@

$(BUILD)/binutils/gprof/Makefile: projects/binutils/configure $(BUILD)/binutils/_done
	@mkdir -p $(BUILD)/binutils/gprof
	$(L0)"configure gprof"$(L1) cd $(BUILD)/binutils/gprof && $(E) $(PWD)/projects/binutils/gprof/configure $(CONFIG_GRPOF) $(L2)

# =================================================
# gcc
# =================================================
CONFIG_GCC = --prefix=$(PREFIX) --target=m68k-amigaos --enable-languages=c,c++,objc --enable-version-specific-runtime-libs --disable-libssp --disable-nls \
	--with-headers=$(PWD)/projects/newlib-cygwin/newlib/libc/sys/amigaos/include/ --disable-shared --enable-threads=$(THREADS) \
	--with-stage1-ldflags="-dynamic-libgcc -dynamic-libstdc++" --with-boot-ldflags="-dynamic-libgcc -dynamic-libstdc++"	

# OSX : libs added by the command brew install gmp mpfr libmpc
ifeq (Darwin, $(findstring Darwin, $(UNAME_S)))
	CONFIG_GCC += --with-gmp-include=/usr/local/include --with-gmp-lib=/usr/local/lib --with-mpfr-include=/usr/local/include --with-mpfr-lib=/usr/local/lib --with-mpfr-include=/usr/local/include --with-mpfr-lib=/usr/local/lib
endif


GCC_CMD := m68k-amigaos-c++ m68k-amigaos-g++ m68k-amigaos-gcc-$(GCC_VERSION) m68k-amigaos-gcc-nm \
	m68k-amigaos-gcov m68k-amigaos-gcov-tool m68k-amigaos-cpp m68k-amigaos-gcc m68k-amigaos-gcc-ar \
	m68k-amigaos-gcc-ranlib m68k-amigaos-gcov-dump
GCC := $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(GCC_CMD))

GCC_DIR := . gcc gcc/c gcc/c-family gcc/cp gcc/objc gcc/config/m68k libiberty libcpp libdecnumber
GCCD := $(patsubst %,projects/gcc/%, $(GCC_DIR))

gcc: $(BUILD)/gcc/_done

$(BUILD)/gcc/_done: $(BUILD)/gcc/Makefile $(shell find 2>/dev/null $(GCCD) -maxdepth 1 -type f )
	$(L0)"make gcc"$(L1) $(MAKE) -C $(BUILD)/gcc all-gcc $(L2)
	$(L0)"install gcc"$(L1) $(MAKE) -C $(BUILD)/gcc install-gcc $(L2)
	@echo "done" >$@

$(BUILD)/gcc/Makefile: projects/gcc/configure $(BUILD)/binutils/_done
	@mkdir -p $(BUILD)/gcc
ifneq ($(OWNGMP),)
	@mkdir -p projects/gcc/gmp
	@mkdir -p projects/gcc/mpc
	@mkdir -p projects/gcc/mpfr
	@rsync -a projects/$(GMP)/* projects/gcc/gmp
	@rsync -a projects/$(MPC)/* projects/gcc/mpc
	@rsync -a projects/$(MPFR)/* projects/gcc/mpfr
endif
	$(L0)"configure gcc"$(L1) cd $(BUILD)/gcc && $(E) $(PWD)/projects/gcc/configure $(CONFIG_GCC) $(L2)

projects/gcc/configure:
	@cd projects &&	git clone -b $(GCC_BRANCH) --depth 16 $(GIT_GCC)

# =================================================
# fd2sfd
# =================================================
CONFIG_FD2SFD := --prefix=$(PREFIX) --target=m68k-amigaos

fd2sfd: $(BUILD)/fd2sfd/_done

$(BUILD)/fd2sfd/_done: $(PREFIX)/bin/fd2sfd
	@echo "done" >$@

$(PREFIX)/bin/fd2sfd: $(BUILD)/fd2sfd/Makefile $(shell find 2>/dev/null projects/fd2sfd -not \( -path projects/fd2sfd/.git -prune \) -type f)
	$(L0)"make fd2sfd"$(L1) $(MAKE) -C $(BUILD)/fd2sfd all $(L2)
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install fd2sfd"$(L1) $(MAKE) -C $(BUILD)/fd2sfd install $(L2)

$(BUILD)/fd2sfd/Makefile: projects/fd2sfd/configure
	@mkdir -p $(BUILD)/fd2sfd
	$(L0)"configure fd2sfd"$(L1) cd $(BUILD)/fd2sfd && $(E) $(PWD)/projects/fd2sfd/configure $(CONFIG_FD2SFD) $(L2)

projects/fd2sfd/configure:
	@cd projects &&	git clone -b master --depth 4 $(GIT_FD2SFD)
	for i in $$(find patches/fd2sfd/ -type f); \
	do if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "projects/$${j%.diff}" "$$i"; fi ; done

# =================================================
# fd2pragma
# =================================================
fd2pragma: $(BUILD)/fd2pragma/_done

$(BUILD)/fd2pragma/_done: $(PREFIX)/bin/fd2pragma
	@echo "done" >$@

$(PREFIX)/bin/fd2pragma: $(BUILD)/fd2pragma/fd2pragma
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install fd2sfd"$(L1) install $(BUILD)/fd2pragma/fd2pragma $(PREFIX)/bin/ $(L2)

$(BUILD)/fd2pragma/fd2pragma: projects/fd2pragma/makefile $(shell find 2>/dev/null projects/fd2pragma -not \( -path projects/fd2pragma/.git -prune \) -type f)
	@mkdir -p $(BUILD)/fd2pragma
	$(L0)"make fd2sfd"$(L1) cd projects/fd2pragma && $(CC) -o $(PWD)/$@ $(CFLAGS) fd2pragma.c $(L2)

projects/fd2pragma/makefile:
	@cd projects &&	git clone -b master --depth 4 $(GIT_FD2PRAGMA)

# =================================================
# ira
# =================================================
ira: $(BUILD)/ira/_done

$(BUILD)/ira/_done: $(PREFIX)/bin/ira
	@echo "done" >$@

$(PREFIX)/bin/ira: $(BUILD)/ira/ira
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install ira"$(L1) install $(BUILD)/ira/ira $(PREFIX)/bin/ $(L2)

$(BUILD)/ira/ira: projects/ira/Makefile $(shell find 2>/dev/null projects/ira -not \( -path projects/ira/.git -prune \) -type f)
	@mkdir -p $(BUILD)/ira
	$(L0)"make ira"$(L1) cd projects/ira && $(CC) -o $(PWD)/$@ $(CFLAGS) *.c -std=c99 $(L2)

projects/ira/Makefile:
	@cd projects &&	git clone -b master --depth 4 $(GIT_IRA)

# =================================================
# sfdc
# =================================================
CONFIG_SFDC := --prefix=$(PREFIX) --target=m68k-amigaos

sfdc: $(BUILD)/sfdc/_done

$(BUILD)/sfdc/_done: $(PREFIX)/bin/sfdc
	@echo "done" >$@

$(PREFIX)/bin/sfdc: $(BUILD)/sfdc/Makefile
	$(L0)"make sfdc"$(L1) $(MAKE) -C $(BUILD)/sfdc sfdc $(L2)
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install sfdc"$(L1) install $(BUILD)/sfdc/sfdc $(PREFIX)/bin $(L2)

$(BUILD)/sfdc/Makefile: projects/sfdc/configure $(shell find 2>/dev/null projects/sfdc -not \( -path projects/sfdc/.git -prune \)  -type f)
	@rsync -a projects/sfdc $(BUILD)/ --exclude .git
	$(L0)"configure sfdc"$(L1) cd $(BUILD)/sfdc && $(E) $(PWD)/$(BUILD)/sfdc/configure $(CONFIG_SFDC) $(L2)

projects/sfdc/configure:
	@cd projects &&	git clone -b master --depth 4 $(GIT_SFDC)
	for i in $$(find patches/sfdc/ -type f); \
	do if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "projects/$${j%.diff}" "$$i"; fi ; done

# =================================================
# vasm
# =================================================
VASM_CMD := vasmm68k_mot
VASM := $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VASM_CMD))

vasm: $(BUILD)/vasm/_done

$(BUILD)/vasm/_done: $(BUILD)/vasm/Makefile
	$(L0)"make vasm"$(L1) $(MAKE) -C $(BUILD)/vasm CPU=m68k SYNTAX=mot $(L2)
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install vasm"$(L1) install $(BUILD)/vasm/vasmm68k_mot $(PREFIX)/bin/ ;\
	install $(BUILD)/vasm/vobjdump $(PREFIX)/bin/ $(L2)
	@echo "done" >$@

$(BUILD)/vasm/Makefile: projects/vasm/Makefile $(shell find 2>/dev/null projects/vasm -not \( -path projects/vasm/.git -prune \) -type f)
	@rsync -a projects/vasm $(BUILD)/ --exclude .git
	@touch $(BUILD)/vasm/Makefile

projects/vasm/Makefile:
	@cd projects &&	git clone -b master --depth 4 $(GIT_VASM)

# =================================================
# vbcc
# =================================================
VBCC_CMD := vbccm68k vprof vc
VBCC := $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VBCC_CMD))

vbcc: $(BUILD)/vbcc/_done

$(BUILD)/vbcc/_done: $(BUILD)/vbcc/Makefile
	$(L0)"make vbcc dtgen"$(L1) TARGET=m68k $(MAKE) -C $(BUILD)/vbcc bin/dtgen $(L2)
	@cd $(BUILD)/vbcc && echo -e "y\\ny\\nsigned char\\ny\\nunsigned char\\nn\\ny\\nsigned short\\nn\\ny\\nunsigned short\\nn\\ny\\nsigned int\\nn\\ny\\nunsigned int\\nn\\ny\\nsigned long long\\nn\\ny\\nunsigned long long\\nn\\ny\\nfloat\\nn\\ny\\ndouble\\n" >c.txt
	$(L0)"run vbcc dtgen"$(L1) cd $(BUILD)/vbcc && bin/dtgen machines/m68k/machine.dt machines/m68k/dt.h machines/m68k/dt.c <c.txt $(L2)
	$(L0)"make vbcc"$(L1) TARGET=m68k $(MAKE) -C $(BUILD)/vbcc $(L2)
	@mkdir -p $(PREFIX)/bin/
	@rm -rf $(BUILD)/vbcc/bin/*.dSYM
	$(L0)"install vbcc"$(L1) install $(BUILD)/vbcc/bin/v* $(PREFIX)/bin/ $(L2)
	@echo "done" >$@

$(BUILD)/vbcc/Makefile: projects/vbcc/Makefile $(shell find 2>/dev/null projects/vbcc -not \( -path projects/vbcc/.git -prune \) -type f)
	@rsync -a projects/vbcc $(BUILD)/ --exclude .git
	@mkdir -p $(BUILD)/vbcc/bin
	@touch $(BUILD)/vbcc/Makefile

projects/vbcc/Makefile:
	@cd projects &&	git clone -b master --depth 4 $(GIT_VBCC)

# =================================================
# vlink
# =================================================
VLINK_CMD := vlink
VLINK := $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VLINK_CMD))

vlink: $(BUILD)/vlink/_done vbcc-target

$(BUILD)/vlink/_done: $(BUILD)/vlink/Makefile $(shell find 2>/dev/null projects/vlink -not \( -path projects/vlink/.git -prune \) -type f)
	$(L0)"make vlink"$(L1) cd $(BUILD)/vlink && TARGET=m68k $(MAKE) $(L2)
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install vlink"$(L1) install $(BUILD)/vlink/vlink $(PREFIX)/bin/ $(L2)
	@echo "done" >$@

$(BUILD)/vlink/Makefile: projects/vlink/Makefile
	@rsync -a projects/vlink $(BUILD)/ --exclude .git

projects/vlink/Makefile:
	@cd projects &&	git clone -b master --depth 4 $(GIT_VLINK)

.PHONY: lha
lha: $(BUILD)/_lha_done

$(BUILD)/_lha_done:
	@if [ ! -e "$$(which lha 2>/dev/null)" ]; then \
	  cd $(BUILD) && rm -rf lha; \
	  $(L00)"clone lha"$(L1) git clone $(GIT_LHA); $(L2); \
	  cd lha; \
	  $(L00)"configure lha"$(L1) aclocal; autoheader; automake -a; autoconf; ./configure; $(L2); \
	  $(L00)"make lha"$(L1) make all; $(L2); \
	  $(L00)"install lha"$(L1) mkdir -p $(PREFIX)/bin/; install src/lha$(EXEEXT) $(PREFIX)/bin/lha$(EXEEXT); $(L2); \
	fi
	@echo "done" >$@


.PHONY: vbcc-target
vbcc-target: $(BUILD)/vbcc_target_m68k-amigaos/_done

$(BUILD)/vbcc_target_m68k-amigaos/_done: $(BUILD)/vbcc_target_m68k-amigaos.info patches/vc.config $(BUILD)/vasm/_done
	@mkdir -p $(PREFIX)/m68k-amigaos/vbcc/include
	$(L0)"copying vbcc headers"$(L1) rsync $(BUILD)/vbcc_target_m68k-amigaos/targets/m68k-amigaos/include/* $(PREFIX)/m68k-amigaos/vbcc/include $(L2)
	@mkdir -p $(PREFIX)/m68k-amigaos/vbcc/lib
	$(L0)"copying vbcc headers"$(L1) rsync $(BUILD)/vbcc_target_m68k-amigaos/targets/m68k-amigaos/lib/* $(PREFIX)/m68k-amigaos/vbcc/lib $(L2)
	@echo "done" >$@
	$(L0)"creating vbcc config"$(L1) sed -e "s|PREFIX|$(PREFIX)|g" patches/vc.config >$(BUILD)/vasm/vc.config ;\
	install $(BUILD)/vasm/vc.config $(PREFIX)/bin/ $(L2)


$(BUILD)/vbcc_target_m68k-amigaos.info: download/vbcc_target_m68k-amigaos.lha $(BUILD)/_lha_done
	$(L0)"unpack vbcc_target_m68k-amigaos"$(L1) cd $(BUILD) && lha xf ../download/vbcc_target_m68k-amigaos.lha $(L2)
	@touch $(BUILD)/vbcc_target_m68k-amigaos.info

download/vbcc_target_m68k-amigaos.lha:
	$(L0)"downloading vbcc_target"$(L1) cd download && wget http://aminet.net/dev/c/vbcc_target_m68k-amiga.lha -O vbcc_target_m68k-amigaos.lha $(L2)

# =================================================
# L I B R A R I E S
# =================================================
# =================================================
# NDK - no git
# =================================================

NDK_INCLUDE = $(shell find 2>/dev/null projects/$(NDK_FOLDER_NAME_H) -type f)
NDK_INCLUDE_SFD = $(shell find 2>/dev/null projects/$(NDK_FOLDER_NAME_SFD) -type f -name *.sfd)
NDK_INCLUDE_INLINE = $(patsubst projects/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$(PREFIX)/m68k-amigaos/ndk-include/inline/%.h,$(NDK_INCLUDE_SFD))
NDK_INCLUDE_LVO    = $(patsubst projects/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$(PREFIX)/m68k-amigaos/ndk-include/lvo/%_lib.i,$(NDK_INCLUDE_SFD))
NDK_INCLUDE_PROTO  = $(patsubst projects/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$(PREFIX)/m68k-amigaos/ndk-include/proto/%.h,$(NDK_INCLUDE_SFD))
SYS_INCLUDE2 = $(filter-out $(NDK_INCLUDE_PROTO),$(patsubst projects/$(NDK_FOLDER_NAME_H)/%,$(PREFIX)/m68k-amigaos/ndk-include/%, $(NDK_INCLUDE)))

.PHONY: ndk-inline ndk-lvo ndk-proto

ndk: $(BUILD)/ndk-include_ndk

$(BUILD)/ndk-include_ndk: $(BUILD)/ndk-include_ndk0 $(NDK_INCLUDE_INLINE) $(NDK_INCLUDE_LVO) $(NDK_INCLUDE_PROTO) projects/fd2sfd/configure projects/fd2pragma/makefile
	$(MAKE) ndk_inc=1 ndk-proto ndk-lvo ndk-inline
	@mkdir -p $(BUILD)/ndk-include/
	@echo "done" >$@

$(BUILD)/ndk-include_ndk0: projects/$(NDK_FOLDER_NAME).info $(NDK_INCLUDE) $(BUILD)/fd2sfd/_done $(BUILD)/fd2pragma/_done
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk-include
	@rsync -a $(PWD)/projects/$(NDK_FOLDER_NAME_H)/* $(PREFIX)/m68k-amigaos/ndk-include --exclude proto --exclude inline
	$(L0)"STDARGing ndk"$(L1) for i in $$(find $(PREFIX)/m68k-amigaos/ndk-include/clib/*protos.h -type f); do \
		echo $$i; \
		LC_CTYPE=C sed -i.bak -E 's/([a-zA-Z0-9 _]*)([[:blank:]]+|\*)([a-zA-Z0-9_]+)\(/\1\2 __stdargs \3(/g' $$i; \
		rm $$i.bak; done $(L2)	
	@rsync -a $(PWD)/projects/$(NDK_FOLDER_NAME_I)/* $(PREFIX)/m68k-amigaos/ndk-include
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk/lib/fd
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk/lib/sfd
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk/lib/libs
	@rsync -a $(PWD)/projects/$(NDK_FOLDER_NAME_FD)/* $(PREFIX)/m68k-amigaos/ndk/lib/fd
	@rsync -a $(PWD)/projects/$(NDK_FOLDER_NAME_SFD)/* $(PREFIX)/m68k-amigaos/ndk/lib/sfd
	@rsync -a $(PWD)/projects/$(NDK_FOLDER_NAME_LIBS)/* $(PREFIX)/m68k-amigaos/ndk/lib/libs
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk-include/proto
	@cp -p projects/$(NDK_FOLDER_NAME_H)/proto/alib.h $(PREFIX)/m68k-amigaos/ndk-include/proto
	@cp -p projects/$(NDK_FOLDER_NAME_H)/proto/cardres.h $(PREFIX)/m68k-amigaos/ndk-include/proto
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk-include/inline
	@cp -p projects/fd2sfd/cross/share/m68k-amigaos/alib.h $(PREFIX)/m68k-amigaos/ndk-include/inline
	@cp -p projects/fd2pragma/Include/inline/stubs.h $(PREFIX)/m68k-amigaos/ndk-include/inline
	@cp -p projects/fd2pragma/Include/inline/macros.h $(PREFIX)/m68k-amigaos/ndk-include/inline
	@mkdir -p $(BUILD)/ndk-include/
	@echo "done" >$@

ndk-inline: $(NDK_INCLUDE_INLINE) sfdc $(BUILD)/ndk-include_inline
$(NDK_INCLUDE_INLINE): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD) $(BUILD)/ndk-include_inline $(BUILD)/ndk-include_lvo $(BUILD)/ndk-include_proto $(BUILD)/ndk-include_ndk0
	$(L0)"sfdc inline $(@F)"$(L1) sfdc --target=m68k-amigaos --mode=macros --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/ndk-include/inline/%.h,projects/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$@) $(L2)

ndk-lvo: $(NDK_INCLUDE_LVO) sfdc
$(NDK_INCLUDE_LVO): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD) $(BUILD)/ndk-include_lvo $(BUILD)/ndk-include_ndk0
	$(L0)"sfdc lvo $(@F)"$(L1) sfdc --target=m68k-amigaos --mode=lvo --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/ndk-include/lvo/%_lib.i,projects/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$@) $(L2)

ndk-proto: $(NDK_INCLUDE_PROTO) sfdc
$(NDK_INCLUDE_PROTO): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD)	$(BUILD)/ndk-include_proto $(BUILD)/ndk-include_ndk0
	$(L0)"sfdc proto $(@F)"$(L1) sfdc --target=m68k-amigaos --mode=proto --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/ndk-include/proto/%.h,projects/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$@) $(L2)

$(BUILD)/ndk-include_inline: projects/$(NDK_FOLDER_NAME).info
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk-include/inline
	@mkdir -p $(BUILD)/ndk-include/
	@echo "done" >$@

$(BUILD)/ndk-include_lvo: projects/$(NDK_FOLDER_NAME).info
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk-include/lvo
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk13-include/lvo
	@mkdir -p $(BUILD)/ndk-include/
	@echo "done" >$@

$(BUILD)/ndk-include_proto: projects/$(NDK_FOLDER_NAME).info
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk-include/proto
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk13-include/proto
	@mkdir -p $(BUILD)/ndk-include/
	@echo "done" >$@

projects/$(NDK_FOLDER_NAME).info: $(BUILD)/_lha_done download/$(NDK_ARC_NAME).lha $(shell find 2>/dev/null patches/$(NDK_FOLDER_NAME)/ -type f)
	$(L0)"unpack ndk"$(L1) cd projects && lha xf ../download/$(NDK_ARC_NAME).lha $(L2)
	@touch -t 0001010000 download/$(NDK_ARC_NAME).lha
	$(L0)"patch ndk"$(L1) for i in $$(find patches/$(NDK_FOLDER_NAME)/ -type f); do \
	   if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "projects/$${j%.diff}" "$$i"; \
		else cp -pv "$$i" "projects/$${i:8}"; fi ; done $(L2)
	@touch projects/$(NDK_FOLDER_NAME).info

download/$(NDK_ARC_NAME).lha:
	@cd download && wget $(NDK_URL)


# =================================================
# NDK1.3 - emulated from NDK
# =================================================
.PHONY: ndk_13
ndk13: $(BUILD)/ndk-include_ndk13

$(BUILD)/ndk-include_ndk13: $(BUILD)/ndk-include_ndk $(BUILD)/fd2sfd/_done $(BUILD)/sfdc/_done
	@while read p; do p=$$(echo $$p|tr -d '\n'); mkdir -p $(PREFIX)/m68k-amigaos/ndk13-include/$$(dirname $$p); cp $(PREFIX)/m68k-amigaos/ndk-include/$$p $(PREFIX)/m68k-amigaos/ndk13-include/$$p; done < patches/ndk13/hfiles
	$(L0)"extract ndk13"$(L1) while read p; do p=$$(echo $$p|tr -d '\n'); \
	  mkdir -p $(PREFIX)/m68k-amigaos/ndk13-include/$$(dirname $$p); \
	  if grep V36 $(PREFIX)/m68k-amigaos/ndk-include/$$p; then \
	  LC_CTYPE=C sed -n -e '/#ifndef[[:space:]]*CLIB/,/V36/p' $(PREFIX)/m68k-amigaos/ndk-include/$$p | sed -e 's/__stdargs//g' >$(PREFIX)/m68k-amigaos/ndk13-include/$$p; \
	  echo -e "#ifdef __cplusplus\n}\n#endif /* __cplusplus */\n#endif" >>$(PREFIX)/m68k-amigaos/ndk13-include/$$p; \
	  else cp $(PREFIX)/m68k-amigaos/ndk-include/$$p $(PREFIX)/m68k-amigaos/ndk13-include/$$p; fi \
	done < patches/ndk13/chfiles $(L2)
	@while read p; do p=$$(echo $$p|tr -d '\n'); mkdir -p $(PREFIX)/m68k-amigaos/ndk13-include/$$(dirname $$p); echo "" >$(PREFIX)/m68k-amigaos/ndk13-include/$$p; done < patches/ndk13/ehfiles
	@echo '#undef	EXECNAME' > $(PREFIX)/m68k-amigaos/ndk13-include/exec/execname.h
	@echo '#define	EXECNAME	"exec.library"' >> $(PREFIX)/m68k-amigaos/ndk13-include/exec/execname.h
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk/lib/fd13
	@while read p; do p=$$(echo $$p|tr -d '\n'); LC_CTYPE=C sed -n -e '/##base/,/V36/P'  $(PREFIX)/m68k-amigaos/ndk/lib/fd/$$p >$(PREFIX)/m68k-amigaos/ndk/lib/fd13/$$p; done < patches/ndk13/fdfiles
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk/lib/sfd13
	@for i in $(PREFIX)/m68k-amigaos/ndk/lib/fd13/*; do fd2sfd $$i $(PREFIX)/m68k-amigaos/ndk13-include/clib/$$(basename $$i _lib.fd)_protos.h > $(PREFIX)/m68k-amigaos/ndk/lib/sfd13/$$(basename $$i .fd).sfd; done
	$(L0)"macros+protos ndk13"$(L1) for i in $(PREFIX)/m68k-amigaos/ndk/lib/sfd13/*; do \
	  sfdc --target=m68k-amigaos --mode=macros --output=$(PREFIX)/m68k-amigaos/ndk13-include/inline/$$(basename $$i _lib.sfd).h $$i; \
	  sfdc --target=m68k-amigaos --mode=proto --output=$(PREFIX)/m68k-amigaos/ndk13-include/proto/$$(basename $$i _lib.sfd).h $$i; \
	done $(L2)
	$(L0)"STDARGing ndk13"$(L1) for i in $$(find $(PREFIX)/m68k-amigaos/ndk13-include/clib/*protos.h -type f); do \
	echo $$i; \
	LC_CTYPE=C sed -i.bak -E 's/([a-zA-Z0-9 _]*)([[:blank:]]+|\*)([a-zA-Z0-9_]+)\(/\1\2 __stdargs \3(/g' $$i; \
	rm $$i.bak; done $(L2)	
	@echo "done" >$@

# =================================================
# netinclude
# =================================================
.PHONY: netinclude
netinclude: $(BUILD)/_netinclude

$(BUILD)/_netinclude: projects/amiga-netinclude/README.md $(BUILD)/ndk-include_ndk $(shell find 2>/dev/null projects/amiga-netinclude/include -type f)
	@mkdir -p $(PREFIX)/m68k-amigaos/ndk-include
	@rsync -a $(PWD)/projects/amiga-netinclude/include/* $(PREFIX)/m68k-amigaos/ndk-include
	@echo "done" >$@

projects/amiga-netinclude/README.md:
	@cd projects &&	git clone -b master --depth 4 $(GIT_AMIGA_NETINCLUDE)

# =================================================
# libamiga
# =================================================
LIBAMIGA := $(PREFIX)/m68k-amigaos/lib/libamiga.a $(PREFIX)/m68k-amigaos/lib/libb/libamiga.a

libamiga: $(LIBAMIGA)
	@echo "built $(LIBAMIGA)"

$(LIBAMIGA):
	@mkdir -p $(@D)
	@cp -p $(patsubst $(PREFIX)/m68k-amigaos/%,%,$@) $(@D)

# =================================================
# libnix
# =================================================

LIBNIX_SRC = $(shell find 2>/dev/null projects/libnix -not \( -path projects/libnix/.git -prune \) -not \( -path projects/libnix/sources/stubs/libbases -prune \) -not \( -path projects/libnix/sources/stubs/libnames -prune \) -type f)

libnix: $(BUILD)/libnix/_done

$(BUILD)/libnix/_done: $(BUILD)/newlib/_done $(BUILD)/ndk-include_ndk $(BUILD)/ndk-include_ndk13 $(BUILD)/_netinclude $(BUILD)/binutils/_done $(BUILD)/gcc/_done projects/libnix/Makefile.gcc6 $(LIBAMIGA) $(LIBNIX_SRC)
	@mkdir -p $(PREFIX)/m68k-amigaos/libnix/lib/libnix
	@mkdir -p $(BUILD)/libnix
	@mkdir -p $(PREFIX)/lib/gcc/m68k-amigaos/$(GCC_VERSION)
	@if [ ! -e $(PREFIX)/lib/gcc/m68k-amigaos/$(GCC_VERSION)/libgcc.a ]; then $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/lib/gcc/m68k-amigaos/$(GCC_VERSION)/libgcc.a; fi
	$(L0)"make libnix"$(L1) CFLAGS="$(CFLAGS_FOR_TARGET)" $(MAKE) -C $(BUILD)/libnix -f $(PWD)/projects/libnix/Makefile.gcc6 root=$(PWD)/projects/libnix all $(L2)
	$(L0)"install libnix"$(L1) $(MAKE) -C $(BUILD)/libnix -f $(PWD)/projects/libnix/Makefile.gcc6 root=$(PWD)/projects/libnix install $(L2)
	@rsync --delete -a projects/libnix/sources/headers/* $(PREFIX)/m68k-amigaos/libnix/include/
	@echo "done" >$@

projects/libnix/Makefile.gcc6:
	@cd projects &&	git clone -b master --depth 4 $(GIT_LIBNIX)

# =================================================
# gcc libs
# =================================================
LIBGCCS_NAMES := libgcov.a libstdc++.a libsupc++.a
LIBGCCS := $(patsubst %,$(PREFIX)/lib/gcc/m68k-amigaos/$(GCC_VERSION)/%,$(LIBGCCS_NAMES))

libgcc: $(BUILD)/gcc/_libgcc_done

$(BUILD)/gcc/_libgcc_done: $(BUILD)/libnix/_done $(BUILD)/libpthread/_done $(LIBAMIGA) $(shell find 2>/dev/null projects/gcc/libgcc -type f)
	$(L0)"make libgcc"$(L1) $(MAKE) -C $(BUILD)/gcc all-target $(L2)
	$(L0)"install libgcc"$(L1) $(MAKE) -C $(BUILD)/gcc install-target $(L2)
	@echo "done" >$@

# =================================================
# clib2
# =================================================

clib2: $(BUILD)/clib2/_done

$(BUILD)/clib2/_done: projects/clib2/LICENSE $(shell find 2>/dev/null projects/clib2 -not \( -path projects/clib2/.git -prune \) -type f) $(BUILD)/libnix/_done $(LIBAMIGA)
	@mkdir -p $(BUILD)/clib2/
	@rsync -a projects/clib2/library/* $(BUILD)/clib2
	@cd $(BUILD)/clib2 && find * -name lib\*.a -delete
	$(L0)"make clib2"$(L1) $(MAKE) -C $(BUILD)/clib2 -f GNUmakefile.68k -j1 $(L2)
	@mkdir -p $(PREFIX)/m68k-amigaos/clib2
	@rsync -a $(BUILD)/clib2/include $(PREFIX)/m68k-amigaos/clib2
	@rsync -a $(BUILD)/clib2/lib $(PREFIX)/m68k-amigaos/clib2
	@echo "done" >$@

projects/clib2/LICENSE:
	@cd projects && git clone -b master --depth 4 $(GIT_CLIB2)

# =================================================
# libdebug
# =================================================
CONFIG_LIBDEBUG := --prefix=$(PREFIX) --target=m68k-amigaos --host=m68k-amigaos

libdebug: $(BUILD)/libdebug/_done

$(BUILD)/libdebug/_done: $(BUILD)/libdebug/Makefile
	$(L0)"make libdebug"$(L1) $(MAKE) -C $(BUILD)/libdebug $(L2)
	@cp $(BUILD)/libdebug/libdebug.a $(PREFIX)/m68k-amigaos/lib/
	@echo "done" >$@

$(BUILD)/libdebug/Makefile: $(BUILD)/libnix/_done projects/libdebug/configure $(shell find 2>/dev/null projects/libdebug -not \( -path projects/libdebug/.git -prune \) -type f)
	@mkdir -p $(BUILD)/libdebug
	$(L0)"configure libdebug"$(L1) cd $(BUILD)/libdebug && LD=m68k-amigaos-ld CC=m68k-amigaos-gcc CFLAGS="$(CFLAGS_FOR_TARGET)" $(PWD)/projects/libdebug/configure $(CONFIG_LIBDEBUG) $(L2)

projects/libdebug/configure:
	@cd projects &&	git clone -b master --depth 4 $(GIT_LIBDEBUG)
	@touch -t 0001010000 projects/libdebug/configure.ac

# =================================================
# libsdl
# =================================================
CONFIG_LIBSDL12 := PREFX=$(PREFIX) PREF=$(PREFIX)

libSDL12: $(BUILD)/libSDL12/_done

$(BUILD)/libSDL12/_done: $(BUILD)/libSDL12/Makefile
	$(MAKE) sdk=ahi
	$(MAKE) sdk=cgx
	$(L0)"make libSDL12"$(L1) cd $(BUILD)/libSDL12 && CFLAGS="$(CFLAGS_FOR_TARGET)" $(MAKE) -f Makefile $(CONFIG_LIBSDL12) $(L2)
	$(L0)"install libSDL12"$(L1) cp $(BUILD)/libSDL12/libSDL.a $(PREFIX)/m68k-amigaos/lib/ $(L2)
	@mkdir -p $(PREFIX)/m68k-amigaos/include/GL
	@mkdir -p $(PREFIX)/m68k-amigaos/include/SDL
	@rsync -a $(BUILD)/libSDL12/include/GL/*.i $(PREFIX)/m68k-amigaos/include/GL/
	@rsync -a $(BUILD)/libSDL12/include/GL/*.h $(PREFIX)/m68k-amigaos/include/GL/
	@rsync -a $(BUILD)/libSDL12/include/SDL/*.h $(PREFIX)/m68k-amigaos/include/SDL/
	@echo "done" >$@

$(BUILD)/libSDL12/Makefile: $(BUILD)/libnix/_done projects/libSDL12/Makefile $(shell find 2>/dev/null projects/libSDL12 -not \( -path projects/libSDL12/.git -prune \) -type f)
	@mkdir -p $(BUILD)/libSDL12
	@rsync -a projects/libSDL12/* $(BUILD)/libSDL12
	@touch $(BUILD)/libSDL12/Makefile

projects/libSDL12/Makefile:
	@cd projects &&	git clone -b master --depth 4  $(GIT_LIBSDL12)


# =================================================
# libpthread
# =================================================

libpthread: $(BUILD)/libpthread/_done

$(BUILD)/libpthread/_done: $(BUILD)/libpthread/Makefile
	$(L0)"make libpthread"$(L1) cd $(BUILD)/libpthread && $(MAKE) -f Makefile $(L2)
	$(L0)"install libpthread"$(L1) cp $(BUILD)/libpthread/libpthread.a $(PREFIX)/m68k-amigaos/lib/ $(L2)
	@rsync -a --exclude=debug.h $(BUILD)/libpthread/*.h $(PREFIX)/m68k-amigaos/include/
	@echo "done" >$@

$(BUILD)/libpthread/Makefile: $(BUILD)/libnix/_done projects/aros-stuff/pthreads/Makefile $(shell find 2>/dev/null projects/aros-stuff/pthreads -type f)
	@mkdir -p $(BUILD)/libpthread
	@rsync -a projects/aros-stuff/pthreads/* $(BUILD)/libpthread
	@touch $(BUILD)/libpthread/Makefile

projects/aros-stuff/pthreads/Makefile:
	@cd projects &&	git clone -b master --depth 4  $(GIT_AROSSTUFF)

# =================================================
# newlib
# =================================================
NEWLIB_CONFIG := CC=m68k-amigaos-gcc CXX=m68k-amigaos-g++
NEWLIB_FILES = $(shell find 2>/dev/null projects/newlib-cygwin/newlib -type f)

.PHONY: newlib
newlib: $(BUILD)/newlib/_done

$(BUILD)/newlib/_done: $(BUILD)/newlib/newlib/libc.a
	@echo "done" >$@

$(BUILD)/newlib/newlib/libc.a: $(BUILD)/newlib/newlib/Makefile $(NEWLIB_FILES)
	@rsync -a $(PWD)/projects/newlib-cygwin/newlib/libc/include/ $(PREFIX)/m68k-amigaos/sys-include
	@rsync -a $(PWD)/projects/newlib-cygwin/newlib/libc/sys/amigaos/include/stabs.h $(PREFIX)/m68k-amigaos/sys-include
	$(L0)"make newlib"$(L1) $(MAKE) -C $(BUILD)/newlib/newlib $(L2)
	$(L0)"install newlib"$(L1) $(MAKE) -C $(BUILD)/newlib/newlib install $(L2)
	@for x in $$(find $(PREFIX)/m68k-amigaos/lib/* -name libm.a); do ln -sf $$x $${x%*m.a}__m__.a; done
	@touch $@

$(BUILD)/newlib/newlib/Makefile: projects/newlib-cygwin/newlib/configure $(BUILD)/ndk-include_ndk $(BUILD)/gcc/_done
	@mkdir -p $(BUILD)/newlib/newlib
	@if [ ! -f "$(BUILD)/newlib/newlib/Makefile" ]; then \
	$(L00)"configure newlib"$(L1) cd $(BUILD)/newlib/newlib && $(NEWLIB_CONFIG) CFLAGS="$(CFLAGS_FOR_TARGET)" CXXFLAGS="$(CXXFLAGS_FOR_TARGET)" $(PWD)/projects/newlib-cygwin/newlib/configure --host=m68k-amigaos --prefix=$(PREFIX) --enable-newlib-io-long-long --enable-newlib-io-c99-formats --enable-newlib-reent-small --enable-newlib-mb --enable-newlib-long-time_t $(L2) \
	; else touch "$(BUILD)/newlib/newlib/Makefile"; fi

projects/newlib-cygwin/newlib/configure:
	@cd projects &&	git clone -b $(NEWLIB_BRANCH) --depth 4  $(GIT_NEWLIB_CYGWIN)

# =================================================
# ixemul
# =================================================
projects/ixemul/configure:
	@cd projects &&	git clone $(GIT_IXEMUL)

# =================================================
# sdk installation
# =================================================
.PHONY: sdk all-sdk
sdk: libnix $(BUILD)/_lha_done
	$(L0)"sdk $(sdk)"$(L1) $(PWD)/sdk/install install $(sdk) $(PREFIX) $(L2)

SDKS0=$(shell find sdk/*.sdk)
SDKS=$(patsubst sdk/%.sdk,%,$(SDKS0))
.PHONY: $(SDKS)
all-sdk: $(SDKS)

$(SDKS): libnix
	$(MAKE) sdk=$@

# =================================================
# update repos
# =================================================
.PHONY: update-repos
update-repos:
	@cd projects/amiga-netinclude && $(UPDATE)$(GIT_AMIGA_NETINCLUDE)$(ANDPULL)
	@cd projects/binutils         && $(UPDATE)$(GIT_BINUTILS)$(ANDPULL)
	@cd projects/clib2            && $(UPDATE)$(GIT_CLIB2)$(ANDPULL)
	@cd projects/fd2pragma        && $(UPDATE)$(GIT_FD2PRAGMA)$(ANDPULL)
	@cd projects/fd2sfd           && $(UPDATE)$(GIT_FD2SFD)$(ANDPULL)
	@cd projects/gcc              && $(UPDATE)$(GIT_GCC)$(ANDPULL)
	@cd projects/ira              && $(UPDATE)$(GIT_IRA)$(ANDPULL)
	@cd projects/ixemul           && $(UPDATE)$(GIT_IXEMUL)$(ANDPULL)
#	@cd projects/lha              && $(UPDATE)$(GIT_LHA)$(ANDPULL)
	@cd projects/libdebug         && $(UPDATE)$(GIT_LIBDEBUG)$(ANDPULL)
	@cd projects/libnix           && $(UPDATE)$(GIT_LIBNIX)$(ANDPULL)
	@cd projects/libSDL12         && $(UPDATE)$(GIT_LIBSDL12)$(ANDPULL)
	@cd projects/newlib-cygwin    && $(UPDATE)$(GIT_NEWLIB_CYGWIN)$(ANDPULL)
	@cd projects/sfdc             && $(UPDATE)$(GIT_SFDC)$(ANDPULL)
	@cd projects/vasm             && $(UPDATE)$(GIT_VASM)$(ANDPULL)
	@cd projects/vbcc             && $(UPDATE)$(GIT_VBCC)$(ANDPULL)
	@cd projects/vlink            && $(UPDATE)$(GIT_VLINK)$(ANDPULL)


# =================================================
# run gcc torture check
# =================================================
ifeq (,$(board))
board = amigaos
endif

.PHONY: check
check:
	@ln -sf $(PREFIX)/m68k-amigaos/libnix $(BUILD)/gcc/m68k-amigaos/libnix
	$(MAKE) -C $(BUILD)/gcc check-gcc-c "RUNTESTFLAGS=--target_board=$(board) execute.exp=* SIM=vamos" | grep '# of\|PASS\|FAIL\|===\|Running\|Using' 


# =================================================
# info
# =================================================
.PHONY: info v r b l
info:
	@echo $@ $(UNAME_S)
	@echo PREFIX=$(PREFIX)
	@echo GCC_VERSION=$(GCC_VERSION)
	@echo CFLAGS=$(CFLAGS)
	@echo CFLAGS_FOR_TARGET=$(CFLAGS_FOR_TARGET)
	@$(CC) -v -E - </dev/null |& grep " version "
	@$(CXX) -v -E - </dev/null |& grep " version "
	@echo $(BUILD)

# print the latest git log entry for all projects
l:
	@for i in projects/* ; do pushd . >/dev/null; cd $$i 2>/dev/null && ([[ -d ".git" ]] && echo $$i && git log -n1 --pretty=oneline); popd >/dev/null; done
	@echo "." && git log -n1 --pretty=oneline

# print the git remotes for all projects
r:
	@for i in projects/* ; do pushd . >/dev/null; cd $$i 2>/dev/null && ([[ -d ".git" ]] && echo $$i && git remote -v); popd >/dev/null; done
	@echo "." && git remote -v

# print the git branches for all projects
b:
	@for i in projects/* ; do pushd . >/dev/null; cd $$i 2>/dev/null && ([[ -d ".git" ]] && echo $$i && (git branch | grep '*')); popd >/dev/null; done
	@echo "." && git remote -v


# checkout for a given date
v:
	@D="$(date)"; \
	pushd projects >/dev/null; \
	for i in * ; do \
	pushd . >/dev/null; \
	cd $$i 2>/dev/null; \
	if [ -d ".git" ]; then \
	echo $$i;\
	B=master;\
	if [ "$$i" == "binutils" ] || [ "$$i" == "newlib-cygwin" ]; then B=amiga; fi;\
	if [ "$$i" == "gcc" ]; then  B="gcc-6-branch"; fi;\
	git checkout $$B; \
	if [ "$$D" != "" ]; then git checkout `git rev-list -n 1 --first-parent --before="$$D" $$B`; fi;\
	fi;\
	popd >/dev/null; \
	done; \
	popd >/dev/null; \
	echo .; \
	git checkout $$B; \
	if [ "$$D" != "" ]; then \
	git checkout `git rev-list -n 1 --first-parent --before="$$D" $$B`; \
	fi
