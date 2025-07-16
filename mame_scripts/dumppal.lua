-- dofile("roms/rad_sbw/mame_scripts/dumppal.lua")

local datetime = os.date("%Y-%m-%d_%H-%M-%S")

for tag, palette in pairs(manager.machine.palettes) do
    local filename = "pallete_" .. datetime .. "_" .. tag ..".pal"
    filename = filename:gsub('[\\/:*?"<>|]', '_')
    path = "roms/rad_sbw/data/" .. filename
    local file = io.open(path, "wb")
    for i=0, palette.entries-1 do
        local rgb = palette:pen_color(i)
        local r = (rgb >> 16) & 0xFF
        local g = (rgb >>  8) & 0xFF
        local b = (rgb >>  0) & 0xFF
        file:write(string.char(r, g, b))
    end
    file:close()
end
