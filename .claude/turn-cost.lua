#!/usr/bin/env luajit
-- Claude Code Stop hook: report the USD cost of the turn that just finished.
--
-- Reads the Stop hook JSON on stdin, walks the session transcript back to the
-- prompt that started this turn, and prices every assistant response since then.
--
-- Pricing and the cost formula are lifted from Claude Code's own baked-in model
-- catalog (see TIERS/TIER_OF below), so the numbers line up with /cost and the
-- status line rather than being an independent guess.

local cjson = require("cjson.safe") -- .safe returns nil, err instead of raising

-- cjson maps JSON null to a sentinel userdata, not nil; treat it as missing.
local NULL = cjson.null

-- --- pricing, USD per million tokens -------------------------------------
-- Extracted from the Claude Code binary's hand-maintained model catalog
-- (pricing_tiers). Keys: input, output, cache write 5m, cache write 1h,
-- cache read, USD per web-search request.
local TIERS = {
  tier_2_10  = { inp = 2,   out = 10, cw5m = 2.5,   cw1h = 4,   cr = 0.2,  ws = 0.01 },
  tier_3_15  = { inp = 3,   out = 15, cw5m = 3.75,  cw1h = 6,   cr = 0.3,  ws = 0.01 },
  tier_5_25  = { inp = 5,   out = 25, cw5m = 6.25,  cw1h = 10,  cr = 0.5,  ws = 0.01 },
  tier_10_50 = { inp = 10,  out = 50, cw5m = 12.5,  cw1h = 20,  cr = 1,    ws = 0.01 },
  tier_15_75 = { inp = 15,  out = 75, cw5m = 18.75, cw1h = 30,  cr = 1.5,  ws = 0.01 },
  haiku_35   = { inp = 0.8, out = 4,  cw5m = 1,     cw1h = 1.6, cr = 0.08, ws = 0.01 },
  haiku_45   = { inp = 1,   out = 5,  cw5m = 1.25,  cw1h = 2,   cr = 0.1,  ws = 0.01 },
}

local TIER_OF = {
  ["claude-3-5-haiku"]  = "haiku_35",
  ["claude-haiku-4-5"]  = "haiku_45",
  ["claude-3-5-sonnet"] = "tier_3_15",
  ["claude-3-7-sonnet"] = "tier_3_15",
  ["claude-sonnet-4-0"] = "tier_3_15",
  ["claude-sonnet-4-5"] = "tier_3_15",
  ["claude-sonnet-4-6"] = "tier_3_15",
  ["claude-sonnet-5"]   = "tier_2_10",
  ["claude-opus-4-0"]   = "tier_15_75",
  ["claude-opus-4-1"]   = "tier_15_75",
  ["claude-opus-4-5"]   = "tier_5_25",
  ["claude-opus-4-6"]   = "tier_5_25",
  ["claude-opus-4-7"]   = "tier_5_25",
  ["claude-opus-4-8"]   = "tier_5_25",
  ["claude-opus-5"]     = "tier_5_25",
  ["claude-fable-5"]    = "tier_10_50",
  ["claude-mythos-5"]   = "tier_10_50",
}

-- Fast mode is billed at double the standard tier.
local FAST_MULTIPLIER = 2
-- Claude Code applies a 10% surcharge for US data residency.
local US_GEO_MULTIPLIER = 1.1

-- Ordered: first family substring that matches wins.
local FAMILY_FALLBACK = {
  { "haiku",  "haiku_45" },
  { "sonnet", "tier_2_10" },
  { "opus",   "tier_5_25" },
  { "fable",  "tier_10_50" },
  { "mythos", "tier_10_50" },
}

-- --------------------------------------------------------------- helpers --
local function sub(s, pattern, repl)
  return (s:gsub(pattern, repl))
end

-- Field lookup that also folds cjson's null sentinel into the default.
local function get(tbl, key, default)
  if type(tbl) ~= "table" then return default end
  local v = tbl[key]
  if v == nil or v == NULL then return default end
  return v
end

local function num(tbl, key)
  return tonumber(get(tbl, key, 0)) or 0
end

--- Reduce a provider-specific / dated model id to a catalog key.
local function canonical(model)
  local m = sub(sub(model, "^%s+", ""), "%s+$", "")
  m = sub(m, "%[[12][mM]%]$", "")            -- opus[1m] context suffix
  m = sub(m, "^us%.", "")                    -- bedrock region prefix
  m = sub(m, "^eu%.", "")
  m = sub(m, "^apac%.", "")
  m = sub(m, "^anthropic%.", "")
  m = sub(m, "%-v%d+:%d+$", "")              -- bedrock version suffix
  m = sub(m, "[@%-]%d%d%d%d%d%d%d%d$", "")   -- dated release suffix
  return m
end

local function tier_for(model, speed)
  local key = canonical(model)
  local tier = TIER_OF[key]
  if tier == nil then
    for _, entry in ipairs(FAMILY_FALLBACK) do
      if key:find(entry[1], 1, true) then
        tier = entry[2]
        break
      end
    end
  end
  if tier == nil then return nil end

  local costs = {}
  for k, v in pairs(TIERS[tier]) do costs[k] = v end
  if speed == "fast" then
    for _, k in ipairs({ "inp", "out", "cw5m", "cw1h", "cr" }) do
      costs[k] = costs[k] * FAST_MULTIPLIER
    end
  end
  return costs
end

--- Mirror of Claude Code's per-message cost calculation.
local function price(usage, model)
  local costs = tier_for(model, get(usage, "speed"))
  if costs == nil then return nil end

  local inp = num(usage, "input_tokens")
  local out = num(usage, "output_tokens")
  local cr = num(usage, "cache_read_input_tokens")
  local cw = num(usage, "cache_creation_input_tokens")

  -- Cache writes split between the 1h and 5m TTLs, each priced differently.
  local cw1h = math.min(num(get(usage, "cache_creation"), "ephemeral_1h_input_tokens"), cw)
  local cache_write = (cw1h / 1e6) * costs.cw1h + ((cw - cw1h) / 1e6) * costs.cw5m

  local total = (inp / 1e6) * costs.inp
    + (out / 1e6) * costs.out
    + (cr / 1e6) * costs.cr
    + cache_write
  if get(usage, "inference_geo") == "us" then
    total = total * US_GEO_MULTIPLIER
  end

  -- Server-side web search is billed per request, outside the geo multiplier.
  local searches = num(get(usage, "server_tool_use"), "web_search_requests")
  return total + searches * costs.ws
end

local function group(int)
  local n
  repeat
    int, n = int:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
  until n == 0
  return int
end

local function fmt_usd(x)
  if x >= 1 then
    local int, frac = string.format("%.2f", x):match("^(-?%d+)%.(%d+)$")
    return "$" .. group(int) .. "." .. frac
  end
  return "$" .. string.format("%.4f", x)
end

local function fmt_tok(n)
  if n >= 1e6 then return string.format("%.2fM", n / 1e6) end
  if n >= 1e3 then return string.format("%.1fk", n / 1e3) end
  return string.format("%d", n)
end

-- Stand-in key for assistant messages without an id, so the dedup set can
-- still hold them (Lua tables cannot be indexed by nil).
local NO_ID = {}

local function tally(entries, from)
  local seen, cost, unpriced = {}, 0.0, false
  local tok = { inp = 0, out = 0, cr = 0, cw = 0 }
  for i = from, #entries do
    local e = entries[i]
    if get(e, "type") == "assistant" then
      local msg = get(e, "message", {})
      local usage = get(msg, "usage")
      local model = get(msg, "model", "")
      -- Assistant entries repeat once per content block; price each
      -- API response once. Synthetic messages cost nothing.
      local mid = get(msg, "id", NO_ID)
      if usage and model ~= "" and model ~= "<synthetic>" and not seen[mid] then
        seen[mid] = true
        local c = price(usage, model)
        if c == nil then
          unpriced = true
        else
          cost = cost + c
          tok.inp = tok.inp + num(usage, "input_tokens")
          tok.out = tok.out + num(usage, "output_tokens")
          tok.cr = tok.cr + num(usage, "cache_read_input_tokens")
          tok.cw = tok.cw + num(usage, "cache_creation_input_tokens")
        end
      end
    end
  end
  return cost, tok, unpriced
end

-- ------------------------------------------------------------------ main --
local payload = cjson.decode(io.read("*a") or "")
if type(payload) ~= "table" then return end

local path = get(payload, "transcript_path")
if type(path) ~= "string" or path == "" then return end
local fh = io.open(path, "r")
if not fh then return end
local prompt_id = get(payload, "prompt_id")

local entries = {}
for line in fh:lines() do
  line = sub(sub(line, "^%s+", ""), "%s+$", "")
  if line ~= "" then
    local entry = cjson.decode(line)
    if type(entry) == "table" then entries[#entries + 1] = entry end
  end
end
fh:close()

-- Find where this turn began: the entry carrying the hook's prompt_id,
-- else the last entry that came from a submitted prompt.
local start
if prompt_id then
  for i, e in ipairs(entries) do
    if get(e, "promptId") == prompt_id then
      start = i
      break
    end
  end
end
if start == nil then
  for i, e in ipairs(entries) do
    if e.promptSource ~= nil then start = i end
  end
end
if start == nil then start = 0 end

local turn_cost, tok, unpriced = tally(entries, start + 1)
local session_cost = tally(entries, 1)

if tok.out == 0 and turn_cost == 0 then return end

local msg = "turn " .. fmt_usd(turn_cost)
  .. "  ·  in " .. fmt_tok(tok.inp) .. " / out " .. fmt_tok(tok.out)
  .. " / cache r " .. fmt_tok(tok.cr) .. " w " .. fmt_tok(tok.cw)
  .. "  ·  session " .. fmt_usd(session_cost)
if unpriced then
  msg = msg .. "  (some models unpriced)"
end

io.write(cjson.encode({ systemMessage = msg, suppressOutput = true }))
