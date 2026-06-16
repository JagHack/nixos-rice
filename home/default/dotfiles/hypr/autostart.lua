-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function ()
  hl.exec_cmd("waybar")
  hl.exec_cmd("sh $HOME/.config/ags/launch.sh")
  hl.exec_cmd("bash ~/.config/hypr/scripts/wallpaper-restore.sh")
  hl.exec_cmd("bash ~/.config/hypr/scripts/wallpaper-precache.sh")
  hl.exec_cmd("wl-paste --watch cliphist store")
  -- hl.exec_cmd(terminal)
  -- hl.exec_cmd("nm-applet")
  -- hl.exec_cmd("hyprpaper & firefox")
end)
