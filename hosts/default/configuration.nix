{ config, pkgs, lib, inputs, ... }:
let
  breezex-black-cursor = pkgs.callPackage ./pkgs/breezex-black-cursor.nix { };
in
{
  imports = [
    ./hardware-configuration.nix
    ./bootloader.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # ── Networking ────────────────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.dhcpcd.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  # ── Tailscale ─────────────────────────────────────────────────────────────
  services.tailscale.enable = true;

  # ── Locale & Time ─────────────────────────────────────────────────────────
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # ── Boot ──────────────────────────────────────────────────────────────────
  # The bootloader (GRUB, UEFI or BIOS) lives in ./bootloader.nix, which
  # install.sh regenerates per machine based on the detected firmware.
  boot.kernelParams = [ "acpi_osi=Linux" ];

  # ── Users ─────────────────────────────────────────────────────────────────
  users.users.jaghack = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    # Set a real password after first boot with `passwd`, or replace this with
    # `hashedPassword` / `hashedPasswordFile` (see the NixOS manual). The greeter
    # below (greetd + tuigreet) will prompt for it at login.
    initialPassword = "changeme";
    shell = pkgs.zsh;
  };

  # ── Desktop & Compositor ─────────────────────────────────────────────────
  programs.hyprland.enable = true;
  programs.zsh.enable = true;
  programs.dconf.enable = true;

  # ── Greeter (greetd + tuigreet) ───────────────────────────────────────────
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --user-menu --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # ── GNOME Keyring & portal services ──────────────────────────────────────
  security.pam.services.login.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # ── Nvidia GPU ────────────────────────────────────────────────────────────
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # ── nix-ld (run unpatched binaries) ───────────────────────────────────────
  programs.nix-ld.enable = true;

  # ── Cursor & Theming variables ────────────────────────────────────────────
  environment.variables = {
    XCURSOR_THEME = "BreezeX-Black";
    XCURSOR_SIZE  = "24";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";
  };

  # ── Qt dark mode ──────────────────────────────────────────────────────────
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  # ── GTK dark mode (system-wide) ───────────────────────────────────────────
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
        };
      };
    }
  ];

  environment.etc = {
    "xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=1
      gtk-theme-name=Adwaita-dark
    '';
    "xdg/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=1
      gtk-theme-name=Adwaita-dark
    '';
  };

  # ── Fonts ─────────────────────────────────────────────────────────────────
  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "FiraCode Nerd Font Mono" ];
        sansSerif = [ "FiraCode Nerd Font Propo" ];
        serif     = [ "FiraCode Nerd Font" ];
      };
    };
  };

  # ── System Packages ───────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git
    kitty
    discord
    rofi
    fractal
    spotify
    notesnook
    vim
    nodejs
    neovim
    wget
    curl
    waybar
    hyprlock
    ags
    astal.mpris
    astal.notifd
    libnotify
    pavucontrol
    pciutils
    alsa-utils
    inputs.zen-browser.packages."${pkgs.system}".default

    # Cursor theme
    breezex-black-cursor

    # Dark Mode and Theming
    adw-gtk3
    gnome-themes-extra
    libsForQt5.qt5ct
    kdePackages.qt6ct

    # GNOME Utilities & Display config
    gnome-disk-utility
    gnome-control-center
    gnome-system-monitor
    nautilus
    baobab
    eog
    evince
    wdisplays

    # CLI essentials
    ripgrep
    fd
    bat
    eza
    lsd
    fzf
    zoxide
    starship
    tmux
    jq
    yq-go
    tldr
    zsh-autosuggestions
    zsh-syntax-highlighting

    # System & hardware utilities
    htop
    btop
    lsof
    usbutils
    nvme-cli
    smartmontools
    acpi

    # Archives
    unzip
    zip
    p7zip
    unrar
    gnutar

    # Networking
    nmap
    dnsutils
    whois
    traceroute
    speedtest-cli

    # Filesystem
    ncdu
    duf
    rsync
    rclone

    # Dev tools
    gcc
    gnumake
    python3
    (python3.withPackages (ps: with ps; [
      fritzconnection
    ]))
    gh
    lazygit
    docker-compose
    vscodium

    # Screenshots (Wayland-native)
    grim
    slurp
    satty

    # Wallpaper daemon (awww = the new name for swww)
    awww

    # Minecraft
    prismlauncher

    # Misc
    fastfetch
    ffmpeg
    imagemagick
    xdg-utils
    wl-clipboard
    cliphist
    brightnessctl
    playerctl
  ];

  systemd.services.disable-audio-automute = {
    description = "Disable HDA auto-mute so rear speakers work with front headphones plugged in";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.alsa-utils}/bin/amixer -c 0 sset 'Auto-Mute Mode' Disabled";
      RemainAfterExit = true;
    };
  };

  system.stateVersion = "24.11";
}
