#!/bin/bash
DIRECTION=${1:-next}

CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')
ACTIVE_ADDR=$(hyprctl activewindow -j | jq -r '.address')

mapfile -t WINDOWS < <(hyprctl clients -j | jq -r --argjson ws "$CURRENT_WS" \
    '[.[] | select(.workspace.id == $ws)] | sort_by(.address) | .[].address')

COUNT=${#WINDOWS[@]}
[ "$COUNT" -le 1 ] && exit 0

CURRENT_IDX=-1
for i in "${!WINDOWS[@]}"; do
    if [ "${WINDOWS[$i]}" = "$ACTIVE_ADDR" ]; then
        CURRENT_IDX=$i
        break
    fi
done

if [ "$DIRECTION" = "next" ]; then
    NEXT_IDX=$(( (CURRENT_IDX + 1) % COUNT ))
else
    NEXT_IDX=$(( (CURRENT_IDX - 1 + COUNT) % COUNT ))
fi

NEXT_ADDR="${WINDOWS[$NEXT_IDX]}"
hyprctl dispatch "hl.dsp.focus({window='address:${NEXT_ADDR}'})"
hyprctl dispatch 'hl.dsp.window.bring_to_top()'
