#!/bin/sh
pid=$(dbus-send --session --print-reply --dest=org.freedesktop.DBus \
    /org/freedesktop/DBus org.freedesktop.DBus.GetConnectionUnixProcessID \
    string:"io.Astal.astal" 2>/dev/null | awk '/uint32/ {print $2}')
[ -n "$pid" ] && kill -9 "$pid" && sleep 0.2

exec env GI_TYPELIB_PATH=/run/current-system/sw/lib/girepository-1.0 \
         GSETTINGS_SCHEMA_DIR="$HOME/.config/ags/schemas" \
         ags run "$HOME/.config/ags/app.ts"
