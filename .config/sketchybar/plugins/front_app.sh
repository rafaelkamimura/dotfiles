#!/bin/bash

# Enhanced front app with icon
if [ "$SENDER" = "front_app_switched" ]; then
  APP_ICON=$(~/.config/sketchybar/plugins/icon_map.sh "$INFO")
  sketchybar --set $NAME label="$INFO" icon="$APP_ICON"
fi