------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- DP-2: ASUS VS239 (left monitor)
hl.monitor({
    output   = "DP-2",
    mode     = "1920x1080@60",
    position = "0x521",
    scale    = 1,
})

-- HDMI-A-1: ASUSTek VG249Q3R (center monitor)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "1920x650",
    scale    = 1,
})

-- DP-3: Dell P2720D (right monitor)
hl.monitor({
    output   = "DP-3",
    mode     = "2560x1440@60",
    position = "3840x0",
    scale    = 1,
})

-- Workspace-to-monitor bindings
hl.workspace_rule({ workspace = "1", monitor = "DP-2",    default = true })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-3",    default = true })
