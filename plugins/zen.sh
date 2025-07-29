#!/bin/bash

# Zen mode toggle
zen_on() {
  sketchybar --set apple.logo drawing=off \
             --set '/space\..*/' drawing=off \
             --set space_separator drawing=off \
             --set front_app drawing=off \
             --set volume drawing=off \
             --set battery drawing=off \
             --set cpu.percent drawing=off \
             --set ram.percent drawing=off \
             --set network drawing=off
}

zen_off() {
  sketchybar --set apple.logo drawing=on \
             --set '/space\..*/' drawing=on \
             --set space_separator drawing=on \
             --set front_app drawing=on \
             --set volume drawing=on \
             --set battery drawing=on \
             --set cpu.percent drawing=on \
             --set ram.percent drawing=on \
             --set network drawing=on
}

if [ "$1" = "on" ]; then
  zen_on
elif [ "$1" = "off" ]; then
  zen_off
else
  if [ "$(sketchybar --query apple.logo | jq -r ".geometry.drawing")" = "on" ]; then
    zen_on
  else
    zen_off
  fi
fi