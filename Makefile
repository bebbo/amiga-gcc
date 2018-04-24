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
export PATH := $(PREFIX)/bin:$(PATH)
SHELL = /bin/bash

GCCBRANCH ?= gcc-6-branch
GCCVERSION = $(shell cat 2>/dev/null projects/gcc/gcc/BASE-VER)

CFLAGS?=-Os
CPPFLAGS=$(CFLAGS)
CXXFLAGS=$(CFLAGS)
TARGET_C_FLAGS?=-Os -g -fomit-frame-pointer

E=CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)" CXXFLAGS="$(CXXFLAGS)" LIBCFLAGS_FOR_TARGET="$(TARGET_C_FLAGS)"


# =================================================
# determine exe extension for cygwin
$(eval MYMAKE = $(shell which make) )
$(eval MYMAKEEXE = $(shell which "$(MYMAKE:%=%.exe)") )
EXEEXT=$(MYMAKEEXE:%=.exe)
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
	@echo "make <target>        builds a target: binutils, gcc, fd2sfd, fd2pragma, ira, sfdc, vasm, vbcc, vlink, libnix, ixemul, libgcc, clib2, libdebug, libSDL12"
	@echo "make clean           remove the build folder"
	@echo "make clean-<target>	remove the target's build folder"
	@echo "make clean-prefix    remove all content from the prefix folder"
	@echo "make update          perform git pull for all targets"
	@echo "make update-<target> perform git pull for the given target"
	@echo "make sdk=<sdk>       install the sdk <sdk>"
	@echo "make all-sdk         install all sdks"

# =================================================
# all
# =================================================
.PHONY: all gcc binutils fd2sfd fd2pragma ira sfdc vasm vbcc vlink libnix ixemul libgcc clib2 libdebug libSDL12
all: gcc binutils fd2sfd fd2pragma ira sfdc vbcc vasm vlink libnix ixemul libgcc clib2 libdebug libSDL12

# =================================================
# clean
# =================================================
.PHONY: clean-prefix clean clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vasm clean-vbcc clean-vlink clean-libnix clean-ixemul clean-libgcc clean-clib2 clean-libdebug clean-libSDL12
clean: clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vasm clean-vbcc clean-vlink clean-libnix clean-ixemul clean-clib2 clean-libdebug clean-libSDL12
	rm -rf build

clean-gcc:
	rm -rf build/gcc

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

# clean-prefix drops the files from prefix folder
clean-prefix:
	rm -rf $(PREFIX)/*
	mkdir -p $(PREFIX)/bin

# =================================================
# update all projects
# =================================================
.PHONY: update update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vasm update-vbcc update-vlink update-libnix update-ixemul update-clib2 update-libdebug update-libSDL12 update-ndk
update: update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vasm update-vbcc update-vlink update-libnix update-ixemul update-clib2 update-libdebug update-libSDL12 update-ndk

update-gcc: projects/gcc/configure
	cd projects/gcc && export DEPTH=4; while true; do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH && break; export DEPTH=$$(($$DEPTH+$$DEPTH));done
	GCCVERSION=$(shell cat 2>/dev/null projects/gcc/gcc/BASE-VER)

update-binutils: projects/binutils/configure
	@pushd projects/binutils && a=($$(git remote -v)); if [ "$${a[1]}" == "$(GIT_BINUTILS)" ]; then git pull; else \
	  cd .. ; rm -rf binutils; popd; $(MAKE) projects/binutils/configure; fi

update-fd2fsd: projects/fd2sfd/configure
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

status-all:
	GCCVERSION=$(shell cat 2>/dev/null projects/gcc/gcc/BASE-VER)
# =================================================
# B I N
# =================================================
	
# =================================================
# gcc
# =================================================
CONFIG_GCC=--prefix=$(PREFIX) --target=m68k-amigaos --enable-languages=c,c++,objc --enable-version-specific-runtime-libs --disable-libssp --disable-nls

GCC_CMD = m68k-amigaos-c++ m68k-amigaos-g++ m68k-amigaos-gcc-$(GCCVERSION) m68k-amigaos-gcc-nm \
	m68k-amigaos-gcov m68k-amigaos-gcov-tool m68k-amigaos-cpp m68k-amigaos-gcc m68k-amigaos-gcc-ar \
	m68k-amigaos-gcc-ranlib m68k-amigaos-gcov-dump
GCC = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(GCC_CMD))

GCC_DIR = . gcc gcc/c gcc/c-family gcc/cp gcc/objc gcc/config/m68k libiberty libcpp libdecnumber
GCCD = $(patsubst %,projects/gcc/%, $(GCC_DIR))

gcc: build/gcc/_done

build/gcc/_done: build/gcc/Makefile $(shell find 2>/dev/null $(GCCD) -maxdepth 1 -type f ) build/binutils/_done
	cd build/gcc && $(MAKE) all-gcc
	cd build/gcc && $(MAKE) install-gcc
	echo "done" >build/gcc/_done
	@echo "built $(GCC)"

build/gcc/Makefile: projects/gcc/configure projects/ixemul/configure build/binutils/_done
	@mkdir -p build/gcc
	cd build/gcc && $(E) $(PWD)/projects/gcc/configure $(CONFIG_GCC)

projects/gcc/configure:
	@mkdir -p projects
	cd projects &&	git clone -b $(GCCBRANCH) --depth 4 https://github.com/bebbo/gcc

# =================================================
# binutils
# =================================================
CONFIG_BINUTILS=--prefix=$(PREFIX) --target=m68k-amigaos
BINUTILS_CMD = m68k-amigaos-addr2line m68k-amigaos-ar m68k-amigaos-as m68k-amigaos-c++filt \
	m68k-amigaos-ld m68k-amigaos-nm m68k-amigaos-objcopy m68k-amigaos-objdump m68k-amigaos-ranlib \
	m68k-amigaos-readelf m68k-amigaos-size m68k-amigaos-strings m68k-amigaos-strip
BINUTILS = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(BINUTILS_CMD))

BINUTILS_DIR = . bfd gas ld binutils opcodes
BINUTILSD = $(patsubst %,projects/binutils/%, $(BINUTILS_DIR))

binutils: build/binutils/_done

build/binutils/_done: build/binutils/Makefile $(shell find 2>/dev/null $(BINUTILSD) -maxdepth 1 -type f)
	touch -d19710101 projects/binutils/binutils/arparse.y
	touch -d19710101 projects/binutils/binutils/arlex.l
	touch -d19710101 projects/binutils/ld/ldgram.y
	cd build/binutils && $(MAKE)
	cd build/binutils && $(MAKE) install
	echo "done" >build/binutils/_done
	echo "build $(BINUTILS)"

build/binutils/Makefile: projects/binutils/configure
	@mkdir -p build/binutils
	cd build/binutils && $(E) $(PWD)/projects/binutils/configure $(CONFIG_BINUTILS)

ifeq ($(GIT_BINUTILS),)
GIT_BINUTILS = https://github.com/bebbo/amigaos-binutils-2.14
endif
projects/binutils/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 $(GIT_BINUTILS) binutils


# =================================================
# fd2sfd
# =================================================
CONFIG_FD2SFD = --prefix=$(PREFIX) --target=m68k-amigaos

fd2sfd: build/fd2sfd/_done

build/fd2sfd/_done: $(PREFIX)/bin/fd2sfd
	@echo "built $(PREFIX)/bin/fd2sfd"
	@echo "done" >$@

$(PREFIX)/bin/fd2sfd: build/fd2sfd/Makefile $(shell find 2>/dev/null projects/fd2sfd -not \( -path projects/fd2sfd/.git -prune \) -type f)
	cd build/fd2sfd && $(MAKE) all
	mkdir -p $(PREFIX)/bin/
	cd build/fd2sfd && $(MAKE) install

build/fd2sfd/Makefile: projects/fd2sfd/configure
	@mkdir -p build/fd2sfd
	cd build/fd2sfd && $(E) $(PWD)/projects/fd2sfd/configure $(CONFIG_FD2SFD)

projects/fd2sfd/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/cahirwpz/fd2sfd

# =================================================
# fd2pragma
# =================================================
fd2pragma: build/fd2pragma/_done

build/fd2pragma/_done: $(PREFIX)/bin/fd2pragma
	@echo "built $(PREFIX)/bin/fd2pragma"
	@echo "done" >$@

$(PREFIX)/bin/fd2pragma: build/fd2pragma/fd2pragma
	mkdir -p $(PREFIX)/bin/
	install build/fd2pragma/fd2pragma $(PREFIX)/bin/

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

build/ira/_done: $(PREFIX)/bin/ira
	@echo "built $(PREFIX)/bin/ira"
	@echo "done" >$@

$(PREFIX)/bin/ira: build/ira/ira
	mkdir -p $(PREFIX)/bin/
	install build/ira/ira $(PREFIX)/bin/

build/ira/ira: projects/ira/Makefile $(shell find 2>/dev/null projects/ira -not \( -path projects/ira/.git -prune \) -type f)
	@mkdir -p build/ira
	cd projects/ira && $(CC) -o $(PWD)/$@ $(CFLAGS) *.c -std=c99

projects/ira/Makefile:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/ira

# =================================================
# sfdc
# =================================================
CONFIG_SFDC = --prefix=$(PREFIX) --target=m68k-amigaos

sfdc: build/sfdc/_done

build/sfdc/_done: $(PREFIX)/bin/sfdc
	@echo "built $(PREFIX)/bin/sfdc"
	@echo "done" >$@

$(PREFIX)/bin/sfdc: build/sfdc/Makefile $(shell find 2>/dev/null projects/sfdc -not \( -path projects/sfdc/.git -prune \)  -type f)
	cd build/sfdc && $(MAKE) sfdc
	mkdir -p $(PREFIX)/bin/
	install build/sfdc/sfdc $(PREFIX)/bin

build/sfdc/Makefile: projects/sfdc/configure
	rsync -a projects/sfdc build --exclude .git
	cd build/sfdc && $(E) $(PWD)/build/sfdc/configure $(CONFIG_SFDC)

projects/sfdc/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/adtools/sfdc

# =================================================
# vasm
# =================================================
VASM_CMD = vasmm68k_mot
VASM = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VASM_CMD))

vasm: build/vasm/_done

build/vasm/_done: build/vasm/Makefile $(shell find 2>/dev/null projects/vasm -not \( -path projects/vasm/.git -prune \) -type f)
	cd build/vasm && $(MAKE) CPU=m68k SYNTAX=mot
	mkdir -p $(PREFIX)/bin/
	install build/vasm/vasmm68k_mot $(PREFIX)/bin/
	install build/vasm/vobjdump $(PREFIX)/bin/
	cp patches/vc.config build/vasm/vc.config
	sed -e "s|PREFIX|$(PREFIX)|g" -i build/vasm/vc.config
	mkdir -p $(PREFIX)/m68k-amigaos/etc/
	install build/vasm/vc.config $(PREFIX)/bin/
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
VBCC = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VBCC_CMD))

vbcc: build/vbcc/_done

build/vbcc/_done: build/vbcc/Makefile $(shell find 2>/dev/null projects/vbcc -not \( -path projects/vbcc/.git -prune \) -type f)
	cd build/vbcc && TARGET=m68k $(MAKE) bin/dtgen
	cd build/vbcc && echo -e "y\\ny\\nsigned char\\ny\\nunsigned char\\nn\\ny\\nsigned short\\nn\\ny\\nunsigned short\\nn\\ny\\nsigned int\\nn\\ny\\nunsigned int\\nn\\ny\\nsigned long long\\nn\\ny\\nunsigned long long\\nn\\ny\\nfloat\\nn\\ny\\ndouble\\n" >c.txt; bin/dtgen machines/m68k/machine.dt machines/m68k/dt.h machines/m68k/dt.c <c.txt
	cd build/vbcc && TARGET=m68k $(MAKE)
	mkdir -p $(PREFIX)/bin/
	install build/vbcc/bin/v* $(PREFIX)/bin/
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
VLINK = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VLINK_CMD))

vlink: build/vlink/_done

build/vlink/_done: build/vlink/Makefile $(shell find 2>/dev/null projects/vlink -not \( -path projects/vlink/.git -prune \) -type f)
	cd build/vlink && TARGET=m68k $(MAKE)
	mkdir -p $(PREFIX)/bin/
	install build/vlink/vlink $(PREFIX)/bin/
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
SYS_INCLUDE_INLINE = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX)/m68k-amigaos/sys-include/inline/%.h,$(NDK_INCLUDE_SFD))
SYS_INCLUDE_LVO    = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX)/m68k-amigaos/sys-include/lvo/%_lib.i,$(NDK_INCLUDE_SFD))
SYS_INCLUDE_PROTO  = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX)/m68k-amigaos/sys-include/proto/%.h,$(NDK_INCLUDE_SFD))
SYS_INCLUDE2 = $(filter-out $(SYS_INCLUDE_PROTO),$(patsubst projects/NDK_3.9/Include/include_h/%,$(PREFIX)/m68k-amigaos/sys-include/%, $(NDK_INCLUDE)))


.PHONY: sys-include2 sys-inline sys-lvo sys-proto

sys-include2: build/sys-include/_done2

build/sys-include/_done2: projects/NDK_3.9.info $(NDK_INCLUDE) $(SYS_INCLUDE_INLINE) $(SYS_INCLUDE_LVO) $(SYS_INCLUDE_PROTO) projects/fd2sfd/configure projects/fd2pragma/makefile
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include
	rsync -a $(PWD)/projects/NDK_3.9/Include/include_h/* $(PREFIX)/m68k-amigaos/sys-include --exclude proto
	rsync -a $(PWD)/projects/NDK_3.9/Include/include_i/* $(PREFIX)/m68k-amigaos/sys-include
	mkdir -p $(PREFIX)/m68k-amigaos/ndk/lib
	rsync -a $(PWD)/projects/NDK_3.9/Include/fd $(PREFIX)/m68k-amigaos/ndk/lib
	rsync -a $(PWD)/projects/NDK_3.9/Include/sfd $(PREFIX)/m68k-amigaos/ndk/lib
	rsync -a $(PWD)/projects/NDK_3.9/Include/linker_libs $(PREFIX)/m68k-amigaos/ndk/lib
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include/proto
	cp -p projects/NDK_3.9/Include/include_h/proto/alib.h $(PREFIX)/m68k-amigaos/sys-include/proto
	cp -p projects/NDK_3.9/Include/include_h/proto/cardres.h $(PREFIX)/m68k-amigaos/sys-include/proto
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include/inline
	cp -p projects/fd2sfd/cross/share/m68k-amigaos/alib.h $(PREFIX)/m68k-amigaos/sys-include/inline
	cp -p projects/fd2pragma/Include/inline/stubs.h $(PREFIX)/m68k-amigaos/sys-include/inline
	cp -p projects/fd2pragma/Include/inline/macros.h $(PREFIX)/m68k-amigaos/sys-include/inline
	mkdir -p build/sys-include/
	echo "done" >$@

sys-inline: $(SYS_INCLUDE_INLINE) sfdc
$(SYS_INCLUDE_INLINE): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD) build/sys-include/_inline build/sys-include/_lvo build/sys-include/_proto
	sfdc --target=m68k-amigaos --mode=macros --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/sys-include/inline/%.h,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@)

sys-lvo: $(SYS_INCLUDE_LVO) sfdc
$(SYS_INCLUDE_LVO): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD)
	sfdc --target=m68k-amigaos --mode=lvo --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/sys-include/lvo/%_lib.i,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@)

sys-proto: $(SYS_INCLUDE_PROTO) sfdc
$(SYS_INCLUDE_PROTO): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD)	
	sfdc --target=m68k-amigaos --mode=proto --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/sys-include/proto/%.h,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@)

build/sys-include/_inline:
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include/inline
	mkdir -p build/sys-include/
	echo "done" >$@

build/sys-include/_lvo:
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include/lvo
	mkdir -p build/sys-include/
	echo "done" >$@

build/sys-include/_proto:
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include/proto
	mkdir -p build/sys-include/
	echo "done" >$@

projects/NDK_3.9.info: download/NDK39.lha $(shell find 2>/dev/null patches/NDK_3.9/ -type f)
	mkdir -p projects
	if [ ! -e "$$(which lha)" ]; then cd build && rm -rf lha; git clone https://github.com/jca02266/lha; cd lha; aclocal; autoheader; automake -a; autoconf; ./configure; make all; install src/lha$(EXEEXT) /usr/bin; fi
	cd projects && lha xf ../download/NDK39.lha
	touch -d19710101 download/NDK39.lha
	for i in $$(find patches/NDK_3.9/ -type f); \
	do if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "projects/$${j%.diff}" "$$i"; \
		else cp -pv "$$i" "projects/$${i:8}"; fi ; done
	touch projects/NDK_3.9.info

download/NDK39.lha:
	mkdir -p download
	cd download && wget http://www.haage-partner.de/download/AmigaOS/NDK39.lha
	
# =================================================
# ixemul
# =================================================
CONFIG_IXEMUL = --prefix=$(PREFIX) --target=m68k-amigaos --host=m68k-amigaos --disable-cat

IXEMUL_INCLUDE = $(shell find 2>/dev/null projects/ixemul/include -type f)
SYS_INCLUDE = $(patsubst projects/ixemul/include/%,$(PREFIX)/m68k-amigaos/sys-include/%, $(IXEMUL_INCLUDE))

build/ixemul/Makefile: build/libnix/_done projects/ixemul/configure $(shell find 2>/dev/null projects/ixemul -not \( -path projects/ixemul/.git -prune \) -type f)
	mkdir -p build/ixemul
	cd build/ixemul && $(A) $(PWD)/projects/ixemul/configure $(CONFIG_IXEMUL)

.PHONY: sys-include
sys-include: build/sys-include/_done

build/sys-include/_done: $(IXEMUL_INCLUDE) projects/ixemul/configure
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include
	rsync -a projects/ixemul/include/* $(PREFIX)/m68k-amigaos/sys-include
	mkdir -p build/sys-include/
	echo "done" >$@

projects/ixemul/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/ixemul

# =================================================
# libnix
# =================================================


CONFIG_LIBNIX = --prefix=$(PREFIX)/m68k-amigaos/libnix --target=m68k-amigaos --host=m68k-amigaos

LIBNIX_SRC = $(shell find 2>/dev/null projects/libnix -not \( -path projects/libnix/.git -prune \) -not \( -path projects/libnix/sources/stubs/libbases -prune \) -not \( -path projects/libnix/sources/stubs/libnames -prune \) -type f)

libnix: build/libnix/_done

build/libnix/_done: build/libnix/Makefile
	cd build/libnix && $(MAKE)
	cd build/libnix && $(MAKE) install
	@echo "done" >build/libnix/_done
	@echo "built $(LIBNIX)"
		
build/libnix/Makefile: build/sys-include/_done build/sys-include/_done2 build/binutils/_done build/gcc/_done projects/libnix/configure projects/libnix/Makefile.in $(LIBNIX_SRC)
	mkdir -p $(PREFIX)/m68k-amigaos/libnix/lib/libnix
	mkdir -p build/libnix
	echo 'void foo(){}' > build/libnix/x.c
	if [ ! -e $(PREFIX)/m68k-amigaos/libnix/lib/libnix/ncrt0.o ]; then $(PREFIX)/bin/m68k-amigaos-gcc -c build/libnix/x.c -o $(PREFIX)/m68k-amigaos/libnix/lib/libnix/ncrt0.o; fi
	if [ ! -e $(PREFIX)/m68k-amigaos/libnix/lib/libnix/libm.a ]; then $(PREFIX)/bin/m68k-amigaos-ar r $(PREFIX)/m68k-amigaos/libnix/lib/libnix/libm.a; fi
	if [ ! -e $(PREFIX)/m68k-amigaos/libnix/lib/libnix/libnixmain.a ]; then $(PREFIX)/bin/m68k-amigaos-ar r $(PREFIX)/m68k-amigaos/libnix/lib/libnix/libnixmain.a; fi
	if [ ! -e $(PREFIX)/m68k-amigaos/libnix/lib/libnix/libnix.a ]; then $(PREFIX)/bin/m68k-amigaos-ar r $(PREFIX)/m68k-amigaos/libnix/lib/libnix/libnix.a; fi
	if [ ! -e $(PREFIX)/m68k-amigaos/libnix/lib/libnix/libnix20.a ]; then $(PREFIX)/bin/m68k-amigaos-ar r $(PREFIX)/m68k-amigaos/libnix/lib/libnix/libnix20.a; fi
	if [ ! -e $(PREFIX)/m68k-amigaos/libnix/lib/libnix/libstubs.a ]; then $(PREFIX)/bin/m68k-amigaos-ar r $(PREFIX)/m68k-amigaos/libnix/lib/libnix/libstubs.a; fi
	mkdir -p $(PREFIX)/lib/gcc/m68k-amigaos/$(GCCVERSION)
	if [ ! -e $(PREFIX)/lib/gcc/m68k-amigaos/$(GCCVERSION)/libgcc.a ]; then $(PREFIX)/bin/m68k-amigaos-ar r $(PREFIX)/lib/gcc/m68k-amigaos/$(GCCVERSION)/libgcc.a; fi
	cd build/libnix && CFLAGS="$(TARGET_C_FLAGS)" AR=m68k-amigaos-ar AS=m68k-amigaos-as CC=m68k-amigaos-gcc $(A) $(PWD)/projects/libnix/configure $(CONFIG_LIBNIX)
	mkdir -p $(PREFIX)/m68k-amigaos/libnix/include/
	rsync -a projects/libnix/sources/headers/* $(PREFIX)/m68k-amigaos/libnix/include/
	touch build/libnix/Makefile
	
projects/libnix/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/libnix

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
# gcc libs
# =================================================
LIBGCCS_NAMES=libgcov.a libstdc++.a libsupc++.a
LIBGCCS= $(patsubst %,$(PREFIX)/lib/gcc/m68k-amigaos/$(GCCVERSION)/%,$(LIBGCCS_NAMES))

libgcc: build/gcc/_libgcc_done

build/gcc/_libgcc_done: build/libnix/_done $(LIBAMIGA)
	cd build/gcc && $(MAKE) all-target
	cd build/gcc && $(MAKE) install-target
	echo "done" >build/gcc/_libgcc_done
	echo "$(LIBGCCS)"

# =================================================
# clib2
# =================================================

clib2: build/clib2/_done

build/clib2/_done: projects/clib2/LICENSE $(shell find 2>/dev/null projects/clib2 -not \( -path projects/clib2/.git -prune \) -type f) build/libnix/Makefile $(LIBAMIGA)
	mkdir -p build/clib2/
	rsync -a projects/clib2/library/* build/clib2
	cd build/clib2 && $(MAKE) -f GNUmakefile.68k
	mkdir -p $(PREFIX)/m68k-amigaos/clib2
	rsync -a build/clib2/include $(PREFIX)/m68k-amigaos/clib2
	rsync -a build/clib2/lib $(PREFIX)/m68k-amigaos/clib2
	echo "done" >build/clib2/_done	

projects/clib2/LICENSE:
	@mkdir -p projects
	cd projects && git clone -b master --depth 4 https://github.com/bebbo/clib2

# =================================================
# libdebug
# =================================================
CONFIG_LIBDEBUG = --prefix=$(PREFIX) --target=m68k-amigaos --host=m68k-amigaos

libdebug: build/libdebug/_done

build/libdebug/_done: build/libdebug/Makefile
	cd build/libdebug && $(MAKE)
	cp build/libdebug/libdebug.a $(PREFIX)/m68k-amigaos/lib/
	echo "done" >build/libdebug/_done

build/libdebug/Makefile: build/libnix/_done projects/libdebug/configure $(shell find 2>/dev/null projects/libdebug -not \( -path projects/libdebug/.git -prune \) -type f)
	mkdir -p build/libdebug
	cd build/libdebug && CFLAGS="$(TARGET_C_FLAGS)" $(PWD)/projects/libdebug/configure $(CONFIG_LIBDEBUG)

projects/libdebug/configure:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4 https://github.com/bebbo/libdebug
	touch -d19710101 projects/libdebug/configure.ac

# =================================================
# libsdl
# =================================================
CONFIG_LIBSDL12 = PREFX=$(PREFIX) PREF=$(PREFIX)

libSDL12: build/libSDL12/_done

build/libSDL12/_done: build/libSDL12/Makefile.bax
	$(MAKE) sdk=ahi
	$(MAKE) sdk=cgx
	cd build/libSDL12 && CFLAGS="$(TARGET_C_FLAGS)" $(MAKE) -f Makefile.bax $(CONFIG_LIBSDL12)
	cp build/libSDL12/libSDL.a $(PREFIX)/m68k-amigaos/lib/
	mkdir -p $(PREFIX)/include/GL
	mkdir -p $(PREFIX)/include/SDL
	rsync -a build/libSDL12/include/GL/*.i $(PREFIX)/include/GL/
	rsync -a build/libSDL12/include/GL/*.h $(PREFIX)/include/GL/
	rsync -a build/libSDL12/include/SDL/*.h $(PREFIX)/include/SDL/
	echo "done" >build/libSDL12/_done

build/libSDL12/Makefile.bax: build/libnix/_done projects/libSDL12/Makefile.bax $(shell find 2>/dev/null projects/libSDL12 -not \( -path projects/libSDL12/.git -prune \) -type f)
	mkdir -p build/libSDL12
	rsync -a projects/libSDL12/* build/libSDL12
	touch build/libSDL12/Makefile.bax

projects/libSDL12/Makefile.bax:
	@mkdir -p projects
	cd projects &&	git clone -b master --depth 4  https://github.com/AmigaPorts/libSDL12


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
	$(MAKE) sdk=$@
	
info:
	@echo PREFIX=$(PREFIX)
	@echo GCCBRANCH=$(GCCBRANCH)
	@echo GCCVERSION=$(GCCVERSION)
	@echo CFLAGS=$(CFLAGS)
	@echo TARGET_C_FLAGS=$(TARGET_C_FLAGS)
	
