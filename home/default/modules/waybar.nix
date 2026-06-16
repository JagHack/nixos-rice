{ config, pkgs, ... }:
# Waybar — manages structural config (layout, modules) and base stylesheet.
# colors.css is intentionally EXCLUDED — it is generated at runtime by
# ~/.config/themes/apply.sh from a template and must remain writable.
{
  home.file = {
    ".config/waybar/config".source    = ../dotfiles/waybar/config;
    ".config/waybar/style.css".source = ../dotfiles/waybar/style.css;

    ".config/waybar/scripts/gpu-usage.sh" = {
      source     = ../dotfiles/waybar/scripts/gpu-usage.sh;
      executable = true;
    };
  };
}
