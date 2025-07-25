-- dofile("roms/rad_sbw/mame_scripts/dumpaddressspaces.lua")

function dump_map_handler_data(mhd)
    print("                    Handler Type: " .. mhd.handlertype)
    print(string.format("                    Bits: %X", mhd.bits))
    local name = mhd.name
    if name ~= nil then
        print("                    Name: " .. name)
    end
    local tag = mhd.tag
    if tag ~= nil then
        print("                    Tag: " .. tag)
    end
end

for _, device in pairs(manager.machine.devices) do
    print("Device: " .. device.tag)

    if device.spaces then
        for space_name, address_space in pairs(device.spaces) do
            print("  Address Space: " .. space_name)
            print("    Name: " .. address_space.name)
            print(string.format("    Shift: %X", address_space.shift))
            print(string.format("    Index: %X", address_space.index))
            print(string.format("    Address Mask: %06X", address_space.address_mask))
            print(string.format("    Data Width: %X", address_space.data_width))
            print("    Endianness: " .. address_space.endianness)
            local map = address_space.map
            if map ~= nil then
                print("    Map:")
                print("        Space Number: " .. map.spacenum)
                print("        Device: " .. map.device.tag)
                print("        Unmap Value: " .. map.unmap_value)
                print(string.format("        Global Mask: %06X", map.global_mask))
                print("        Entries:")
                for i, entry in pairs(map.entries) do
                    print("            Entry: " .. i)
                    print(string.format("                Address Start: %06X", entry.address_start))
                    print(string.format("                Address End: %06X", entry.address_end))
                    print(string.format("                Address Mirror: %06X", entry.address_mirror))
                    print(string.format("                Address Mask: %06X", entry.address_mask))
                    print(string.format("                Mask: %06X", entry.mask))
                    print(string.format("                CSWidth: %06X", entry.cswidth))
                    local read = entry.read
                    if read ~= nil then
                        print("                Read:")
                        dump_map_handler_data(read)
                    end
                    local write = entry.write
                    if write ~= nil then
                        print("                Write:")
                        dump_map_handler_data(write)
                    end
                    local share = entry.share
                    if share ~= nil then
                        print("                Share: " .. share)
                    end
                    local region = entry.region
                    if region ~= nil then
                        print("                Region: " .. entry.region)
                    end
                    print(string.format("                Region Offset: %06X", entry.region_offset))
                end
            end
        end
    else
        print("  No address spaces found for this device.")
    end
    print("")
end
