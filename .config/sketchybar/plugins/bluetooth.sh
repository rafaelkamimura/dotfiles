#!/bin/bash

# Bluetooth status and connected devices
BT_STATUS=$(system_profiler SPBluetoothDataType 2>/dev/null | grep "Bluetooth Power" | awk '{print $3}')

if [ "$BT_STATUS" = "On" ]; then
    # Get connected devices
    CONNECTED_DEVICES=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -A 20 "Connected:" | grep -E "^\s+[A-Za-z]" | head -3 | wc -l | tr -d ' ')
    
    if [ "$CONNECTED_DEVICES" -gt 0 ]; then
        ICON="󰂯"
        COLOR=0xffa6da95  # Green
        LABEL="$CONNECTED_DEVICES"
    else
        ICON="󰂲"
        COLOR=0xffeed49f  # Yellow
        LABEL="On"
    fi
else
    ICON="󰂲"
    COLOR=0xff939ab7  # Grey
    LABEL="Off"
fi

sketchybar --set $NAME icon="$ICON" \
                      label="$LABEL" \
                      icon.color=$COLOR