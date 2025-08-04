#!/bin/bash

case "$SENDER" in
  "mouse.entered")
    sketchybar --animate elastic 25 \
               --set apple.logo background.color=0xff45475a \
                                background.height=32 \
                                background.shadow.distance=5 \
                                icon.color=0xff74c7ec \
                                icon.font="SF Pro:Black:22.0"
    ;;
  "mouse.exited")
    sketchybar --animate elastic 25 \
               --set apple.logo background.color=0xff313244 \
                                background.height=30 \
                                background.shadow.distance=3 \
                                icon.color=0xff89b4fa \
                                icon.font="SF Pro:Black:20.0"
    ;;
esac