#!/usr/bin/env lust
-- Claude Code status line:
-- dir | claude account | git branch | model | session cost [context] |
-- lines changed | session title
--
-- Reads the status JSON that Claude Code pipes in on stdin.

-- lust built-ins: JSON parser and process runner (no shell involved).
local json = require("lust.json")
local proc = require("lust.sys.proc")

-- ---------------------------------------------------------------- config --

local C = {
  RESET  = "\27[0m",
  DIM    = "\27[2m",
  WHITE  = "\27[37m",
  CYAN   = "\27[36m",
  GREEN  = "\27[32m",
  YELLOW = "\27[33m",
  ORANGE = "\27[38;5;208m",
  RED    = "\27[31m",
  MAGENTA = "\27[35m",
}

-- Colors of the plain (non-threshold) segments.
local DIR_COLOR    = C.CYAN
local USER_COLOR   = C.MAGENTA  -- claude account
local BRANCH_COLOR = C.GREEN
local MODEL_COLOR  = C.DIM
local DIFF_COLOR   = C.DIM
local TITLE_COLOR  = C.WHITE

local SEP = " " .. C.DIM .. "|" .. C.RESET .. " "

-- Session cost in USD: white until the first threshold is crossed.
local COST_FORMAT = "%.2f"
local COST_LEVELS = {
  { at = 20, color = C.RED    },
  { at = 10, color = C.ORANGE },
  { at =  3, color = C.YELLOW },
  { at =  0, color = C.WHITE  },
}

-- Current context size in tokens. Absolute size is what drives input cost,
-- so it rides along with the session cost: $0.00 [35k]
local CTX_LEVELS = {
  { at = 400000, color = C.RED,    marker = " ⚠⚠" },
  { at = 200000, color = C.ORANGE, marker = " ⚠"  },
  { at = 100000, color = C.YELLOW, marker = " ↑"  },
  { at =      0, color = C.WHITE,  marker = ""    },
}

-- --------------------------------------------------------------- helpers --
local NULL = json.null

local function get(tbl, path, default)
  local cur = tbl
  for key in path:gmatch("[^%.]+") do
    if type(cur) ~= "table" then return default end
    cur = cur[key]
  end
  if cur == nil or cur == NULL then return default end
  return cur
end

-- Runs argv (no shell, so no quoting needed) and returns its trimmed
-- stdout, or nil if it failed or printed nothing.
local function capture(argv)
  local status, out = proc.run(argv, { stderr = "null" })
  if status ~= 0 or not out then return nil end
  out = out:gsub("%s+$", "")
  if out == "" then return nil end
  return out
end

local function fmt_tokens(n)
  n = tonumber(n) or 0

  if n >= 1000000 then
    return string.format("%.1fM", n / 1000000)
  elseif n >= 1000 then
    return string.format("%.0fk", n / 1000)
  end

  return tostring(math.floor(n))
end

-- Highest matching level, descending by `at`.
local function level_for(value, levels)
  for _, level in ipairs(levels) do
    if value >= level.at then return level end
  end
  return levels[#levels]
end

-- ------------------------------------------------------------------ main --
local data = json.decode(io.read("*a") or "")
if type(data) ~= "table" then data = {} end

local dir = get(data, "workspace.current_dir", get(data, "cwd", ""))
local model = get(data, "model.display_name", "")
local cost = tonumber(get(data, "cost.total_cost_usd", 0)) or 0
local added = math.floor(tonumber(get(data, "cost.total_lines_added", 0)) or 0)
local removed = math.floor(tonumber(get(data, "cost.total_lines_removed", 0)) or 0)

local ctx_tokens =
  tonumber(get(data, "context_window.total_input_tokens", 0)) or 0

local home = os.getenv("HOME")
local short_dir = dir
if home and home ~= "" and dir:sub(1, #home) == home then
  short_dir = "~" .. dir:sub(#home + 1)
end

-- Claude account Claude Code is logged into. The status JSON doesn't carry
-- it, but Claude Code keeps it in .claude.json (in $CLAUDE_CONFIG_DIR if
-- set, else $HOME) under oauthAccount. Prefer the display name, fall back
-- to the email address; nil when logged out or using an API key.
local function claude_account()
  local cfg_dir = os.getenv("CLAUDE_CONFIG_DIR")
  if not cfg_dir or cfg_dir == "" then cfg_dir = home end
  if not cfg_dir or cfg_dir == "" then return nil end

  local f = io.open(cfg_dir .. "/.claude.json", "r")
  if not f then return nil end
  local cfg = json.decode(f:read("*a") or "")
  f:close()
  if type(cfg) ~= "table" then return nil end

  local name = get(cfg, "oauthAccount.displayName", "")
  if name == "" then name = get(cfg, "oauthAccount.emailAddress", "") end
  if name == "" then return nil end
  return name
end

local user = claude_account()

-- Session title. The status JSON doesn't carry it, but the transcript has
-- one JSON line per title change: "custom-title" (set via /rename) and
-- "ai-title" (generated). The latest custom title wins over the latest
-- generated one. Lines are prefiltered by plain substring search so only
-- the few title lines get decoded; scanning a 14MB transcript takes ~12ms.
local function session_title(path)
  if path == "" then return nil end
  local f = io.open(path, "r")
  if not f then return nil end

  local custom, ai
  for line in f:lines() do
    if line:find('"type":"custom-title"', 1, true) then
      local entry = json.decode(line)
      local t = type(entry) == "table" and get(entry, "customTitle", "") or ""
      if t ~= "" then custom = t end
    elseif line:find('"type":"ai-title"', 1, true) then
      local entry = json.decode(line)
      local t = type(entry) == "table" and get(entry, "aiTitle", "") or ""
      if t ~= "" then ai = t end
    end
  end
  f:close()

  local title = custom or ai
  if not title then return nil end
  -- Control characters (newlines, escapes) would break the one-line bar.
  title = title:gsub("%c", " ")
  return title
end

local title = session_title(get(data, "transcript_path", ""))

local branch
if dir ~= "" then
  branch = capture({ "git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" })
end

local parts = { DIR_COLOR .. short_dir .. C.RESET }

if user then
  parts[#parts + 1] = USER_COLOR .. user .. C.RESET
end

if branch then
  parts[#parts + 1] = BRANCH_COLOR .. branch .. C.RESET
end

if model ~= "" then
  parts[#parts + 1] = MODEL_COLOR .. model .. C.RESET
end

local cost_level = level_for(cost, COST_LEVELS)
local cost_text =
  cost_level.color .. "$" .. string.format(COST_FORMAT, cost) .. C.RESET

local ctx_level = level_for(ctx_tokens, CTX_LEVELS)
local ctx_text = ctx_level.color ..
  "[" .. fmt_tokens(ctx_tokens) .. ctx_level.marker .. "]" .. C.RESET

parts[#parts + 1] = cost_text .. " " .. ctx_text

if added ~= 0 or removed ~= 0 then
  parts[#parts + 1] = DIFF_COLOR ..
    "+" .. added .. "/-" .. removed ..
    C.RESET
end

if title then
  parts[#parts + 1] = TITLE_COLOR .. title .. C.RESET
end

io.write(table.concat(parts, SEP))
