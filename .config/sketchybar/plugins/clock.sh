#!/bin/bash

# Enhanced clock with better time display and context
case "$SENDER" in
  "mouse.entered")
    # Show detailed time info on hover
    FULL_TIME=$(date '+%I:%M:%S %p')
    TIMEZONE=$(date '+%Z')
    UPTIME=$(uptime | awk '{print $3}' | sed 's/,//')
    
    # Remove leading zero from hour
    FULL_TIME=$(echo "$FULL_TIME" | sed 's/^0//')
    
    LABEL="$FULL_TIME $TIMEZONE • Up $UPTIME"
    
    sketchybar --set $NAME label="$LABEL"
    ;;
  "mouse.exited")
    # Return to normal display
    HOUR=$(date +%H)
    MINUTE=$(date +%M)
    
    # 12-hour format without leading zero
    TIME_12H=$(date '+%I:%M %p' | sed 's/^0//')
    
    # Time-based contextual icons
    if [ $HOUR -ge 6 ] && [ $HOUR -lt 12 ]; then
        TIME_CONTEXT="☀️ $TIME_12H"
    elif [ $HOUR -ge 12 ] && [ $HOUR -lt 18 ]; then
        TIME_CONTEXT="🌤️ $TIME_12H"
    elif [ $HOUR -ge 18 ] && [ $HOUR -lt 22 ]; then
        TIME_CONTEXT="🌅 $TIME_12H"
    else
        TIME_CONTEXT="🌙 $TIME_12H"
    fi
    
    # Special times
    if [ $HOUR -eq 12 ] && [ $MINUTE -eq 0 ]; then
        TIME_CONTEXT="🕛 Noon"
    elif [ $HOUR -eq 0 ] && [ $MINUTE -eq 0 ]; then
        TIME_CONTEXT="🕛 Midnight"
    fi
    
    sketchybar --set $NAME label="$TIME_CONTEXT"
    ;;
  *)
    # Default display - 12-hour format with context
    HOUR=$(date +%H)
    MINUTE=$(date +%M)
    
    # 12-hour format without leading zero
    TIME_12H=$(date '+%I:%M %p' | sed 's/^0//')
    
    # Time-based contextual icons
    if [ $HOUR -ge 6 ] && [ $HOUR -lt 12 ]; then
        TIME_CONTEXT="☀️ $TIME_12H"
    elif [ $HOUR -ge 12 ] && [ $HOUR -lt 18 ]; then
        TIME_CONTEXT="🌤️ $TIME_12H"
    elif [ $HOUR -ge 18 ] && [ $HOUR -lt 22 ]; then
        TIME_CONTEXT="🌅 $TIME_12H"
    else
        TIME_CONTEXT="🌙 $TIME_12H"
    fi
    
    # Special times
    if [ $HOUR -eq 12 ] && [ $MINUTE -eq 0 ]; then
        TIME_CONTEXT="🕛 Noon"
    elif [ $HOUR -eq 0 ] && [ $MINUTE -eq 0 ]; then
        TIME_CONTEXT="🕛 Midnight"
    fi
    
    sketchybar --set $NAME icon="" \
                         label="$TIME_CONTEXT"
    ;;
esac