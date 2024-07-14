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
$(eval SHELL = $(shell which bash 2>/dev/null) ) 

PREFIX ?= /opt/amiga
export PATH := $(PREFIX)/bin:$(PATH)

TARGET ?= m68k-amigaos

UNAME_S := $(shell uname -s)
BUILD := $(shell pwd)/build-$(UNAME_S)-$(TARGET)
PROJECTS := $(shell pwd)/projects
DOWNLOAD := $(shell pwd)/download
__BUILDDIR := $(shell mkdir -p $(BUILD))
__PROJECTDIR := $(shell mkdir -p $(PROJECTS))
__DOWNLOADDIR := $(shell mkdir -p $(DOWNLOAD))

GCC_VERSION ?= $(shell cat 2>/dev/null $(PROJECTS)/gcc/gcc/BASE-VER)

ifeq ($(UNAME_S), Darwin)
	SED := gsed
else ifeq ($(UNAME_S), FreeBSD)
	SED := gsed
else
	SED := sed
endif

# get git urls and branches from .repos file
$(shell  [ ! -f .repos ] && cp default-repos .repos)
modules := $(shell cat .repos | $(SED) -e 's/[[:blank:]]\+/ /g' | cut -d' ' -f1)
get_url = $(shell grep $(1) .repos | $(SED) -e 's/[[:blank:]]\+/ /g' | cut -d' ' -f2)
get_branch = $(shell grep $(1) .repos | $(SED) -e 's/[[:blank:]]\+/ /g' | cut -d' ' -f3)
$(foreach modu,$(modules),$(eval $(modu)_URL=$(call get_url,$(modu))))
$(foreach modu,$(modules),$(eval $(modu)_BRANCH=$(call get_branch,$(modu))))

ifneq ($(NDK),3.9)
NDK_URL              := http://aminet.net/dev/misc/NDK3.2.lha
NDK_ARC_NAME         := NDK3.2
NDK_FOLDER_NAME      := NDK3.2
NDK_FOLDER_NAME_H    := NDK3.2/Include_H
NDK_FOLDER_NAME_I    := NDK3.2/Include_I
NDK_FOLDER_NAME_FD   := NDK3.2/FD
NDK_FOLDER_NAME_SFD  := NDK3.2/SFD
NDK_FOLDER_NAME_LIBS := NDK3.2/lib
else
NDK_URL         := http://hp.alinea-computer.de/AmigaOS/NDK39.lha
NDK_ARC_NAME    := NDK3.9
NDK_FOLDER_NAME := NDK_3.9/Include
NDK_FOLDER_NAME_H    := NDK_3.9/Include/include_h
NDK_FOLDER_NAME_I    := NDK_3.9/Include/include_i
NDK_FOLDER_NAME_FD   := NDK_3.9/Include/fd
NDK_FOLDER_NAME_SFD  := NDK_3.9/Include/sfd
NDK_FOLDER_NAME_LIBS := NDK_3.9/Include/linker_libs
endif

CFLAGS ?= -Os
CXXFLAGS ?= $(CFLAGS)
CFLAGS_FOR_TARGET ?= -O2 -fomit-frame-pointer
CXXFLAGS_FOR_TARGET ?= $(CFLAGS_FOR_TARGET) -fno-exceptions -fno-rtti

E:=CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" CFLAGS_FOR_BUILD="$(CFLAGS)" CXXFLAGS_FOR_BUILD="$(CXXFLAGS)"  CFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)" CXXFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)"

THREADS ?= no

# =================================================
# determine exe extension for cygwin
$(eval MYMAKE = $(shell which $(MAKE) 2>/dev/null) )
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
ifneq ($(VERBOSE),)
verbose = $(VERBOSE)
endif
ifeq ($(verbose),)
L1 = ; ($(FLOCK) 200; echo -e \\033[33m$$__p...\\033[0m >>.state; echo -ne \\033[33m$$__p...\\033[0m ) 200>.lock; mkdir -p log; __l="log/$$__p.log" ; (
L2 = )$(TEEEE) "$$__l"; __r=$$?; ($(FLOCK) 200; if (( $$__r > 0 )); then \
  echo -e \\n\\033[K\\033[31m$$__p...failed\\033[0m; \
   $(SED) -n '1,/\*\*\*/p' "$$__l" | tail -n 100; \
  echo -e \\033[31m$$__p...failed\\033[0m; \
  echo -e use \\033[1mless \"$$__l\"\\033[0m to view the full log and search for \*\*\*; \
  else echo -e \\n\\033[K\\033[32m$$__p...done\\033[0m; fi \
  ;grep -v "$$__p" .state >.state0 2>/dev/null; mv .state0 .state ;echo -n $$(cat .state | paste -sd " " -); ) 200>.lock; [[ $$__r -gt 0 ]] && exit $$__r; echo -n ""
else
L1 = ;(
L2 = )
endif

# =================================================
# download files
# =================================================
define get-file
$(L0)"downloading $(1)"$(L1) cd $(DOWNLOAD); \
  mv $(3) $(3).bak; \
  wget $(2) -O $(3).neu; \
  if [ -s $(3).neu ]; then \
    if [ "$$(cmp --silent $(3).neu $(3).bak); echo $$?" == 0 ]; then \
      mv $(3).bak $(3); \
      rm $(3).neu; \
    else \
      mv $(3).neu $(3); \
      rm -f $(3).bak; \
    fi \
  else \
    rm $(3).neu; \
  fi; \
  cd .. $(L2)
endef

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
	@echo "make help					display this help"
	@echo "make info					print prefix and other flags"
	@echo "make all 					build and install all"
	@echo "make min 					build and install the minimal to use gcc"
	@echo "make <target>					builds a target: binutils, gcc, gprof, fd2sfd, fd2pragma, ira, sfdc, vasm, vbcc, vlink, libnix, ixemul, libgcc, clib2, libdebug, libSDL12, libpthread, ndk, ndk13"
	@echo "make clean					remove the build folder"
	@echo "make clean-<target>				remove the target's build folder"
	@echo "make drop-prefix				remove all content from the prefix folder"
	@echo "make update					perform git pull for all targets"
	@echo "make update-<target>				perform git pull for the given target"
	@echo "make sdk=<sdk>					install the sdk <sdk>"
	@echo "make all-sdk					install all sdks"
	@echo "make l   					print the last log entry for each project"
	@echo "make b   					print the branch for each project"
	@echo "make r   					print the remote for each project"
	@echo "make v [date=<date>]				checkout all projects for a given date, checkout to branch if no date given"
	@echo "make branch branch=<branch> mod=<module>	switch the module to the given branch"
	@echo ""
	@echo "the optional parameter THREADS=posix will build it with thread support"

# =================================================
# all
# =================================================
.PHONY: all gcc gdb gprof binutils fd2sfd fd2pragma ira sfdc vasm libnix ixemul libgcc clib2 libdebug libpthread ndk ndk13 min
all: gcc binutils gdb gprof fd2sfd fd2pragma ira sfdc vasm libnix ixemul libgcc clib2 libdebug libpthread ndk ndk13 libSDL12

min: binutils gcc gprof libnix libgcc

# =================================================
# clean
# =================================================
ifneq ($(OWNMPC),)
.PHONY: clean-gmp clean-mpc clean-mpfr
clean: clean-gmp clean-mpc clean-mpfr
endif

.PHONY: drop-prefix clean clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vasm clean-vbcc clean-vlink clean-libnix clean-ixemul clean-libgcc clean-clib2 clean-libdebug clean-libpthread clean-newlib clean-ndk
clean: clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vasm clean-vbcc clean-vlink clean-libnix clean-ixemul clean-clib2 clean-libdebug clean-libpthread clean-newlib clean-ndk clean-gmp clean-mpc clean-mpfr clean-libSDL12
	rm -rf $(BUILD)
	rm -rf *.log
	mkdir -p $(BUILD)

clean-gcc:
	rm -rf $(BUILD)/gcc

clean-gmp:
	rm -rf $(PROJECTS)/gcc/gmp

clean-mpc:
	rm -rf $(PROJECTS)/gcc/mpc

clean-mpfr:
	rm -rf $(PROJECTS)/gcc/mpfr

clean-libgcc:
	rm -rf $(BUILD)/gcc/$(TARGET)
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

clean-libpthread:
	rm -rf $(BUILD)/libpthread

clean-newlib:
	rm -rf $(BUILD)/newlib

# drop-prefix drops the files from prefix folder
drop-prefix:
	rm -rf $(PREFIX)/bin
	rm -rf $(PREFIX)/etc
	rm -rf $(PREFIX)/info
	rm -rf $(PREFIX)/libexec
	rm -rf $(PREFIX)/lib/gcc
	rm -rf $(PREFIX)/$(TARGET)
	rm -rf $(PREFIX)/man
	rm -rf $(PREFIX)/share
	@mkdir -p $(PREFIX)/bin

# =================================================
# update all projects
# =================================================

.PHONY: update update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vasm update-vbcc update-vlink update-libnix update-ixemul update-clib2 update-libdebug update-libSDL12 update-libpthread update-ndk update-newlib update-netinclude
update: update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vasm update-vbcc update-vlink update-libnix update-ixemul update-clib2 update-libdebug update-libSDL12 update-libpthread update-ndk update-newlib update-netinclude
	+$(MAKE) -B $(DOWNLOAD)/vbcc_target_m68k-amigaos.lha
	+$(MAKE) -B $(DOWNLOAD)/vbcc_target_m68k-kick13.lha
	+$(MAKE) -B $(DOWNLOAD)/$(NDK_ARC_NAME).lha
	+$(MAKE) -B $(DOWNLOAD)/ixemul-sdk.lha
	+$(MAKE) -B $(DOWNLOAD)/$(ZLIB).tar.xz
	+$(MAKE) -B $(DOWNLOAD)/$(LIBPNG).tar.xz
	+$(MAKE) -B $(DOWNLOAD)/$(LIBFREETYPE).tar.xz
	+$(MAKE) -B $(DOWNLOAD)/$(LIBSDLMIXER).tar.gz
	+$(MAKE) -B $(DOWNLOAD)/$(LIBSDLTTF).tar.gz

update-gcc: $(PROJECTS)/gcc/configure
	@cd $(PROJECTS)/gcc && git pull || (export DEPTH=16; while true; do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH && break; export DEPTH=$$(($$DEPTH+$$DEPTH));done)

update-binutils: $(PROJECTS)/binutils/configure
	@cd $(PROJECTS)/binutils && git pull || (export DEPTH=16; while true; do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH && break; export DEPTH=$$(($$DEPTH+$$DEPTH));done)

update-fd2sfd: $(PROJECTS)/fd2sfd/configure
	@cd $(PROJECTS)/fd2sfd && git pull

update-fd2pragma: $(PROJECTS)/fd2pragma/makefile
	@cd $(PROJECTS)/fd2pragma && git pull

update-ira: $(PROJECTS)/ira/Makefile
	@cd $(PROJECTS)/ira && git pull

update-sfdc: $(PROJECTS)/sfdc/configure
	@cd $(PROJECTS)/sfdc && git pull

update-vasm: $(PROJECTS)/vasm/Makefile
	@cd $(PROJECTS)/vasm && git pull

update-vbcc: $(PROJECTS)/vbcc/Makefile
	@cd $(PROJECTS)/vbcc && git pull

update-vlink: $(PROJECTS)/vlink/Makefile
	@cd $(PROJECTS)/vlink && git pull

update-libnix: $(PROJECTS)/libnix/Makefile.gcc6
	@cd $(PROJECTS)/libnix && git pull

update-ixemul: $(PROJECTS)/ixemul/configure
	@cd $(PROJECTS)/ixemul && git pull

update-clib2: $(PROJECTS)/clib2/LICENSE
	@cd $(PROJECTS)/clib2 && git pull

update-libdebug: $(PROJECTS)/libdebug/configure
	@cd $(PROJECTS)/libdebug && git pull

update-libSDL12: $(PROJECTS)/libSDL12/Makefile
	@cd $(PROJECTS)/libSDL12 && git pull

update-libpthread: $(PROJECTS)/aros-stuff/pthreads/Makefile
	@cd $(PROJECTS)/aros-stuff && git pull

update-ndk: $(DOWNLOAD)/$(NDK_ARC_NAME).lha
	$(MAKE) $(PROJECTS)/$(NDK_FOLDER_NAME).info

update-newlib: $(PROJECTS)/newlib-cygwin/newlib/configure
	@cd $(PROJECTS)/newlib-cygwin && git pull

update-netinclude: $(PROJECTS)/amiga-netinclude/README.md
	@cd $(PROJECTS)/amiga-netinclude && git pull

update-gmp:
	if [ -a $(DOWNLOAD)/$(GMPFILE) ]; \
	then rm -rf $(PROJECTS)/$(GMP); rm -rf $(PROJECTS)/gcc/gmp; \
	else cd $(DOWNLOAD) && wget ftp://ftp.gnu.org/gnu/gmp/$(GMPFILE); \
	fi;
	@cd $(PROJECTS) && tar xf $(DOWNLOAD)/$(GMPFILE)

update-mpc:
	if [ -a $(DOWNLOAD)/$(MPCFILE) ]; \
	then rm -rf projcts/$(MPC); rm -rf $(PROJECTS)/gcc/mpc; \
	else cd $(DOWNLOAD) && wget ftp://ftp.gnu.org/gnu/mpc/$(MPCFILE); \
	fi;
	@cd $(PROJECTS) && tar xf $(DOWNLOAD)/$(MPCFILE)

update-mpfr:
	if [ -a $(DOWNLOAD)/$(MPFRFILE) ]; \
	then rm -rf $(PROJECTS)/$(MPFR); rm -rf $(PROJECTS)/gcc/mpfr; \
	else cd $(DOWNLOAD) && wget ftp://ftp.gnu.org/gnu/mpfr/$(MPFRFILE); \
	fi;
	@cd $(PROJECTS) && tar xf $(DOWNLOAD)/$(MPFRFILE)

# =================================================
# B I N
# =================================================

# =================================================
# binutils
# =================================================
CONFIG_BINUTILS =--prefix=$(PREFIX) --target=$(TARGET) --disable-werror --enable-tui --disable-nls

ifneq (m68k-elf,$(TARGET))
CONFIG_BINUTILS += --disable-plugins
endif

# FreeBSD, OSX : libs added by the command brew install gmp
ifeq (Darwin, $(findstring Darwin, $(UNAME_S)))
	BREW_PREFIX := $$(brew --prefix)
	CONFIG_BINUTILS += --with-libgmp-prefix=$(BREW_PREFIX)
endif

ifeq (FreeBSD, $(findstring FreeBSD, $(UNAME_S)))
	PORTS_PREFIX?=/usr/local
	CONFIG_BINUTILS += --with-libgmp-prefix=$(PORTS_PREFIX)
endif

BINUTILS_CMD := $(TARGET)-addr2line $(TARGET)-ar $(TARGET)-as $(TARGET)-c++filt \
	$(TARGET)-ld $(TARGET)-nm $(TARGET)-objcopy $(TARGET)-objdump $(TARGET)-ranlib \
	$(TARGET)-readelf $(TARGET)-size $(TARGET)-strings $(TARGET)-strip
BINUTILS := $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(BINUTILS_CMD))

BINUTILS_DIR := . bfd gas ld binutils opcodes
BINUTILSD := $(patsubst %,$(PROJECTS)/binutils/%, $(BINUTILS_DIR))

ALL_GDB := all-gdb
INSTALL_GDB := install-gdb

binutils: $(BUILD)/binutils/_done

$(BUILD)/binutils/_done: $(BUILD)/binutils/Makefile $(shell find 2>/dev/null $(PROJECTS)/binutils -not \( -path $(PROJECTS)/binutils/.git -prune \) -not \( -path $(PROJECTS)/binutils/gprof -prune \) -type f)
	@touch -t 0001010000 $(PROJECTS)/binutils/binutils/arparse.y
	@touch -t 0001010000 $(PROJECTS)/binutils/binutils/arlex.l
	@touch -t 0001010000 $(PROJECTS)/binutils/ld/ldgram.y
	@touch -t 0001010000 $(PROJECTS)/binutils/intl/plural.y
	$(L0)"make binutils bfd"$(L1)$(MAKE) -C $(BUILD)/binutils all-bfd $(L2)
	$(L0)"make binutils gas"$(L1)$(MAKE) -C $(BUILD)/binutils all-gas $(L2)
	$(L0)"make binutils binutils"$(L1)$(MAKE) -C $(BUILD)/binutils all-binutils $(L2)
	$(L0)"make binutils ld"$(L1)$(MAKE) -C $(BUILD)/binutils all-ld $(L2)
	$(L0)"install binutils"$(L1)$(MAKE) -C $(BUILD)/binutils install-gas install-binutils install-ld $(L2)
	@echo "done" >$@

$(BUILD)/binutils/Makefile: $(PROJECTS)/binutils/configure
	@mkdir -p $(BUILD)/binutils
	$(L0)"configure binutils"$(L1) cd $(BUILD)/binutils && $(E) $(PROJECTS)/binutils/configure $(CONFIG_BINUTILS) $(L2)


$(PROJECTS)/binutils/configure:
	@cd $(PROJECTS) &&	git clone -b $(binutils_BRANCH) --depth 16 $(binutils_URL) binutils

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
CONFIG_GRPOF := --prefix=$(PREFIX) --target=$(TARGET) --disable-werror

gprof: $(BUILD)/binutils/_gprof

$(BUILD)/binutils/_gprof: $(BUILD)/binutils/gprof/Makefile $(shell find 2>/dev/null $(PROJECTS)/binutils/gprof -type f)
	$(L0)"make gprof"$(L1)$(MAKE) -C $(BUILD)/binutils/gprof all $(L2)
	$(L0)"install gprof"$(L1)$(MAKE) -C $(BUILD)/binutils/gprof install $(L2)
	@echo "done" >$@

$(BUILD)/binutils/gprof/Makefile: $(PROJECTS)/binutils/configure $(BUILD)/binutils/_done
	@mkdir -p $(BUILD)/binutils/gprof
	$(L0)"configure gprof"$(L1) cd $(BUILD)/binutils/gprof && $(E) $(PROJECTS)/binutils/gprof/configure $(CONFIG_GRPOF) $(L2)

# =================================================
# gcc
# =================================================
CONFIG_GCC = --prefix=$(PREFIX) --target=$(TARGET) --enable-languages=c,c++,objc,$(ADDLANG) --enable-version-specific-runtime-libs --disable-libssp --disable-nls \
	--with-headers=$(PROJECTS)/newlib-cygwin/newlib/libc/sys/amigaos/include/ --disable-shared --enable-threads=$(THREADS) \
	--with-stage1-ldflags="-dynamic-libgcc -dynamic-libstdc++" --with-boot-ldflags="-dynamic-libgcc -dynamic-libstdc++"	

# FreeBSD, OSX : libs added by the command brew install gmp mpfr libmpc
ifeq (Darwin, $(findstring Darwin, $(UNAME_S)))
	BREW_PREFIX := $$(brew --prefix)
	CONFIG_GCC += --with-gmp=$(BREW_PREFIX) \
		--with-mpfr=$(BREW_PREFIX) \
		--with-mpc=$(BREW_PREFIX)
endif

ifeq (FreeBSD, $(findstring FreeBSD, $(UNAME_S)))
	PORTS_PREFIX?=/usr/local
	CONFIG_GCC += --with-gmp=$(PORTS_PREFIX) \
		--with-mpfr=$(PORTS_PREFIX) \
		--with-mpc=$(PORTS_PREFIX)
endif

GCC_CMD := $(TARGET)-c++ $(TARGET)-g++ $(TARGET)-gcc-$(GCC_VERSION) $(TARGET)-gcc-nm \
	$(TARGET)-gcov $(TARGET)-gcov-tool $(TARGET)-cpp $(TARGET)-gcc $(TARGET)-gcc-ar \
	$(TARGET)-gcc-ranlib $(TARGET)-gcov-dump
GCC := $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(GCC_CMD))

GCC_DIR := . gcc gcc/c gcc/c-family gcc/cp gcc/objc gcc/config/m68k libiberty libcpp libdecnumber
GCCD := $(patsubst %,$(PROJECTS)/gcc/%, $(GCC_DIR))

gcc: $(BUILD)/gcc/_done

$(BUILD)/gcc/_done: $(BUILD)/gcc/Makefile $(shell find 2>/dev/null $(GCCD) -maxdepth 1 -type f )
	$(L0)"make gcc"$(L1) $(MAKE) -C $(BUILD)/gcc all-gcc $(L2)
	$(L0)"install gcc"$(L1) $(MAKE) -C $(BUILD)/gcc install-gcc $(L2)
	@echo "done" >$@

$(BUILD)/gcc/Makefile: $(PROJECTS)/gcc/configure $(BUILD)/binutils/_done
	@mkdir -p $(BUILD)/gcc
ifneq ($(OWNGMP),)
	@mkdir -p $(PROJECTS)/gcc/gmp
	@mkdir -p $(PROJECTS)/gcc/mpc
	@mkdir -p $(PROJECTS)/gcc/mpfr
	@rsync -a --no-group $(PROJECTS)/$(GMP)/* $(PROJECTS)/gcc/gmp
	@rsync -a --no-group $(PROJECTS)/$(MPC)/* $(PROJECTS)/gcc/mpc
	@rsync -a --no-group $(PROJECTS)/$(MPFR)/* $(PROJECTS)/gcc/mpfr
endif
	$(L0)"configure gcc"$(L1) cd $(BUILD)/gcc && $(E) $(PROJECTS)/gcc/configure $(CONFIG_GCC) $(L2)

$(PROJECTS)/gcc/configure:
	@cd $(PROJECTS) &&	git clone -b $(gcc_BRANCH) --depth 16 $(gcc_URL)

# =================================================
# fd2sfd
# =================================================
CONFIG_FD2SFD := --prefix=$(PREFIX) --target=$(TARGET)

fd2sfd: $(BUILD)/fd2sfd/_done

$(BUILD)/fd2sfd/_done: $(PREFIX)/bin/fd2sfd
	@echo "done" >$@

$(PREFIX)/bin/fd2sfd: $(BUILD)/fd2sfd/Makefile $(shell find 2>/dev/null $(PROJECTS)/fd2sfd -not \( -path $(PROJECTS)/fd2sfd/.git -prune \) -type f)
	$(L0)"make fd2sfd"$(L1) $(MAKE) -C $(BUILD)/fd2sfd all $(L2)
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install fd2sfd"$(L1) $(MAKE) -C $(BUILD)/fd2sfd install $(L2)

$(BUILD)/fd2sfd/Makefile: $(PROJECTS)/fd2sfd/configure
	@mkdir -p $(BUILD)/fd2sfd
	$(L0)"configure fd2sfd"$(L1) cd $(BUILD)/fd2sfd && $(E) $(PROJECTS)/fd2sfd/configure $(CONFIG_FD2SFD) $(L2)

$(PROJECTS)/fd2sfd/configure:
	@cd $(PROJECTS) &&	git clone -b $(fd2sfd_BRANCH) --depth 4 $(fd2sfd_URL)
	for i in $$(find patches/fd2sfd/ -type f); \
	do if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "$(PROJECTS)/$${j%.diff}" "$$i"; fi ; done

# =================================================
# fd2pragma
# =================================================
fd2pragma: $(BUILD)/fd2pragma/_done

$(BUILD)/fd2pragma/_done: $(PREFIX)/bin/fd2pragma
	@echo "done" >$@

$(PREFIX)/bin/fd2pragma: $(BUILD)/fd2pragma/fd2pragma
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install fd2sfd"$(L1) install $(BUILD)/fd2pragma/fd2pragma $(PREFIX)/bin/ $(L2)

$(BUILD)/fd2pragma/fd2pragma: $(PROJECTS)/fd2pragma/makefile $(shell find 2>/dev/null $(PROJECTS)/fd2pragma -not \( -path $(PROJECTS)/fd2pragma/.git -prune \) -type f)
	@mkdir -p $(BUILD)/fd2pragma
	$(L0)"make fd2sfd"$(L1) cd $(PROJECTS)/fd2pragma && $(CC) -o $@ $(CFLAGS) fd2pragma.c $(L2)

$(PROJECTS)/fd2pragma/makefile:
	@cd $(PROJECTS) &&	git clone -b $(fd2pragma_BRANCH) --depth 4 $(fd2pragma_URL)

# =================================================
# ira
# =================================================
ira: $(BUILD)/ira/_done

$(BUILD)/ira/_done: $(PREFIX)/bin/ira
	@echo "done" >$@

$(PREFIX)/bin/ira: $(BUILD)/ira/ira
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install ira"$(L1) install $(BUILD)/ira/ira $(PREFIX)/bin/ $(L2)

$(BUILD)/ira/ira: $(PROJECTS)/ira/Makefile $(shell find 2>/dev/null $(PROJECTS)/ira -not \( -path $(PROJECTS)/ira/.git -prune \) -type f)
	@mkdir -p $(BUILD)/ira
	$(L0)"make ira"$(L1) cd $(PROJECTS)/ira && $(CC) -o $@ $(CFLAGS) *.c -std=c99 $(L2)

$(PROJECTS)/ira/Makefile:
	@cd $(PROJECTS) &&	git clone -b $(ira_BRANCH) --depth 4 $(ira_URL)

# =================================================
# sfdc
# =================================================
CONFIG_SFDC := --prefix=$(PREFIX) --target=$(TARGET)

sfdc: $(BUILD)/sfdc/_done

$(BUILD)/sfdc/_done: $(PREFIX)/bin/sfdc
	@echo "done" >$@

$(PREFIX)/bin/sfdc: $(BUILD)/sfdc/Makefile
	$(L0)"make sfdc"$(L1) $(MAKE) -C $(BUILD)/sfdc sfdc $(L2)
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install sfdc"$(L1) install $(BUILD)/sfdc/sfdc $(PREFIX)/bin $(L2)

$(BUILD)/sfdc/Makefile: $(PROJECTS)/sfdc/configure $(shell find 2>/dev/null $(PROJECTS)/sfdc -not \( -path $(PROJECTS)/sfdc/.git -prune \)  -type f)
	@rsync -a --no-group $(PROJECTS)/sfdc $(BUILD)/ --exclude .git
	$(L0)"configure sfdc"$(L1) cd $(BUILD)/sfdc && $(E) $(BUILD)/sfdc/configure $(CONFIG_SFDC) $(L2)

$(PROJECTS)/sfdc/configure:
	@cd $(PROJECTS) &&	git clone -b $(sfdc_BRANCH) --depth 4 $(sfdc_URL)

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

$(BUILD)/vasm/Makefile: $(PROJECTS)/vasm/Makefile $(shell find 2>/dev/null $(PROJECTS)/vasm -not \( -path $(PROJECTS)/vasm/.git -prune \) -type f)
	@rsync -a --no-group $(PROJECTS)/vasm $(BUILD)/ --exclude .git
	@touch $(BUILD)/vasm/Makefile

$(PROJECTS)/vasm/Makefile:
	@cd $(PROJECTS) &&	git clone -b $(vasm_BRANCH) --depth 4 $(vasm_URL)

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

$(BUILD)/vbcc/Makefile: $(PROJECTS)/vbcc/Makefile $(shell find 2>/dev/null $(PROJECTS)/vbcc -not \( -path $(PROJECTS)/vbcc/.git -prune \) -type f)
	@rsync -a --no-group $(PROJECTS)/vbcc $(BUILD)/ --exclude .git
	@mkdir -p $(BUILD)/vbcc/bin
	@touch $(BUILD)/vbcc/Makefile

$(PROJECTS)/vbcc/Makefile:
	@cd $(PROJECTS) &&	git clone -b $(vbcc_BRANCH) --depth 4 $(vbcc_URL)

# =================================================
# vlink
# =================================================
VLINK_CMD := vlink
VLINK := $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VLINK_CMD))

vlink: $(BUILD)/vlink/_done vbcc-target

$(BUILD)/vlink/_done: $(BUILD)/vlink/Makefile $(shell find 2>/dev/null $(PROJECTS)/vlink -not \( -path $(PROJECTS)/vlink/.git -prune \) -type f)
	$(L0)"make vlink"$(L1) cd $(BUILD)/vlink && TARGET=m68k $(MAKE) $(L2)
	@mkdir -p $(PREFIX)/bin/
	$(L0)"install vlink"$(L1) install $(BUILD)/vlink/vlink $(PREFIX)/bin/ $(L2)
	@echo "done" >$@

$(BUILD)/vlink/Makefile: $(PROJECTS)/vlink/Makefile
	@rsync -a --no-group $(PROJECTS)/vlink $(BUILD)/ --exclude .git

$(PROJECTS)/vlink/Makefile:
	@cd $(PROJECTS) &&	git clone -b $(vlink_BRANCH) --depth 4 $(vlink_URL)

.PHONY: lha
lha: $(BUILD)/_lha_done

$(BUILD)/_lha_done:
	@if [ ! -e "$$(which lha 2>/dev/null)" ]; then \
	  cd $(BUILD) && rm -rf lha; \
	  $(L00)"clone lha"$(L1) git clone -b $(lha_BRANCH) $(lha_URL); $(L2); \
	  cd lha; \
	  $(L00)"configure lha"$(L1) aclocal; autoheader; automake -a; autoconf; ./configure; $(L2); \
	  $(L00)"make lha"$(L1) make all; $(L2); \
	  $(L00)"install lha"$(L1) mkdir -p $(PREFIX)/bin/; install src/lha$(EXEEXT) $(PREFIX)/bin/lha$(EXEEXT); $(L2); \
	fi
	@echo "done" >$@


.PHONY: vbcc-target
vbcc-target: $(BUILD)/vbcc_target_$(TARGET)/_done $(BUILD)/vbcc_target_m68k-kick13/_done

$(BUILD)/vbcc_target_m68k-kick13/_done: $(BUILD)/vbcc_target_m68k-kick13.info patches/vc.config $(BUILD)/vasm/_done
	@mkdir -p $(PREFIX)/m68k-kick13/vbcc/include
	$(L0)"copying vbcc headers"$(L1) rsync --no-group $(BUILD)/vbcc_target_m68k-kick13/targets/m68k-kick13/include/* $(PREFIX)/m68k-kick13/vbcc/include $(L2)
	@mkdir -p $(PREFIX)/m68k-kick13/vbcc/lib
	$(L0)"copying vbcc headers"$(L1) rsync --no-group $(BUILD)/vbcc_target_m68k-kick13/targets/m68k-kick13/lib/* $(PREFIX)/m68k-kick13/vbcc/lib $(L2)
	@echo "done" >$@
	$(L0)"creating vbcc kick13 config"$(L1) $(SED) -e "s|PREFIX|$(PREFIX)|g" patches/kick13.config >$(BUILD)/vasm/kick13.config ;\
	install $(BUILD)/vasm/kick13.config $(PREFIX)/bin/ $(L2)

$(BUILD)/vbcc_target_m68k-amigaos/_done: $(BUILD)/vbcc_target_m68k-amigaos.info $(BUILD)/vasm/_done
	@mkdir -p $(PREFIX)/m68k-amigaos/vbcc/include
	$(L0)"copying vbcc headers"$(L1) rsync --no-group $(BUILD)/vbcc_target_m68k-amigaos/targets/m68k-amigaos/include/* $(PREFIX)/m68k-amigaos/vbcc/include $(L2)
	@mkdir -p $(PREFIX)/m68k-amigaos/vbcc/lib
	$(L0)"copying vbcc headers"$(L1) rsync --no-group $(BUILD)/vbcc_target_m68k-amigaos/targets/m68k-amigaos/lib/* $(PREFIX)/m68k-amigaos/vbcc/lib $(L2)
	@echo "done" >$@
	$(L0)"creating vbcc config"$(L1) $(SED) -e "s|PREFIX|$(PREFIX)|g" patches/vc.config >$(BUILD)/vasm/vc.config ;\
	install $(BUILD)/vasm/vc.config $(PREFIX)/bin/ $(L2)


$(BUILD)/vbcc_target_m68k-kick13.info: $(DOWNLOAD)/vbcc_target_m68k-kick13.lha $(BUILD)/_lha_done
	$(L0)"unpack vbcc_target_m68k-kick13"$(L1) cd $(BUILD) && lha xf $(DOWNLOAD)/vbcc_target_m68k-kick13.lha $(L2)
	@touch $(BUILD)/vbcc_target_m68k-kick13.info

$(BUILD)/vbcc_target_m68k-amigaos.info: $(DOWNLOAD)/vbcc_target_m68k-amigaos.lha $(BUILD)/_lha_done
	$(L0)"unpack vbcc_target_m68k-amigaos"$(L1) cd $(BUILD) && lha xf $(DOWNLOAD)/vbcc_target_m68k-amigaos.lha $(L2)
	@touch $(BUILD)/vbcc_target_m68k-amigaos.info

$(DOWNLOAD)/vbcc_target_m68k-kick13.lha:
	$(call get-file,vbcc_target13,http://aminet.net/dev/c/vbcc_target_m68k-kick13.lha,vbcc_target_m68k-kick13.lha)

$(DOWNLOAD)/vbcc_target_m68k-amigaos.lha:
	$(call get-file,vbcc_target,http://aminet.net/dev/c/vbcc_target_m68k-amiga.lha,vbcc_target_m68k-amigaos.lha)

# =================================================
# L I B R A R I E S
# =================================================
# =================================================
# NDK - no git
# =================================================

NDK_INCLUDE = $(shell find 2>/dev/null $(PROJECTS)/$(NDK_FOLDER_NAME_H) -type f)
NDK_INCLUDE_SFD = $(shell find 2>/dev/null $(PROJECTS)/$(NDK_FOLDER_NAME_SFD) -type f -name *.sfd)
NDK_INCLUDE_INLINE = $(patsubst $(PROJECTS)/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$(PREFIX)/$(TARGET)/ndk-include/inline/%.h,$(NDK_INCLUDE_SFD))
NDK_INCLUDE_INLINE_VBCC = $(patsubst $(PROJECTS)/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$(PREFIX)/$(TARGET)/ndk-include/inline/%_protos.h,$(NDK_INCLUDE_SFD))
NDK_INCLUDE_LVO    = $(patsubst $(PROJECTS)/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$(PREFIX)/$(TARGET)/ndk-include/lvo/%_lib.i,$(NDK_INCLUDE_SFD))
NDK_INCLUDE_PROTO  = $(patsubst $(PROJECTS)/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$(PREFIX)/$(TARGET)/ndk-include/proto/%.h,$(NDK_INCLUDE_SFD))
SYS_INCLUDE2 = $(filter-out $(NDK_INCLUDE_PROTO),$(patsubst $(PROJECTS)/$(NDK_FOLDER_NAME_H)/%,$(PREFIX)/$(TARGET)/ndk-include/%, $(NDK_INCLUDE)))

.PHONY: ndk-inline ndk-inline-vbcc ndk-lvo ndk-proto

ndk: $(BUILD)/ndk-include_ndk

$(BUILD)/ndk-include_ndk: $(BUILD)/ndk-include_ndk0 $(NDK_INCLUDE_INLINE) $(NDK_INCLUDE_INLINE_VBCC) $(NDK_INCLUDE_LVO) $(NDK_INCLUDE_PROTO) $(PROJECTS)/fd2sfd/configure $(PROJECTS)/fd2pragma/makefile
	$(MAKE) ndk_inc=1 ndk-proto ndk-lvo ndk-inline ndk-inline-vbcc
	@mkdir -p $(BUILD)/ndk-include/
	@echo "done" >$@

$(BUILD)/ndk-include_ndk0: $(PROJECTS)/$(NDK_FOLDER_NAME).info $(NDK_INCLUDE) $(BUILD)/fd2sfd/_done $(BUILD)/fd2pragma/_done
	@mkdir -p $(PREFIX)/$(TARGET)/ndk-include
	@rsync -a --no-group $(PROJECTS)/$(NDK_FOLDER_NAME_H)/* $(PREFIX)/$(TARGET)/ndk-include --exclude proto --exclude inline
	$(L0)"STDARGing ndk"$(L1) for i in $$(find $(PREFIX)/$(TARGET)/ndk-include/clib/*protos.h -type f); do \
		echo $$i; \
		LC_CTYPE=C $(SED) -i.bak -E 's/([a-zA-Z0-9 _]*)([[:blank:]]+|\*)([a-zA-Z0-9_]+)\(/\1\2 __stdargs \3(/g' $$i; \
		rm $$i.bak; done $(L2)	
	@rsync -a --no-group $(PROJECTS)/$(NDK_FOLDER_NAME_I)/* $(PREFIX)/$(TARGET)/ndk-include
	@mkdir -p $(PREFIX)/$(TARGET)/ndk/lib/fd
	@mkdir -p $(PREFIX)/$(TARGET)/ndk/lib/sfd
	@mkdir -p $(PREFIX)/$(TARGET)/ndk/lib/libs
	@rsync -a --no-group $(PROJECTS)/$(NDK_FOLDER_NAME_FD)/* $(PREFIX)/$(TARGET)/ndk/lib/fd
	@rsync -a --no-group $(PROJECTS)/$(NDK_FOLDER_NAME_SFD)/* $(PREFIX)/$(TARGET)/ndk/lib/sfd
	@rsync -a --no-group $(PROJECTS)/$(NDK_FOLDER_NAME_LIBS)/* $(PREFIX)/$(TARGET)/ndk/lib/libs
	@mkdir -p $(PREFIX)/$(TARGET)/ndk-include/proto
	@cp -p $(PROJECTS)/$(NDK_FOLDER_NAME_H)/proto/alib.h $(PREFIX)/$(TARGET)/ndk-include/proto
	@cp -p $(PROJECTS)/$(NDK_FOLDER_NAME_H)/proto/cardres.h $(PREFIX)/$(TARGET)/ndk-include/proto
	@mkdir -p $(PREFIX)/$(TARGET)/ndk-include/inline
	@cp -p $(PROJECTS)/fd2sfd/cross/share/m68k-amigaos/alib.h $(PREFIX)/$(TARGET)/ndk-include/inline
	@cp -p $(PROJECTS)/fd2pragma/Include/inline/stubs.h $(PREFIX)/$(TARGET)/ndk-include/inline
	@cp -p $(PROJECTS)/fd2pragma/Include/inline/macros.h $(PREFIX)/$(TARGET)/ndk-include/inline
	@mkdir -p $(BUILD)/ndk-include/
	@echo "done" >$@

ndk-inline: $(NDK_INCLUDE_INLINE) sfdc $(BUILD)/ndk-include_inline
$(NDK_INCLUDE_INLINE): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD) $(BUILD)/ndk-include_inline $(BUILD)/ndk-include_lvo $(BUILD)/ndk-include_proto $(BUILD)/ndk-include_ndk0
	$(L0)"sfdc inline $(@F)"$(L1) sfdc --target=m68k-amigaos --mode=macros --output=$@ $(patsubst $(PREFIX)/$(TARGET)/ndk-include/inline/%.h,$(PROJECTS)/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$@) $(L2)

ndk-inline-vbcc: $(NDK_INCLUDE_INLINE_VBCC) sfdc $(BUILD)/ndk-include_inline
$(NDK_INCLUDE_INLINE_VBCC): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD) $(BUILD)/ndk-include_inline $(BUILD)/ndk-include_lvo $(BUILD)/ndk-include_proto $(BUILD)/ndk-include_ndk0
	$(L0)"sfdc inline vbcc $(@F)"$(L1) sfdc --target=m68kvbcc-amigaos --mode=macros --output=$@ $(patsubst $(PREFIX)/$(TARGET)/ndk-include/inline/%_protos.h,$(PROJECTS)/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$@) $(L2)

ndk-lvo: $(NDK_INCLUDE_LVO) sfdc
$(NDK_INCLUDE_LVO): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD) $(BUILD)/ndk-include_lvo $(BUILD)/ndk-include_ndk0
	$(L0)"sfdc lvo $(@F)"$(L1) sfdc --target=m68k-amigaos --mode=lvo --output=$@ $(patsubst $(PREFIX)/$(TARGET)/ndk-include/lvo/%_lib.i,$(PROJECTS)/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$@) $(L2)

ndk-proto: $(NDK_INCLUDE_PROTO) sfdc
$(NDK_INCLUDE_PROTO): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD)	$(BUILD)/ndk-include_proto $(BUILD)/ndk-include_ndk0
	$(L0)"sfdc proto $(@F)"$(L1) sfdc --target=m68k-amigaos --mode=proto --output=$@ $(patsubst $(PREFIX)/$(TARGET)/ndk-include/proto/%.h,$(PROJECTS)/$(NDK_FOLDER_NAME_SFD)/%_lib.sfd,$@) $(L2)

$(BUILD)/ndk-include_inline: $(PROJECTS)/$(NDK_FOLDER_NAME).info
	@mkdir -p $(PREFIX)/$(TARGET)/ndk-include/inline
	@mkdir -p $(BUILD)/ndk-include/
	@echo "done" >$@

$(BUILD)/ndk-include_lvo: $(PROJECTS)/$(NDK_FOLDER_NAME).info
	@mkdir -p $(PREFIX)/$(TARGET)/ndk-include/lvo
	@mkdir -p $(PREFIX)/$(TARGET)/ndk13-include/lvo
	@mkdir -p $(BUILD)/ndk-include/
	@echo "done" >$@

$(BUILD)/ndk-include_proto: $(PROJECTS)/$(NDK_FOLDER_NAME).info
	@mkdir -p $(PREFIX)/$(TARGET)/ndk-include/proto
	@mkdir -p $(PREFIX)/$(TARGET)/ndk13-include/proto
	@mkdir -p $(BUILD)/ndk-include/
	@echo "done" >$@

$(PROJECTS)/$(NDK_FOLDER_NAME).info: $(BUILD)/_lha_done $(DOWNLOAD)/$(NDK_ARC_NAME).lha $(shell find 2>/dev/null patches/$(NDK_FOLDER_NAME)/ -type f)
	$(L0)"unpack ndk"$(L1) cd $(PROJECTS) && if [[ $(NDK_ARC_NAME) == "NDK3.2" ]] ; \
	   then mkdir NDK3.2 ; cd NDK3.2 ; fi ; \
	   lha xf $(DOWNLOAD)/$(NDK_ARC_NAME).lha $(L2)
	@touch -t 0001010000 $(DOWNLOAD)/$(NDK_ARC_NAME).lha
	$(L0)"patch ndk"$(L1) for i in $$(find patches/$(NDK_FOLDER_NAME)/ -type f); do \
	   if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "$(PROJECTS)/$${j%.diff}" "$$i"; \
		else cp -pv "$$i" "$(PROJECTS)/$${i:8}"; fi ; done $(L2)
	@touch $(PROJECTS)/$(NDK_FOLDER_NAME).info

$(DOWNLOAD)/$(NDK_ARC_NAME).lha:
	$(call get-file,$(NDK_ARC_NAME),$(NDK_URL),$(NDK_ARC_NAME).lha)


# =================================================
# NDK1.3 - emulated from NDK
# =================================================
.PHONY: ndk_13
ndk13: $(BUILD)/ndk-include_ndk13

$(BUILD)/ndk-include_ndk13: $(BUILD)/ndk-include_ndk $(BUILD)/fd2sfd/_done $(BUILD)/sfdc/_done
	@while read p; do p=$$(echo $$p|tr -d '\n'); mkdir -p $(PREFIX)/$(TARGET)/ndk13-include/$$(dirname $$p); cp $(PREFIX)/$(TARGET)/ndk-include/$$p $(PREFIX)/$(TARGET)/ndk13-include/$$p; done < patches/ndk13/hfiles
	$(L0)"extract ndk13"$(L1) while read p; do p=$$(echo $$p|tr -d '\n'); \
	  mkdir -p $(PREFIX)/$(TARGET)/ndk13-include/$$(dirname $$p); \
	  if grep V36 $(PREFIX)/$(TARGET)/ndk-include/$$p; then \
	  LC_CTYPE=C $(SED) -n -e '/#ifndef[[:space:]]*CLIB/,/V36/p' $(PREFIX)/$(TARGET)/ndk-include/$$p | $(SED) -e 's/__stdargs//g' >$(PREFIX)/$(TARGET)/ndk13-include/$$p; \
	  echo -e "#ifdef __cplusplus\n}\n#endif /* __cplusplus */\n#endif" >>$(PREFIX)/$(TARGET)/ndk13-include/$$p; \
	  else LC_CTYPE=C $(SED) $(PREFIX)/$(TARGET)/ndk-include/$$p -e 's/__stdargs//g' >$(PREFIX)/$(TARGET)/ndk13-include/$$p; fi \
	done < patches/ndk13/chfiles $(L2)
	@while read p; do p=$$(echo $$p|tr -d '\n'); mkdir -p $(PREFIX)/$(TARGET)/ndk13-include/$$(dirname $$p); echo "" >$(PREFIX)/$(TARGET)/ndk13-include/$$p; done < patches/ndk13/ehfiles
	@echo '#undef	EXECNAME' > $(PREFIX)/$(TARGET)/ndk13-include/exec/execname.h
	@echo '#define	EXECNAME	"exec.library"' >> $(PREFIX)/$(TARGET)/ndk13-include/exec/execname.h
	@mkdir -p $(PREFIX)/$(TARGET)/ndk/lib/fd13
	@while read p; do p=$$(echo $$p|tr -d '\n'); LC_CTYPE=C $(SED) -n -e '/##base/,/V36/P'  $(PREFIX)/$(TARGET)/ndk/lib/fd/$$p >$(PREFIX)/$(TARGET)/ndk/lib/fd13/$$p; done < patches/ndk13/fdfiles
	@mkdir -p $(PREFIX)/$(TARGET)/ndk/lib/sfd13
	@for i in $(PREFIX)/$(TARGET)/ndk/lib/fd13/*; do fd2sfd $$i $(PREFIX)/$(TARGET)/ndk13-include/clib/$$(basename $$i _lib.fd)_protos.h > $(PREFIX)/$(TARGET)/ndk/lib/sfd13/$$(basename $$i .fd).sfd; done
	$(L0)"macros+protos ndk13"$(L1) for i in $(PREFIX)/$(TARGET)/ndk/lib/sfd13/*; do \
	  sfdc --target=m68k-amigaos --mode=macros --output=$(PREFIX)/$(TARGET)/ndk13-include/inline/$$(basename $$i _lib.sfd).h $$i; \
	  sfdc --target=m68k-amigaos --mode=proto --output=$(PREFIX)/$(TARGET)/ndk13-include/proto/$$(basename $$i _lib.sfd).h $$i; \
	done $(L2)
	$(L0)"STDARGing ndk13"$(L1) for i in $$(find $(PREFIX)/$(TARGET)/ndk13-include/clib/*protos.h -type f); do \
	echo $$i; \
	LC_CTYPE=C $(SED) -i.bak -E 's/([a-zA-Z0-9 _]*)([[:blank:]]+|\*)([a-zA-Z0-9_]+)\(/\1\2 __stdargs \3(/g' $$i; \
	rm $$i.bak; done $(L2)	
	@echo "done" >$@

# =================================================
# netinclude
# =================================================
.PHONY: netinclude
netinclude: $(BUILD)/_netinclude

$(BUILD)/_netinclude: $(PROJECTS)/amiga-netinclude/README.md $(BUILD)/ndk-include_ndk $(shell find 2>/dev/null $(PROJECTS)/amiga-netinclude/include -type f)
	@mkdir -p $(PREFIX)/$(TARGET)/ndk-include
	@rsync -a --no-group $(PROJECTS)/amiga-netinclude/include/* $(PREFIX)/$(TARGET)/ndk-include
	@echo "done" >$@

$(PROJECTS)/amiga-netinclude/README.md:
	@cd $(PROJECTS) &&	git clone -b $(amiga-netinclude_BRANCH) --depth 4 $(amiga-netinclude_URL)

# =================================================
# libamiga
# =================================================
LIBAMIGA := $(PREFIX)/$(TARGET)/lib/libamiga.a
LIBBAMIGA := $(PREFIX)/$(TARGET)/lib/libb/libamiga.a

libamiga: $(LIBAMIGA) $(LIBBAMIGA)
	@echo "built $(LIBAMIGA) and $(LIBBAMIGA)"

$(LIBAMIGA): 
	@mkdir -p $(@D)
	#@cp $(PROJECTS)/$(NDK_FOLDER_NAME_LIBS)/amiga.lib $@
	@cp lib/libamiga.a $@

$(LIBBAMIGA): 
	@mkdir -p $(@D)
	@cp lib/libb/libamiga.a $@

# =================================================
# libnix
# =================================================

LIBNIX_SRC = $(shell find 2>/dev/null $(PROJECTS)/libnix -not \( -path $(PROJECTS)/libnix/.git -prune \) -not \( -path $(PROJECTS)/libnix/sources/stubs/libbases -prune \) -not \( -path $(PROJECTS)/libnix/sources/stubs/libnames -prune \) -type f)

libnix: $(BUILD)/libnix/_done

$(BUILD)/libnix/_done: $(BUILD)/newlib/_done $(BUILD)/ndk-include_ndk $(BUILD)/ndk-include_ndk13 $(BUILD)/_netinclude $(BUILD)/binutils/_done $(BUILD)/gcc/_done $(PROJECTS)/libnix/Makefile.gcc6 $(LIBAMIGA) $(LIBNIX_SRC)
	@mkdir -p $(PREFIX)/$(TARGET)/libnix/lib/libnix
	@mkdir -p $(BUILD)/libnix
	@mkdir -p $(PREFIX)/lib/gcc/$(TARGET)/$(GCC_VERSION)
	@if [ ! -e $(PREFIX)/lib/gcc/$(TARGET)/$(GCC_VERSION)/libgcc.a ]; then $(PREFIX)/bin/$(TARGET)-ar rcs $(PREFIX)/lib/gcc/$(TARGET)/$(GCC_VERSION)/libgcc.a; fi
	$(L0)"make libnix"$(L1) CFLAGS="$(CFLAGS_FOR_TARGET)" $(MAKE) -C $(BUILD)/libnix -f $(PROJECTS)/libnix/Makefile.gcc6 root=$(PROJECTS)/libnix all $(L2)
	$(L0)"install libnix"$(L1) $(MAKE) -C $(BUILD)/libnix -f $(PROJECTS)/libnix/Makefile.gcc6 root=$(PROJECTS)/libnix install $(L2)
	@rsync --delete -a --no-group $(PROJECTS)/libnix/sources/headers/* $(PREFIX)/$(TARGET)/libnix/include/
	@echo "done" >$@

$(PROJECTS)/libnix/Makefile.gcc6:
	@cd $(PROJECTS) &&	git clone -b $(libnix_BRANCH) --depth 4 $(libnix_URL)

# =================================================
# gcc libs
# =================================================
LIBGCCS_NAMES := libgcov.a libstdc++.a libsupc++.a
LIBGCCS := $(patsubst %,$(PREFIX)/lib/gcc/$(TARGET)/$(GCC_VERSION)/%,$(LIBGCCS_NAMES))

libgcc: $(BUILD)/gcc/_libgcc_done

$(BUILD)/gcc/_libgcc_done: $(BUILD)/libnix/_done $(BUILD)/libpthread/_done $(LIBAMIGA) $(shell find 2>/dev/null $(PROJECTS)/gcc/libgcc -type f)
	$(L0)"make libgcc"$(L1) $(MAKE) -C $(BUILD)/gcc all-target $(L2)
	$(L0)"install libgcc"$(L1) $(MAKE) -C $(BUILD)/gcc install-target $(L2)
	@echo "done" >$@

# =================================================
# clib2
# =================================================

clib2: $(BUILD)/clib2/_done

$(BUILD)/clib2/_done: $(PROJECTS)/clib2/LICENSE $(shell find 2>/dev/null $(PROJECTS)/clib2 -not \( -path $(PROJECTS)/clib2/.git -prune \) -type f) $(BUILD)/libnix/_done $(LIBAMIGA)
	@mkdir -p $(BUILD)/clib2/
	@rsync -a --no-group $(PROJECTS)/clib2/library/* $(BUILD)/clib2
	@cd $(BUILD)/clib2 && find * -name lib\*.a -delete
	$(L0)"make clib2"$(L1) $(MAKE) -C $(BUILD)/clib2 -f GNUmakefile.68k -j1 $(L2)
	@mkdir -p $(PREFIX)/$(TARGET)/clib2
	@rsync -a --no-group $(BUILD)/clib2/include $(PREFIX)/$(TARGET)/clib2
	@rsync -a --no-group $(BUILD)/clib2/lib $(PREFIX)/$(TARGET)/clib2
	@echo "done" >$@

$(PROJECTS)/clib2/LICENSE:
	@cd $(PROJECTS) && git clone -b $(clib2_BRANCH) --depth 4 $(clib2_URL)

# =================================================
# libdebug
# =================================================
CONFIG_LIBDEBUG := --prefix=$(PREFIX) --target=$(TARGET) --host=$(TARGET)

libdebug: $(BUILD)/libdebug/_done

$(BUILD)/libdebug/_done: $(BUILD)/libdebug/Makefile
	$(L0)"make libdebug"$(L1) $(MAKE) -C $(BUILD)/libdebug $(L2)
	@cp $(BUILD)/libdebug/libdebug.a $(PREFIX)/$(TARGET)/lib/
	@echo "done" >$@

$(BUILD)/libdebug/Makefile: $(BUILD)/libnix/_done $(PROJECTS)/libdebug/configure $(shell find 2>/dev/null $(PROJECTS)/libdebug -not \( -path $(PROJECTS)/libdebug/.git -prune \) -type f)
	@mkdir -p $(BUILD)/libdebug
	$(L0)"configure libdebug"$(L1) cd $(BUILD)/libdebug && LD=$(TARGET)-ld CC=$(TARGET)-gcc CFLAGS="$(CFLAGS_FOR_TARGET)" $(PROJECTS)/libdebug/configure $(CONFIG_LIBDEBUG) $(L2)

$(PROJECTS)/libdebug/configure:
	@cd $(PROJECTS) &&	git clone -b $(libdebug_BRANCH) --depth 4 $(libdebug_URL)
	@touch -t 0001010000 $(PROJECTS)/libdebug/configure.ac

# =================================================
# libpthread
# =================================================

libpthread: $(BUILD)/libpthread/_done

$(BUILD)/libpthread/_done: $(BUILD)/libpthread/Makefile
	@rsync -a --no-group --exclude=debug.h $(BUILD)/libpthread/*.h $(PREFIX)/$(TARGET)/include/
	$(L0)"make libpthread"$(L1) cd $(BUILD)/libpthread && $(MAKE) -f Makefile.gcc6 $(L2)
	$(L0)"install libpthread lib"$(L1) cp $(BUILD)/libpthread/lib/libpthread.a $(PREFIX)/$(TARGET)/lib/ $(L2)
	$(L0)"install libpthread libb"$(L1) cp $(BUILD)/libpthread/libb/libpthread.a $(PREFIX)/$(TARGET)/lib/libb/ $(L2)
	$(L0)"install libpthread libm020"$(L1) cp $(BUILD)/libpthread/libm020/libpthread.a $(PREFIX)/$(TARGET)/lib/libm020/ $(L2)
	$(L0)"install libpthread libm020bb"$(L1) cp $(BUILD)/libpthread/libm020bb/libpthread.a $(PREFIX)/$(TARGET)/lib/libb/libm020/ $(L2)
	$(L0)"install libpthread libm020bb32"$(L1) cp $(BUILD)/libpthread/libm020bb32/libpthread.a $(PREFIX)/$(TARGET)/lib/libb32/libm020/ $(L2)
	@echo "done" >$@

$(BUILD)/libpthread/Makefile: $(BUILD)/libnix/_done $(PROJECTS)/aros-stuff/pthreads/Makefile $(shell find 2>/dev/null $(PROJECTS)/aros-stuff/pthreads -type f)
	@mkdir -p $(BUILD)/libpthread
	@rsync -a --no-group $(PROJECTS)/aros-stuff/pthreads/* $(BUILD)/libpthread
	@touch $(BUILD)/libpthread/Makefile

$(PROJECTS)/aros-stuff/pthreads/Makefile:
	@cd $(PROJECTS) &&	git clone -b $(aros-stuff_BRANCH) --depth 4 $(aros-stuff_URL)

# =================================================
# newlib
# =================================================
NEWLIB_CONFIG := CC=$(TARGET)-gcc CXX=$(TARGET)-g++
NEWLIB_FILES = $(shell find 2>/dev/null $(PROJECTS)/newlib-cygwin/newlib -type f)

.PHONY: newlib
newlib: $(BUILD)/newlib/_done

$(BUILD)/newlib/_done: $(BUILD)/newlib/newlib/libc.a
	@echo "done" >$@

$(BUILD)/newlib/newlib/libc.a: $(BUILD)/newlib/newlib/Makefile $(NEWLIB_FILES)
	@rsync -a --no-group $(PROJECTS)/newlib-cygwin/newlib/libc/include/ $(PREFIX)/$(TARGET)/sys-include
	@rsync -a --no-group $(PROJECTS)/newlib-cygwin/newlib/libc/sys/amigaos/include/stabs.h $(PREFIX)/$(TARGET)/sys-include
	$(L0)"make newlib"$(L1) $(MAKE) -C $(BUILD)/newlib/newlib $(L2)
	$(L0)"install newlib"$(L1) $(MAKE) -C $(BUILD)/newlib/newlib install $(L2)
	@for x in $$(find $(PREFIX)/$(TARGET)/lib/* -name libm.a); do ln -sf $$x $${x%*m.a}__m__.a; done
	@touch $@

$(BUILD)/newlib/newlib/Makefile: $(PROJECTS)/newlib-cygwin/newlib/configure $(BUILD)/ndk-include_ndk $(BUILD)/gcc/_done
	@mkdir -p $(BUILD)/newlib/newlib
	@if [ ! -f "$(BUILD)/newlib/newlib/Makefile" ]; then \
	$(L00)"configure newlib"$(L1) cd $(BUILD)/newlib/newlib && $(NEWLIB_CONFIG) CFLAGS="$(CFLAGS_FOR_TARGET)" CC_FOR_BUILD="$(CC)" CXXFLAGS="$(CXXFLAGS_FOR_TARGET)" $(PROJECTS)/newlib-cygwin/newlib/configure --host=$(TARGET) --prefix=$(PREFIX) --enable-newlib-io-long-long --enable-newlib-io-c99-formats --enable-newlib-reent-small --enable-newlib-mb --enable-newlib-long-time_t $(L2) \
	; else touch "$(BUILD)/newlib/newlib/Makefile"; fi

$(PROJECTS)/newlib-cygwin/newlib/configure:
	@cd $(PROJECTS) &&	git clone -b $(newlib-cygwin_BRANCH) --depth 4  $(newlib-cygwin_URL)

# =================================================
# ixemul
# =================================================
$(PROJECTS)/ixemul/configure:
	@cd $(PROJECTS) &&	git clone -b $(ixemul_BRANCH) $(ixemul_URL)

.PHONY: ixemul
ixemul:	$(PREFIX)/$(TARGET)/ixemul/lib/libc.a

$(PREFIX)/$(TARGET)/ixemul/lib/libc.a: $(BUILD)/ixemul/lib/libc.a
	@mkdir -p $(PREFIX)/$(TARGET)/ixemul
	$(L0)"installing ixemul-sdk"$(L1) rsync -a --no-group $(BUILD)/ixemul/* $(PREFIX)/$(TARGET)/ixemul/ $(L2)


$(BUILD)/ixemul/lib/libc.a: $(DOWNLOAD)/ixemul-sdk.lha
	@mkdir -p $(BUILD)/ixemul
	$(L0)"unpacking ixemul-sdk.lha"$(L1) cd $(BUILD)/ixemul && lha xf $(DOWNLOAD)/ixemul-sdk.lha $(L2)

$(DOWNLOAD)/ixemul-sdk.lha:
	$(call get-file,ixemul-sdk,https://aminet.net/util/libs/ixemul-sdk.lha,ixemul-sdk.lha)

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

$(SDKS): libnix lha
	$(MAKE) sdk=$@

# =================================================
# update repos
# =================================================
.PHONY: update-repos
update-repos:
	@for i in $(modules); do \
		url=$$(grep $$i .repos | sed -e 's/[[:blank:]]\+/ /g' | cut -d' ' -f2); \
		bra=$$(grep $$i .repos | sed -e 's/[[:blank:]]\+/ /g' | cut -d' ' -f3); \
		bra=$${bra/$$'\n'} ;\
		bra=$${bra/$$'\r'} ;\
		if [ -e projects/$$i ]; then \
			pushd projects/$$i; \
			echo setting remote origin from $$(git remote get-url origin) to $$url using branch $$bra.; \
			git remote remove origin; \
			git remote add origin $$url; \
			git remote set-branches origin $$bra; \
			git pull --depth 4; \
			git checkout $$bra; \
			popd; \
		fi; \
	done

# =================================================
# run gcc torture check
# =================================================
ifeq (,$(board))
board = amigaos
endif

.PHONY: check
check:
	@ln -sf $(PREFIX)/$(TARGET)/libnix $(BUILD)/gcc/$(TARGET)/libnix
	$(MAKE) -C $(BUILD)/gcc check-gcc-c "RUNTESTFLAGS=--target_board=$(board) execute.exp=* SIM=vamos" | grep '# of\|PASS\|FAIL\|===\|Running\|Using' 


# =================================================
# info
# =================================================
.PHONY: info v r b l branch
info:
	@echo $@ $(UNAME_S)
	@echo PREFIX=$(PREFIX)
	@echo GCC_VERSION=$(GCC_VERSION)
	@echo CFLAGS=$(CFLAGS)
	@echo CFLAGS_FOR_TARGET=$(CFLAGS_FOR_TARGET)
	@$(CC) -v -E - </dev/null |& grep " version "
	@$(CXX) -v -E - </dev/null |& grep " version "
	@echo $(BUILD)
	@echo $(PROJECTS)
	@echo MODULES = $(modules)

# print the latest git log entry for all projects
l:
	@for i in $(PROJECTS)/* ; do pushd . >/dev/null; cd $$i 2>/dev/null && ([[ -d ".git" ]] && echo $$i && git log -n1 --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short); popd >/dev/null; done
	@echo "." && git log -n1 --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short

# print the git remotes for all projects
r:
	@for i in $(PROJECTS)/* ; do pushd . >/dev/null; cd $$i 2>/dev/null && ([[ -d ".git" ]] && echo $$i && git remote -v); popd >/dev/null; done
	@echo "." && git remote -v

# print the git branches for all projects
b:
	@for i in $(PROJECTS)/* ; do pushd . >/dev/null; cd $$i 2>/dev/null && ([[ -d ".git" ]] && echo $$i && (git branch | grep '*')); popd >/dev/null; done
	@echo "." && git remote -v


# checkout for a given date
v:
	@D="$(date)"; \
	for i in $(modules); do \
		bra=$$(grep $$i .repos | sed -e 's/[[:blank:]]\+/ /g' | cut -d' ' -f3); \
		bra=$${bra/$$'\n'} ;\
		bra=$${bra/$$'\r'} ;\
		if [ -e projects/$$i ]; then \
			pushd projects/$$i >/dev/null; \
			echo $$i;\
			git checkout $$bra; \
			if [ "$$D" != "" ]; then \
				(export DEPTH=16; while [ "" == "$$( git rev-list -n 1 --first-parent --before="$$D" $$bra)" ]; \
					do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH ; export DEPTH=$$(($$DEPTH+$$DEPTH)); done); \
				git checkout `git rev-list -n 1 --first-parent --before="$$D" $$bra`; \
			fi;\
			popd >/dev/null; \
		fi;\
	done; \
	echo .; \
	B=master; \
	git checkout $$B; \
	if [ "$$D" != "" ]; then \
		git checkout `git rev-list -n 1 --first-parent --before="$$D" $$B`; \
	fi

# change version to the given branch
branch:
	@if [ "" != "$(branch)" ] && [ "1" == "$$(grep -c $(mod) .repos)" ]; then \
		echo $(mod) $(branch) ; \
	    url=$$(grep $(mod) .repos | sed -e 's/[[:blank:]]\+/ /g' | cut -d' ' -f2); \
	    mv .repos .repos.bak; \
	    grep -v $(mod) .repos.bak > .repos; \
	    echo "$(mod) $$url $(branch)" >> .repos; \
	    if [ -d  projects/$(mod) ]; then \
	      pushd projects/$(mod); \
	      git fetch origin $(branch):$(branch); \
	      git checkout $(branch); \
	      git branch --set-upstream-to=origin/$(branch) $(branch); \
	      popd ; \
	   fi \
	else \
		echo "$(mod) $(branch) does NOT exist!"; \
	fi


# =================================================
# multilib support
# =================================================
MULTI = MODNAME/.: \
		MODNAME/libm020:-m68020 \
		MODNAME/libm020/libm881:-m68020_-m68881 \
		MODNAME/libb:-fbaserel \
		MODNAME/libb/libm020:-fbaserel_-m68020 \
		MODNAME/libb/libm020/libm881:-fbaserel_-m68020_-m68881 \
		MODNAME/libb32/libm020:-fbaserel32_-m68020 \
		MODNAME/libb32/libm020/libm881:-fbaserel32_-m68020_-m68881

# 1=module name, 2=from name, 3 = to name
COPY_MULTILIBS = $(foreach T, $(subst MODNAME,$1,$(MULTI)),cp $(BUILD)/$(word 1,$(subst :, ,${T}))/$2 $(BUILD)/$(word 1,$(subst :, ,${T}))/$3;)

# 1=module name, 2=lib name
INSTALL_MULTILIBS = $(L0)"install $1"$(L1) $(foreach T, $(subst MODNAME,$1,$(MULTI)),rsync -av --no-group $(BUILD)/$(word 1,$(subst :, ,${T}))/$2 $(PREFIX)/lib/$(word 1,$(subst :, ,$(subst $1/,,${T})));) $(L2)

# 1=module name 3,4... = params for make
MULTIMAKE = $(L0)"make $1"$(L1) $(foreach T,$(subst MODNAME,$1,$(MULTI)), $(MAKE) -C $(BUILD)/$(word 1,$(subst :, ,${T})) $3 $4 $5 $6 $7 $8;) $(L2)

# 1=module name 2=multilib path 3=cflags
MULTICONFIGURE1 = mkdir -p $(BUILD)/$2 && cd $(BUILD)/$2 && \
	PKG_CONFIG=/bin/false CC=$(TARGET)-gcc CXX=$(TARGET)-g++ AR=$(TARGET)-ar LD=$(TARGET)-ld CFLAGS="$(subst _, ,$3) -noixemul $(CFLAGS_FOR_TARGET)" $(PROJECTS)/$1/configure

# 1=module name 3,4...= params for configure
MULTICONFIGURE = $(L0)"configure $1"$(L1) $(foreach T,$(subst MODNAME,$1,$(MULTI)),$(call MULTICONFIGURE1,$1,$(word 1,$(subst :, ,${T})),$(word 2,$(subst :, ,${T}))) $3 $4 $5 $6 $7 $8;)$(L2)

# =================================================
# zlib
# =================================================
ZLIB=zlib-1.2.13

.PHONY: zlib clean-zlib

clean-zlib:
	rm -rf $(BUILD)/$(ZLIB)

zlib: $(BUILD)/$(ZLIB)/_done

$(BUILD)/$(ZLIB)/_done: $(PREFIX)/lib/libz.a
	@echo "done" >$@

$(PREFIX)/lib/libz.a: $(BUILD)/$(ZLIB)/libz.a
	@rsync -a --no-group $(PROJECTS)/$(ZLIB)/zlib.h $(PREFIX)/include/ 
	@rsync -a --no-group $(BUILD)/$(ZLIB)/zconf.h $(PREFIX)/include/
	$(call INSTALL_MULTILIBS,$(ZLIB),libz.a)
	@touch $@

$(BUILD)/$(ZLIB)/libz.a: $(BUILD)/$(ZLIB)/Makefile
	+$(call MULTIMAKE,$(ZLIB),libz.a)
	@touch $@

$(BUILD)/$(ZLIB)/Makefile: $(PROJECTS)/$(ZLIB)/configure
	$(call MULTICONFIGURE,$(ZLIB),libz.a,)
	@touch $@

$(PROJECTS)/$(ZLIB)/configure: $(DOWNLOAD)/$(ZLIB).tar.xz
	tar -C $(PROJECTS) -xf $(DOWNLOAD)/$(ZLIB).tar.xz
	@touch $@

$(DOWNLOAD)/$(ZLIB).tar.xz:
	$(call get-file,zlib,https://zlib.net/$(ZLIB).tar.xz,$(ZLIB).tar.xz)
	

# =================================================
# libpng
# =================================================
LIBPNG=libpng-1.6.39

.PHONY: libpng clean-libpng

clean-libpng:
	rm -rf $(BUILD)/$(LIBPNG)

libpng: $(BUILD)/$(LIBPNG)/_done

$(BUILD)/$(LIBPNG)/_done: $(PREFIX)/lib/libpng.a
	@echo "done" >$@

$(PREFIX)/lib/libpng.a: $(BUILD)/$(LIBPNG)/libpng.a
	@rsync -a --no-group $(PROJECTS)/$(LIBPNG)/png.h $(PREFIX)/include/ 
	@rsync -a --no-group $(PROJECTS)/$(LIBPNG)/pngconf.h $(PREFIX)/include/ 
	@rsync -a --no-group $(BUILD)/$(LIBPNG)/pnglibconf.h $(PREFIX)/include/
	@$(call COPY_MULTILIBS,$(LIBPNG),.libs/libpng16.a,libpng.a)
	$(call INSTALL_MULTILIBS,$(LIBPNG),libpng.a)
	@touch $@

$(BUILD)/$(LIBPNG)/libpng.a: $(BUILD)/$(LIBPNG)/Makefile
	+$(call MULTIMAKE,$(LIBPNG),libpng.a)
	@touch $@

$(BUILD)/$(LIBPNG)/Makefile: $(PROJECTS)/$(LIBPNG)/configure
	$(call MULTICONFIGURE,$(LIBPNG),libpng.a,--host=$(TARGET))
	@touch $@

$(PROJECTS)/$(LIBPNG)/configure: $(DOWNLOAD)/$(LIBPNG).tar.xz $(BUILD)/$(ZLIB)/_done $(BUILD)/libnix/_done
	tar -C $(PROJECTS) -xf $(DOWNLOAD)/$(LIBPNG).tar.xz
	@touch $@

$(DOWNLOAD)/$(LIBPNG).tar.xz:
	$(call get-file,libpng16,https://sourceforge.net/projects/libpng/files/libpng16/$(subst libpng-,,$(LIBPNG))/$(LIBPNG).tar.xz,$(LIBPNG).tar.xz)

# =================================================
# libfreetype
# =================================================
LIBFREETYPE=freetype-2.12.1

.PHONY: libfreetype2 clean-libfreetype2

clean-libfreetype2:
	rm -rf $(BUILD)/$(LIBFREETYPE)

libfreetype2: $(BUILD)/$(LIBFREETYPE)/_done

$(BUILD)/$(LIBFREETYPE)/_done: $(PREFIX)/lib/libfreetype.a
	@echo "done" >$@

$(PREFIX)/lib/libfreetype.a: $(BUILD)/$(LIBFREETYPE)/libfreetype.a
	@rsync -a --no-group $(PROJECTS)/$(LIBFREETYPE)/include/ft2build.h $(PREFIX)/include/ 
	@rsync -a --no-group $(PROJECTS)/$(LIBFREETYPE)/include/freetype $(PREFIX)/include/ 
	@$(call COPY_MULTILIBS,$(LIBFREETYPE),.libs/libfreetype.a,libfreetype.a)
	$(call INSTALL_MULTILIBS,$(LIBFREETYPE),libfreetype.a)
	@touch $@

$(BUILD)/$(LIBFREETYPE)/libfreetype.a: $(BUILD)/$(LIBFREETYPE)/Makefile
	+$(call MULTIMAKE,$(LIBFREETYPE),libfreetype.a)
	@touch $@

$(BUILD)/$(LIBFREETYPE)/Makefile: $(PROJECTS)/$(LIBFREETYPE)/configure
	$(call MULTICONFIGURE,$(LIBFREETYPE),libfreetype.a,--host=$(TARGET),--disable-shared)
	@touch $@

$(PROJECTS)/$(LIBFREETYPE)/configure: $(DOWNLOAD)/$(LIBFREETYPE).tar.xz $(BUILD)/libnix/_done
	tar -C $(PROJECTS) -xf $(DOWNLOAD)/$(LIBFREETYPE).tar.xz
	@touch $@

$(DOWNLOAD)/$(LIBFREETYPE).tar.xz:
	$(call get-file,$(LIBFREETYPE),https://download.savannah.gnu.org/releases/freetype/$(LIBFREETYPE).tar.xz,$(LIBFREETYPE).tar.xz)

# =================================================
# libsdl this is 68030 only ...
# =================================================
LIBSDL12=libSDL12
CONFIG_LIBSDL12 := PREFX=$(PREFIX) PREF=$(PREFIX)

.PHONY: libSDL12 clean-libSDL12
clean-libSDL12:
	rm -rf $(BUILD)/$(LIBSDL12)


libSDL12: $(BUILD)/libSDL12/_done

$(BUILD)/libSDL12/_done: $(BUILD)/libSDL12/Makefile
	$(MAKE) sdk=ahi
	$(MAKE) sdk=cgx
	$(L0)"make libSDL12"$(L1) cd $(BUILD)/libSDL12 && CFLAGS="$(CFLAGS_FOR_TARGET)" $(MAKE) -f Makefile $(CONFIG_LIBSDL12) $(L2)
	$(L0)"install libSDL12"$(L1) cp $(BUILD)/libSDL12/libSDL.a $(PREFIX)/lib/ $(L2)
	@mkdir -p $(PREFIX)/include/GL
	@mkdir -p $(PREFIX)/include/SDL
	@rsync -a --no-group $(BUILD)/libSDL12/include/GL/*.i $(PREFIX)/include/GL/
	@rsync -a --no-group $(BUILD)/libSDL12/include/GL/*.h $(PREFIX)/include/GL/
	@rsync -a --no-group $(BUILD)/libSDL12/include/SDL/*.h $(PREFIX)/include/SDL/
	@echo '#include "SDL/SDL.h"' >$(PREFIX)/include/SDL.h
	@echo '#include "SDL/SDL_audio.h"' >$(PREFIX)/include/SDL_audio.h
	@echo '#include "SDL/SDL_version.h"' >$(PREFIX)/include/SDL_version.h
	@echo -e 'while test $$# -gt 0; do\n  case "$$1" in\n   --cflags)\n      echo -I$(PREFIX)/include/SDL\n      ;;\n  esac\n  shift\ndone' > $(PREFIX)/bin/sdl-config
	@chmod 0777 $(PREFIX)/bin/sdl-config	
	@echo "done" >$@

$(BUILD)/libSDL12/Makefile: $(BUILD)/libnix/_done $(PROJECTS)/libSDL12/Makefile $(shell find 2>/dev/null $(PROJECTS)/libSDL12 -not \( -path $(PROJECTS)/libSDL12/.git -prune \) -type f)
	@mkdir -p $(BUILD)/libSDL12
	@rsync -a --no-group $(PROJECTS)/libSDL12/* $(BUILD)/libSDL12
	@touch $(BUILD)/libSDL12/Makefile

$(PROJECTS)/libSDL12/Makefile:
	@cd $(PROJECTS) &&      git clone -b $(libSDL12_BRANCH) --depth 4 $(libSDL12_URL)

# =================================================
# libSDLmixer
# =================================================
LIBSDLMIXER=SDL_mixer-SDL-1.2

# 1=module name
MULTICC_SDLMIXER = $(L0)"compiling $1"$(L1) $(foreach T,$(subst MODNAME,$1,$(MULTI)), cd $(BUILD)/$(word 1,$(subst :, ,${T})) && \
	$(TARGET)-gcc -c $$(grep "CFLAGS  =" Makefile | cut -d "=" -f 2 | sed -e 's|srcdir|$(PROJECTS)/${T}|g') $$(grep "EXTRA_CFLAGS =" Makefile | cut -d "=" -f 2) \
	-I $(PREFIX)/include/SDL \
	$(PROJECTS)/$1/*.c && \
	$(TARGET)-ar rcs $2 *.o \
	;) $(L2)

.PHONY: libsdlmixer clean-libsdlmixer

clean-libsdlmixer:
	rm -rf $(BUILD)/$(LIBSDLMIXER)

libsdlmixer: $(BUILD)/$(LIBSDLMIXER)/_done

$(BUILD)/$(LIBSDLMIXER)/_done: $(PREFIX)/lib/libSDL_mixer.a
	@echo "done" >$@

$(PREFIX)/lib/libSDL_mixer.a: $(BUILD)/$(LIBSDLMIXER)/libSDL_mixer.a
	@mkdir -p $(PREFIX)/include/SDL
	@rsync -a --no-group $(PROJECTS)/$(LIBSDLMIXER)/SDL_mixer.h $(PREFIX)/include/SDL
	$(call INSTALL_MULTILIBS,$(LIBSDLMIXER),libSDL_mixer.a)
	@touch $@

$(BUILD)/$(LIBSDLMIXER)/libSDL_mixer.a: $(BUILD)/$(LIBSDLMIXER)/Makefile
	+$(call MULTICC_SDLMIXER,$(LIBSDLMIXER),libSDL_mixer.a)
	@touch $@

$(BUILD)/$(LIBSDLMIXER)/Makefile: $(PROJECTS)/$(LIBSDLMIXER)/configure
	$(call MULTICONFIGURE,$(LIBSDLMIXER),libSDL_mixer.a,--host=$(TARGET),--disable-shared,--enable-static,--prefix=$(PREFIX))
	@touch $@

$(PROJECTS)/$(LIBSDLMIXER)/configure: $(DOWNLOAD)/$(LIBSDLMIXER).tar.gz $(BUILD)/libSDL12/_done $(BUILD)/libnix/_done
	tar -C $(PROJECTS) -xf $(DOWNLOAD)/$(LIBSDLMIXER).tar.gz
	@touch $@

$(DOWNLOAD)/$(LIBSDLMIXER).tar.gz:
	$(call get-file,$(LIBSDLMIXER),https://github.com/SDL-mirror/SDL_mixer/archive/SDL-1.2.tar.gz,$(LIBSDLMIXER).tar.gz)

# =================================================
# libSDLttf
# =================================================
LIBSDLTTF=SDL_ttf-SDL-1.2

# 1=module name
MULTICC_SDLTTF = $(L0)"compiling $1"$(L1) $(foreach T,$(subst MODNAME,$1,$(MULTI)), cd $(BUILD)/$(word 1,$(subst :, ,${T})) && \
	$(TARGET)-gcc -c $$(grep "CFLAGS  =" Makefile | cut -d "=" -f 2 | sed -e 's|srcdir|$(PROJECTS)/${T}|g') $$(grep "EXTRA_CFLAGS =" Makefile | cut -d "=" -f 2) \
	-I $(PREFIX)/include/SDL \
	$(PROJECTS)/$1/*.c && \
	$(TARGET)-ar rcs $2 *.o \
	;) $(L2)

.PHONY: libsdlttf clean-libsdlttf

clean-libsdlttf:
	rm -rf $(BUILD)/$(LIBSDLTTF)

libsdlttf: $(BUILD)/$(LIBSDLTTF)/_done

$(BUILD)/$(LIBSDLTTF)/_done: $(PREFIX)/lib/libSDL_ttf.a
	@echo "done" >$@

$(PREFIX)/lib/libSDL_ttf.a: $(BUILD)/$(LIBSDLTTF)/libSDL_ttf.a
	@mkdir -p $(PREFIX)/include/SDL
	@rsync -a --no-group $(PROJECTS)/$(LIBSDLTTF)/SDL_ttf.h $(PREFIX)/include/SDL
	$(call INSTALL_MULTILIBS,$(LIBSDLTTF),libSDL_ttf.a)
	@touch $@

$(BUILD)/$(LIBSDLTTF)/libSDL_ttf.a: $(BUILD)/$(LIBSDLTTF)/Makefile
	+$(call MULTICC_SDLTTF,$(LIBSDLTTF),libSDL_ttf.a)
	@touch $@

$(BUILD)/$(LIBSDLTTF)/Makefile: $(PROJECTS)/$(LIBSDLTTF)/configure
	$(call MULTICONFIGURE,$(LIBSDLTTF),libSDL_ttf.a,--host=$(TARGET),--disable-shared,--enable-static,--prefix=$(PREFIX))
	@touch $@

$(PROJECTS)/$(LIBSDLTTF)/configure: $(DOWNLOAD)/$(LIBSDLTTF).tar.gz $(BUILD)/libSDL12/_done $(BUILD)/libnix/_done
	tar -C $(PROJECTS) -xf $(DOWNLOAD)/$(LIBSDLTTF).tar.gz
	@touch $@

$(DOWNLOAD)/$(LIBSDLTTF).tar.gz:
	$(call get-file,$(LIBSDLTTF),https://github.com/SDL-mirror/SDL_ttf/archive/SDL-1.2.tar.gz,$(LIBSDLTTF).tar.gz)
