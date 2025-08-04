#!/bin/bash

# Productivity Timer with Pomodoro Technique
# Supports work sessions, short breaks, and long breaks with statistics

TIMER_DIR="$HOME/.config/sketchybar/timer_data"
STATE_FILE="$TIMER_DIR/timer_state"
STATS_FILE="$TIMER_DIR/daily_stats"
LOG_FILE="$TIMER_DIR/timer_log"

# Create timer directory if it doesn't exist
mkdir -p "$TIMER_DIR"

# Default settings (in seconds)
POMODORO_DURATION=1500    # 25 minutes
SHORT_BREAK_DURATION=300  # 5 minutes
LONG_BREAK_DURATION=900   # 15 minutes
LONG_BREAK_INTERVAL=4     # Every 4 pomodoros

# Initialize default state if file doesn't exist
init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        cat > "$STATE_FILE" << EOF
session_type=Pomodoro
time_left=1500
is_running=false
start_time=0
session_count=0
total_sessions_today=0
last_date=$(date +%Y-%m-%d)
EOF
    fi
    
    # Reset daily stats if it's a new day
    local today=$(date +%Y-%m-%d)
    local last_date=$(grep "last_date=" "$STATE_FILE" | cut -d'=' -f2)
    
    if [ "$today" != "$last_date" ]; then
        sed -i '' "s/total_sessions_today=.*/total_sessions_today=0/" "$STATE_FILE"
        sed -i '' "s/last_date=.*/last_date=$today/" "$STATE_FILE"
        sed -i '' "s/session_count=.*/session_count=0/" "$STATE_FILE"
    fi
}

# Read current state
read_state() {
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    else
        init_state
        source "$STATE_FILE"
    fi
}

# Write state to file
write_state() {
    cat > "$STATE_FILE" << EOF
session_type=$session_type
time_left=$time_left
is_running=$is_running
start_time=$start_time
session_count=$session_count
total_sessions_today=$total_sessions_today
last_date=$last_date
EOF
}

# Format time for display
format_time() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local remaining_seconds=$((seconds % 60))
    printf "%02d:%02d" $minutes $remaining_seconds
}

# Calculate progress (0.0 to 1.0)
calculate_progress() {
    local current_time_left=$1
    local total_duration
    
    case "$session_type" in
        "Pomodoro") total_duration=$POMODORO_DURATION ;;
        "Short Break") total_duration=$SHORT_BREAK_DURATION ;;
        "Long Break") total_duration=$LONG_BREAK_DURATION ;;
        *) total_duration=$POMODORO_DURATION ;;
    esac
    
    local elapsed=$((total_duration - current_time_left))
    local progress=$(echo "scale=2; $elapsed / $total_duration" | bc -l 2>/dev/null)
    echo "${progress:-0.00}"
}

# Send timer update to SketchyBar
update_display() {
    local formatted_time=$(format_time $time_left)
    local progress=$(calculate_progress $time_left)
    
    sketchybar --trigger timer_update \
               time_left="$formatted_time" \
               session_type="$session_type" \
               is_running="$is_running" \
               progress="$progress" \
               sessions_today="$total_sessions_today"
}

# Start or pause timer
start_stop_timer() {
    read_state
    
    if [ "$is_running" = "true" ]; then
        # Pause timer
        is_running=false
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        time_left=$((time_left - elapsed))
        
        if [ $time_left -lt 0 ]; then
            time_left=0
        fi
    else
        # Start timer
        is_running=true
        start_time=$(date +%s)
        
        # If time_left is 0, reset to appropriate duration
        if [ $time_left -eq 0 ]; then
            case "$session_type" in
                "Pomodoro") time_left=$POMODORO_DURATION ;;
                "Short Break") time_left=$SHORT_BREAK_DURATION ;;
                "Long Break") time_left=$LONG_BREAK_DURATION ;;
            esac
        fi
    fi
    
    write_state
    update_display
}

# Reset current timer
reset_timer() {
    read_state
    
    is_running=false
    case "$session_type" in
        "Pomodoro") time_left=$POMODORO_DURATION ;;
        "Short Break") time_left=$SHORT_BREAK_DURATION ;;
        "Long Break") time_left=$LONG_BREAK_DURATION ;;
    esac
    
    write_state
    update_display
}

# Skip to next session
skip_session() {
    read_state
    
    # Complete current session and move to next
    complete_session
}

# Complete current session and transition to next
complete_session() {
    read_state
    
    local next_session_type
    local next_duration
    
    if [ "$session_type" = "Pomodoro" ]; then
        # Completed a pomodoro
        session_count=$((session_count + 1))
        total_sessions_today=$((total_sessions_today + 1))
        
        # Determine next session type
        if [ $((session_count % LONG_BREAK_INTERVAL)) -eq 0 ]; then
            next_session_type="Long Break"
            next_duration=$LONG_BREAK_DURATION
        else
            next_session_type="Short Break"
            next_duration=$SHORT_BREAK_DURATION
        fi
        
        # Log completed pomodoro
        echo "$(date): Completed Pomodoro #$session_count" >> "$LOG_FILE"
        
    else
        # Completed a break
        next_session_type="Pomodoro"
        next_duration=$POMODORO_DURATION
        
        # Log completed break
        echo "$(date): Completed $session_type" >> "$LOG_FILE"
    fi
    
    # Update state for next session
    session_type="$next_session_type"
    time_left=$next_duration
    is_running=false
    
    write_state
    
    # Trigger completion notification
    sketchybar --trigger timer_complete \
               session_type="$session_type" \
               next_session="$next_session_type"
    
    update_display
}

# Check if timer should complete (called by background process)
check_timer() {
    read_state
    
    if [ "$is_running" = "true" ]; then
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local remaining=$((time_left - elapsed))
        
        if [ $remaining -le 0 ]; then
            # Timer completed
            time_left=0
            is_running=false
            write_state
            complete_session
        else
            # Update remaining time
            time_left=$remaining
            write_state
            update_display
        fi
    fi
}

# Send completion notification
notify_complete() {
    read_state
    
    local message
    local sound
    
    case "$session_type" in
        "Pomodoro")
            message="Pomodoro completed! Time for a break."
            sound="Glass"
            ;;
        "Short Break")
            message="Break over! Ready for another pomodoro?"
            sound="Bottle"
            ;;
        "Long Break")
            message="Long break finished! Back to work."
            sound="Bottle"
            ;;
    esac
    
    # Play sound
    afplay "/System/Library/Sounds/${sound}.aiff" 2>/dev/null &
    
    # Show notification
    osascript -e "display notification \"$message\" with title \"Productivity Timer\" sound name \"$sound\""
    
    # Optional: Use terminal-notifier if available for better notifications
    if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier -title "Productivity Timer" -message "$message" -sound "$sound"
    fi
}

# Get current state for display
get_state() {
    read_state
    update_display
}

# Show hover preview
hover_preview() {
    read_state
    local progress=$(calculate_progress $time_left)
    local percentage=$(echo "scale=0; $progress * 100" | bc -l 2>/dev/null)
    
    # Quick status notification
    osascript -e "display notification \"${percentage}% complete\" with title \"$session_type Timer\""
}

# Start background timer process
start_background_timer() {
    # Kill existing background timer
    pkill -f "productivity_timer.sh background" 2>/dev/null
    
    # Start new background process
    (
        while true; do
            sleep 1
            "$0" check_timer
        done
    ) &
    
    echo $! > "$TIMER_DIR/timer_pid"
}

# Stop background timer process
stop_background_timer() {
    if [ -f "$TIMER_DIR/timer_pid" ]; then
        local pid=$(cat "$TIMER_DIR/timer_pid")
        kill "$pid" 2>/dev/null
        rm -f "$TIMER_DIR/timer_pid"
    fi
    pkill -f "productivity_timer.sh background" 2>/dev/null
}

# Handle different actions
case "$1" in
    "init")
        init_state
        get_state
        start_background_timer
        ;;
    "start_stop")
        start_stop_timer
        if [ "$is_running" = "true" ]; then
            start_background_timer
        fi
        ;;
    "reset")
        reset_timer
        ;;
    "skip")
        skip_session
        ;;
    "check_timer")
        check_timer
        ;;
    "notify_complete")
        notify_complete
        ;;
    "get_state")
        get_state
        ;;
    "hover_preview")
        hover_preview
        ;;
    "click")
        # Handle general clicks - toggle popup
        ;;
    "background")
        # Background timer loop
        while true; do
            sleep 1
            check_timer
        done
        ;;
    *)
        # Default: initialize and get state
        init_state
        get_state
        ;;
esac