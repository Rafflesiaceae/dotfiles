#!/usr/bin/env luajit
-- Claude Code status line:
-- dir | git branch | model | session cost [context] | lines changed
--
-- Reads the status JSON that Claude Code pipes in on stdin.

local cjson = require("cjson.safe")

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
}

-- Colors of the plain (non-threshold) segments.
local DIR_COLOR    = C.CYAN
local BRANCH_COLOR = C.GREEN
local MODEL_COLOR  = C.DIM
local DIFF_COLOR   = C.DIM

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
local NULL = cjson.null

local function get(tbl, path, default)
  local cur = tbl
  for key in path:gmatch("[^%.]+") do
    if type(cur) ~= "table" then return default end
    cur = cur[key]
  end
  if cur == nil or cur == NULL then return default end
  return cur
end

local function capture(cmd)
  local pipe = io.popen(cmd .. " 2>/dev/null")
  if not pipe then return nil end
  local out = pipe:read("*a")
  local ok = pipe:close()
  if not ok or not out then return nil end
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
local data = cjson.decode(io.read("*a") or "")
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

local branch
if dir ~= "" then
  branch = capture(
    "git -C '" .. dir:gsub("'", "'\\''") ..
    "' rev-parse --abbrev-ref HEAD"
  )
end

local parts = { DIR_COLOR .. short_dir .. C.RESET }

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

io.write(table.concat(parts, SEP))
