local clock = require("i3sd.modules.clock")
local filesystem = require("i3sd.modules.filesystem")
local memory = require("i3sd.modules.memory")
local pipewire_volume = require("i3sd.modules.pipewire_volume")
local power_profiles = require("i3sd.modules.power_profiles")
local systemd = require("i3sd.modules.systemd")
local nvidia = require("i3sd.modules.nvidia")
local json_command = require("i3sd.modules.json_command")
local command = require("i3sd.modules.command")

local color_bad = "#FF0000"
local color_degraded = "#FDD102"
local color_dim = "#99947B"

-- Failed system and user units are hidden while both managers are healthy.
systemd {
    scope = "both",
    order = 500000,
    format = function(value)
        return {
            full_text = ("systemd: %d failed"):format(value.count),
            color = color_bad,
            urgent = true,
        }
    end,
}

-- The original root disk block is warning-only below ten percent available.
filesystem {
    path = "/",
    interval = 2,
    warn_below = 10,
    critical_below = 10,
    hysteresis = 1,
    order = 40,
    format = function(value)
        return {
            full_text = ("🧱 Disk: %.0f%%"):format(value.available_percent),
            color = color_bad,
        }
    end,
}

-- Memory stays hidden while healthy and escalates at the original 20/10
-- percent available thresholds.
memory {
    interval = 2,
    warn_below = 20,
    critical_below = 10,
    hysteresis = 2,
    order = 30,
    format = function(value)
        return {
            full_text = ("RAM: %.0f%%"):format(value.available_percent),
            color = value.severity == "critical" and color_bad or color_degraded,
            urgent = value.severity == "critical",
        }
    end,
}

block {
    name = "load",
    order = 20,
    interval = 2,
    update = function(ctx)
        local postfix = "  "
        local snapshot = assert(ctx:sample("load"))
        if snapshot.load1 > 2.0 then
            ctx:set {
                full_text = ("🔲 <span foreground='%s'>%.2f</span>" .. postfix):format(color_degraded, snapshot.load1),
                markup = "pango",
            }
            return
        end
        ctx:set {
            full_text = ("🔲 %.2f" .. postfix):format(snapshot.load1),
            markup = "pango",
        }
    end,
}

power_profiles {
    order = 1000,
    format = function(value)
        local labels = {
            ["power-saver"] = {"   😴   ", ""},
            balanced        = {"   ➗   ", ""},
            performance     = {"   🎯   ", ""},
        }
        -- return "⚡ " .. (labels[value.active_profile] or value.active_profile)
        -- return ("%s %s"):format(labels[value.active_profile][1], labels[value.active_profile][2])
        return {
            full_text = ("<span foreground='%s'>%s</span>"):format(color_dim, labels[value.active_profile][1]),
            markup = "pango",
            background = "#272822",
        }
        -- if value.active_profile ~= "power-saver" then
        --     return ("👽 %s"):format(labels[value.active_profile])
        -- else
        --     return "👽"
        -- end
    end,
}

clock {
    format = "📰 %Y-%m-%d  🕓 %H:%M:%S ·",
    interval = 2,
    order = 10,
}

nvidia {
    index = 0,
    interval = 5,
    order = 900,
    format = function(value)
        -- return ("🔘 %.0f%% %.1fW"):format(
        return ("  🔘 %02.0f%% "):format(math.min(value.load_percent, 99) or 0)
        -- return ("🔘 %.0f"):format((value.load_percent/10) or 0)
    end,
}

json_command {
    command = { "codex-usage", "--json" },
    interval = 30,
    order = 10000,
    format = function(value)
        local result = ("🍚 %.0f%% %s/%.0f%% %s"):format(
                tonumber(value["5h"]) or 0,
                value["5h_reset_local"],
                tonumber(value.week) or 0,
                value["week_reset_local"]
            )

        if value.credits > 0 then
            result = result .. (" · credits %g"):format(tonumber(value.credits) or 0)
        end

        return {
            full_text = result .. "  ",
            markup = "pango",
        }
    end,
}

-- Reminds about a pending full system upgrade once the last one is at least
-- five days old. The distribution is decided once from os-release when the
-- configuration loads, so only its own pipeline ever runs. Each pipeline
-- prints the epoch of the last full upgrade, or nothing when its log is
-- missing or has no upgrade yet, which keeps the block hidden; errors go to
-- /dev/null instead of i3sd's stderr. The do block keeps its locals out of
-- the rest of the configuration.
do
    local reminder_days = 5
    local script
    if i3sd.os_like("arch") then
        script = [==[grep -i 'full system upgrade' /var/log/pacman.log 2>/dev/null | tail -1 | awk -F'[][]' '{print $2}' | xargs -r -I{} date --date={} +%s]==]
    elseif i3sd.os_like("debian") then
        -- apt history rotates, so the rotated gzip logs are searched as well.
        script = [==[zcat -f /var/log/apt/history.log* 2>/dev/null | awk '/^Start-Date:/ { d = $2 " " $3 } /^Commandline:.* (dist-|full-)?upgrade( |$)/ { print d }' | sort | tail -1 | xargs -r -I{} date --date={} +%s]==]
    end

    -- Other distributions get no block at all.
    if script ~= nil then
        command {
            name = "upgrade_reminder",
            shell = script,
            -- Upgrades are a days-scale concern, so checking every six hours is enough.
            interval = 6 * 3600,
            order = 400000,
            format = function(stdout)
                local last = tonumber(stdout:match("%d+"))
                if last == nil or (os.time() - last) / 86400 < reminder_days then
                    return nil
                end
                return {
                    full_text = "Update " .. i3sd.os_release.NAME .. "  ",
                    color = "#FDA202",
                }
            end,
        }
    end
end

-- The block updates immediately when the default sink, volume, or mute state
-- changes; no polling interval is involved.
-- pipewire_volume {
--     order = 800,
-- }

-- Not represented here yet: read_file content, battery, cpu_temperature, and
-- volume need APIs/modules not present in this implementation. The commented
-- wireless and Ethernet blocks are outside i3sd's network-status scope.
