-- remembers volume/mute state by writing to a /tmp file
local muted_file = "/tmp/.mpv.local."..
    os.getenv("USER")..
    ".global-mute"
local volume_file = "/tmp/.mpv.local."..
    os.getenv("USER")..
    ".global-volume"

local function write_mute_globally(_, mute)
    if mute then
        io.open(muted_file, "w"):close()
    else
        os.remove(muted_file)
    end
end

local function write_volume_globally(_, vol)
    local f = io.open(volume_file, "w")
    f:write(vol)
    f:close()
end

mp.observe_property("mute", "bool", write_mute_globally)
mp.observe_property("volume", "number", write_volume_globally)

-- load muted
local muted_file_exists = io.open(muted_file, "r") ~= nil
if muted_file_exists then
    mp.set_property_bool("mute", true)
end

-- load volume
local volume_file = io.open(volume_file, "r")
if volume_file ~= nil then
    mp.set_property_number("volume", tonumber(volume_file:read()))
end
