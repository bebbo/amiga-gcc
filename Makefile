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

BUILD ?= build

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
.PHONY: all gcc binutils fd2sfd fd2pragma ira sfdc vasm vbcc vlink libnix ixemul libgcc clib2 libdebug libSDL12 ndk ndk13
all: gcc binutils fd2sfd fd2pragma ira sfdc vbcc vasm vlink libnix ixemul libgcc clib2 libdebug libSDL12 ndk ndk13

# =================================================
# clean
# =================================================
ifneq ($(findstring MSYS,$(USED_CC_VERSION)),)
.PHONY: clean-gmp clean-mpc clean-mpfr
clean: clean-gmp clean-mpc clean-mpfr
endif

.PHONY: clean-prefix clean clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vasm clean-vbcc clean-vlink clean-libnix clean-ixemul clean-libgcc clean-clib2 clean-libdebug clean-libSDL12 clean-newlib clean-ndk
clean: clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vasm clean-vbcc clean-vlink clean-libnix clean-ixemul clean-clib2 clean-libdebug clean-libSDL12 clean-newlib clean-ndk clean-gmp clean-mpc clean-mpfr
	rm -rf $(BUILD)

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
	rm $(BUILD)/gcc/_libgcc_done

clean-binutils:
	rm -rf $(BUILD)/binutils

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
	rm -rf $(BUILD)/ndk-include

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

clean-newlib:
	rm -rf $(BUILD)/newlib

# clean-prefix drops the files from prefix folder
clean-prefix:
	rm -rf $(PREFIX)/bin
	rm -rf $(PREFIX)/libexec
	rm -rf $(PREFIX)/lib/gcc
	rm -rf $(PREFIX)/m68k-amigaos
	mkdir -p $(PREFIX)/bin

# =================================================
# update all projects
# =================================================
ifneq ($(findstring MSYS,$(USED_CC_VERSION)),)
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

update-gmp:
	@mkdir -p download
	if [ -a download/$(GMPFILE) ]; \
	then rm -rf projects/$(GMP); rm -rf projects/gcc/gmp; \
	else cd download && wget ftp://ftp.gnu.org/gnu/gmp/$(GMPFILE); \
	fi;
	cd projects && tar xf ../download/$(GMPFILE)
	
update-mpc:
	@mkdir -p download
	if [ -a download/$(MPCFILE) ]; \
	then rm -rf projcts/$(MPC); rm -rf projects/gcc/mpc; \
	else cd download && wget ftp://ftp.gnu.org/gnu/mpc/$(MPCFILE); \
	fi;
	cd projects && tar xf ../download/$(MPCFILE)

update-mpfr:
	@mkdir -p download
	if [ -a download/$(MPFRFILE) ]; \
	then rm -rf projects/$(MPFR); rm -rf projects/gcc/mpfr; \
	else cd download && wget ftp://ftp.gnu.org/gnu/mpfr/$(MPFRFILE); \
	fi;
	cd projects && tar xf ../download/$(MPFRFILE)

status-all:
	GCC_VERSION=$(shell cat 2>/dev/null projects/gcc/gcc/BASE-VER)
# =================================================
# B I N
# =================================================
	
# =================================================
# gcc
# =================================================
CONFIG_GCC=--prefix=$(PREFIX) --target=m68k-amigaos --enable-languages=c,c++,objc --enable-version-specific-runtime-libs --disable-libssp --disable-nls \
	--with-headers=$(PWD)/projects/newlib-cygwin/newlib/libc/sys/amigaos/include/ --disable-shared


GCC_CMD = m68k-amigaos-c++ m68k-amigaos-g++ m68k-amigaos-gcc-$(GCC_VERSION) m68k-amigaos-gcc-nm \
	m68k-amigaos-gcov m68k-amigaos-gcov-tool m68k-amigaos-cpp m68k-amigaos-gcc m68k-amigaos-gcc-ar \
	m68k-amigaos-gcc-ranlib m68k-amigaos-gcov-dump
GCC = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(GCC_CMD))

GCC_DIR = . gcc gcc/c gcc/c-family gcc/cp gcc/objc gcc/config/m68k libiberty libcpp libdecnumber
GCCD = $(patsubst %,projects/gcc/%, $(GCC_DIR))

gcc: $(BUILD)/gcc/_done

$(BUILD)/gcc/_done: $(BUILD)/gcc/Makefile $(shell find 2>/dev/null $(GCCD) -maxdepth 1 -type f )
	$(MAKE) -C $(BUILD)/gcc all-gcc $(LOG)
	$(MAKE) -C $(BUILD)/gcc install-gcc $(LOG)
	echo "done" >$@
	@echo "built $(GCC)"

$(BUILD)/gcc/Makefile: projects/gcc/configure $(BUILD)/binutils/_done
	@mkdir -p $(BUILD)/gcc
ifneq ($(findstring MSYS,$(USED_CC_VERSION)),)	
	@mkdir -p projects/gcc/gmp
	@mkdir -p projects/gcc/mpc
	@mkdir -p projects/gcc/mpfr
	rsync -a projects/$(GMP)/* projects/gcc/gmp
	rsync -a projects/$(MPC)/* projects/gcc/mpc
	rsync -a projects/$(MPFR)/* projects/gcc/mpfr
endif	
#	if [ "$(UNAME_S)" == "Darwin" ]; then cd $(BUILD)/gcc && contrib/download_prerequisites; fi
	cd $(BUILD)/gcc && $(E) $(PWD)/projects/gcc/configure $(CONFIG_GCC) $(LOG)

projects/gcc/configure:
	@mkdir -p projects
	cd projects &&	git clone -b $(GCC_BRANCH) --depth 16 https://github.com/bebbo/gcc

# =================================================
# binutils
# =================================================
CONFIG_BINUTILS=--prefix=$(PREFIX) --target=m68k-amigaos --disable-plugins --disable-werror
BINUTILS_CMD = m68k-amigaos-addr2line m68k-amigaos-ar m68k-amigaos-as m68k-amigaos-c++filt \
	m68k-amigaos-ld m68k-amigaos-nm m68k-amigaos-objcopy m68k-amigaos-objdump m68k-amigaos-ranlib \
	m68k-amigaos-readelf m68k-amigaos-size m68k-amigaos-strings m68k-amigaos-strip
BINUTILS = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(BINUTILS_CMD))

BINUTILS_DIR = . bfd gas ld binutils opcodes
BINUTILSD = $(patsubst %,projects/binutils/%, $(BINUTILS_DIR))

ifeq ($(findstring clang,$(CC)),)
ALL_GDB = all-gdb
INSTALL_GDB = install-gdb
endif

binutils: $(BUILD)/binutils/_done

$(BUILD)/binutils/_done: $(BUILD)/binutils/gas/Makefile $(shell find 2>/dev/null projects/binutils -not \( -path projects/binutils/.git -prune \) -type f)
	touch -t 0001010000 projects/binutils/binutils/arparse.y
	touch -t 0001010000 projects/binutils/binutils/arlex.l
	touch -t 0001010000 projects/binutils/ld/ldgram.y
	$(MAKE) -C $(BUILD)/binutils all-gas all-binutils all-ld $(ALL_GDB) $(LOG)
	$(MAKE) -C $(BUILD)/binutils install-gas install-binutils install-ld $(INSTALL_GDB) $(LOG)
	echo "done" >$@
	echo "build $(BINUTILS)"

$(BUILD)/binutils/gas/Makefile: projects/binutils/configure
	@mkdir -p $(BUILD)/binutils
	cd $(BUILD)/binutils && $(E) $(PWD)/projects/binutils/configure $(CONFIG_BINUTILS) $(LOG)

projects/binutils/configure:
	@mkdir -p projects
	cd projects &&	git clone -b $(BINUTILS_BRANCH) --depth 16 $(BINUTILS_GIT) binutils


# =================================================
# fd2sfd
# =================================================
CONFIG_FD2SFD = --prefix=$(PREFIX) --target=m68k-amigaos

fd2sfd: $(BUILD)/fd2sfd/_done

$(BUILD)/fd2sfd/_done: $(PREFIX)/bin/fd2sfd
	@echo "built $(PREFIX)/bin/fd2sfd"
	@echo "done" >$@

$(PREFIX)/bin/fd2sfd: $(BUILD)/fd2sfd/Makefile $(shell find 2>/dev/null projects/fd2sfd -not \( -path projects/fd2sfd/.git -prune \) -type f)
	$(MAKE) -C $(BUILD)/fd2sfd all $(LOG)
	mkdir -p $(PREFIX)/bin/
	$(MAKE) -C $(BUILD)/fd2sfd install $(LOG)
$(BUILD)/fd2sfd/Makefile: projects/fd2sfd/configure
	@mkdir -p $(BUILD)/fd2sfd
	cd $(BUILD)/fd2sfd && $(E) $(PWD)/projects/fd2sfd/configure $(CONFIG_FD2SFD) $(LOG)

projects/fd2sfd/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/cahirwpz/fd2sfd
	for i in $$(find patches/fd2sfd/ -type f); \
	do if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "projects/$${j%.diff}" "$$i"; fi ; done

# =================================================
# fd2pragma
# =================================================
fd2pragma: $(BUILD)/fd2pragma/_done

$(BUILD)/fd2pragma/_done: $(PREFIX)/bin/fd2pragma
	@echo "built $(PREFIX)/bin/fd2pragma"
	@echo "done" >$@

$(PREFIX)/bin/fd2pragma: $(BUILD)/fd2pragma/fd2pragma
	mkdir -p $(PREFIX)/bin/
	install $(BUILD)/fd2pragma/fd2pragma $(PREFIX)/bin/

$(BUILD)/fd2pragma/fd2pragma: projects/fd2pragma/makefile $(shell find 2>/dev/null projects/fd2pragma -not \( -path projects/fd2pragma/.git -prune \) -type f)
	@mkdir -p $(BUILD)/fd2pragma
	cd projects/fd2pragma && $(CC) -o $(PWD)/$@ $(CFLAGS) fd2pragma.c

projects/fd2pragma/makefile:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/adtools/fd2pragma

# =================================================
# ira
# =================================================
ira: $(BUILD)/ira/_done

$(BUILD)/ira/_done: $(PREFIX)/bin/ira
	@echo "built $(PREFIX)/bin/ira"
	@echo "done" >$@

$(PREFIX)/bin/ira: $(BUILD)/ira/ira
	mkdir -p $(PREFIX)/bin/
	install $(BUILD)/ira/ira $(PREFIX)/bin/

$(BUILD)/ira/ira: projects/ira/Makefile $(shell find 2>/dev/null projects/ira -not \( -path projects/ira/.git -prune \) -type f)
	@mkdir -p $(BUILD)/ira
	cd projects/ira && $(CC) -o $(PWD)/$@ $(CFLAGS) *.c -std=c99

projects/ira/Makefile:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/ira

# =================================================
# sfdc
# =================================================
CONFIG_SFDC = --prefix=$(PREFIX) --target=m68k-amigaos

sfdc: $(BUILD)/sfdc/_done

$(BUILD)/sfdc/_done: $(PREFIX)/bin/sfdc
	@echo "built $(PREFIX)/bin/sfdc"
	@echo "done" >$@

$(PREFIX)/bin/sfdc: $(BUILD)/sfdc/Makefile $(shell find 2>/dev/null projects/sfdc -not \( -path projects/sfdc/.git -prune \)  -type f)
	$(MAKE) -C $(BUILD)/sfdc sfdc $(LOG)
	mkdir -p $(PREFIX)/bin/
	install $(BUILD)/sfdc/sfdc $(PREFIX)/bin

$(BUILD)/sfdc/Makefile: projects/sfdc/configure
	rsync -a projects/sfdc $(BUILD)/ --exclude .git
	cd $(BUILD)/sfdc && $(E) $(PWD)/$(BUILD)/sfdc/configure $(CONFIG_SFDC) $(LOG)

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
VASM = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VASM_CMD))

vasm: $(BUILD)/vasm/_done

$(BUILD)/vasm/_done: $(BUILD)/vasm/Makefile $(shell find 2>/dev/null projects/vasm -not \( -path projects/vasm/.git -prune \) -type f)
	$(MAKE) -C $(BUILD)/vasm CPU=m68k SYNTAX=mot $(LOG)
	mkdir -p $(PREFIX)/bin/
	install $(BUILD)/vasm/vasmm68k_mot $(PREFIX)/bin/
	install $(BUILD)/vasm/vobjdump $(PREFIX)/bin/
	cp patches/vc.config $(BUILD)/vasm/vc.config
	sed -e "s|PREFIX|$(PREFIX)|g" -i.bak $(BUILD)/vasm/vc.config
	mkdir -p $(PREFIX)/m68k-amigaos/etc/
	install $(BUILD)/vasm/vc.config $(PREFIX)/bin/
	@echo "done" >$@
	@echo "built $(vasm)"

$(BUILD)/vasm/Makefile: projects/vasm/Makefile
	rsync -a projects/vasm $(BUILD)/ --exclude .git

projects/vasm/Makefile:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/leffmann/vasm

# =================================================
# vbcc
# =================================================
VBCC_CMD = vbccm68k vprof vc
VBCC = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VBCC_CMD))

vbcc: $(BUILD)/vbcc/_done

$(BUILD)/vbcc/_done: $(BUILD)/vbcc/Makefile $(shell find 2>/dev/null projects/vbcc -not \( -path projects/vbcc/.git -prune \) -type f)
	cd $(BUILD)/vbcc && TARGET=m68k $(MAKE) bin/dtgen $(LOG)
	cd $(BUILD)/vbcc && echo -e "y\\ny\\nsigned char\\ny\\nunsigned char\\nn\\ny\\nsigned short\\nn\\ny\\nunsigned short\\nn\\ny\\nsigned int\\nn\\ny\\nunsigned int\\nn\\ny\\nsigned long long\\nn\\ny\\nunsigned long long\\nn\\ny\\nfloat\\nn\\ny\\ndouble\\n" >c.txt; bin/dtgen machines/m68k/machine.dt machines/m68k/dt.h machines/m68k/dt.c <c.txt
	cd $(BUILD)/vbcc && TARGET=m68k $(MAKE) $(LOG)
	mkdir -p $(PREFIX)/bin/
	rm -rf $(BUILD)/vbcc/bin/*.dSYM
	install $(BUILD)/vbcc/bin/v* $(PREFIX)/bin/
	@echo "done" >$@
	@echo "built $(VBCC)"

$(BUILD)/vbcc/Makefile: projects/vbcc/Makefile
	rsync -a projects/vbcc $(BUILD)/ --exclude .git
	mkdir -p $(BUILD)/vbcc/bin

projects/vbcc/Makefile:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/leffmann/vbcc

# =================================================
# vlink
# =================================================
VLINK_CMD = vlink
VLINK = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VLINK_CMD))

vlink: $(BUILD)/vlink/_done

$(BUILD)/vlink/_done: $(BUILD)/vlink/Makefile $(shell find 2>/dev/null projects/vlink -not \( -path projects/vlink/.git -prune \) -type f)
	cd $(BUILD)/vlink && TARGET=m68k $(MAKE) $(LOG)
	mkdir -p $(PREFIX)/bin/
	install $(BUILD)/vlink/vlink $(PREFIX)/bin/
	@echo "done" >$@
	@echo "built $(VLINK)"

$(BUILD)/vlink/Makefile: projects/vlink/Makefile
	rsync -a projects/vlink $(BUILD)/ --exclude .git

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
NDK_INCLUDE_INLINE = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX)/m68k-amigaos/ndk-include/inline/%.h,$(NDK_INCLUDE_SFD))
NDK_INCLUDE_LVO    = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX)/m68k-amigaos/ndk-include/lvo/%_lib.i,$(NDK_INCLUDE_SFD))
NDK_INCLUDE_PROTO  = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX)/m68k-amigaos/ndk-include/proto/%.h,$(NDK_INCLUDE_SFD))
SYS_INCLUDE2 = $(filter-out $(NDK_INCLUDE_PROTO),$(patsubst projects/NDK_3.9/Include/include_h/%,$(PREFIX)/m68k-amigaos/ndk-include/%, $(NDK_INCLUDE)))

.PHONY: ndk-inline ndk-lvo ndk-proto

ndk: $(BUILD)/ndk-include/_ndk 

$(BUILD)/ndk-include/_ndk: $(BUILD)/ndk-include/_ndk0 $(NDK_INCLUDE_INLINE) $(NDK_INCLUDE_LVO) $(NDK_INCLUDE_PROTO) projects/fd2sfd/configure projects/fd2pragma/makefile
	mkdir -p $(BUILD)/ndk-include/
	echo "done" >$@

$(BUILD)/ndk-include/_ndk0: projects/NDK_3.9.info $(NDK_INCLUDE)
	mkdir -p $(PREFIX)/m68k-amigaos/ndk-include
	rsync -a $(PWD)/projects/NDK_3.9/Include/include_h/* $(PREFIX)/m68k-amigaos/ndk-include --exclude proto
	rsync -a $(PWD)/projects/NDK_3.9/Include/include_i/* $(PREFIX)/m68k-amigaos/ndk-include
	mkdir -p $(PREFIX)/m68k-amigaos/ndk/lib
	rsync -a $(PWD)/projects/NDK_3.9/Include/fd $(PREFIX)/m68k-amigaos/ndk/lib
	rsync -a $(PWD)/projects/NDK_3.9/Include/sfd $(PREFIX)/m68k-amigaos/ndk/lib
	rsync -a $(PWD)/projects/NDK_3.9/Include/linker_libs $(PREFIX)/m68k-amigaos/ndk/lib
	mkdir -p $(PREFIX)/m68k-amigaos/ndk-include/proto
	cp -p projects/NDK_3.9/Include/include_h/proto/alib.h $(PREFIX)/m68k-amigaos/ndk-include/proto
	cp -p projects/NDK_3.9/Include/include_h/proto/cardres.h $(PREFIX)/m68k-amigaos/ndk-include/proto
	mkdir -p $(PREFIX)/m68k-amigaos/ndk-include/inline
	cp -p projects/fd2sfd/cross/share/m68k-amigaos/alib.h $(PREFIX)/m68k-amigaos/ndk-include/inline
	cp -p projects/fd2pragma/Include/inline/stubs.h $(PREFIX)/m68k-amigaos/ndk-include/inline
	cp -p projects/fd2pragma/Include/inline/macros.h $(PREFIX)/m68k-amigaos/ndk-include/inline
	mkdir -p $(BUILD)/ndk-include/
	echo "done" >$@

ndk-inline: $(NDK_INCLUDE_INLINE) sfdc $(BUILD)/ndk-include/_inline 
$(NDK_INCLUDE_INLINE): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD) $(BUILD)/ndk-include/_inline $(BUILD)/ndk-include/_lvo $(BUILD)/ndk-include/_proto $(BUILD)/ndk-include/_ndk0
	sfdc --target=m68k-amigaos --mode=macros --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/ndk-include/inline/%.h,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@)

ndk-lvo: $(NDK_INCLUDE_LVO) sfdc
$(NDK_INCLUDE_LVO): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD) $(BUILD)/ndk-include/_lvo $(BUILD)/ndk-include/_ndk0
	sfdc --target=m68k-amigaos --mode=lvo --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/ndk-include/lvo/%_lib.i,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@)

ndk-proto: $(NDK_INCLUDE_PROTO) sfdc
$(NDK_INCLUDE_PROTO): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD)	$(BUILD)/ndk-include/_proto $(BUILD)/ndk-include/_ndk0
	sfdc --target=m68k-amigaos --mode=proto --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/ndk-include/proto/%.h,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@)

$(BUILD)/ndk-include/_inline:
	mkdir -p $(PREFIX)/m68k-amigaos/ndk-include/inline
	mkdir -p $(BUILD)/ndk-include/
	echo "done" >$@

$(BUILD)/ndk-include/_lvo:
	mkdir -p $(PREFIX)/m68k-amigaos/ndk-include/lvo
	mkdir -p $(PREFIX)/m68k-amigaos/ndk13-include/lvo
	mkdir -p $(BUILD)/ndk-include/
	echo "done" >$@

$(BUILD)/ndk-include/_proto:
	mkdir -p $(PREFIX)/m68k-amigaos/ndk-include/proto
	mkdir -p $(PREFIX)/m68k-amigaos/ndk13-include/proto
	mkdir -p $(BUILD)/ndk-include/
	echo "done" >$@

projects/NDK_3.9.info: download/NDK39.lha $(shell find 2>/dev/null patches/NDK_3.9/ -type f)
	mkdir -p projects
	mkdir -p $(BUILD)/
	if [ ! -e "$$(which lha)" ]; then cd $(BUILD)/ && rm -rf lha; git clone https://github.com/jca02266/lha; cd lha; aclocal; autoheader; automake -a; autoconf; ./configure; make all; mkdir -p $(PREFIX)/bin/; install src/lha$(EXEEXT) $(PREFIX)/bin/lha$(EXEEXT); fi
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

ndk13: $(BUILD)/ndk-include/_ndk13

$(BUILD)/ndk-include/_ndk13: $(BUILD)/ndk-include/_ndk
	while read p; do mkdir -p $(PREFIX)/m68k-amigaos/ndk13-include/$$(dirname $$p); cp $(PREFIX)/m68k-amigaos/ndk-include/$$p $(PREFIX)/m68k-amigaos/ndk13-include/$$p; done < patches/ndk13/hfiles
	while read p; do \
	  mkdir -p $(PREFIX)/m68k-amigaos/ndk13-include/$$(dirname $$p); \
	  if grep V36 $(PREFIX)/m68k-amigaos/ndk-include/$$p; then \
	  LC_CTYPE=C sed -n -e '/#ifndef  CLIB/,/V36/p' $(PREFIX)/m68k-amigaos/ndk-include/$$p >$(PREFIX)/m68k-amigaos/ndk13-include/$$p; \
	  echo -e "#ifdef __cplusplus\n}\n#endif /* __cplusplus */\n#endif" >>$(PREFIX)/m68k-amigaos/ndk13-include/$$p; \
	  else cp $(PREFIX)/m68k-amigaos/ndk-include/$$p $(PREFIX)/m68k-amigaos/ndk13-include/$$p; fi \
	done < patches/ndk13/chfiles
	while read p; do mkdir -p $(PREFIX)/m68k-amigaos/ndk13-include/$$(dirname $$p); echo "" >$(PREFIX)/m68k-amigaos/ndk13-include/$$p; done < patches/ndk13/ehfiles
	echo '#undef	EXECNAME' > $(PREFIX)/m68k-amigaos/ndk13-include/exec/execname.h
	echo '#define	EXECNAME	"exec.library"' >> $(PREFIX)/m68k-amigaos/ndk13-include/exec/execname.h
	mkdir -p $(PREFIX)/m68k-amigaos/ndk/lib/fd13
	while read p; do LC_CTYPE=C sed -n -e '/##base/,/V36/P'  $(PREFIX)/m68k-amigaos/ndk/lib/fd/$$p >$(PREFIX)/m68k-amigaos/ndk/lib/fd13/$$p; done < patches/ndk13/fdfiles
	mkdir -p $(PREFIX)/m68k-amigaos/ndk/lib/sfd13
	for i in $(PREFIX)/m68k-amigaos/ndk/lib/fd13/*; do fd2sfd $$i $(PREFIX)/m68k-amigaos/ndk13-include/clib/$$(basename $$i _lib.fd)_protos.h > $(PREFIX)/m68k-amigaos/ndk/lib/sfd13/$$(basename $$i .fd).sfd; done
	for i in $(PREFIX)/m68k-amigaos/ndk/lib/sfd13/*; do \
	  sfdc --target=m68k-amigaos --mode=macros --output=$(PREFIX)/m68k-amigaos/ndk13-include/inline/$$(basename $$i _lib.sfd).h $$i; \
	  sfdc --target=m68k-amigaos --mode=proto --output=$(PREFIX)/m68k-amigaos/ndk13-include/proto/$$(basename $$i _lib.sfd).h $$i; \
	done
	echo "done" >$@

# =================================================
# netinclude
# =================================================
$(BUILD)/_netinclude: projects/amiga-netinclude/README.md $(BUILD)/ndk-include/_ndk $(shell find 2>/dev/null projects/amiga-netinclude/include -type f)
	mkdir -p $(PREFIX)/m68k-amigaos/ndk-include
	rsync -a $(PWD)/projects/amiga-netinclude/include/* $(PREFIX)/m68k-amigaos/ndk-include
	echo "done" >$@

projects/amiga-netinclude/README.md: 
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/amiga-netinclude

# =================================================
# libamiga
# =================================================
LIBAMIGA=$(PREFIX)/m68k-amigaos/lib/libamiga.a $(PREFIX)/m68k-amigaos/lib/libb/libamiga.a

libamiga: $(LIBAMIGA)
	@echo "built $(LIBAMIGA)"

$(LIBAMIGA):
	mkdir -p $(@D)
	cp -p $(patsubst $(PREFIX)/m68k-amigaos/%,%,$@) $(@D)

# =================================================
# libnix
# =================================================

CONFIG_LIBNIX = --prefix=$(PREFIX)/m68k-amigaos/libnix --target=m68k-amigaos --host=m68k-amigaos

LIBNIX_SRC = $(shell find 2>/dev/null projects/libnix -not \( -path projects/libnix/.git -prune \) -not \( -path projects/libnix/sources/stubs/libbases -prune \) -not \( -path projects/libnix/sources/stubs/libnames -prune \) -type f)

libnix: $(BUILD)/libnix/_done

$(BUILD)/libnix/_done: $(BUILD)/libnix/Makefile
	$(MAKE) -C $(BUILD)/libnix $(LOG)
	$(MAKE) -C $(BUILD)/libnix install $(LOG)
	cd $(BUILD)/newlib/complex && $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/m68k-amigaos/libnix/lib/libm.a $(COMPLEX_FILES)
	cd $(BUILD)/newlib/complex/libb && $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/m68k-amigaos/libnix/lib/libb/libm.a $(COMPLEX_FILES)
	cd $(BUILD)/newlib/complex/libm020 && $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/m68k-amigaos/libnix/lib/libm020/libm.a $(COMPLEX_FILES)
	cd $(BUILD)/newlib/complex/libm020/libb && $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/m68k-amigaos/libnix/lib/libm020/libb/libm.a $(COMPLEX_FILES)
	cd $(BUILD)/newlib/complex/libm020/libb32 && $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/m68k-amigaos/libnix/lib/libm020/libb32/libm.a $(COMPLEX_FILES)
	@echo "done" >$@
	@echo "built $(LIBNIX)"
		
$(BUILD)/libnix/Makefile: $(BUILD)/newlib/_done $(BUILD)/ndk-include/_ndk $(BUILD)/ndk-include/_ndk13 $(BUILD)/_netinclude $(BUILD)/binutils/_done $(BUILD)/gcc/_done projects/libnix/configure projects/libnix/Makefile.in $(LIBAMIGA) $(LIBNIX_SRC) 
	mkdir -p $(PREFIX)/m68k-amigaos/libnix/lib/libnix 
	mkdir -p $(BUILD)/libnix
	echo 'void foo(){}' > $(BUILD)/libnix/x.c
	if [ ! -e $(PREFIX)/m68k-amigaos/lib/libstubs.a ]; then $(PREFIX)/bin/m68k-amigaos-ar r $(PREFIX)/m68k-amigaos/lib/libstubs.a; fi
	mkdir -p $(PREFIX)/lib/gcc/m68k-amigaos/$(GCC_VERSION)
	if [ ! -e $(PREFIX)/lib/gcc/m68k-amigaos/$(GCC_VERSION)/libgcc.a ]; then $(PREFIX)/bin/m68k-amigaos-ar r $(PREFIX)/lib/gcc/m68k-amigaos/$(GCC_VERSION)/libgcc.a; fi
	cd $(BUILD)/libnix && CFLAGS="$(TARGET_C_FLAGS)" AR=m68k-amigaos-ar AS=m68k-amigaos-as CC=m68k-amigaos-gcc $(A) $(PWD)/projects/libnix/configure $(CONFIG_LIBNIX) $(LOG)
	mkdir -p $(PREFIX)/m68k-amigaos/libnix/include/
	rsync -a projects/libnix/sources/headers/* $(PREFIX)/m68k-amigaos/libnix/include/
	touch $(BUILD)/libnix/Makefile
	
projects/libnix/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/libnix

# =================================================
# gcc libs
# =================================================
LIBGCCS_NAMES=libgcov.a libstdc++.a libsupc++.a
LIBGCCS= $(patsubst %,$(PREFIX)/lib/gcc/m68k-amigaos/$(GCC_VERSION)/%,$(LIBGCCS_NAMES))

libgcc: $(BUILD)/gcc/_libgcc_done

$(BUILD)/gcc/_libgcc_done: $(BUILD)/libnix/_done $(LIBAMIGA)
	$(MAKE) -C $(BUILD)/gcc all-target $(LOG)
	$(MAKE) -C $(BUILD)/gcc install-target $(LOG)
	echo "done" >$@
	echo "$(LIBGCCS)"

# =================================================
# clib2
# =================================================

clib2: $(BUILD)/clib2/_done

$(BUILD)/clib2/_done: projects/clib2/LICENSE $(shell find 2>/dev/null projects/clib2 -not \( -path projects/clib2/.git -prune \) -type f) $(BUILD)/libnix/Makefile $(LIBAMIGA)
	mkdir -p $(BUILD)/clib2/
	rsync -a projects/clib2/library/* $(BUILD)/clib2
	cd $(BUILD)/clib2 && find * -name lib\*.a -delete
	$(MAKE) -C $(BUILD)/clib2 -f GNUmakefile.68k $(LOG)
	mkdir -p $(PREFIX)/m68k-amigaos/clib2
	rsync -a $(BUILD)/clib2/include $(PREFIX)/m68k-amigaos/clib2
	rsync -a $(BUILD)/clib2/lib $(PREFIX)/m68k-amigaos/clib2
	cd $(BUILD)/newlib/complex && $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/m68k-amigaos/clib2/lib/libm.a $(COMPLEX_FILES)
	cd $(BUILD)/newlib/complex/libb && $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/m68k-amigaos/clib2/lib/libb/libm.a $(COMPLEX_FILES)
	cd $(BUILD)/newlib/complex/libm020 && $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/m68k-amigaos/clib2/lib/libm020/libm.a $(COMPLEX_FILES)
	cd $(BUILD)/newlib/complex/libm020/libb && $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/m68k-amigaos/clib2/lib/libm020/libb/libm.a $(COMPLEX_FILES)
	cd $(BUILD)/newlib/complex/libm020/libb32 && $(PREFIX)/bin/m68k-amigaos-ar rcs $(PREFIX)/m68k-amigaos/clib2/lib/libm020/libb32/libm.a $(COMPLEX_FILES)
	echo "done" >$@	

projects/clib2/LICENSE:
	@mkdir -p projects
	cd projects && git clone -b master --depth 4 https://github.com/bebbo/clib2

# =================================================
# libdebug
# =================================================
CONFIG_LIBDEBUG = --prefix=$(PREFIX) --target=m68k-amigaos --host=m68k-amigaos

libdebug: $(BUILD)/libdebug/_done

$(BUILD)/libdebug/_done: $(BUILD)/libdebug/Makefile
	$(MAKE) -C $(BUILD)/libdebug $(LOG)
	cp $(BUILD)/libdebug/libdebug.a $(PREFIX)/m68k-amigaos/lib/
	echo "done" >$@

$(BUILD)/libdebug/Makefile: $(BUILD)/libnix/_done projects/libdebug/configure $(shell find 2>/dev/null projects/libdebug -not \( -path projects/libdebug/.git -prune \) -type f)
	mkdir -p $(BUILD)/libdebug
	cd $(BUILD)/libdebug && CFLAGS="$(TARGET_C_FLAGS)" $(PWD)/projects/libdebug/configure $(CONFIG_LIBDEBUG) $(LOG)

projects/libdebug/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/libdebug
	touch -t 0001010000 projects/libdebug/configure.ac

# =================================================
# libsdl
# =================================================
CONFIG_LIBSDL12 = PREFX=$(PREFIX) PREF=$(PREFIX)

libSDL12: $(BUILD)/libSDL12/_done

$(BUILD)/libSDL12/_done: $(BUILD)/libSDL12/Makefile.bax
	$(MAKE) sdk=ahi $(LOG)
	$(MAKE) sdk=cgx $(LOG)
	cd $(BUILD)/libSDL12 && CFLAGS="$(TARGET_C_FLAGS)" $(MAKE) -f Makefile.bax $(CONFIG_LIBSDL12) $(LOG)
	cp $(BUILD)/libSDL12/libSDL.a $(PREFIX)/m68k-amigaos/lib/
	mkdir -p $(PREFIX)/include/GL
	mkdir -p $(PREFIX)/include/SDL
	rsync -a $(BUILD)/libSDL12/include/GL/*.i $(PREFIX)/include/GL/
	rsync -a $(BUILD)/libSDL12/include/GL/*.h $(PREFIX)/include/GL/
	rsync -a $(BUILD)/libSDL12/include/SDL/*.h $(PREFIX)/include/SDL/
	echo "done" >$@

$(BUILD)/libSDL12/Makefile.bax: $(BUILD)/libnix/_done projects/libSDL12/Makefile.bax $(shell find 2>/dev/null projects/libSDL12 -not \( -path projects/libSDL12/.git -prune \) -type f)
	mkdir -p $(BUILD)/libSDL12
	rsync -a projects/libSDL12/* $(BUILD)/libSDL12
	touch $(BUILD)/libSDL12/Makefile.bax

projects/libSDL12/Makefile.bax:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4  https://github.com/AmigaPorts/libSDL12


# =================================================
# newlib
# =================================================
NEWLIB_CONFIG = CC=m68k-amigaos-gcc
NEWLIB_FILES = $(shell find 2>/dev/null projects/newlib-cygwin/newlib -type f)

.PHONY: newlib
newlib: $(BUILD)/newlib/_done

COMPLEX_FILES = lib_a-cabs.o   lib_a-cacosf.o   lib_a-cacosl.o  lib_a-casin.o    lib_a-casinhl.o  lib_a-catanh.o   lib_a-ccos.o    lib_a-ccoshl.o        lib_a-cephes_subrl.o  lib_a-cimag.o   lib_a-clog10.o   lib_a-conj.o   lib_a-cpowf.o   lib_a-cprojl.o  lib_a-csin.o    lib_a-csinhl.o  lib_a-csqrtl.o  lib_a-ctanhf.o \
	lib_a-cabsf.o  lib_a-cacosh.o   lib_a-carg.o    lib_a-casinf.o   lib_a-casinl.o   lib_a-catanhf.o  lib_a-ccosf.o   lib_a-ccosl.o         lib_a-cexp.o          lib_a-cimagf.o  lib_a-clog10f.o  lib_a-conjf.o  lib_a-cpowl.o   lib_a-creal.o   lib_a-csinf.o   lib_a-csinl.o   lib_a-ctan.o    lib_a-ctanhl.o \
	lib_a-cabsl.o  lib_a-cacoshf.o  lib_a-cargf.o   lib_a-casinh.o   lib_a-catan.o    lib_a-catanhl.o  lib_a-ccosh.o   lib_a-cephes_subr.o   lib_a-cexpf.o         lib_a-cimagl.o  lib_a-clogf.o    lib_a-conjl.o  lib_a-cproj.o   lib_a-crealf.o  lib_a-csinh.o   lib_a-csqrt.o   lib_a-ctanf.o   lib_a-ctanl.o \
	lib_a-cacos.o  lib_a-cacoshl.o  lib_a-cargl.o   lib_a-casinhf.o  lib_a-catanf.o   lib_a-catanl.o   lib_a-ccoshf.o  lib_a-cephes_subrf.o  lib_a-cexpl.o         lib_a-clog.o    lib_a-clogl.o    lib_a-cpow.o   lib_a-cprojf.o  lib_a-creall.o  lib_a-csinhf.o  lib_a-csqrtf.o  lib_a-ctanh.o 

$(BUILD)/newlib/_done: $(BUILD)/newlib/newlib/libc.a 
	echo "done" >$@

$(BUILD)/newlib/newlib/libc.a: $(BUILD)/newlib/newlib/Makefile $(BUILD)/ndk-include/_ndk $(NEWLIB_FILES)
	$(MAKE) -C $(BUILD)/newlib/newlib $(LOG)
	$(MAKE) -C $(BUILD)/newlib/newlib install $(LOG)
	mkdir -p $(BUILD)/newlib/complex
	cd $(BUILD)/newlib/complex && $(PREFIX)/bin/m68k-amigaos-ar x $(PREFIX)/m68k-amigaos/lib/libm.a $(COMPLEX_FILES)
	mkdir -p $(BUILD)/newlib/complex/libb
	cd $(BUILD)/newlib/complex/libb && $(PREFIX)/bin/m68k-amigaos-ar x $(PREFIX)/m68k-amigaos/lib/libb/libm.a $(COMPLEX_FILES)
	mkdir -p $(BUILD)/newlib/complex/libm020
	cd $(BUILD)/newlib/complex/libm020 && $(PREFIX)/bin/m68k-amigaos-ar x $(PREFIX)/m68k-amigaos/lib/libm020/libm.a $(COMPLEX_FILES)
	mkdir -p $(BUILD)/newlib/complex/libm020/libb
	cd $(BUILD)/newlib/complex/libm020/libb && $(PREFIX)/bin/m68k-amigaos-ar x $(PREFIX)/m68k-amigaos/lib/libm020/libb/libm.a $(COMPLEX_FILES)
	mkdir -p $(BUILD)/newlib/complex/libm020/libb32
	cd $(BUILD)/newlib/complex/libm020/libb32 && $(PREFIX)/bin/m68k-amigaos-ar x $(PREFIX)/m68k-amigaos/lib/libm020/libb32/libm.a $(COMPLEX_FILES)
	touch $@

ifeq (,$(wildcard $(BUILD)/gcc/_done))
$(BUILD)/newlib/newlib/Makefile: $(BUILD)/gcc/_done
endif

$(BUILD)/newlib/newlib/Makefile: projects/newlib-cygwin/configure  
	mkdir -p $(BUILD)/newlib/newlib
	cd $(BUILD)/newlib/newlib && $(NEWLIB_CONFIG) CFLAGS="$(TARGET_C_FLAGS)" $(PWD)/projects/newlib-cygwin/newlib/configure --host=m68k-amigaos --prefix=$(PREFIX) $(LOG)

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
	@$(PWD)/sdk/install install $(sdk) $(PREFIX)

SDKS0=$(shell find sdk/*.sdk)
SDKS=$(patsubst sdk/%.sdk,%,$(SDKS0))
.PHONY: $(SDKS)
all-sdk: $(SDKS)

$(SDKS): libnix
	$(MAKE) sdk=$@ $(LOG)
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
