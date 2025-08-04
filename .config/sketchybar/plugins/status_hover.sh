#!/bin/bash

# Enhanced status group hover effects with performance indicators
case "$SENDER" in
  "mouse.entered")
    # Get current system load for dynamic colors
    CPU_LOAD=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//' | cut -d. -f1)
    
    if [ "${CPU_LOAD:-50}" -gt 80 ]; then
        HOVER_COLOR=0xfff38ba8  # Red for high load
        BORDER_COLOR=0xfff38ba8
        SHADOW_COLOR=0x80f38ba8
    elif [ "${CPU_LOAD:-50}" -gt 50 ]; then
        HOVER_COLOR=0xfff9e2af  # Yellow for medium load
        BORDER_COLOR=0xfff9e2af
        SHADOW_COLOR=0x80f9e2af
    else
        HOVER_COLOR=0xffa6e3a1  # Green for low load
        BORDER_COLOR=0xffa6e3a1
        SHADOW_COLOR=0x80a6e3a1
    fi
    
    sketchybar --animate elastic 30 \
               --set status_group background.color=$HOVER_COLOR \
                                  background.height=36 \
                                  background.border_color=$BORDER_COLOR \
                                  background.border_width=3 \
                                  background.shadow.distance=12 \
                                  background.shadow.color=$SHADOW_COLOR
    ;;
  "mouse.exited")
    sketchybar --animate elastic 30 \
               --set status_group background.color=0xff313244 \
                                  background.height=30 \
                                  background.border_color=0xfff9e2af \
                                  background.border_width=2 \
                                  background.shadow.distance=8 \
                                  background.shadow.color=0x80f9e2af
    ;;
esac