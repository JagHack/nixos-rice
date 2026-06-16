#!/usr/bin/env bash
# GPU usage percentage — supports Nvidia, AMD, Intel

get_gpu_usage() {
    # Nvidia via nvidia-smi
    if command -v nvidia-smi &>/dev/null; then
        usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
        if [[ "$usage" =~ ^[0-9]+$ ]]; then
            echo "$usage"
            return
        fi
    fi

    # AMD via sysfs
    for card in /sys/class/drm/card*/device/gpu_busy_percent; do
        [ -f "$card" ] && cat "$card" && return
    done

    # Intel via sysfs render engine busy %
    for card in /sys/class/drm/renderD*/; do
        busy="/sys/kernel/debug/dri/0/i915_frequency_info"
        [ -f "$busy" ] && break
    done

    echo "0"
}

usage=$(get_gpu_usage)
usage=${usage:-0}
echo "{\"text\": \"󰢮 ${usage}%\", \"tooltip\": \"${usage}%\", \"percentage\": ${usage}}"
