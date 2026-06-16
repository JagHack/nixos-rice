#!/bin/bash
TARGET=$1
CURRENT=$(hyprctl activeworkspace -j | jq -r '.id')

if [ "$CURRENT" -eq "$TARGET" ]; then
    hyprctl dispatch 'hl.dsp.focus({workspace="previous"})'
else
    hyprctl dispatch "hl.dsp.focus({workspace=$TARGET})"
fi
