# Kilo text editor

This repository contains the lightweight Kilo text editor by Salvatore Sanfilippo ported to BoredOS.

## Decoupled Building

This repository is designed to compile **either within the main BoredOS tree OR completely standalone**.

### 1. Integrated Build (Within BoredOS)
If built from the BoredOS root tree, the build system passes `BOREDOS_SDK` to the Makefile. It immediately compiles the editor against the shared pre-built SDK:
```bash
make BOREDOS_SDK=/path/to/shared/sdk
```

### 2. Standalone Build (Isolated Clone)
If cloned completely separately in isolation, running `make` will **automatically bootstrap the SDK**:
```bash
make
```
If `build/sdk` is missing, the Makefile automatically clones the pure standard library dependency from `https://github.com/boredos/libc.git`, compiles it, installs it to `build/sdk`, and builds `kilo.elf` standalone!

## Staging Installation
To stage the text editor binary into your target initrd root filesystem directory:
```bash
make DESTDIR=/path/to/initrd/root install
```
- Binary is routed to `/bin/kilo.elf`
