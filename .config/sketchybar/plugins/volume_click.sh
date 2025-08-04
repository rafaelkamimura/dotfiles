#!/bin/bash

# Volume slider toggle
WIDTH_CHANGE=$(sketchybar --query volume.slider | jq -r ".geometry.drawing")

if [ "$WIDTH_CHANGE" = "off" ]; then
  sketchybar --animate tanh 30 \
             --set volume.slider drawing=on
else
  sketchybar --animate tanh 30 \
             --set volume.slider drawing=off
fi