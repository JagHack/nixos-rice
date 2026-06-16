#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  clipboard-picker.sh — Launch rofi in clipboard mode (cliphist browser)
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(dirname "$0")"
ROFI_THEME="$HOME/.config/rofi/clipboard.rasi"

exec rofi \
    -show clipboard \
    -modi "clipboard:${SCRIPT_DIR}/clipboard-mode.sh" \
    -theme "$ROFI_THEME" \
    -mesg "Enter: paste  •  Alt+d: delete  •  Esc: close"
