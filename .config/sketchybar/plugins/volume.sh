#!/bin/bash

# Felix-style volume
VOLUME=$(osascript -e "output volume of (get volume settings)")

if [ "$VOLUME" -eq 0 ]; then
    ICON="󰸈"
elif [ "$VOLUME" -lt 30 ]; then
    ICON="󰕿"
elif [ "$VOLUME" -lt 70 ]; then
    ICON="󰖀"
else
    ICON="󰕾"
fi

sketchybar --set $NAME icon="$ICON" label="$VOLUME%"