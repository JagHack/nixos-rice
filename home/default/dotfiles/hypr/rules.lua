--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.layer_rule({
    name  = "waybar-blur",
    match = { namespace = "waybar" },
    blur  = true,
})

hl.layer_rule({
    name  = "ags-dashboard-blur",
    match = { namespace = "dashboard" },
    blur  = true,
})

hl.layer_rule({
    name  = "ags-popup-blur",
    match = { namespace = "notifications-popup" },
    blur  = true,
})

hl.window_rule({
    name  = "kitty-transparency",
    match = { class = "kitty" },
    opacity = "1.0 0.8",
})

-- App workspace assignments
hl.window_rule({ name = "discord-ws9",  match = { class = "discord" },   workspace = "9" })
hl.window_rule({ name = "fractal-ws9",  match = { class = "org.gnome.Fractal" }, workspace = "9" })
hl.window_rule({ name = "spotify-ws9",  match = { class = "Spotify" },   workspace = "9" })
hl.window_rule({ name = "browser-ws2",  match = { class = "zen-beta" },  workspace = "2" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- Set gaps to 3px when only one window is open
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 3, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 3, gaps_in = 0 })

-- Optional window rules for smart gaps consistency
hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 2,
    rounding    = 10,
})
hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },
    border_size = 2,
    rounding    = 10,
})
