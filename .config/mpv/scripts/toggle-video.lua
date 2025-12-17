-- toggle-video.lua
local mp = require("mp")

local video_disabled = false

-- Create a persistent OSD overlay
local status_overlay = mp.create_osd_overlay("ass-events")
status_overlay.z = -1000  -- draw above most things (subtitles etc.)

local function update_status_overlay()
    if video_disabled then
        -- ASS formatting:
        -- \an7 = top-left, \fs20 = font size, \bord/\shad = border & shadow
        status_overlay.data = [[{\an5\fs50\bord1\shad1}Video disabled - press F4 to re-enable]]
        status_overlay.hidden = false
    else
        status_overlay.hidden = true
    end
    status_overlay:update()
end

function toggle_video_decode()
    if not video_disabled then
        mp.set_property("vid", "no") -- Disable video decoding
        video_disabled = true
    else
        mp.set_property("vid", "auto") -- Re-enable video decoding

        -- Force refresh by seeking to current timestamp
        local pos = mp.get_property_number("time-pos", 0)
        mp.commandv("seek", tostring(pos), "absolute", "exact")

        video_disabled = false
    end

    -- Update the persistent overlay whenever we toggle
    update_status_overlay()
end

-- Keep overlay in sync when a new file is loaded
mp.register_event("file-loaded", function()
    video_disabled = (mp.get_property("vid") == "no")
    update_status_overlay()
end)

-- Make it bindable from input.conf
mp.add_key_binding(nil, "toggle-video-decode", toggle_video_decode)
