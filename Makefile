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
PREFIX=/opt/amiga
export PATH := $(PREFIX)/bin:$(PATH)
SHELL = /bin/bash

GCCBRANCH=gcc-6-branch
GCCVERSION=$(shell cat projects/gcc/gcc/BASE-VER)

CFLAGS=-Os
CPPFLAGS=-Os
CXXFLAGS=-Os
E=CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)" CXXFLAGS="$(CXXFLAGS)"

# cross compile:
A=CFLAGS="-Os" CPPFLAGS="-Os" CXXFLAGS="-Os"

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
	@echo "make help 		display this help"
	@echo "make all 		build and install all"
	@echo "make <target>		builds a target: binutils, gcc, fd2sfd, fd2pragma, ira, sfdc, vbcc, vlink, libnix, ixemul, libgcc"
	@echo "make clean		remove the build folder"
	@echo "make clean-<target>	remove the target's build folder"
	@echo "make clean-prefix	remove all content from the prefix folder"
	@echo "make update		perform git pull for all targets"
	@echo "make update-<target>	perform git pull for the given target"

# =================================================
# all
# =================================================
.PHONY: all gcc binutils fd2sfd fd2pragma ira sfdc vbcc vlink libnix ixemul libgcc
all: gcc binutils fd2sfd fd2pragma ira sfdc vbcc vlink libnix ixemul libgcc

# =================================================
# clean
# =================================================
.PHONY: clean-prefix clean clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vbcc clean-vlink clean-libnix clean-ixemul
clean: clean-gcc clean-binutils clean-fd2sfd clean-fd2pragma clean-ira clean-sfdc clean-vbcc clean-vlink clean-libnix clean-ixemul
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

clean-vlink:
	rm -rf build/vlink

clean-libnix:
	rm -rf build/libnix
	
clean-ixemul:
	rm -rf build/ixemul

# clean-prefix drops the files from prefix folder
clean-prefix:
	rm -rf $(PREFIX)/*
	mkdir -p $(PREFIX)/bin

# =================================================
# update all projects
# =================================================
.PHONY: update update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vbcc update-vlink update-libnix update-ixemul
update: update-gcc update-binutils update-fd2sfd update-fd2pragma update-ira update-sfdc update-vbcc update-vlink update-libnix update-ixemul

update-gcc: projects/gcc/configure
	pushd projects/gcc; export DEPTH=1; while true; do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH && break; export DEPTH=$$(($$DEPTH+$$DEPTH));done; popd
	GCCVERSION=$(shell cat projects/gcc/gcc/BASE-VER)

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

update-vlink: projects/vlink/Makefile
	pushd projects/vlink; git pull; popd

update-libnix: projects/libnix/configure
	pushd projects/libnix; git pull; popd
	
update-ixemul: projects/ixemul/configure
	pushd projects/ixemul; git pull; popd

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
GCCP = $(patsubst m68k-amigaos%,$(PREFIX)/bin/\%%$(EXEEXT), $(GCC_CMD))

GCC_DIR = . gcc gcc/c gcc/c-family gcc/cp gcc/objc gcc/config/m68k libiberty libcpp libdecnumber
GCCD = $(patsubst %,projects/gcc/%, $(GCC_DIR))

gcc: build/gcc/.done

build/gcc/.done: $(GCC)
	@echo "built $(GCC)"
	@echo "done" >$@

$(GCCP): build/gcc/Makefile $(shell find $(GCCD) -maxdepth 1 -type f ) build/binutils/.done
	pushd build/gcc; $(MAKE) all-gcc;	popd
	pushd build/gcc; $(MAKE) install-gcc; popd

build/gcc/Makefile: projects/gcc/configure projects/ixemul/configure
	@mkdir -p build/gcc
	pushd build/gcc; $(E) $(PWD)/projects/gcc/configure $(CONFIG_GCC); popd

projects/gcc/configure:
	@mkdir -p projects
	pushd projects;	git clone -b $(GCCBRANCH) --depth 1 https://github.com/bebbo/gcc; popd

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

binutils: build/binutils/.done

build/binutils/.done: $(BINUTILS)
	@echo "built $(BINUTILS)"
	@echo "done" >$@


$(BINUTILSP): build/binutils/Makefile $(shell find $(BINUTILSD) -maxdepth 1 -type f)
	touch -d19710101 projects/binutils/binutils/arparse.y
	touch -d19710101 projects/binutils/binutils/arlex.l
	touch -d19710101 projects/binutils/ld/ldgram.y
	pushd build/binutils; $(MAKE) all install; popd

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

fd2sfd: build/fd2sfd/.done

build/fd2sfd/.done: $(PREFIX)/bin/fd2sfd
	@echo "built $(PREFIX)/bin/fd2sfd"
	@echo "done" >$@

$(PREFIX)/bin/fd2sfd: build/fd2sfd/Makefile $(shell find projects/fd2sfd -not \( -path projects/fd2sfd/.git -prune \) -type f)
	pushd build/fd2sfd; $(MAKE) all; popd
	mkdir -p $(PREFIX)/bin/
	pushd build/fd2sfd; $(MAKE) install; popd

build/fd2sfd/Makefile: projects/fd2sfd/configure
	@mkdir -p build/fd2sfd
	pushd build/fd2sfd; $(E) $(PWD)/projects/fd2sfd/configure $(CONFIG_FD2SFD); popd

projects/fd2sfd/configure:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/cahirwpz/fd2sfd; popd

# =================================================
# fd2pragma
# =================================================
fd2pragma: build/fd2pragma/.done

build/fd2pragma/.done: $(PREFIX)/bin/fd2pragma
	@echo "built $(PREFIX)/bin/fd2pragma"
	@echo "done" >$@

$(PREFIX)/bin/fd2pragma: build/fd2pragma/fd2pragma
	mkdir -p $(PREFIX)/bin/
	install build/fd2pragma/fd2pragma $(PREFIX)/bin/

build/fd2pragma/fd2pragma: projects/fd2pragma/makefile $(shell find projects/fd2pragma -not \( -path projects/fd2pragma/.git -prune \) -type f)
	@mkdir -p build/fd2pragma
	pushd projects/fd2pragma; $(CC) -o $(PWD)/$@ $(CFLAGS) fd2pragma.c; popd

projects/fd2pragma/makefile:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/adtools/fd2pragma; popd

# =================================================
# ira
# =================================================
ira: build/ira/.done

build/ira/.done: $(PREFIX)/bin/ira
	@echo "built $(PREFIX)/bin/ira"
	@echo "done" >$@

$(PREFIX)/bin/ira: build/ira/ira
	mkdir -p $(PREFIX)/bin/
	install build/ira/ira $(PREFIX)/bin/

build/ira/ira: projects/ira/Makefile $(shell find projects/ira -not \( -path projects/ira/.git -prune \) -type f)
	@mkdir -p build/ira
	pushd projects/ira; $(CC) -o $(PWD)/$@ $(CFLAGS) ira.c ira_2.c supp.c; popd

projects/ira/Makefile:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/bebbo/ira; popd

# =================================================
# sfdc
# =================================================
CONFIG_SFDC = --prefix=$(PREFIX) --target=m68k-amigaos

sfdc: build/sfdc/.done

build/sfdc/.done: $(PREFIX)/bin/sfdc
	@echo "built $(PREFIX)/bin/sfdc"
	@echo "done" >$@

$(PREFIX)/bin/sfdc: build/sfdc/Makefile $(shell find projects/sfdc -not \( -path projects/sfdc/.git -prune \)  -type f)
	pushd build/sfdc; $(MAKE) sfdc; popd
	mkdir -p $(PREFIX)/bin/
	install build/sfdc/sfdc $(PREFIX)/bin

build/sfdc/Makefile: projects/sfdc/configure
	rsync -a projects/sfdc build --exclude .git
	pushd build/sfdc; $(E) $(PWD)/build/sfdc/configure $(CONFIG_SFDC); popd

projects/sfdc/configure:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/adtools/sfdc; popd

# =================================================
# vbcc
# =================================================
VBCC_CMD = vbccm68k vprof vc
VBCC = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VBCC_CMD))
VBCCP = $(patsubst v%,$(PREFIX)/bin/\%%$(EXEEXT), $(VBCC_CMD))

vbcc: build/vbcc/.done

build/vbcc/.done: $(VBCC)
	@echo "built $(VBCC)"
	@echo "done" >$@

$(VBCCP): build/vbcc/Makefile $(shell find projects/vbcc -not \( -path projects/vbcc/.git -prune \) -type f)
	pushd build/vbcc; TARGET=m68k $(MAKE) bin/dtgen; popd
	pushd build/vbcc; echo -e "y\\ny\\nsigned char\\ny\\nunsigned char\\nn\\ny\\nsigned short\\nn\\ny\\nunsigned short\\nn\\ny\\nsigned int\\nn\\ny\\nunsigned int\\nn\\ny\\nsigned long long\\nn\\ny\\nunsigned long long\\nn\\ny\\nfloat\\nn\\ny\\ndouble\\n" >c.txt; bin/dtgen machines/m68k/machine.dt machines/m68k/dt.h machines/m68k/dt.c <c.txt; popd
	pushd build/vbcc; TARGET=m68k $(MAKE); popd
	mkdir -p $(PREFIX)/bin/
	install build/vbcc/bin/v* $(PREFIX)/bin/

build/vbcc/Makefile: projects/vbcc/Makefile
	rsync -a projects/vbcc build --exclude .git
	mkdir -p build/vbcc/bin

projects/vbcc/Makefile:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/leffmann/vbcc; popd

# =================================================
# vlink
# =================================================
VLINK_CMD = vlink
VLINK = $(patsubst %,$(PREFIX)/bin/%$(EXEEXT), $(VLINK_CMD))
VLINKP = $(patsubst v%,$(PREFIX)/bin/\%%$(EXEEXT), $(VLINK_CMD))

vlink: build/vlink/.done

build/vlink/.done: $(VLINK)
	@echo "built $(VLINK)"
	@echo "done" >$@

$(VLINKP): build/vlink/Makefile $(shell find projects/vlink -not \( -path projects/vlink/.git -prune \) -type f)
	pushd build/vlink; TARGET=m68k $(MAKE); popd
	mkdir -p $(PREFIX)/bin/
	install build/vlink/vlink $(PREFIX)/bin/

build/vlink/Makefile: projects/vlink/Makefile
	rsync -a projects/vlink build --exclude .git

projects/vlink/Makefile:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/leffmann/vlink; popd

# =================================================
# L I B R A R I E S
# =================================================
# =================================================
# NDK - no git
# =================================================

NDK_INCLUDE = $(shell find projects/NDK_3.9/Include/include_h -type f)
NDK_INCLUDE_SFD = $(shell find projects/NDK_3.9/Include/sfd -type f -name *.sfd)
SYS_INCLUDE_INLINE = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX)/m68k-amigaos/sys-include/inline/%.h,$(NDK_INCLUDE_SFD))
SYS_INCLUDE_LVO    = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX)/m68k-amigaos/sys-include/lvo/%.h,$(NDK_INCLUDE_SFD))
SYS_INCLUDE_PROTO  = $(patsubst projects/NDK_3.9/Include/sfd/%_lib.sfd,$(PREFIX)/m68k-amigaos/sys-include/proto/%.h,$(NDK_INCLUDE_SFD))
SYS_INCLUDE2 = $(filter-out $(SYS_INCLUDE_PROTO),$(patsubst projects/NDK_3.9/Include/include_h/%,$(PREFIX)/m68k-amigaos/sys-include/%, $(NDK_INCLUDE)))


.PHONY: sys-include2

sys-include2: build/sys-include/.done2

build/sys-include/.done2: projects/NDK_3.9.info $(NDK_INCLUDE) $(SYS_INCLUDE_INLINE) $(SYS_INCLUDE_PRAGMA) $(SYS_INCLUDE_PROTO) projects/fd2sfd/configure projects/fd2pragma/makefile
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

$(SYS_INCLUDE_INLINE): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD) build/sys-include/.inline build/sys-include/.lvo build/sys-include/.proto
	sfdc --target=m68k-amigaos --mode=macros --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/sys-include/inline/%.h,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@) 

$(SYS_INCLUDE_LVO): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD)
	sfdc --target=m68k-amigaos --mode=lvo --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/sys-include/lvo/%.h,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@) 

$(SYS_INCLUDE_PROTO): $(PREFIX)/bin/sfdc $(NDK_INCLUDE_SFD)	
	sfdc --target=m68k-amigaos --mode=proto --output=$@ $(patsubst $(PREFIX)/m68k-amigaos/sys-include/proto/%.h,projects/NDK_3.9/Include/sfd/%_lib.sfd,$@) 

build/sys-include/.inline:
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include/inline
	mkdir -p build/sys-include/
	echo "done" >$@

build/sys-include/.lvo:
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include/lvo
	mkdir -p build/sys-include/
	echo "done" >$@

build/sys-include/.proto:
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include/proto
	mkdir -p build/sys-include/
	echo "done" >$@

projects/NDK_3.9.info: download/NDK39.lha
	mkdir -p projects
	pushd projects; lha x ../download/NDK39.lha; popd
	touch -d19710101 download/NDK39.lha
	for i in $$(find patches/NDK_3.9/ -type f); \
	do if [[ "$$i" == *.diff ]] ; \
		then j=$${i:8}; patch -N "projects/$${j%.diff}" "$$i"; \
		else cp -pv "$$i" "projects/$${i:8}"; fi ; done

download/NDK39.lha:
	mkdir -p download
	pushd download; wget http://www.haage-partner.de/download/AmigaOS/NDK39.lha; popd
	
# =================================================
# ixemul
# =================================================
CONFIG_IXEMUL = --prefix=$(PREFIX) --target=m68k-amigaos --host=m68k-amigaos --disable-cat

IXEMUL_INCLUDE = $(shell find projects/ixemul/include -type f)
SYS_INCLUDE = $(patsubst projects/ixemul/include/%,$(PREFIX)/m68k-amigaos/sys-include/%, $(IXEMUL_INCLUDE))

build/ixemul/Makefile: $(DUMMYLIBSP) projects/ixemul/configure $(shell find projects/ixemul -not \( -path projects/ixemul/.git -prune \) -type f)
	mkdir -p build/ixemul
	pushd build/ixemul; $(A) $(PWD)/projects/ixemul/configure $(CONFIG_IXEMUL); popd

.PHONY: sys-include
sys-include: build/sys-include/.done

build/sys-include/.done: $(IXEMUL_INCLUDE) projects/ixemul/configure
	mkdir -p $(PREFIX)/m68k-amigaos/sys-include
	rsync -a projects/ixemul/include/* $(PREFIX)/m68k-amigaos/sys-include
	mkdir -p build/sys-include/
	echo "done" >$@

projects/ixemul/configure:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/bebbo/ixemul; popd

# =================================================
# libnix
# =================================================
LIBNIXLIBS=libm.a libnixmain.a libnix.a libnix20.a libstubs.a
DUMMYLIBSP=$(PREFIX)/lib/gcc/m68k-amigaos/$(GCCVERSION)/libgcc.a $(patsubst %,$(PREFIX)/m68k-amigaos/libnix/lib/libnix/%,$(LIBNIXLIBS))
LIBNIX=$(patsubst %,$(PREFIX)/m68k-amigaos/libnix/lib/libb/libnix/%,$(LIBNIXLIBS))
DUMMYSTART=$(PREFIX)/m68k-amigaos/libnix/lib/libnix/ncrt0.o


build/libnix/.dummydone: 
	$(MAKE) dummylibs
	mkdir -p build/libnix
	echo "done" > build/libnix/.dummydone

.PHONY: dummylibs
dummylibs: $(DUMMYLIBSP)

$(DUMMYLIBSP): $(DUMMYSTART)
	echo "creating dummy lib $@"
	$(PREFIX)/bin/m68k-amigaos-ar r $@

$(DUMMYSTART): build/gcc/.done
	mkdir -p build/libnix 
	@mkdir -p $(PREFIX)/lib/gcc/m68k-amigaos/$(GCCVERSION)
	@mkdir -p $(PREFIX)/m68k-amigaos/libnix/lib/libnix
	echo 'void foo(){}' > build/libnix/x.c
	$(PREFIX)/bin/m68k-amigaos-gcc -c build/libnix/x.c -o $(DUMMYSTART)

CONFIG_LIBNIX = --prefix=$(PREFIX)/m68k-amigaos/libnix --target=m68k-amigaos --host=m68k-amigaos

LIBNIX_SRC = $(shell find projects/libnix -not \( -path projects/libnix/.git -prune \) -not \( -path projects/libnix/sources/stubs/libbases -prune \) -not \( -path projects/libnix/sources/stubs/libnames -prune \) -type f)

libnix: build/libnix/.done

build/libnix/.done: $(LIBNIX)
	@echo "built $(LIBNIX)"
	@echo "done" >$@

$(LIBNIX): build/libnix/.build

build/libnix/.build: build/binutils/.done build/gcc/.done build/libnix/Makefile 
	mkdir -p $(PREFIX)/m68k-amigaos/libnix/lib/libnix/
	mkdir -p $(PREFIX)/m68k-amigaos/libnix/include/
	pushd build/libnix; $(MAKE); popd
	pushd build/libnix; $(MAKE) install; popd
	rsync -a projects/libnix/sources/headers/* $(PREFIX)/m68k-amigaos/libnix/include/
	@echo "done" >build/libnix/.build
		
build/libnix/Makefile: build/sys-include/.done build/sys-include/.done2 build/libnix/.dummydone projects/libnix/configure $(LIBNIX_SRC)		
	pushd build/libnix; AR=m68k-amigaos-ar AS=m68k-amigaos-as CC=m68k-amigaos-gcc $(A) $(PWD)/projects/libnix/configure $(CONFIG_LIBNIX); popd
	touch build/libnix/Makefile
	
projects/libnix/configure:
	@mkdir -p projects
	pushd projects;	git clone -b master --depth 1 https://github.com/bebbo/libnix; popd

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
LIBGCCSP=$(patsubst $(PREFIX)/lib/gcc/m68k-amigaos/$(GCCVERSION)/lib%,$(PREFIX)/lib/gcc/m68k-amigaos/$(GCCVERSION)/\%%,$(LIBGCCS))

libgcc: $(LIBGCCS)

$(LIBGCCSP): build/libnix/.done $(DUMMYLIBSP) $(LIBAMIGA)
	pushd build/gcc; $(MAKE) all-target; popd
	pushd build/gcc; $(MAKE) install-target; popd
