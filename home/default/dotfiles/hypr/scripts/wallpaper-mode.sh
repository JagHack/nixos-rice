#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  wallpaper-mode.sh  —  Rofi script-mode handler for the wallpaper picker.
#
#  Rofi script mode protocol:
#    $ROFI_RETV == 0  →  initial call: print entries to stdout
#    $ROFI_RETV == 1  →  entry selected: $1 is the chosen label, set wallpaper
#    $ROFI_RETV == 10-28  →  custom keybindings (unused here)
#
#  Launch with:
#    rofi -show wallpaper -modi "wallpaper:~/.config/hypr/scripts/wallpaper-mode.sh"
# ─────────────────────────────────────────────────────────────────────────────

CACHE_DIR="$HOME/.cache/wallpaper-picker"
ROFI_CACHE="$CACHE_DIR/rofi-input.cache"
LABEL_INDEX="$CACHE_DIR/label-to-path.tsv"
LAST_WALL_FILE="$CACHE_DIR/.last_wallpaper"

TRANSITION_TYPE="wipe"
TRANSITION_DURATION=0.8
TRANSITION_FPS=60

# ── Ensure awww daemon is alive ───────────────────────────────────────────────
ensure_daemon() {
  if ! pgrep -x "awww-daemon" > /dev/null 2>&1; then
    awww-daemon --no-cache &
    sleep 0.5
  fi
}

# ── ROFI_RETV=0 : List entries ───────────────────────────────────────────────
if [[ "${ROFI_RETV:-0}" == "0" ]]; then
  # If cache is missing, regenerate it (first run only — normally done at startup)
  if [[ ! -f "$ROFI_CACHE" ]]; then
    bash "$(dirname "$0")/wallpaper-precache.sh"
  fi
  # Stream the pre-built cache directly — zero loops, zero subprocesses
  cat "$ROFI_CACHE"
  exit 0
fi

# ── ROFI_RETV=1 : Entry selected ─────────────────────────────────────────────
if [[ "${ROFI_RETV:-0}" == "1" ]]; then
  CHOSEN_LABEL="$1"
  [[ -z "$CHOSEN_LABEL" ]] && exit 0

  # Resolve label → full path via TSV index
  CHOSEN_PATH=$(grep -m1 $'^'"${CHOSEN_LABEL//./\\.}"$'\t' "$LABEL_INDEX" | cut -f2) || true

  if [[ -z "$CHOSEN_PATH" ]] || [[ ! -f "$CHOSEN_PATH" ]]; then
    exit 0
  fi

  ensure_daemon

  awww img "$CHOSEN_PATH" \
    --transition-type "$TRANSITION_TYPE" \
    --transition-duration "$TRANSITION_DURATION" \
    --transition-fps "$TRANSITION_FPS" \
    --transition-bezier ".43,1.19,1,.4"

  echo "$CHOSEN_PATH" > "$LAST_WALL_FILE"
  # Keep the hyprlock background (blurred current wallpaper) in sync
  ln -sf "$CHOSEN_PATH" "$CACHE_DIR/current"

  notify-send "Wallpaper changed" "$(basename "$CHOSEN_PATH")" \
    --icon="$CHOSEN_PATH" 2>/dev/null || true
  exit 0
fi
