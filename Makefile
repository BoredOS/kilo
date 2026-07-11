# Copyright (c) 2026 Christiaan (chris@boreddev.nl)
# Kilo Editor Standalone Makefile

CC = x86_64-boredos-gcc
LD = x86_64-boredos-ld

ifneq ($(BOREDOS_SDK),)
  ifeq ($(wildcard $(BOREDOS_SDK)/lib/libc.a),)
    BOOTSTRAP_SDK = $(BOREDOS_SDK)
    SDK_PATH      = $(BOREDOS_SDK)
  else
    SDK_PATH      = $(BOREDOS_SDK)
  endif
endif

ifeq ($(SDK_PATH),)
  SDK_PATH = $(abspath build/sdk)
  ifeq ($(wildcard $(SDK_PATH)/lib/libc.a),)
    BOOTSTRAP_SDK = $(SDK_PATH)
  endif
endif

DESTDIR ?= $(abspath build/dist)

CFLAGS  = -Wall -Wextra -std=gnu11 -ffreestanding -O2 -fno-stack-protector \
          -fno-stack-check -fno-lto -fno-pie -m64 -march=x86-64 -mno-red-zone \
          -isystem $(SDK_PATH)/include

LDFLAGS = -m elf_x86_64 -nostdlib -static -no-pie -Ttext=0x40000000 \
          --no-dynamic-linker -z text -z max-page-size=0x1000 -e _start \
          -L$(SDK_PATH)/lib

APPS    = kilo.elf

all: $(APPS)

kilo.elf: obj/kilo.o
	$(LD) $(LDFLAGS) $(SDK_PATH)/lib/crt0.o $(SDK_PATH)/lib/crti.o $< -lc $(SDK_PATH)/lib/crtn.o -o $@

obj/%.o: src/%.c
	@mkdir -p obj
	$(CC) $(CFLAGS) -c $< -o $@

install: all
	mkdir -p $(DESTDIR)/bin
	cp $(APPS) $(DESTDIR)/bin/

.PHONY: bup
bup: all
	rm -rf build/package
	mkdir -p build/package/bin
	cp kilo.elf build/package/bin/
	@echo 'name = "kilo"' > build/package/MANIFEST.toml
	@echo 'version = "1.0.0"' >> build/package/MANIFEST.toml
	@echo '[install]' >> build/package/MANIFEST.toml
	@echo 'bin = "/bin"' >> build/package/MANIFEST.toml
	x86_64-boredos-strip --strip-unneeded build/package/bin/*.elf 2>/dev/null || true
	tar -cf build/kilo.tar -C build/package MANIFEST.toml bin
	lz4 -f build/kilo.tar build/kilo.bup
	rm -f build/kilo.tar
	rm -rf build/package

clean:
	rm -rf obj build $(APPS)
