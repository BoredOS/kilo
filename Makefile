# Copyright (c) 2026 Christiaan (chris@boreddev.nl)
# Kilo Editor Standalone Makefile

CC = x86_64-boredos-gcc

DESTDIR ?= $(abspath build/dist)

CFLAGS  = -Wall -Wextra -std=gnu11 -O2 -fno-stack-protector \
          -fno-stack-check -m64 -march=x86-64

LDFLAGS = -Wl,-z,max-page-size=0x1000 -Wl,-dynamic-linker,/usr/lib/ld.so -Wl,-rpath,/usr/lib:/lib

APPS    = kilo.elf

all: $(APPS)

kilo.elf: obj/kilo.o
	$(CC) $< $(LDFLAGS) -o $@

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
