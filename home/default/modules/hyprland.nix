{ config, pkgs, lib, ... }:
# Hyprland dotfiles — manages static Lua config files and scripts via home.file.
# hypr-colors.lua is seeded via home.activation so apply.sh can overwrite it
# freely at runtime. appearance.lua is now a proper HM symlink.
{
  home.activation.seedHyprColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dest="$HOME/.config/hypr/hypr-colors.lua"
    if [ ! -f "$dest" ]; then
      install -Dm644 ${../dotfiles/themes/templates/hypr-colors.lua.tpl} "$dest"
    fi
  '';

  home.file = {
    # ── Lua config entrypoints ──────────────────────────────────────────────
    ".config/hypr/hyprland.lua".source    = ../dotfiles/hypr/hyprland.lua;
    ".config/hypr/appearance.lua".source  = ../dotfiles/hypr/appearance.lua;
    ".config/hypr/monitors.lua".source    = ../dotfiles/hypr/monitors.lua;
    ".config/hypr/env.lua".source         = ../dotfiles/hypr/env.lua;
    ".config/hypr/programs.lua".source    = ../dotfiles/hypr/programs.lua;
    ".config/hypr/autostart.lua".source   = ../dotfiles/hypr/autostart.lua;
    ".config/hypr/permissions.lua".source = ../dotfiles/hypr/permissions.lua;
    ".config/hypr/input.lua".source       = ../dotfiles/hypr/input.lua;
    ".config/hypr/keybinds.lua".source    = ../dotfiles/hypr/keybinds.lua;
    ".config/hypr/rules.lua".source       = ../dotfiles/hypr/rules.lua;

    # ── Scripts ──────────────────────────────────────────────────────────────
    ".config/hypr/scripts/alt-tab.sh" = {
      source     = ../dotfiles/hypr/scripts/alt-tab.sh;
      executable = true;
    };
    ".config/hypr/scripts/lock.sh" = {
      source     = ../dotfiles/hypr/scripts/lock.sh;
      executable = true;
    };
    ".config/hypr/scripts/fritzbox-reconnect.py" = {
      source     = ../dotfiles/hypr/scripts/fritzbox-reconnect.py;
      executable = true;
    };
    ".config/hypr/scripts/theme-mode.sh" = {
      source     = ../dotfiles/hypr/scripts/theme-mode.sh;
      executable = true;
    };
    ".config/hypr/scripts/theme-picker.sh" = {
      source     = ../dotfiles/hypr/scripts/theme-picker.sh;
      executable = true;
    };
    ".config/hypr/scripts/toggle-workspace.sh" = {
      source     = ../dotfiles/hypr/scripts/toggle-workspace.sh;
      executable = true;
    };
    ".config/hypr/scripts/wallpaper-mode.sh" = {
      source     = ../dotfiles/hypr/scripts/wallpaper-mode.sh;
      executable = true;
    };
    ".config/hypr/scripts/wallpaper-picker.sh" = {
      source     = ../dotfiles/hypr/scripts/wallpaper-picker.sh;
      executable = true;
    };
    ".config/hypr/scripts/clipboard-mode.sh" = {
      source     = ../dotfiles/hypr/scripts/clipboard-mode.sh;
      executable = true;
    };
    ".config/hypr/scripts/clipboard-picker.sh" = {
      source     = ../dotfiles/hypr/scripts/clipboard-picker.sh;
      executable = true;
    };
    ".config/hypr/scripts/wallpaper-precache.sh" = {
      source     = ../dotfiles/hypr/scripts/wallpaper-precache.sh;
      executable = true;
    };
    ".config/hypr/scripts/wallpaper-restore.sh" = {
      source     = ../dotfiles/hypr/scripts/wallpaper-restore.sh;
      executable = true;
    };
    ".config/hypr/scripts/toggle-audio-output.sh" = {
      source     = ../dotfiles/hypr/scripts/toggle-audio-output.sh;
      executable = true;
    };
  };
}
