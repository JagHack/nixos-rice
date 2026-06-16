#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  wallpaper-precache.sh  —  Pre-generates thumbnails + the rofi input cache.
#  Run at Hyprland startup. Picker reads the cache file directly — zero loops
#  at launch time, rofi appears instantly.
# ─────────────────────────────────────────────────────────────────────────────

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures}"
CACHE_DIR="$HOME/.cache/wallpaper-picker"
THUMB_SIZE="270x150"
JOBS="$(nproc)"

mkdir -p "$CACHE_DIR"

# ── Collect all images ────────────────────────────────────────────────────────
mapfile -t IMAGES < <(
  find "$WALLPAPER_DIR" \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    | sort
)
[[ ${#IMAGES[@]} -eq 0 ]] && exit 0

# ── Generate thumbnails in parallel (index-based names, no md5sum needed) ────
generate_thumb() {
  local index="$1" img="$2"
  local thumb="$CACHE_DIR/thumb_${index}.png"
  [[ -f "$thumb" ]] && return 0
  convert "$img" \
    -thumbnail "${THUMB_SIZE}^" \
    -gravity center -extent "$THUMB_SIZE" \
    -strip \
    "$thumb" 2>/dev/null || true
}
export -f generate_thumb
export CACHE_DIR THUMB_SIZE

paste <(seq 0 $((${#IMAGES[@]} - 1))) <(printf '%s\n' "${IMAGES[@]}") | \
  xargs -P "$JOBS" -L1 bash -c 'generate_thumb "$1" "$2"' _

# ── Write rofi input cache (label \0 icon \x1f path \x1f) ───────────────────
{
  for i in "${!IMAGES[@]}"; do
    printf '%s\x00icon\x1f%s\x1f\n' \
      "$(basename "${IMAGES[$i]}")" \
      "$CACHE_DIR/thumb_${i}.png"
  done
} > "$CACHE_DIR/rofi-input.cache.tmp"
mv "$CACHE_DIR/rofi-input.cache.tmp" "$CACHE_DIR/rofi-input.cache"

# ── Write label → full path index (for picker to resolve selection) ──────────
{
  for i in "${!IMAGES[@]}"; do
    printf '%s\t%s\n' "$(basename "${IMAGES[$i]}")" "${IMAGES[$i]}"
  done
} > "$CACHE_DIR/label-to-path.tsv"
