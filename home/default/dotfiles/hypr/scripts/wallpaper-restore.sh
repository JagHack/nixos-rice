#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  wallpaper-restore.sh  —  Restore last chosen wallpaper on Hyprland start
#  Source in autostart.lua:  hl.exec_cmd("~/.config/hypr/scripts/wallpaper-restore.sh")
# ─────────────────────────────────────────────────────────────────────────────

LAST_WALL_FILE="$HOME/.cache/wallpaper-picker/.last_wallpaper"
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures}"
FALLBACK=""

mkdir -p "$(dirname "$LAST_WALL_FILE")"

# ── Start awww daemon ────────────────────────────────────────────────────────
if ! pgrep -x "awww-daemon" > /dev/null 2>&1; then
  awww-daemon --no-cache &
  sleep 0.8
fi

# ── Pick wallpaper to restore ────────────────────────────────────────────────
if [[ -f "$LAST_WALL_FILE" ]]; then
  WALL=$(cat "$LAST_WALL_FILE")
  if [[ -f "$WALL" ]]; then
    awww img "$WALL" \
      --transition-type fade \
      --transition-duration 1.5 \
      --transition-fps 60
    exit 0
  fi
fi

# ── Fallback: pick a random wallpaper ───────────────────────────────────────
FALLBACK=$(
  find "$WALLPAPER_DIR" \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    | shuf -n 1
)

if [[ -n "$FALLBACK" ]]; then
  awww img "$FALLBACK" \
    --transition-type fade \
    --transition-duration 1.5 \
    --transition-fps 60
  echo "$FALLBACK" > "$LAST_WALL_FILE"
fi
