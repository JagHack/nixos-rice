{ config, pkgs, lib, ... }:
# Theme system — manages the apply.sh script and all theme/template source files.
# apply.sh READS from these files and WRITES to other config dirs (waybar/colors.css,
# kitty/kitty-colors.conf, etc.). Those generated outputs are NOT managed here.
{
  # Seed theme on first login — runs apply.sh with the default theme if the
  # generated outputs don't exist yet (i.e., the user has never run apply.sh).
  home.activation.seedTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.config/waybar/colors.css" ]; then
      mkdir -p "$HOME/.config/mako"
      bash "$HOME/.config/themes/apply.sh" dark-nature 2>/dev/null || true
    fi
  '';

  home.file = {
    ".config/themes/apply.sh" = {
      source     = ../dotfiles/themes/apply.sh;
      executable = true;
    };

    # Template sources (read-only — apply.sh reads, never writes here)
    ".config/themes/templates/hypr-colors.lua.tpl".source            = ../dotfiles/themes/templates/hypr-colors.lua.tpl;
    ".config/themes/templates/ags-style.css.tpl".source              = ../dotfiles/themes/templates/ags-style.css.tpl;
    ".config/themes/templates/fastfetch-config.jsonc.tpl".source     = ../dotfiles/themes/templates/fastfetch-config.jsonc.tpl;
    ".config/themes/templates/kitty-colors.conf.tpl".source          = ../dotfiles/themes/templates/kitty-colors.conf.tpl;
    ".config/themes/templates/mako-config.tpl".source                = ../dotfiles/themes/templates/mako-config.tpl;
    ".config/themes/templates/rofi-theme-picker.rasi.tpl".source     = ../dotfiles/themes/templates/rofi-theme-picker.rasi.tpl;
    ".config/themes/templates/rofi-theme.rasi.tpl".source            = ../dotfiles/themes/templates/rofi-theme.rasi.tpl;
    ".config/themes/templates/rofi-wallpaper-picker.rasi.tpl".source = ../dotfiles/themes/templates/rofi-wallpaper-picker.rasi.tpl;
    ".config/themes/templates/rofi-clipboard.rasi.tpl".source        = ../dotfiles/themes/templates/rofi-clipboard.rasi.tpl;
    ".config/themes/templates/swaync-style.css.tpl".source           = ../dotfiles/themes/templates/swaync-style.css.tpl;
    ".config/themes/templates/hyprlock.conf.tpl".source              = ../dotfiles/themes/templates/hyprlock.conf.tpl;
    ".config/themes/templates/waybar-colors.css.tpl".source          = ../dotfiles/themes/templates/waybar-colors.css.tpl;

    # Theme definitions
    ".config/themes/themes/dark-nature.theme".source   = ../dotfiles/themes/themes/dark-nature.theme;
    ".config/themes/themes/rose-pine-moon.theme".source = ../dotfiles/themes/themes/rose-pine-moon.theme;
    ".config/themes/themes/stargazer.theme".source     = ../dotfiles/themes/themes/stargazer.theme;
    ".config/themes/themes/sunset-room.theme".source   = ../dotfiles/themes/themes/sunset-room.theme;
  };
}
