# Patches

These are patches for other projects that help them work with rad_sbw or provide quality of life improvements.

### `mame.patch`

This patch removes the integrity checks for roms from mame. MAME won't validate checksums, file sizes, or known hashes. This makes it easier to load non-matching roms. MAME can be built with a command similar to `make SOURCES=tvgames/xavix.cpp SYMBOLS=1 TOOLS=0 REGENIE=1 NOWERROR=1 MODERN_WIN_API=1 -j8 vs2022`, adjust as needed for your platform. There is more information about compiling MAME on the [Compiling MAME page](https://docs.mamedev.org/initialsetup/compilingmame.html).
