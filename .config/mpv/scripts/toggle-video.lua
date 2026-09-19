-- toggle-video.lua
local mp = require("mp")

-- Explicitly disabled by the user via toggle-video-decode.
local manual_disabled = false

-- Temporarily disabled because the window was not visible for long enough.
local auto_disabled = false

-- Value of "vid" before automatic disabling, so we can restore it exactly.
local auto_restore_vid = nil

local window_visible = nil

-- Delay before automatically disabling video decoding while hidden.
local AUTO_DISABLE_DELAY = 30.0

-- How long the window must remain continuously visible before restoring video.
local AUTO_ENABLE_DELAY = 0.8

-- Countdown refresh interval.
local AUTO_ENABLE_TICK = 0.05

-- Pending automatic-disable timer.
local auto_disable_timer = nil

-- Periodic timer used for the automatic-enable countdown.
local auto_enable_timer = nil
local auto_enable_started_at = nil

-- Temporary key bindings that exist only while the automatic-enable
-- countdown is active.
local AUTO_ENABLE_ENTER_BINDING = "auto-enable-video-enter"
local AUTO_ENABLE_KP_ENTER_BINDING = "auto-enable-video-kp-enter"
local AUTO_ENABLE_MOUSE_BINDING = "auto-enable-video-mouse"

-- Create a persistent OSD overlay.
local status_overlay = mp.create_osd_overlay("ass-events")
status_overlay.z = -1000

local function update_status_overlay()
    if manual_disabled then
        status_overlay.data =
            [[{\an5\fs50\bord1\shad1}Video disabled - press F4 to re-enable]]
        status_overlay.hidden = false

    elseif auto_enable_timer and auto_enable_started_at then
        local elapsed = mp.get_time() - auto_enable_started_at
        local remaining = math.max(0, AUTO_ENABLE_DELAY - elapsed)

        status_overlay.data = string.format(
            [[{\an5\fs50\bord1\shad1}Re-enabling video in %.2f]],
            remaining
        )
        status_overlay.hidden = false

    else
        status_overlay.hidden = true
    end

    status_overlay:update()
end

local function refresh_video()
    -- Force a refresh by seeking to the current timestamp.
    local pos = mp.get_property_number("time-pos")
    if pos then
        mp.commandv("seek", tostring(pos), "absolute", "exact")
    end
end

local function cancel_auto_disable_timer()
    if auto_disable_timer then
        auto_disable_timer:kill()
        auto_disable_timer = nil
    end
end

local function remove_auto_enable_skip_bindings()
    mp.remove_key_binding(AUTO_ENABLE_ENTER_BINDING)
    mp.remove_key_binding(AUTO_ENABLE_KP_ENTER_BINDING)
    mp.remove_key_binding(AUTO_ENABLE_MOUSE_BINDING)
end

local function cancel_auto_enable_countdown()
    if auto_enable_timer then
        auto_enable_timer:kill()
        auto_enable_timer = nil
    end

    auto_enable_started_at = nil

    remove_auto_enable_skip_bindings()
    update_status_overlay()
end

local function auto_disable_video()
    if manual_disabled or auto_disabled then
        return
    end

    -- The window must still be hidden when the delay expires.
    if window_visible ~= false then
        return
    end

    local vid = mp.get_property("vid")

    -- Already disabled by something outside our visibility handling.
    -- Do not assume we are allowed to restore it later.
    if vid == "no" then
        return
    end

    auto_restore_vid = vid or "auto"

    mp.set_property("vid", "no")
    auto_disabled = true
end

local function finish_auto_enable()
    if not auto_disabled then
        return
    end

    -- The window must be visible when video is restored.
    if window_visible ~= true then
        return
    end

    -- An explicit manual disable always wins.
    if manual_disabled then
        return
    end

    mp.set_property("vid", auto_restore_vid or "auto")

    auto_disabled = false
    auto_restore_vid = nil

    refresh_video()
end

local function skip_auto_enable_countdown()
    -- These bindings should only exist during the countdown, but still
    -- validate all state before restoring video.
    if not auto_enable_timer or not auto_enable_started_at then
        return
    end

    if window_visible ~= true then
        cancel_auto_enable_countdown()
        return
    end

    if manual_disabled or not auto_disabled then
        cancel_auto_enable_countdown()
        return
    end

    -- Stop the countdown and remove its temporary input bindings before
    -- restoring video.
    auto_enable_timer:kill()
    auto_enable_timer = nil
    auto_enable_started_at = nil

    remove_auto_enable_skip_bindings()

    finish_auto_enable()
    update_status_overlay()
end

local function install_auto_enable_skip_bindings()
    -- Forced bindings ensure these inputs take precedence while the countdown
    -- is active. They are removed as soon as the countdown finishes/cancels.
    mp.add_forced_key_binding(
        "ENTER",
        AUTO_ENABLE_ENTER_BINDING,
        skip_auto_enable_countdown
    )

    -- Also handle the Enter key on the numeric keypad.
    mp.add_forced_key_binding(
        "KP_ENTER",
        AUTO_ENABLE_KP_ENTER_BINDING,
        skip_auto_enable_countdown
    )

    mp.add_forced_key_binding(
        "MBTN_LEFT",
        AUTO_ENABLE_MOUSE_BINDING,
        skip_auto_enable_countdown
    )
end

local function start_auto_enable_countdown()
    if manual_disabled or not auto_disabled then
        return
    end

    if window_visible ~= true then
        return
    end

    -- Countdown already running.
    if auto_enable_timer then
        return
    end

    auto_enable_started_at = mp.get_time()

    auto_enable_timer = mp.add_periodic_timer(AUTO_ENABLE_TICK, function()
        -- Any loss of visibility cancels the entire countdown.
        if window_visible ~= true then
            cancel_auto_enable_countdown()
            return
        end

        -- Manual disabling during the countdown also cancels it.
        if manual_disabled or not auto_disabled then
            cancel_auto_enable_countdown()
            return
        end

        local elapsed = mp.get_time() - auto_enable_started_at

        if elapsed >= AUTO_ENABLE_DELAY then
            -- Stop the timer before enabling so state is clean.
            auto_enable_timer:kill()
            auto_enable_timer = nil
            auto_enable_started_at = nil

            remove_auto_enable_skip_bindings()

            finish_auto_enable()
            update_status_overlay()
            return
        end

        update_status_overlay()
    end)

    -- ENTER/KP_ENTER or a left click can now bypass the countdown.
    install_auto_enable_skip_bindings()

    update_status_overlay()
end

local function schedule_auto_disable()
    if manual_disabled or auto_disabled or auto_disable_timer then
        return
    end

    auto_disable_timer = mp.add_timeout(AUTO_DISABLE_DELAY, function()
        auto_disable_timer = nil

        -- Re-check visibility when the timer actually fires.
        if window_visible == false then
            auto_disable_video()
        end
    end)
end

local function update_visibility_state()
    if window_visible == nil then
        -- Property unsupported/unavailable.
        return
    end

    if window_visible then
        -- Visibility returned before the 30-second disable threshold.
        cancel_auto_disable_timer()

        if auto_disabled then
            -- Video was already automatically disabled. Do not restore it
            -- immediately: require X seconds of continuous visibility,
            -- unless the user explicitly skips the countdown.
            start_auto_enable_countdown()
        end
    else
        -- Becoming invisible always invalidates an in-progress enable
        -- countdown. The next time the window becomes visible, the entire
        -- X-second countdown starts again from zero.
        cancel_auto_enable_countdown()

        if not auto_disabled then
            -- Video is still enabled. Start the 30-second grace period.
            schedule_auto_disable()
        end
    end
end

local function toggle_video_decode()
    if manual_disabled then
        -- User explicitly re-enabled video.
        manual_disabled = false

        if auto_disabled then
            -- Automatic visibility handling currently owns the disabled
            -- state. It may only restore decoding after continuous
            -- visibility for AUTO_ENABLE_DELAY, or an explicit skip.
            if window_visible then
                start_auto_enable_countdown()
            end
        else
            mp.set_property("vid", "auto")
            refresh_video()

            -- If currently hidden, hand control back to automatic
            -- visibility handling.
            update_visibility_state()
        end
    else
        -- Explicit manual disable. This takes precedence over visibility.
        manual_disabled = true

        cancel_auto_disable_timer()
        cancel_auto_enable_countdown()

        auto_disabled = false
        auto_restore_vid = nil

        mp.set_property("vid", "no")
    end

    update_status_overlay()
end

mp.observe_property("window-visible", "bool", function(_, visible)
    window_visible = visible
    update_visibility_state()
end)

-- Keep state synchronized when a new file is loaded.
mp.register_event("file-loaded", function()
    if manual_disabled then
        cancel_auto_disable_timer()
        cancel_auto_enable_countdown()

        -- Preserve an explicit manual disable across files.
        mp.set_property("vid", "no")

    elseif not auto_disabled then
        -- If decoding was already disabled independently of our automatic
        -- visibility handling, don't assume we're allowed to re-enable it.
        manual_disabled = (mp.get_property("vid") == "no")
    end

    update_status_overlay()

    if not manual_disabled then
        update_visibility_state()
    end
end)

-- Make it bindable from input.conf.
mp.add_key_binding(nil, "toggle-video-decode", toggle_video_decode)
