{ config, pkgs, lib, ... }:
{
  home.file = {
    ".config/nvim/lua/plugins/colorscheme.lua".source = ../dotfiles/nvim/plugins/colorscheme.lua;
  };
}
