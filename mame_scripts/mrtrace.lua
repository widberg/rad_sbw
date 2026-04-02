-- dofile("roms/rad_sbw/mame_scripts/mrtrace.lua")

local CPU_TAG    = ":maincpu"
local OUT_FILE   = "rad_sbw.mrtrace"
local FLUSH_EACH = 512   -- flush every N entries

-- sanity checks

local cpu = manager.machine.devices[CPU_TAG]
if not cpu then
    print("[mrtrace] ERROR: device " .. CPU_TAG .. " not found")
    return
end
if not cpu.debug then
    print("[mrtrace] ERROR: debug interface not available; launch with -debug")
    return
end
if not cpu.debug.add_bb_start_hook then
    print("[mrtrace] ERROR: add_bb_start_hook not available; patch not applied or wrong MAME build")
    return
end
if not cpu.debug.disassemble then
    print("[mrtrace] ERROR: disassemble not available; patch not applied or wrong MAME build")
    return
end

-- ROM region size for offset masking (same logic as drcov.lua)

local bios_region = manager.machine.memory.regions[":bios"]
local rom_mask    = (bios_region and bios_region.size or 0x400000) - 1

-- open output file

local f, err = io.open(OUT_FILE, "w")
if not f then
    print("[mrtrace] ERROR: cannot open " .. OUT_FILE .. ": " .. tostring(err))
    return
end

-- buffered writer

local buf = {}

local function flush()
    if #buf == 0 then return end
    f:write(table.concat(buf, "\n") .. "\n")
    f:flush()
    buf = {}
end

-- BB start hook
--
-- Fires at the very beginning of each basic block with bb_start = first
-- instruction address.  Register state at call time is the entry state of
-- this block, so the disassembly and register snapshot are consistent.

local function on_bb_start(bb_start)
    -- disassemble the first instruction of the block
    local dasm = cpu.debug:disassemble(bb_start) or "???"

    -- snapshot register values in sorted order
    local regs = {}
    for symbol, state_entry in pairs(cpu.state) do
        if state_entry then
            table.insert(regs, string.format("%s=%X", symbol, state_entry.value))
        end
    end

    local bank = (bb_start >> 16) & 0xff
    local pc   = bb_start & 0xffff
    local loc
    if bb_start < 0x800000 and (bb_start & 0x8000) == 0 then
        loc = string.format("RAM  %02X:%04X        ", bank, pc)
    else
        loc = string.format("ROM  %02X:%04X  @%06X", bank, pc, bb_start & rom_mask)
    end

    table.insert(buf, string.format("[%s] %-16s  %s",
        loc, dasm, table.concat(regs, " ")))

    if #buf >= FLUSH_EACH then
        flush()
    end
end

-- flush and close on machine stop

local function on_stop()
    flush()
    f:close()
    print("[mrtrace] trace written to " .. OUT_FILE)
end

-- Store subscriptions in globals so they survive past the chunk and are never GC'd.
_mrtrace_bb_start_sub = cpu.debug:add_bb_start_hook(on_bb_start)
_mrtrace_stop_sub     = emu.add_machine_stop_notifier(on_stop)

print(string.format("[mrtrace] hooked %s  output -> %s", CPU_TAG, OUT_FILE))
