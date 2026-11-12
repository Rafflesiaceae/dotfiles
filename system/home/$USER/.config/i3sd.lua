local clock = require("i3sd.modules.clock")
local filesystem = require("i3sd.modules.filesystem")
local memory = require("i3sd.modules.memory")
local pipewire_volume = require("i3sd.modules.pipewire_volume")
local power_profiles = require("i3sd.modules.power_profiles")
local systemd = require("i3sd.modules.systemd")
local nvidia = require("i3sd.modules.nvidia")
local json_command = require("i3sd.modules.json_command")

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

-- Reminds about a pending full system upgrade once the last one on ArchLinux
-- (pacman.log) or Ubuntu (apt history, including rotated logs) is at least
-- five days old. The shell part only extracts the epoch of the last upgrade
-- per distribution (0 when unknown) and always exits successfully, so a
-- missing log never turns into an error block.
local upgrade_reminder_days = 5
local upgrade_reminder_script = [==[
arch=0
ubuntu=0
if [ -e /var/log/pacman.log ]; then
    t="$(grep -i 'full system upgrade' /var/log/pacman.log | tail -1 | awk -F'[][]' '{print $2}')"
    [ -n "$t" ] && arch="$(date --date="$t" +%s 2>/dev/null || echo 0)"
fi
if [ -e /var/log/apt/history.log ]; then
    t="$(zcat -f /var/log/apt/history.log* | awk '/^Start-Date:/ { d = $2 " " $3 } /^Commandline:.* (dist-|full-)?upgrade( |$)/ { print d }' | sort | tail -1)"
    [ -n "$t" ] && ubuntu="$(date --date="$t" +%s 2>/dev/null || echo 0)"
fi
printf '{"ArchLinux":%s,"Ubuntu":%s}\n' "${arch:-0}" "${ubuntu:-0}"
exit 0
]==]

json_command {
    command = { "sh", "-c", upgrade_reminder_script },
    -- Upgrades are a days-scale concern, so checking every six hours is enough.
    interval = 6 * 3600,
    timeout = 60,
    order = 400000,
    format = function(value)
        local now = os.time()
        local due = {}
        -- Fixed iteration order keeps the text stable if both logs exist.
        for _, distro in ipairs({ "ArchLinux", "Ubuntu" }) do
            local last = tonumber(value[distro]) or 0
            if last > 0 and (now - last) / 86400 >= upgrade_reminder_days then
                due[#due + 1] = "Update " .. distro
            end
        end
        -- Nothing due hides the block.
        if #due == 0 then
            return nil
        end
        return {
            full_text = table.concat(due, " · ") .. "  ",
            color = "#FDA202",
        }
    end,
}

-- The block updates immediately when the default sink, volume, or mute state
-- changes; no polling interval is involved.
-- pipewire_volume {
--     order = 800,
-- }

-- Not represented here yet: read_file content, battery, cpu_temperature, and
-- volume need APIs/modules not present in this implementation. The commented
-- wireless and Ethernet blocks are outside i3sd's network-status scope.
