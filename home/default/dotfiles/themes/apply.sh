#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  apply.sh — DE-wide theme applicator
#
#  Usage:  ~/.config/themes/apply.sh <theme-name>
#  Themes: ~/.config/themes/themes/<name>.theme
#
#  Applies to: waybar · kitty · swaync · rofi · AGS · fastfetch · mako
#              hyprland borders · wallpaper · clipboard picker
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

THEMES_DIR="$HOME/.config/themes"
TEMPLATES_DIR="$THEMES_DIR/templates"

# ── Usage ────────────────────────────────────────────────────────────────────
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <theme-name>"
    echo ""
    echo "Available themes:"
    for t in "$THEMES_DIR/themes/"*.theme; do
        [[ -f "$t" ]] && echo "  $(basename "$t" .theme)"
    done
    exit 1
fi

THEME_FILE="$THEMES_DIR/themes/$1.theme"
if [[ ! -f "$THEME_FILE" ]]; then
    echo "Error: theme '$1' not found at $THEME_FILE"
    exit 1
fi

# ── Load theme ───────────────────────────────────────────────────────────────
source "$THEME_FILE"
echo "Applying theme: $THEME_NAME"

# ── Hex → decimal component helpers ──────────────────────────────────────────
_r() { printf '%d' "0x${1:0:2}"; }
_g() { printf '%d' "0x${1:2:2}"; }
_b() { printf '%d' "0x${1:4:2}"; }

# ── Pre-compute all RGB components ───────────────────────────────────────────
BG_BASE_R=$(_r "$BG_BASE");       BG_BASE_G=$(_g "$BG_BASE");       BG_BASE_B=$(_b "$BG_BASE")
BG_DARK_R=$(_r "$BG_DARK");       BG_DARK_G=$(_g "$BG_DARK");       BG_DARK_B=$(_b "$BG_DARK")
BG_R=$(_r "$BG");                 BG_G=$(_g "$BG");                 BG_B=$(_b "$BG")
BG_SURFACE_R=$(_r "$BG_SURFACE"); BG_SURFACE_G=$(_g "$BG_SURFACE"); BG_SURFACE_B=$(_b "$BG_SURFACE")
BG_MEDIUM_R=$(_r "$BG_MEDIUM");   BG_MEDIUM_G=$(_g "$BG_MEDIUM");   BG_MEDIUM_B=$(_b "$BG_MEDIUM")
BG_BLUR_R=$(_r "$BG_BLUR");       BG_BLUR_G=$(_g "$BG_BLUR");       BG_BLUR_B=$(_b "$BG_BLUR")
BG_HIGH_R=$(_r "$BG_HIGH");       BG_HIGH_G=$(_g "$BG_HIGH");       BG_HIGH_B=$(_b "$BG_HIGH")
BG_HIGHEST_R=$(_r "$BG_HIGHEST"); BG_HIGHEST_G=$(_g "$BG_HIGHEST"); BG_HIGHEST_B=$(_b "$BG_HIGHEST")
BG_HOVER_R=$(_r "$BG_HOVER");     BG_HOVER_G=$(_g "$BG_HOVER");     BG_HOVER_B=$(_b "$BG_HOVER")
BG_ACTIVE_R=$(_r "$BG_ACTIVE");   BG_ACTIVE_G=$(_g "$BG_ACTIVE");   BG_ACTIVE_B=$(_b "$BG_ACTIVE")
SELECTION_R=$(_r "$SELECTION");   SELECTION_G=$(_g "$SELECTION");   SELECTION_B=$(_b "$SELECTION")
OVERLAY_R=$(_r "$OVERLAY");       OVERLAY_G=$(_g "$OVERLAY");       OVERLAY_B=$(_b "$OVERLAY")
BLACK_DIM_R=$(_r "$BLACK_DIM");   BLACK_DIM_G=$(_g "$BLACK_DIM");   BLACK_DIM_B=$(_b "$BLACK_DIM")
FG_R=$(_r "$FG");                 FG_G=$(_g "$FG");                 FG_B=$(_b "$FG")
FG_MUTED_R=$(_r "$FG_MUTED");     FG_MUTED_G=$(_g "$FG_MUTED");     FG_MUTED_B=$(_b "$FG_MUTED")
FG_SUBTLE_R=$(_r "$FG_SUBTLE");   FG_SUBTLE_G=$(_g "$FG_SUBTLE");   FG_SUBTLE_B=$(_b "$FG_SUBTLE")
ACCENT_R=$(_r "$ACCENT");         ACCENT_G=$(_g "$ACCENT");         ACCENT_B=$(_b "$ACCENT")
ACCENT_ALT_R=$(_r "$ACCENT_ALT"); ACCENT_ALT_G=$(_g "$ACCENT_ALT"); ACCENT_ALT_B=$(_b "$ACCENT_ALT")
ACCENT_LIGHT_R=$(_r "$ACCENT_LIGHT"); ACCENT_LIGHT_G=$(_g "$ACCENT_LIGHT"); ACCENT_LIGHT_B=$(_b "$ACCENT_LIGHT")
URGENT_R=$(_r "$URGENT");         URGENT_G=$(_g "$URGENT");         URGENT_B=$(_b "$URGENT")
URGENT_DARK_R=$(_r "$URGENT_DARK"); URGENT_DARK_G=$(_g "$URGENT_DARK"); URGENT_DARK_B=$(_b "$URGENT_DARK")
WARNING_R=$(_r "$WARNING");       WARNING_G=$(_g "$WARNING");       WARNING_B=$(_b "$WARNING")
INFO_R=$(_r "$INFO");             INFO_G=$(_g "$INFO");             INFO_B=$(_b "$INFO")
GREEN_R=$(_r "$GREEN");           GREEN_G=$(_g "$GREEN");           GREEN_B=$(_b "$GREEN")
CYAN_TERM_R=$(_r "$CYAN_TERM");   CYAN_TERM_G=$(_g "$CYAN_TERM");   CYAN_TERM_B=$(_b "$CYAN_TERM")

# ── Template processor ───────────────────────────────────────────────────────
apply_template() {
    local tpl="$1"
    local out="$2"

    sed \
        -e "s|{{THEME_NAME}}|${THEME_NAME}|g" \
        \
        -e "s|{{BG_BASE}}|${BG_BASE}|g"             -e "s|{{BG_BASE_R}}|${BG_BASE_R}|g"     \
        -e "s|{{BG_BASE_G}}|${BG_BASE_G}|g"         -e "s|{{BG_BASE_B}}|${BG_BASE_B}|g"     \
        \
        -e "s|{{BG_DARK}}|${BG_DARK}|g"             -e "s|{{BG_DARK_R}}|${BG_DARK_R}|g"     \
        -e "s|{{BG_DARK_G}}|${BG_DARK_G}|g"         -e "s|{{BG_DARK_B}}|${BG_DARK_B}|g"     \
        \
        -e "s|{{BG_SURFACE}}|${BG_SURFACE}|g"       -e "s|{{BG_SURFACE_R}}|${BG_SURFACE_R}|g" \
        -e "s|{{BG_SURFACE_G}}|${BG_SURFACE_G}|g"   -e "s|{{BG_SURFACE_B}}|${BG_SURFACE_B}|g" \
        \
        -e "s|{{BG_MEDIUM}}|${BG_MEDIUM}|g"         -e "s|{{BG_MEDIUM_R}}|${BG_MEDIUM_R}|g" \
        -e "s|{{BG_MEDIUM_G}}|${BG_MEDIUM_G}|g"     -e "s|{{BG_MEDIUM_B}}|${BG_MEDIUM_B}|g" \
        \
        -e "s|{{BG_BLUR}}|${BG_BLUR}|g"             -e "s|{{BG_BLUR_R}}|${BG_BLUR_R}|g"     \
        -e "s|{{BG_BLUR_G}}|${BG_BLUR_G}|g"         -e "s|{{BG_BLUR_B}}|${BG_BLUR_B}|g"     \
        \
        -e "s|{{BG_HIGH}}|${BG_HIGH}|g"             -e "s|{{BG_HIGH_R}}|${BG_HIGH_R}|g"     \
        -e "s|{{BG_HIGH_G}}|${BG_HIGH_G}|g"         -e "s|{{BG_HIGH_B}}|${BG_HIGH_B}|g"     \
        \
        -e "s|{{BG_HIGHEST}}|${BG_HIGHEST}|g"       -e "s|{{BG_HIGHEST_R}}|${BG_HIGHEST_R}|g" \
        -e "s|{{BG_HIGHEST_G}}|${BG_HIGHEST_G}|g"   -e "s|{{BG_HIGHEST_B}}|${BG_HIGHEST_B}|g" \
        \
        -e "s|{{BG_HOVER}}|${BG_HOVER}|g"           -e "s|{{BG_HOVER_R}}|${BG_HOVER_R}|g"   \
        -e "s|{{BG_HOVER_G}}|${BG_HOVER_G}|g"       -e "s|{{BG_HOVER_B}}|${BG_HOVER_B}|g"   \
        \
        -e "s|{{BG_ACTIVE}}|${BG_ACTIVE}|g"         -e "s|{{BG_ACTIVE_R}}|${BG_ACTIVE_R}|g" \
        -e "s|{{BG_ACTIVE_G}}|${BG_ACTIVE_G}|g"     -e "s|{{BG_ACTIVE_B}}|${BG_ACTIVE_B}|g" \
        \
        -e "s|{{BG}}|${BG}|g"                       -e "s|{{BG_R}}|${BG_R}|g"               \
        -e "s|{{BG_G}}|${BG_G}|g"                   -e "s|{{BG_B}}|${BG_B}|g"               \
        \
        -e "s|{{SELECTION}}|${SELECTION}|g"         -e "s|{{SELECTION_R}}|${SELECTION_R}|g" \
        -e "s|{{SELECTION_G}}|${SELECTION_G}|g"     -e "s|{{SELECTION_B}}|${SELECTION_B}|g" \
        \
        -e "s|{{OVERLAY}}|${OVERLAY}|g"             -e "s|{{OVERLAY_R}}|${OVERLAY_R}|g"     \
        -e "s|{{OVERLAY_G}}|${OVERLAY_G}|g"         -e "s|{{OVERLAY_B}}|${OVERLAY_B}|g"     \
        \
        -e "s|{{BLACK_DIM}}|${BLACK_DIM}|g"         -e "s|{{BLACK_DIM_R}}|${BLACK_DIM_R}|g" \
        -e "s|{{BLACK_DIM_G}}|${BLACK_DIM_G}|g"     -e "s|{{BLACK_DIM_B}}|${BLACK_DIM_B}|g" \
        \
        -e "s|{{FG_SUBTLE}}|${FG_SUBTLE}|g"         -e "s|{{FG_SUBTLE_R}}|${FG_SUBTLE_R}|g" \
        -e "s|{{FG_SUBTLE_G}}|${FG_SUBTLE_G}|g"     -e "s|{{FG_SUBTLE_B}}|${FG_SUBTLE_B}|g" \
        \
        -e "s|{{FG_MUTED}}|${FG_MUTED}|g"           -e "s|{{FG_MUTED_R}}|${FG_MUTED_R}|g"   \
        -e "s|{{FG_MUTED_G}}|${FG_MUTED_G}|g"       -e "s|{{FG_MUTED_B}}|${FG_MUTED_B}|g"   \
        \
        -e "s|{{FG}}|${FG}|g"                       -e "s|{{FG_R}}|${FG_R}|g"               \
        -e "s|{{FG_G}}|${FG_G}|g"                   -e "s|{{FG_B}}|${FG_B}|g"               \
        \
        -e "s|{{ACCENT_LIGHT}}|${ACCENT_LIGHT}|g"   -e "s|{{ACCENT_LIGHT_R}}|${ACCENT_LIGHT_R}|g" \
        -e "s|{{ACCENT_LIGHT_G}}|${ACCENT_LIGHT_G}|g" -e "s|{{ACCENT_LIGHT_B}}|${ACCENT_LIGHT_B}|g" \
        \
        -e "s|{{ACCENT_ALT}}|${ACCENT_ALT}|g"       -e "s|{{ACCENT_ALT_R}}|${ACCENT_ALT_R}|g" \
        -e "s|{{ACCENT_ALT_G}}|${ACCENT_ALT_G}|g"   -e "s|{{ACCENT_ALT_B}}|${ACCENT_ALT_B}|g" \
        \
        -e "s|{{ACCENT}}|${ACCENT}|g"               -e "s|{{ACCENT_R}}|${ACCENT_R}|g"       \
        -e "s|{{ACCENT_G}}|${ACCENT_G}|g"           -e "s|{{ACCENT_B}}|${ACCENT_B}|g"       \
        \
        -e "s|{{URGENT_DARK}}|${URGENT_DARK}|g"     -e "s|{{URGENT_DARK_R}}|${URGENT_DARK_R}|g" \
        -e "s|{{URGENT_DARK_G}}|${URGENT_DARK_G}|g" -e "s|{{URGENT_DARK_B}}|${URGENT_DARK_B}|g" \
        \
        -e "s|{{URGENT}}|${URGENT}|g"               -e "s|{{URGENT_R}}|${URGENT_R}|g"       \
        -e "s|{{URGENT_G}}|${URGENT_G}|g"           -e "s|{{URGENT_B}}|${URGENT_B}|g"       \
        \
        -e "s|{{WARNING}}|${WARNING}|g"             -e "s|{{WARNING_R}}|${WARNING_R}|g"     \
        -e "s|{{WARNING_G}}|${WARNING_G}|g"         -e "s|{{WARNING_B}}|${WARNING_B}|g"     \
        \
        -e "s|{{INFO}}|${INFO}|g"                   -e "s|{{INFO_R}}|${INFO_R}|g"           \
        -e "s|{{INFO_G}}|${INFO_G}|g"               -e "s|{{INFO_B}}|${INFO_B}|g"           \
        \
        -e "s|{{GREEN}}|${GREEN}|g"                 -e "s|{{GREEN_R}}|${GREEN_R}|g"         \
        -e "s|{{GREEN_G}}|${GREEN_G}|g"             -e "s|{{GREEN_B}}|${GREEN_B}|g"         \
        \
        -e "s|{{CYAN_TERM}}|${CYAN_TERM}|g"         -e "s|{{CYAN_TERM_R}}|${CYAN_TERM_R}|g" \
        -e "s|{{CYAN_TERM_G}}|${CYAN_TERM_G}|g"     -e "s|{{CYAN_TERM_B}}|${CYAN_TERM_B}|g" \
        \
        -e "s|{{BORDER1}}|${BORDER1}|g" \
        -e "s|{{BORDER2}}|${BORDER2}|g" \
        -e "s|{{BORDER_INACTIVE}}|${BORDER_INACTIVE}|g" \
        \
        -e "s|{{WALLPAPER}}|${WALLPAPER}|g" \
        "$tpl" > "$out"

    echo "  ✓ $out"
}

# ── Apply all templates ───────────────────────────────────────────────────────
echo ""
echo "Writing config files..."
apply_template "$TEMPLATES_DIR/hypr-colors.lua.tpl"            "$HOME/.config/hypr/hypr-colors.lua"
apply_template "$TEMPLATES_DIR/waybar-colors.css.tpl"          "$HOME/.config/waybar/colors.css"
apply_template "$TEMPLATES_DIR/kitty-colors.conf.tpl"          "$HOME/.config/kitty/kitty-colors.conf"
apply_template "$TEMPLATES_DIR/swaync-style.css.tpl"           "$HOME/.config/swaync/style.css"
apply_template "$TEMPLATES_DIR/rofi-theme.rasi.tpl"            "$HOME/.config/rofi/theme.rasi"
apply_template "$TEMPLATES_DIR/rofi-wallpaper-picker.rasi.tpl" "$HOME/.config/rofi/wallpaper-picker.rasi"
apply_template "$TEMPLATES_DIR/rofi-theme-picker.rasi.tpl"    "$HOME/.config/rofi/theme-picker.rasi"
apply_template "$TEMPLATES_DIR/rofi-clipboard.rasi.tpl"        "$HOME/.config/rofi/clipboard.rasi"
apply_template "$TEMPLATES_DIR/ags-style.css.tpl"              "$HOME/.config/ags/style.css"
apply_template "$TEMPLATES_DIR/fastfetch-config.jsonc.tpl"     "$HOME/.config/fastfetch/config.jsonc"
apply_template "$TEMPLATES_DIR/mako-config.tpl"                "$HOME/.config/mako/config"
apply_template "$TEMPLATES_DIR/hyprlock.conf.tpl"             "$HOME/.config/hypr/hyprlock.conf"

# ── ZSH prompt color ─────────────────────────────────────────────────────────
echo "#${ACCENT}" > "$HOME/.cache/zsh-theme-colors"
echo "  ✓ zsh prompt color updated"

# ── Neovim colorscheme ────────────────────────────────────────────────────────
case "$1" in
    rose-pine-moon) NVIM_SCHEME="rose-pine-moon"     ;;
    dark-nature)    NVIM_SCHEME="catppuccin-mocha"    ;;
    sunset-room)    NVIM_SCHEME="catppuccin-macchiato" ;;
    stargazer)      NVIM_SCHEME="tokyonight-night"    ;;
    *)              NVIM_SCHEME="catppuccin-mocha"    ;;
esac
echo "$NVIM_SCHEME" > "$HOME/.cache/nvim-colorscheme"
echo "  ✓ neovim colorscheme → $NVIM_SCHEME"

# ── Wallpaper ─────────────────────────────────────────────────────────────────
if [[ -f "$WALLPAPER" ]]; then
    echo "  ✓ Setting wallpaper: $(basename "$WALLPAPER")"
    mkdir -p "$HOME/.cache/wallpaper-picker"
    echo "$WALLPAPER" > "$HOME/.cache/wallpaper-picker/.last_wallpaper"
    # Stable symlink the hyprlock background follows (blurred current wallpaper)
    ln -sf "$WALLPAPER" "$HOME/.cache/wallpaper-picker/current"
    if pgrep awww > /dev/null 2>&1; then
        awww img "$WALLPAPER" \
            --transition-type fade \
            --transition-duration 1.5 \
            --transition-fps 60 2>/dev/null || true
    fi
else
    echo "  ⚠ Wallpaper not found: $WALLPAPER"
fi

# ── Reload services ───────────────────────────────────────────────────────────
echo ""
echo "Reloading services..."

# Waybar — reload CSS without restart
if pgrep waybar > /dev/null 2>&1; then
    pkill -SIGUSR2 waybar 2>/dev/null || true
    echo "  ✓ waybar reloaded"
fi

# Kitty — reload config in all running instances
if pgrep -x kitty > /dev/null 2>&1; then
    pkill -SIGUSR1 kitty 2>/dev/null || true
    echo "  ✓ kitty reloaded"
fi

# SwayNC — reload CSS
if pgrep -x swaync > /dev/null 2>&1; then
    swaync-client --reload-css 2>/dev/null || true
    echo "  ✓ swaync reloaded"
fi

# Mako — reload config
if pgrep -x mako > /dev/null 2>&1; then
    makoctl reload 2>/dev/null || true
    echo "  ✓ mako reloaded"
fi

# AGS — full restart required for CSS changes
if pgrep -x ags > /dev/null 2>&1 || dbus-send --session --print-reply \
    --dest=org.freedesktop.DBus /org/freedesktop/DBus \
    org.freedesktop.DBus.GetConnectionUnixProcessID \
    string:"io.Astal.astal" &>/dev/null; then
    sh "$HOME/.config/ags/launch.sh" &
    echo "  ✓ ags restarting"
fi

# Hyprland — reload config for border changes
if command -v hyprctl > /dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl reload 2>/dev/null || true
    echo "  ✓ hyprland reloaded"
fi

echo ""
echo "Theme '$THEME_NAME' applied successfully!"
