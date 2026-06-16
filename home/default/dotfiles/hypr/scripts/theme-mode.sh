#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  theme-mode.sh — Rofi script-mode handler for the theme picker.
#
#  Rofi script mode protocol:
#    $ROFI_RETV == 0  →  initial call: print entries to stdout
#    $ROFI_RETV == 1  →  entry selected: $1 = label, $ROFI_INFO = theme slug
#
#  Launch with:
#    rofi -show theme -modi "theme:~/.config/hypr/scripts/theme-mode.sh"
# ─────────────────────────────────────────────────────────────────────────────

THEMES_DIR="$HOME/.config/themes"
CACHE_DIR="$HOME/.cache/theme-picker"
APPLY_SCRIPT="$THEMES_DIR/apply.sh"

mkdir -p "$CACHE_DIR"

# ── Generate an 80×80 color-swatch preview for a theme ───────────────────────
generate_preview() {
    local slug="$1"
    local theme_file="$2"
    local preview="$CACHE_DIR/${slug}.png"

    [[ -f "$preview" ]] && echo "$preview" && return 0

    local ACCENT ACCENT_ALT
    eval "$(grep -E '^(ACCENT|ACCENT_ALT)=' "$theme_file")"

    # Left-to-right gradient: primary accent → secondary accent
    convert -size 80x80 gradient:"#${ACCENT}"-"#${ACCENT_ALT}" -rotate -90 \
        "$preview" 2>/dev/null

    echo "$preview"
}

# ── ROFI_RETV=0 : List all themes ────────────────────────────────────────────
if [[ "${ROFI_RETV:-0}" == "0" ]]; then
    for theme_file in "$THEMES_DIR/themes/"*.theme; do
        [[ -f "$theme_file" ]] || continue
        slug=$(basename "$theme_file" .theme)

        # Extract display name without executing the file
        display_name=$(grep -m1 '^THEME_NAME=' "$theme_file" | cut -d'"' -f2)
        [[ -z "$display_name" ]] && display_name="$slug"

        preview=$(generate_preview "$slug" "$theme_file")

        printf '%s\x00icon\x1f%s\x1finfo\x1f%s\x1f\n' \
            "$display_name" \
            "$preview" \
            "$slug"
    done
    exit 0
fi

# ── ROFI_RETV=1 : Theme selected ─────────────────────────────────────────────
if [[ "${ROFI_RETV:-0}" == "1" ]]; then
    slug="${ROFI_INFO:-}"
    [[ -z "$slug" ]] && exit 0

    bash "$APPLY_SCRIPT" "$slug" &>/dev/null &

    notify-send "Theme applied" "$1" \
        --icon="$CACHE_DIR/${slug}.png" 2>/dev/null || true
    exit 0
fi
