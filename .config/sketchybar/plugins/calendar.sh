#!/bin/bash

# Enhanced calendar widget with better date formatting
case "$SENDER" in
  "mouse.entered")
    # Show full date with day of week on hover
    FULL_DATE=$(date '+%A, %B %d')
    EVENTS_COUNT=$(osascript -e "
    tell application \"Calendar\"
        set todayEvents to {}
        repeat with cal in calendars
            set calEvents to (every event of cal whose start date ≥ (current date) and start date < ((current date) + 1 * days))
            set todayEvents to todayEvents & calEvents
        end repeat
        return length of todayEvents
    end tell
    " 2>/dev/null)
    
    if [ "$EVENTS_COUNT" -gt 0 ]; then
        LABEL="$FULL_DATE • $EVENTS_COUNT events"
    else
        LABEL="$FULL_DATE • No events"
    fi
    
    sketchybar --set $NAME label="$LABEL"
    ;;
  "mouse.exited")
    # Show compact date normally
    DAY_OF_WEEK=$(date '+%a')
    DATE_NUM=$(date '+%d')
    MONTH=$(date '+%b')
    
    LABEL="$DAY_OF_WEEK $DATE_NUM $MONTH"
    
    sketchybar --set $NAME label="$LABEL"
    ;;
  *)
    # Default display - compact but informative
    DAY_OF_WEEK=$(date '+%a')
    DATE_NUM=$(date '+%d')
    MONTH=$(date '+%b')
    
    LABEL="$DAY_OF_WEEK $DATE_NUM $MONTH"
    
    sketchybar --set $NAME icon="📅" \
                          label="$LABEL"
    ;;
esac