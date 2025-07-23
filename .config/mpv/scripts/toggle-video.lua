-- toggle-video.lua
local mp = require("mp")

local video_disabled = false

function toggle_video_decode()
	if not video_disabled then
		mp.set_property("vid", "no") -- Disable video decoding
		video_disabled = true
		mp.osd_message("Video decoding: OFF")
	else
		mp.set_property("vid", "auto") -- Re-enable video decoding
		-- Force refresh by seeking to current timestamp
		local pos = mp.get_property_number("time-pos", 0)
		mp.commandv("seek", tostring(pos), "absolute", "exact")
		video_disabled = false
		mp.osd_message("Video decoding: ON")
	end
end

mp.add_key_binding("F4", "toggle-video-decode", toggle_video_decode)
