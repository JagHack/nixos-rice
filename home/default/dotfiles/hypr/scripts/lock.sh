#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  lock.sh — launch hyprlock with the TAB key neutralised.
#
#  hyprlock has no per-key ignore option and cannot switch users, so a stray
#  TAB just pollutes the password buffer. We add a *locked* Hyprland bind that
#  swallows TAB (runs a no-op) only for the duration of the lock, then remove
#  it again — so TAB keeps working normally everywhere else. The EXIT trap
#  guarantees the bind is removed even if hyprlock is killed.
# ─────────────────────────────────────────────────────────────────────────────
restore() { hyprctl keyword unbind ",TAB" >/dev/null 2>&1; }
trap restore EXIT

hyprctl keyword bindl ",TAB,exec,true" >/dev/null 2>&1
hyprlock
