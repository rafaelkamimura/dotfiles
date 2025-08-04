#!/bin/bash

# Smart calendar widget with event integration and meeting preparation
# Supports macOS Calendar app integration via AppleScript

CALENDAR_DIR="$HOME/.config/sketchybar/calendar_data"
EVENTS_CACHE="$CALENDAR_DIR/events_cache"
PREP_CHECKLIST="$CALENDAR_DIR/meeting_prep"

# Create calendar directory if it doesn't exist
mkdir -p "$CALENDAR_DIR"

# Get current date and time information
get_current_datetime() {
    local current_date=$(date "+%m/%d")
    local current_time=$(date "+%I:%M %p")
    local current_day=$(date "+%A")
    local timezone=$(date "+%Z (%z)")
    
    echo "current_date:$current_date|current_time:$current_time|current_day:$current_day|timezone:$timezone"
}

# Get today's events from macOS Calendar
get_todays_events() {
    local today=$(date "+%Y-%m-%d")
    local events_output=""
    
    # Use AppleScript to get events from Calendar app
    events_output=$(osascript << 'EOF'
tell application "Calendar"
    set today to (current date)
    set startOfDay to today - (time of today)
    set endOfDay to startOfDay + (24 * 60 * 60) - 1
    
    set eventList to {}
    repeat with cal in calendars
        try
            set calEvents to (events of cal whose start date ≥ startOfDay and start date ≤ endOfDay)
            set eventList to eventList & calEvents
        end try
    end repeat
    
    set eventStrings to {}
    repeat with evt in eventList
        try
            set eventTime to (start date of evt)
            set eventTitle to (summary of evt)
            set eventLocation to ""
            try
                set eventLocation to (location of evt)
            end try
            
            set timeString to (time string of eventTime)
            set eventString to timeString & "|" & eventTitle & "|" & eventLocation
            set end of eventStrings to eventString
        end try
    end repeat
    
    return my listToString(eventStrings, "\n")
end tell

on listToString(lst, delimiter)
    set text item delimiters to delimiter
    set result to lst as string
    set text item delimiters to ""
    return result
end listToString
EOF
)
    
    # If AppleScript fails, try alternative methods
    if [ -z "$events_output" ] || [[ "$events_output" == *"error"* ]]; then
        # Fallback: try using sqlite to read Calendar database (may require permissions)
        local calendar_db="$HOME/Library/Calendars/Calendar.sqlitedb"
        if [ -f "$calendar_db" ]; then
            # This requires Calendar app permissions and may not work on newer macOS versions
            events_output=$(sqlite3 "$calendar_db" "SELECT datetime(ZSTARTDATE + 978307200, 'unixepoch', 'localtime') as start_time, ZTITLE FROM ZCALENDARITEM WHERE date(ZSTARTDATE + 978307200, 'unixepoch', 'localtime') = date('now', 'localtime') ORDER BY ZSTARTDATE;" 2>/dev/null | sed 's/|/|/g')
        fi
    fi
    
    echo "$events_output"
}

# Get upcoming events (next 7 days)
get_upcoming_events() {
    local upcoming_output=""
    
    upcoming_output=$(osascript << 'EOF'
tell application "Calendar"
    set startDate to (current date)
    set endDate to startDate + (7 * 24 * 60 * 60)
    
    set eventList to {}
    repeat with cal in calendars
        try
            set calEvents to (events of cal whose start date ≥ startDate and start date ≤ endDate)
            set eventList to eventList & calEvents
        end try
    end repeat
    
    set eventStrings to {}
    set eventCount to 0
    repeat with evt in eventList
        if eventCount < 5 then
            try
                set eventTime to (start date of evt)
                set eventTitle to (summary of evt)
                set eventLocation to ""
                try
                    set eventLocation to (location of evt)
                end try
                
                set timeString to (short date string of eventTime) & " " & (time string of eventTime)
                set eventString to timeString & "|" & eventTitle & "|" & eventLocation
                set end of eventStrings to eventString
                set eventCount to eventCount + 1
            end try
        end if
    end repeat
    
    return my listToString(eventStrings, "\n")
end tell

on listToString(lst, delimiter)
    set text item delimiters to delimiter
    set result to lst as string
    set text item delimiters to ""
    return result
end listToString
EOF
)
    
    echo "$upcoming_output"
}

# Get next immediate event
get_next_event() {
    local next_event=""
    local countdown=""
    
    next_event=$(osascript << 'EOF'
tell application "Calendar"
    set now to (current date)
    set futureDate to now + (24 * 60 * 60)  -- Next 24 hours
    
    set nextEvent to ""
    set earliestTime to futureDate
    
    repeat with cal in calendars
        try
            set calEvents to (events of cal whose start date ≥ now and start date ≤ futureDate)
            repeat with evt in calEvents
                try
                    set eventTime to (start date of evt)
                    if eventTime < earliestTime then
                        set earliestTime to eventTime
                        set nextEvent to (summary of evt) & "|" & (time string of eventTime)
                    end if
                end try
            end repeat
        end try
    end repeat
    
    if nextEvent is not "" then
        set timeDiff to (earliestTime - now)
        set minutesUntil to round (timeDiff / 60)
        set nextEvent to nextEvent & "|" & minutesUntil
    end if
    
    return nextEvent
end tell
EOF
)
    
    if [ -n "$next_event" ]; then
        local event_title=$(echo "$next_event" | cut -d'|' -f1)
        local event_time=$(echo "$next_event" | cut -d'|' -f2)
        local minutes_until=$(echo "$next_event" | cut -d'|' -f3)
        
        # Format countdown
        if [ "$minutes_until" -gt 60 ]; then
            local hours=$((minutes_until / 60))
            local remaining_minutes=$((minutes_until % 60))
            countdown="${hours}h ${remaining_minutes}m"
        else
            countdown="${minutes_until}m"
        fi
        
        echo "next_event:$event_title|next_event_time:$event_time|countdown:$countdown|minutes_until:$minutes_until"
    else
        echo "next_event:No upcoming events|next_event_time:--|countdown:--|minutes_until:999"
    fi
}

# Count events for today and this week
count_events() {
    local today_count=0
    local week_count=0
    
    # Today's events
    local todays_events=$(get_todays_events)
    if [ -n "$todays_events" ]; then
        today_count=$(echo "$todays_events" | grep -v '^$' | wc -l | tr -d ' ')
    fi
    
    # This week's events
    week_count=$(osascript << 'EOF'
tell application "Calendar"
    set startOfWeek to (current date) - ((weekday of (current date)) - 1) * days
    set startOfWeek to startOfWeek - (time of startOfWeek)
    set endOfWeek to startOfWeek + (7 * 24 * 60 * 60) - 1
    
    set eventCount to 0
    repeat with cal in calendars
        try
            set calEvents to (events of cal whose start date ≥ startOfWeek and start date ≤ endOfWeek)
            set eventCount to eventCount + (count of calEvents)
        end try
    end repeat
    
    return eventCount
end tell
EOF
)
    
    echo "today_events:$today_count|week_events:${week_count:-0}"
}

# Check meeting preparation status
check_meeting_prep() {
    local next_event_data=$(get_next_event | grep "next_event:")
    local minutes_until=$(echo "$next_event_data" | grep -o "minutes_until:[^|]*" | cut -d':' -f2)
    
    if [ -n "$minutes_until" ] && [ "$minutes_until" -le 30 ] && [ "$minutes_until" -gt 0 ]; then
        # Meeting in next 30 minutes - check preparation
        local prep_status="Ready"
        
        # Check if it's a video call (contains common meeting keywords)
        local event_title=$(echo "$next_event_data" | grep -o "next_event:[^|]*" | cut -d':' -f2)
        if [[ "$event_title" == *"Zoom"* ]] || [[ "$event_title" == *"Teams"* ]] || [[ "$event_title" == *"Meet"* ]] || [[ "$event_title" == *"Call"* ]]; then
            # Check basic prep items
            local camera_status=$(system_profiler SPCameraDataType 2>/dev/null | grep -c "Camera")
            local audio_input=$(system_profiler SPAudioDataType 2>/dev/null | grep -c "Built-in Microphone")
            
            if [ "$camera_status" -eq 0 ] || [ "$audio_input" -eq 0 ]; then
                prep_status="Needs attention"
            fi
            
            # Check if Do Not Disturb is on (simplified check)
            local dnd_status=$(defaults read ~/Library/Preferences/ByHost/com.apple.notificationcenterui.* doNotDisturb 2>/dev/null || echo "0")
            if [ "$dnd_status" -eq 0 ]; then
                prep_status="Needs attention"
            fi
        fi
        
        echo "prep_status:$prep_status"
    else
        echo "prep_status:Ready"
    fi
}

# Send meeting reminders
send_meeting_reminders() {
    local next_event_data=$(get_next_event)
    local minutes_until=$(echo "$next_event_data" | grep -o "minutes_until:[^|]*" | cut -d':' -f2)
    
    if [ -n "$minutes_until" ]; then
        # Send reminders at 15, 5, and 1 minute intervals
        if [ "$minutes_until" -eq 15 ] || [ "$minutes_until" -eq 5 ] || [ "$minutes_until" -eq 1 ]; then
            local event_title=$(echo "$next_event_data" | grep -o "next_event:[^|]*" | cut -d':' -f2)
            
            sketchybar --trigger meeting_reminder \
                       event_title="$event_title" \
                       minutes_until="$minutes_until"
        fi
    fi
}

# Get daily schedule summary
get_daily_summary() {
    local busy_hours=0
    local meeting_count=0
    local free_hours=8
    
    # Simplified calculation based on event count
    local todays_events=$(get_todays_events)
    if [ -n "$todays_events" ]; then
        meeting_count=$(echo "$todays_events" | grep -v '^$' | wc -l | tr -d ' ')
        
        # Estimate busy hours (assume 1 hour per meeting)
        busy_hours=$meeting_count
        free_hours=$((8 - busy_hours))
        
        if [ $free_hours -lt 0 ]; then
            free_hours=0
        fi
    fi
    
    echo "busy_hours:$busy_hours|free_hours:$free_hours|meeting_count:$meeting_count"
}

# Show hover information
show_hover_info() {
    local next_event_data=$(get_next_event)
    local next_event=$(echo "$next_event_data" | grep -o "next_event:[^|]*" | cut -d':' -f2)
    local countdown=$(echo "$next_event_data" | grep -o "countdown:[^|]*" | cut -d':' -f2)
    
    local message="Next: $next_event"
    if [ "$countdown" != "--" ]; then
        message="$message in $countdown"
    fi
    
    osascript -e "display notification \"$message\" with title \"Calendar Update\""
}

# Update calendar display
update_calendar_display() {
    # Get all data
    local datetime_data=$(get_current_datetime)
    local next_event_data=$(get_next_event)
    local event_counts=$(count_events)
    local prep_status=$(check_meeting_prep)
    local daily_summary=$(get_daily_summary)
    
    # Parse datetime data
    local current_date=$(echo "$datetime_data" | grep -o 'current_date:[^|]*' | cut -d':' -f2)
    local current_time=$(echo "$datetime_data" | grep -o 'current_time:[^|]*' | cut -d':' -f2)
    local current_day=$(echo "$datetime_data" | grep -o 'current_day:[^|]*' | cut -d':' -f2)
    local timezone=$(echo "$datetime_data" | grep -o 'timezone:[^|]*' | cut -d':' -f2)
    
    # Parse next event data
    local next_event=$(echo "$next_event_data" | grep -o 'next_event:[^|]*' | cut -d':' -f2)
    local next_event_time=$(echo "$next_event_data" | grep -o 'next_event_time:[^|]*' | cut -d':' -f2)
    local countdown=$(echo "$next_event_data" | grep -o 'countdown:[^|]*' | cut -d':' -f2)
    
    # Parse event counts
    local today_events=$(echo "$event_counts" | grep -o 'today_events:[^|]*' | cut -d':' -f2)
    local week_events=$(echo "$event_counts" | grep -o 'week_events:[^|]*' | cut -d':' -f2)
    
    # Parse prep status
    local prep=$(echo "$prep_status" | grep -o 'prep_status:[^|]*' | cut -d':' -f2)
    
    # Update main calendar widget
    sketchybar --trigger calendar_update \
               current_date="$current_date" \
               current_time="$current_time" \
               current_day="$current_day" \
               next_event="$next_event" \
               next_event_time="$next_event_time" \
               countdown="$countdown" \
               prep_status="$prep" \
               today_events="$today_events" \
               week_events="$week_events" \
               timezone="$timezone"
    
    # Update upcoming events
    local upcoming_events=$(get_upcoming_events)
    if [ -n "$upcoming_events" ]; then
        local i=1
        echo "$upcoming_events" | while read -r event_line; do
            if [ -n "$event_line" ] && [ $i -le 5 ]; then
                sketchybar --trigger upcoming_events "event_$i=$event_line"
                i=$((i + 1))
            fi
        done
    fi
    
    # Update daily summary
    local busy_hours=$(echo "$daily_summary" | grep -o 'busy_hours:[^|]*' | cut -d':' -f2)
    local free_hours=$(echo "$daily_summary" | grep -o 'free_hours:[^|]*' | cut -d':' -f2)
    local meeting_count=$(echo "$daily_summary" | grep -o 'meeting_count:[^|]*' | cut -d':' -f2)
    
    sketchybar --trigger daily_summary \
               busy_hours="$busy_hours" \
               free_hours="$free_hours" \
               meeting_count="$meeting_count"
    
    # Check for meeting reminders
    send_meeting_reminders
}

# Handle different actions
case "$1" in
    "init")
        update_calendar_display
        ;;
    "update")
        update_calendar_display
        ;;
    "time_update")
        # Quick time-only update
        local datetime_data=$(get_current_datetime)
        local current_date=$(echo "$datetime_data" | grep -o 'current_date:[^|]*' | cut -d':' -f2)
        
        sketchybar --set widgets.calendar_smart label="$current_date"
        ;;
    "hover")
        show_hover_info
        ;;
    "click")
        if [ "$BUTTON" = "left" ]; then
            # Open Calendar app
            open -a "Calendar"
        elif [ "$BUTTON" = "right" ]; then
            # Open Fantastical if available, otherwise Calendar
            if [ -d "/Applications/Fantastical - Calendar & Tasks.app" ]; then
                open -a "Fantastical - Calendar & Tasks"
            else
                open -a "Calendar"
            fi
        fi
        ;;
    *)
        # Default action
        update_calendar_display
        ;;
esac