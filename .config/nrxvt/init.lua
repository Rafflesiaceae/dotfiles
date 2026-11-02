local opt = nrxvt.opt
opt.font = "xft:Consolas:size=11,xft:Fixed:size=11,xft:Nimbus Sans:size 11,xft:Symbola:size 11;xft:Meiryo:size 11"

-- Keep 50,000 lines of scrollback and disable X input methods.
opt.saveLines = 50000
opt.skipXIM = true

-- The Print key writes the terminal contents to a fresh file.
opt["print-pipe"] = [[cat > $(mktemp $HOME/urxvt.XXXXXX)]]

-- Copy and paste CLIPBOARD through native Lua callbacks.
local api = nrxvt.api
api.bind("Control-Shift-C", function(t)
	local text = api.selection(t)
	if text and #text > 0 then
		api.set_selection(t, text, true)
	end
end)
api.bind("Control-Shift-V", function(t)
	api.selection_request(t, true)
end)

-- Send the visible viewport to the same editor helper as the Perl extension.
api.bind("Control-Shift-L", function(t)
	local lines = {}
	for row = api.view_start(t), api.view_start(t) + api.nrow(t) - 1 do
		local text = api.line(t, row)
		lines[#lines + 1] = text:gsub("%s+$", "")
	end

	-- Pass terminal text as an argument so the shell cannot interpret it as code.
	api.spawn({
		"/bin/sh",
		"-c",
		'exec edit-from-base64-arg "$(printf %s "$1" | base64)"',
		"nrxvt-buffer",
		table.concat(lines, "\n"),
	})
end)

-- title hacks
nrxvt.api.on_title_change(function(t, title)
    local state, rest

    -- claude
    if title:sub(1, #"✳") == "✳" then
        rest = title:sub(#"✳" + 1)
        return "🔷" .. rest
    elseif title:match("^[◐◓◑◒]") then
        rest = title:sub(#"◐" + 1)
        return "🔶" .. rest
    else
        return title
    end
end)

-- Base16 Kokonai colors, including the extended palette entries.
opt.foreground = "#f8f8f2"
opt.background = "#272822"
opt.cursorColor = "#f8f8f2"
opt.color0 = "#272822"
opt.color1 = "#f92826"
opt.color2 = "#a6e22e"
opt.color3 = "#f0b600"
opt.color4 = "#2790d9"
opt.color5 = "#ae81ff"
opt.color6 = "#a1efe4"
opt.color7 = "#f8f8f2"
opt.color8 = "#75715e"
opt.color9 = "#f92826"
opt.color10 = "#a6e22e"
opt.color11 = "#f0b600"
opt.color12 = "#2790d9"
opt.color13 = "#ae81ff"
opt.color14 = "#a1efe4"
opt.color15 = "#f9f8f5"
opt.color16 = "#fd971f"
opt.color17 = "#cc6633"
opt.color18 = "#383830"
opt.color19 = "#49483e"
opt.color20 = "#a59f85"
opt.color21 = "#f5f4f1"
