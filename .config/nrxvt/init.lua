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

-- Win+Shift+D types "hello world" as if typed (no Enter). The keysym is
-- the shifted "D". Note: i3 currently grabs Mod4+Shift+d itself, so this
-- only fires once that i3 binding is removed or changed.
api.bind("Mod4-Shift-D", function(t)
	api.write(t, "hello world")
end)

-- Claude Code idle marker: while Claude Code in a terminal is idle and
-- waiting for a prompt, an urgent "CLAUDE" item is shown in the i3bar via
-- i3sd's directory_blocks module, one item per terminal. marker-watch
-- creates the file and deletes it once its stdin reaches EOF. The terminal
-- holds the write end of that pipe, so the item also disappears when the
-- terminal closes or crashes.
local ffi = require("ffi")
ffi.cdef [[
typedef struct {
	int allocated;
	int used;
	void *actions;
	int pad[16];
} claude_marker_file_actions_t; /* glibc's posix_spawn_file_actions_t */
int pipe2(int fds[2], int flags);
int close(int fd);
int posix_spawn_file_actions_init(claude_marker_file_actions_t *fa);
int posix_spawn_file_actions_destroy(claude_marker_file_actions_t *fa);
int posix_spawn_file_actions_adddup2(claude_marker_file_actions_t *fa, int fd, int newfd);
int posix_spawn_file_actions_addclosefrom_np(claude_marker_file_actions_t *fa, int from);
int posix_spawnp(int *pid, const char *file, const claude_marker_file_actions_t *fa,
	const void *attr, char *const argv[], char *const envp[]);
extern char **environ;
]]

local O_CLOEXEC = 0x80000 -- Linux
local runtime_dir = os.getenv("XDG_RUNTIME_DIR")
local CLAUDE_MARKER = {
	-- i3sd's default directory_blocks directory.
	dir = runtime_dir and runtime_dir ~= "" and runtime_dir .. "/i3sd-blocks",
	-- Full text, short text, options; marker-watch unescapes the "\n".
	-- i3sd has no "alert" option, "urgent" is i3bar's alert highlight.
	contents = [[CLAUDE\nCLAUDE\nurgent=true\n]],
}

-- Starts marker-watch for terminal t unless it is already running. Its
-- stdin is a pipe whose write end only this process holds: the pipe is
-- close-on-exec and the child closes every other descriptor (the pty
-- master and the X connection are not close-on-exec), so neither it nor
-- programs started later keep the marker alive. libev reaps the child.
local function claude_marker_show(t)
	if t.claude_marker_fd or not CLAUDE_MARKER.dir then return end
	local win = nrxvt.api.window(t)
	if not win then return end

	local fds = ffi.new("int[2]")
	if ffi.C.pipe2(fds, O_CLOEXEC) ~= 0 then return end

	local fa = ffi.new("claude_marker_file_actions_t")
	ffi.C.posix_spawn_file_actions_init(fa)
	ffi.C.posix_spawn_file_actions_adddup2(fa, fds[0], 0)
	ffi.C.posix_spawn_file_actions_addclosefrom_np(fa, 3)

	-- The Lua strings stay referenced until posix_spawnp has copied them.
	local args = {
		"marker-watch",
		("%s/claude-nrxvt-%x"):format(CLAUDE_MARKER.dir, win),
		CLAUDE_MARKER.contents,
	}
	local argv = ffi.new("char *[?]", #args + 1)
	for i, arg in ipairs(args) do
		argv[i - 1] = ffi.cast("char *", arg)
	end

	local pid = ffi.new("int[1]")
	local err = ffi.C.posix_spawnp(pid, args[1], fa, nil, argv, ffi.C.environ)
	ffi.C.posix_spawn_file_actions_destroy(fa)
	ffi.C.close(fds[0])

	if err ~= 0 then
		ffi.C.close(fds[1])
		return
	end
	t.claude_marker_fd = fds[1]
end

-- Closing the write end makes marker-watch delete the file and exit.
local function claude_marker_hide(t)
	if not t.claude_marker_fd then return end
	ffi.C.close(t.claude_marker_fd)
	t.claude_marker_fd = nil
end

nrxvt.api.on_destroy(claude_marker_hide)

-- title hacks
nrxvt.api.on_title_change(function(t, title)
    local state, rest

    -- claude: "✳" while idle, a spinner while working. Any other title
    -- (e.g. the shell's once Claude Code exits) hides the marker, too.
    if title:sub(1, #"✳") == "✳" then
        claude_marker_show(t)
        rest = title:sub(#"✳" + 1)
        return "🔷" .. rest
    elseif title:match("^[◐◓◑◒]") then
        claude_marker_hide(t)
        rest = title:sub(#"◐" + 1)
        return "🔶" .. rest
    else
        claude_marker_hide(t)
        return title
    end
end)

-- Base16 Kokonai colors, including the extended palette entries.
opt.foreground = "#f8f8f2"
opt.background = "#272822"
opt.cursorColor = "#f8f8f2"
opt.color0 = "#272822"
opt.color1 = "#ff4535"
opt.color2 = "#a6e22e"
opt.color3 = "#fdd102"
opt.color4 = "#33b9f3"
opt.color5 = "#ae81ff"
opt.color6 = "#73e6e6"
opt.color7 = "#f8f8f2"
opt.color8 = "#99947b"
opt.color9 = "#ff4535"
opt.color10 = "#a6e22e"
opt.color11 = "#fdd102"
opt.color12 = "#33b9f3"
opt.color13 = "#ae81ff"
opt.color14 = "#73e6e6"
opt.color15 = "#f9f8f5"
opt.color16 = "#fd971f"
opt.color17 = "#f355a1"
opt.color18 = "#383830"
opt.color19 = "#49483e"
opt.color20 = "#a59f85"
opt.color21 = "#f5f4f1"
