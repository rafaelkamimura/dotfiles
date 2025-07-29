#!/bin/bash

# Dramatic click animation for Apple logo
sketchybar --animate elastic 20 \
           --set apple.logo background.height=34 \
                            background.shadow.distance=6 \
                            icon.font="SF Pro:Black:22.0"

sleep 0.1

sketchybar --animate elastic 20 \
           --set apple.logo background.height=30 \
                            background.shadow.distance=3 \
                            icon.font="SF Pro:Black:20.0"

# Toggle popup
if [ "$(sketchybar --query apple.logo | jq -r '.popup.drawing')" = "on" ]; then
  sketchybar --set apple.logo popup.drawing=off
else
  sketchybar --set apple.logo popup.drawing=on
fi