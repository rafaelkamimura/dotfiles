#!/bin/bash

# System info bracket hover effects
case "$SENDER" in
  "mouse.entered")
    sketchybar --animate elastic 20 \
               --set system_info background.color=0xff45475a \
                                 background.height=32 \
                                 background.border_color=0xff74c7ec \
                                 background.border_width=2 \
                                 background.shadow.distance=6 \
                                 background.shadow.color=0x6074c7ec
    
    # Enhance individual items
    sketchybar --set cpu.percent icon.color=0xfff38ba8 \
                                 label.color=0xffffffff
    sketchybar --set ram.percent icon.color=0xfff9e2af \
                                 label.color=0xffffffff
    ;;
  "mouse.exited")
    sketchybar --animate elastic 20 \
               --set system_info background.color=0xff313244 \
                                 background.height=30 \
                                 background.border_color=0xff45475a \
                                 background.border_width=1 \
                                 background.shadow.distance=3 \
                                 background.shadow.color=0x40000000
    
    # Reset individual items
    sketchybar --set cpu.percent icon.color=0xfff38ba8 \
                                 label.color=0xffcdd6f4
    sketchybar --set ram.percent icon.color=0xfff9e2af \
                                 label.color=0xffcdd6f4
    ;;
esac