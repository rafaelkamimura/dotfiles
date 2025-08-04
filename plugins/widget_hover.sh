#!/bin/bash

# Source variables for consistent sizing
source "$HOME/.config/sketchybar/variables.sh"

# Universal hover effects for right-side widgets
case "$SENDER" in
  "mouse.entered")
    sketchybar --animate elastic 20 \
               --set $NAME background.color=0xff45475a \
                           background.height=$((WIDGET_HEIGHT - 4)) \
                           background.border_color=0xff74c7ec \
                           background.border_width=2 \
                           background.shadow.distance=6 \
                           background.shadow.color=0x6074c7ec \
                           icon.color=0xff74c7ec \
                           label.color=0xffffffff
    ;;
  "mouse.exited")
    sketchybar --animate elastic 20 \
               --set $NAME background.color=0xff313244 \
                           background.height=$((WIDGET_HEIGHT - 6)) \
                           background.border_color=0xff45475a \
                           background.border_width=1 \
                           background.shadow.distance=3 \
                           background.shadow.color=0x40000000 \
                           icon.color=0xffcdd6f4 \
                           label.color=0xffcdd6f4
    ;;
esac