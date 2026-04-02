-- dofile("roms/rad_sbw/mame_scripts/drcov.lua")

local CPU_TAG    = ":maincpu"
local OUT_FILE   = "rad_sbw.drcov"
local MODULE_NAME = "rad_sbw"

-- sanity checks

local cpu = manager.machine.devices[CPU_TAG]
if not cpu then
    print("[drcov] ERROR: device " .. CPU_TAG .. " not found")
    return
end
if not cpu.debug then
    print("[drcov] ERROR: debug interface not available; launch with -debug")
    return
end
if not cpu.debug.add_bb_end_hook then
    print("[drcov] ERROR: add_bb_end_hook not available; patch not applied or wrong MAME build")
    return
end

-- ROM region size -> offset mask
-- Addresses with bit 15 clear fetch from lowbus RAM (not ROM) and must be
-- excluded.  Addresses with bit 15 set index the ROM via m_rgn[addr & mask].

local bios_region  = manager.machine.memory.regions[":bios"]
local rom_size     = bios_region and bios_region.size or 0x400000
local rom_mask     = rom_size - 1   -- works for any power-of-two ROM size
local module_start = 0
local module_end   = rom_mask       -- inclusive, matches ROM file extents

-- BB table: start_offset → size (keep max size seen for same start)

local bb_map = {}   -- [start_offset] = size  (uint32 offset, uint16 size)
local bb_count = 0

-- BB end hook
--
-- Fires when a BB ends: on every non-sequential PC transition and once more
-- for the last in-progress BB when the device is destroyed.  bb_start is the
-- 24-bit program-space address (CODE_BANK<<16 | PC).
--
-- Lowbus filter: if bit 15 of the 24-bit address is clear the fetch came from
-- lowbus RAM (not ROM) and has no meaningful ROM offset — skip it.

local function on_bb_end(bb_start, bb_end)
    -- skip lowbus RAM fetches: low PC *and* CODE_BANK < 0x80
    -- (CODE_BANK >= 0x80 always fetches from ROM even for PC < 0x8000)
    if bb_start < 0x800000 and (bb_start & 0x8000) == 0 then return end

    local offset = bb_start & rom_mask
    local size   = bb_end - bb_start  -- raw difference; bank can't change mid-block

    -- keep the entry; if we've seen this start before, keep max size
    local prev = bb_map[offset]
    if not prev then
        bb_map[offset] = size
        bb_count = bb_count + 1
    elseif size > prev then
        bb_map[offset] = size
    end
end

-- write drcov on stop

local function write_drcov()
    local f, err = io.open(OUT_FILE, "wb")
    if not f then
        print("[drcov] ERROR: cannot open " .. OUT_FILE .. ": " .. tostring(err))
        return
    end

    -- header
    f:write("DRCOV VERSION: 2\n")
    f:write("DRCOV FLAVOR: drcov\n")

    -- Module Table version 5: 64-bit start/end/entry/offset
    f:write("Module Table: version 5, count 1\n")
    f:write("Columns: id, containing_id, start, end, entry, offset, checksum, timestamp, path\n")
    f:write(string.format("  0,  -1, 0x%016x, 0x%016x, 0x%016x, 0x%016x, 0x%08x, 0x%08x, %s\n",
        module_start,
        module_end + 1,   -- end is exclusive in the module table
        module_start,     -- entry point (unknown, use base)
        0,                -- load offset
        0,                -- checksum
        0,                -- timestamp
        MODULE_NAME))

    -- BB table
    f:write(string.format("BB Table: %d bbs\n", bb_count))

    -- Binary records: uint32 start_offset, uint16 size, uint16 module_id
    for offset, size in pairs(bb_map) do
        -- clamp size to uint16 max
        if size > 0xffff then size = 0xffff end
        f:write(string.pack("<I4I2I2", offset, size, 0))
    end

    f:close()
    print(string.format("[drcov] wrote %d basic blocks to %s", bb_count, OUT_FILE))
end

-- Store subscriptions in globals so they survive past the chunk and are never GC'd.
_drcov_bb_end_sub = cpu.debug:add_bb_end_hook(on_bb_end)
_drcov_stop_sub   = emu.add_machine_stop_notifier(write_drcov)

print(string.format("[drcov] hooked %s  module 0x%06x-0x%06x  output -> %s",
    CPU_TAG, module_start, module_end, OUT_FILE))
