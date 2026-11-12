#!/usr/bin/env lust
-- Claude Code status line:
-- dir | claude account | git branch | model | session cost [context] |
-- new session hint | lines changed | session title
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

-- "Start a new session?" hint. Thresholds come from an analysis of past
-- transcripts: correction/pushback rates and throughput did not degrade with
-- raw context size up to ~150k, but did with repeated compaction (stale
-- topics surviving in the summary) and with many interactive prompts since
-- the last fresh start. Above ~200k throughput dropped and every step costs
-- ~5x what it does at a fresh ~40k start; a compacted session restarts at
-- ~51k anyway. Topic switches are the strongest reason to start fresh, but
-- can't be detected here - that one stays a judgment call.
local HINT = {
  CTX_SOFT        = 150000, -- compact or wrap up soon
  CTX_HARD        = 200000, -- past the throughput drop, near auto-compact
  MAX_COMPACTIONS = 2,      -- prefer a fresh session over another compact
  MAX_PROMPTS     = 8,      -- interactive prompts since start/last compact
  IDLE_SECS       = 3600,   -- prompt cache TTL; after this it's cold
  IDLE_CTX        = 150000, -- only worth flagging for a big cold context
  ICON            = "↻ new session?",
}

-- Prompts that just keep an autonomous loop running. They don't add new
-- topics, so they are not counted towards MAX_PROMPTS.
local CONTINUATION_PROMPTS = {
  ["continue"] = true, ["go on"] = true, ["keep going"] = true,
  ["carry on"] = true, ["finish up what you were doing"] = true,
}

-- Prompt sources that represent a human turn (excludes e.g. "system").
local HUMAN_PROMPT_SOURCES = {
  typed = true, queued = true, suggestion_accepted = true,
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

-- Text of a user prompt entry: content is either a string or a list of
-- blocks of which only the text blocks matter.
local function prompt_text(entry)
  local content = get(entry, "message.content", "")
  if type(content) == "string" then return content end
  if type(content) ~= "table" then return "" end

  local texts = {}
  for _, block in ipairs(content) do
    if type(block) == "table" and block.type == "text"
      and type(block.text) == "string" then
      texts[#texts + 1] = block.text
    end
  end
  return table.concat(texts, " ")
end

-- Seconds since the epoch for a UTC ISO-8601 timestamp such as
-- "2026-11-11T11:26:33.200Z", or nil. os.time() reads a date table as
-- local time, so the local UTC offset is added back; both conversions use
-- isdst = false so DST can't skew the offset.
local function iso_utc_to_epoch(s)
  local y, mo, d, h, mi, se =
    s:match("^(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
  if not y then return nil end

  local now = os.time()
  local utc_now = os.date("!*t", now)
  utc_now.isdst = false
  local offset = now - os.time(utc_now)

  return os.time({
    year = tonumber(y), month = tonumber(mo), day = tonumber(d),
    hour = tonumber(h), min = tonumber(mi), sec = tonumber(se),
    isdst = false,
  }) + offset
end

-- Single pass over the transcript collecting:
--   title       - session title. The status JSON doesn't carry it, but the
--                 transcript has one JSON line per title change:
--                 "custom-title" (set via /rename) and "ai-title"
--                 (generated). The latest custom title wins over the
--                 latest generated one.
--   compactions - number of compact_boundary entries (manual and auto).
--   prompts     - human, non-continuation prompts since the start or the
--                 last compaction.
--   last_ts     - epoch of the newest timestamped entry, for idle time.
-- Lines are prefiltered by plain substring search so only the few
-- interesting lines get decoded; scanning a 14MB transcript takes ~12ms.
local function transcript_stats(path)
  local stats = { compactions = 0, prompts = 0 }
  if path == "" then return stats end
  local f = io.open(path, "r")
  if not f then return stats end

  local custom, ai, last_ts_line
  for line in f:lines() do
    -- Keep a reference to the newest line carrying a timestamp; it is only
    -- parsed once after the loop.
    if line:find('"timestamp":"', 1, true) then last_ts_line = line end

    if line:find('"subtype":"compact_boundary"', 1, true) then
      stats.compactions = stats.compactions + 1
      stats.prompts = 0
    elseif line:find('"promptSource":"', 1, true) then
      local entry = json.decode(line)
      if type(entry) == "table" and entry.type == "user"
        and entry.isSidechain ~= true
        and HUMAN_PROMPT_SOURCES[get(entry, "promptSource", "")] then
        -- Normalize "Continue." / " continue " to the lookup key.
        local text = prompt_text(entry):lower()
          :gsub("^%s+", ""):gsub("[%s%p]+$", "")
        if not CONTINUATION_PROMPTS[text] then
          stats.prompts = stats.prompts + 1
        end
      end
    elseif line:find('"type":"custom-title"', 1, true) then
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

  if last_ts_line then
    local ts = last_ts_line:match('"timestamp":"([^"]+)"')
    stats.last_ts = ts and iso_utc_to_epoch(ts)
  end

  local title = custom or ai
  if title then
    -- Control characters (newlines, escapes) would break the one-line bar.
    stats.title = title:gsub("%c", " ")
  end
  return stats
end

local stats = transcript_stats(get(data, "transcript_path", ""))
local title = stats.title

-- Reasons to start a fresh session, plus whether any of them is severe.
-- Returns nil when there is nothing to hint at.
local function new_session_hint()
  local reasons, severe = {}, false

  -- if ctx_tokens >= HINT.CTX_HARD then
  --   reasons[#reasons + 1] = "ctx≥" .. fmt_tokens(HINT.CTX_HARD)
  --   severe = true
  -- elseif ctx_tokens >= HINT.CTX_SOFT then
  --   reasons[#reasons + 1] = "ctx≥" .. fmt_tokens(HINT.CTX_SOFT)
  -- end

  if stats.compactions >= HINT.MAX_COMPACTIONS then
    reasons[#reasons + 1] = stats.compactions .. "× compacted"
  end

  if stats.prompts >= HINT.MAX_PROMPTS then
    reasons[#reasons + 1] = stats.prompts .. " prompts"
  end

  -- A big context whose prompt cache has expired gets re-written in full
  -- on the next prompt, so a fresh session is the cheaper restart. Needs
  -- statusLine.refreshInterval to show up while actually idle.
  if stats.last_ts and ctx_tokens >= HINT.IDLE_CTX
    and os.time() - stats.last_ts >= HINT.IDLE_SECS then
    reasons[#reasons + 1] = "idle≥" .. math.floor(HINT.IDLE_SECS / 60) ..
      "m, cache cold"
  end

  if #reasons == 0 then return nil end
  -- Multiple independent reasons are as strong a signal as a severe one.
  local color = (severe or #reasons >= 2) and C.RED or C.YELLOW
  return color .. HINT.ICON .. " " .. table.concat(reasons, ", ") .. C.RESET
end

local hint = new_session_hint()

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

if hint then
  parts[#parts + 1] = hint
end

if added ~= 0 or removed ~= 0 then
  parts[#parts + 1] = DIFF_COLOR ..
    "+" .. added .. "/-" .. removed ..
    C.RESET
end

if title then
  parts[#parts + 1] = TITLE_COLOR .. title .. C.RESET
end

io.write(table.concat(parts, SEP))
