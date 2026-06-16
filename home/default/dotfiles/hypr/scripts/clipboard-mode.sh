#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  clipboard-mode.sh — Rofi script-mode handler for clipboard history
#
#  Rofi script mode protocol (ROFI_RETV env var):
#    0  → initial call: print all clipboard entries
#    1  → entry selected: decode it and write to clipboard (paste target)
#    10 → kb-custom-1 (Alt+d): delete entry, then re-list (rofi stays open)
#
#  Launch with:
#    rofi -show clipboard -modi "clipboard:~/.config/hypr/scripts/clipboard-mode.sh"
# ─────────────────────────────────────────────────────────────────────────────

case "${ROFI_RETV:-0}" in
    0)
        cliphist list
        ;;
    1)
        cliphist decode <<< "$1" | wl-copy
        ;;
    10)
        cliphist delete <<< "$1"
        cliphist list
        ;;
esac
