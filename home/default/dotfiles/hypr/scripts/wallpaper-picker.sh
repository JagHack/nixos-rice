#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  wallpaper-picker.sh  —  Launches rofi in script-mode for wallpaper picking.
#  The actual logic lives in wallpaper-mode.sh (rofi script-mode handler).
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(dirname "$0")"
ROFI_THEME="$HOME/.config/rofi/wallpaper-picker.rasi"

exec rofi \
  -show wallpaper \
  -modi "wallpaper:${SCRIPT_DIR}/wallpaper-mode.sh" \
  -show-icons \
  -theme "$ROFI_THEME"
