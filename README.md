# AppoTech OpenRISC language support for Ghidra

This module adds a little-endian storage variant of Ghidra's standard 32-bit
OpenRISC ORBIS language and a separate, hardware-verified JT5295 variant.
`OpenRISC:LE:32:JT5295` models no delay slots, PC+4 call links and the SDK GCC
little-endian ABI. The generic LE variant changes byte order only. Neither
variant defines the chip's unidentified custom opcodes.

## Build and install

Build with the SLEIGH compiler from the Ghidra version you use:

```sh
make GHIDRA_INSTALL_DIR=/path/to/ghidra_12.1.2_PUBLIC build
make GHIDRA_INSTALL_DIR=/path/to/ghidra_12.1.2_PUBLIC install
```

The installer adds `OpenRISC:LE:32:default` and `OpenRISC:LE:32:JT5295` to the
existing OpenRISC processor module and copies their compiled files. Restart Ghidra after
installing so the language provider reloads. The original
`OpenRISC:BE:32:default` remains available for normally big-endian ORBIS32
binaries.

## Importing the camera captures

For SDK ELF files, select `OpenRISC:LE:32:JT5295` and compiler `gcc`.
For raw JT5295 binaries, the JT5295 profile fixes control flow, while its GCC
compiler model is verified for SDK code. Vendor ABI details and custom SPR
semantics still need review. Existing imports and annotations are preserved;
re-import into a separate program when changing the language.
The original 2 MiB SPI image can be imported as raw data. To place
its loaded firmware at the address observed in the RAM capture, set its image
base to `0x01ffde00`: SPI file offset `0x2200` then maps to runtime address
`0x02000000`. The 4 MiB RAM capture already begins at `0x02000000` and can use
that as its image base.

The SPI image mixes code, data, and resources, and the core-specific opcodes
remain unidentified. Review regions before running broad auto-analysis; the
little-endian language only decodes established ORBIS32 instructions.
