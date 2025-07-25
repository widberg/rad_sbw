# MAME Scripts

Lua scripts for MAME that can be run using `dofile` in the console window when launching MAME with `-console`.

### `dumpaddressspaces.lua`

Prints out all the address spaces from all of the devices and their properties.

### `dumppal.lua`

Saves the currently in use pallets from MAME to the `roms/rad_sbw/data/` directory if it exists. Each palette is saved to a separate file. The pen colors for each palette are stored in order of increasing index. The RGB components of each pen color are saved as 3 8-bit integers, one for each component. This format works with yychr.

### `loadpal.lua`

This script takes a palette tag and path to a palette, then replaces the palette with the one from the file. The palette file should be in the same format as the palettes produced by `dumppal.lua`.
