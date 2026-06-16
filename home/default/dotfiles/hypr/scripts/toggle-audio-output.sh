#!/usr/bin/env bash

DEVICE_ID=52

routes=$(pw-cli enum-params "$DEVICE_ID" Route 2>/dev/null)

if echo "$routes" | grep -q '"analog-output-headphones"'; then
    wpctl set-route "$DEVICE_ID" 3
    notify-send -i audio-card "Audio Output" "Switched to Line Out"
else
    wpctl set-route "$DEVICE_ID" 4
    notify-send -i audio-headphones "Audio Output" "Switched to Headphones"
fi
