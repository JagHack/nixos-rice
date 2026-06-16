{ config, pkgs, lib, inputs, ... }:
{
  imports = [ ./rice.nix ];

  home.username    = "jaghack";
  home.homeDirectory = "/home/jaghack";
}
