{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "source": "NixOS_small",
    "color": {
      "1": "38;2;{{ACCENT_ALT_R}};{{ACCENT_ALT_G}};{{ACCENT_ALT_B}}",
      "2": "38;2;{{ACCENT_R}};{{ACCENT_G}};{{ACCENT_B}}"
    },
    "padding": {
      "top": 2,
      "left": 2,
      "right": 4
    }
  },
  "display": {
    "separator": "  󰑃  ",
    "color": "38;2;{{ACCENT_R}};{{ACCENT_G}};{{ACCENT_B}}",
    "key": {
      "width": 12
    }
  },
  "modules": [
    "break",
    {
      "type": "os",
      "key": " DISTRO",
      "keyColor": "38;2;{{ACCENT_R}};{{ACCENT_G}};{{ACCENT_B}}"
    },
    {
      "type": "kernel",
      "key": " KERNEL",
      "keyColor": "38;2;{{ACCENT_R}};{{ACCENT_G}};{{ACCENT_B}}"
    },
    {
      "type": "shell",
      "key": " SHELL",
      "keyColor": "38;2;{{ACCENT_R}};{{ACCENT_G}};{{ACCENT_B}}"
    },
    {
      "type": "uptime",
      "key": "󰅐 UPTIME",
      "keyColor": "38;2;{{ACCENT_R}};{{ACCENT_G}};{{ACCENT_B}}"
    },
    "break",
    {
      "type": "wm",
      "key": " WM/DE",
      "keyColor": "38;2;{{ACCENT_ALT_R}};{{ACCENT_ALT_G}};{{ACCENT_ALT_B}}"
    },
    {
      "type": "terminal",
      "key": " TERMINAL",
      "keyColor": "38;2;{{ACCENT_ALT_R}};{{ACCENT_ALT_G}};{{ACCENT_ALT_B}}"
    },
    "break",
    {
      "type": "cpu",
      "key": "󰻠 CPU",
      "format": "13th Gen Intel(R) Core(TM) i9-13900KF (32) @ 5.80 GHz",
      "keyColor": "38;2;{{FG_MUTED_R}};{{FG_MUTED_G}};{{FG_MUTED_B}}"
    },
    {
      "type": "gpu",
      "key": "󰻑 GPU",
      "format": "GeForce RTX 2070 SUPER",
      "keyColor": "38;2;{{FG_MUTED_R}};{{FG_MUTED_G}};{{FG_MUTED_B}}"
    },
    {
      "type": "memory",
      "key": "󰾆 MEMORY",
      "keyColor": "38;2;{{FG_MUTED_R}};{{FG_MUTED_G}};{{FG_MUTED_B}}"
    },
    "break",
    {
      "type": "custom",
      "format": "\u001b[38;2;{{BLACK_DIM_R}};{{BLACK_DIM_G}};{{BLACK_DIM_B}}m  \u001b[38;2;{{FG_MUTED_R}};{{FG_MUTED_G}};{{FG_MUTED_B}}m  \u001b[38;2;{{ACCENT_ALT_R}};{{ACCENT_ALT_G}};{{ACCENT_ALT_B}}m  \u001b[38;2;{{ACCENT_R}};{{ACCENT_G}};{{ACCENT_B}}m  \u001b[38;2;{{FG_R}};{{FG_G}};{{FG_B}}m  \u001b[38;2;{{INFO_R}};{{INFO_G}};{{INFO_B}}m  \u001b[38;2;{{URGENT_R}};{{URGENT_G}};{{URGENT_B}}m  \u001b[38;2;{{WARNING_R}};{{WARNING_G}};{{WARNING_B}}m  \u001b[38;2;{{GREEN_R}};{{GREEN_G}};{{GREEN_B}}m "
    },
    "break"
  ]
}
