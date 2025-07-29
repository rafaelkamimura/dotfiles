#!/bin/bash

# Enhanced time group with pulsing and contextual effects
case "$SENDER" in
  "mouse.entered")
    # Get time of day for contextual colors
    HOUR=$(date +%H)
    
    if [ $HOUR -ge 6 ] && [ $HOUR -lt 12 ]; then
        # Morning - warm yellow
        BG_COLOR=0xfff9e2af
        BORDER_COLOR=0xffffffff
        SHADOW_COLOR=0xaaf9e2af
    elif [ $HOUR -ge 12 ] && [ $HOUR -lt 18 ]; then
        # Afternoon - bright blue
        BG_COLOR=0xff74c7ec
        BORDER_COLOR=0xffffffff
        SHADOW_COLOR=0xaa74c7ec
    elif [ $HOUR -ge 18 ] && [ $HOUR -lt 22 ]; then
        # Evening - orange
        BG_COLOR=0xfffab387
        BORDER_COLOR=0xffffffff
        SHADOW_COLOR=0xaafab387
    else
        # Night - purple
        BG_COLOR=0xffcba6f7
        BORDER_COLOR=0xffffffff
        SHADOW_COLOR=0xaacba6f7
    fi
    
    sketchybar --animate elastic 30 \
               --set time_group background.color=$BG_COLOR \
                                background.height=38 \
                                background.border_color=$BORDER_COLOR \
                                background.border_width=4 \
                                background.shadow.distance=15 \
                                background.shadow.color=$SHADOW_COLOR
    ;;
  "mouse.exited")
    sketchybar --animate elastic 30 \
               --set time_group background.color=0xff89b4fa \
                                background.height=30 \
                                background.border_color=0xff74c7ec \
                                background.border_width=3 \
                                background.shadow.distance=10 \
                                background.shadow.color=0xaa89b4fa
    ;;
  "system_woke")
    # Subtle pulse when system wakes up
    sketchybar --animate elastic 20 \
               --set time_group background.height=32 \
                                background.shadow.distance=12
    sleep 0.3
    sketchybar --animate elastic 20 \
               --set time_group background.height=30 \
                                background.shadow.distance=10
    ;;
esac