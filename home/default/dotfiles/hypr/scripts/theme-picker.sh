#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  theme-picker.sh — Launch the rofi theme picker.
#  Keybind: Super + Shift + W
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(dirname "$0")"
ROFI_THEME="$HOME/.config/rofi/theme-picker.rasi"

exec rofi \
    -show theme \
    -modi "theme:${SCRIPT_DIR}/theme-mode.sh" \
    -show-icons \
    -theme "$ROFI_THEME"
