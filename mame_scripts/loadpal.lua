-- dofile("roms/rad_sbw/mame_scripts/loadpal.lua")(":palette", "path/to/palette.pal")
-- dofile("roms/rad_sbw/mame_scripts/loadpal.lua") loadpal(":palette", "path/to/palette.pal")

function loadpal(tag, path)
    local palette = manager.machine.palettes[tag]
    local file = io.open(path, "rb")
    for i=0, palette.entries-1 do
        local rgb = file:read(3)
        local r, g, b = rgb:byte(1, 3)
        palette:set_pen_color(i, r, g, b)
    end
    file:close()
end

return loadpal
