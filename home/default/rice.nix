# home/default/rice.nix
#
# Desktop rice — all UI/shell config. Imported by home.nix.
# Does NOT set home.username or home.homeDirectory — those are set in
# home.nix so Home Manager maps files to the correct home directory.
{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./modules/hyprland.nix
    ./modules/waybar.nix
    ./modules/kitty.nix
    ./modules/rofi.nix
    ./modules/swaync.nix
    ./modules/fastfetch.nix
    ./modules/ags.nix
    ./modules/zsh.nix
    ./modules/themes.nix
    ./modules/nvim.nix
  ];

  xdg.mimeApps.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
    pictures  = "${config.home.homeDirectory}/Pictures";
    documents = "${config.home.homeDirectory}/Documents";
    download  = "${config.home.homeDirectory}/Downloads";
    music     = "${config.home.homeDirectory}/Music";
    videos    = "${config.home.homeDirectory}/Videos";
  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
