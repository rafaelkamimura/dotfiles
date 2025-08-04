#!/bin/bash

# Weather group hover effects
case "$SENDER" in
  "mouse.entered")
    sketchybar --animate elastic 30 \
               --set weather_group background.color=0xff45475a \
                                   background.height=36 \
                                   background.border_width=3 \
                                   background.shadow.distance=12 \
               --set weather_info label="22° Sunny"
    ;;
  "mouse.exited")
    sketchybar --animate elastic 30 \
               --set weather_group background.color=0xff6c7086 \
                                   background.height=30 \
                                   background.border_width=2 \
                                   background.shadow.distance=8 \
               --set weather_info label="22°"
    ;;
esac