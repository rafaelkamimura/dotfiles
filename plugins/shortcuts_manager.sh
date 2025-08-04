#!/bin/bash

# Quick shortcuts manager for frequently used applications and system functions

SHORTCUTS_DIR="$HOME/.config/sketchybar/shortcuts_data"
USAGE_LOG="$SHORTCUTS_DIR/usage_log"

# Create shortcuts directory if it doesn't exist
mkdir -p "$SHORTCUTS_DIR"

# Log command usage for analytics
log_usage() {
    local command_type="$1"
    local command_name="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "$timestamp|$command_type|$command_name" >> "$USAGE_LOG"
    
    # Keep only last 1000 entries
    tail -1000 "$USAGE_LOG" > "$USAGE_LOG.tmp" && mv "$USAGE_LOG.tmp" "$USAGE_LOG"
}

# Execute application command
execute_app() {
    local command="$1"
    log_usage "app" "$command"
    
    # Show visual feedback
    osascript -e "display notification \"Opening application...\" with title \"Shortcuts Manager\""
    
    # Execute the command
    eval "$command" &
}

# Execute system command
execute_system() {
    local command="$1"
    log_usage "system" "$command"
    
    # Show confirmation for potentially destructive commands
    if [[ "$command" == *"shutdown"* ]] || [[ "$command" == *"restart"* ]]; then
        local response=$(osascript -e 'display dialog "Are you sure you want to restart your Mac?" buttons {"Cancel", "Restart"} default button "Cancel"')
        
        if [[ "$response" == *"Restart"* ]]; then
            osascript -e "display notification \"Restarting system...\" with title \"System Command\""
            eval "$command"
        fi
    elif [[ "$command" == *"sleep"* ]]; then
        osascript -e "display notification \"Putting system to sleep...\" with title \"System Command\""
        eval "$command"
    else
        # Execute other system commands
        eval "$command" &
        
        # Show feedback based on command type
        if [[ "$command" == *"trash"* ]]; then
            osascript -e "display notification \"Emptying trash...\" with title \"System Command\""
        elif [[ "$command" == *"wifi"* ]]; then
            osascript -e "display notification \"Toggling WiFi...\" with title \"System Command\""
        elif [[ "$command" == *"screenshot"* ]]; then
            osascript -e "display notification \"Taking screenshot to clipboard\" with title \"System Command\""
        elif [[ "$command" == *"displaysleep"* ]]; then
            osascript -e "display notification \"Locking screen...\" with title \"System Command\""
        fi
    fi
}

# Execute quick action
execute_action() {
    local command="$1"
    log_usage "action" "$command"
    
    # Execute and show result for informational commands
    if [[ "$command" == *"ifconfig"* ]]; then
        local ip_address=$(eval "$command")
        osascript -e "display notification \"IP address copied: $ip_address\" with title \"Quick Action\""
        
    elif [[ "$command" == *"AppleShowAllFiles YES"* ]]; then
        eval "$command"
        osascript -e "display notification \"Hidden files are now visible\" with title \"Quick Action\""
        
    elif [[ "$command" == *"AppleShowAllFiles NO"* ]]; then
        eval "$command"
        osascript -e "display notification \"Hidden files are now hidden\" with title \"Quick Action\""
        
    elif [[ "$command" == *"flushcache"* ]]; then
        eval "$command" 2>/dev/null
        osascript -e "display notification \"DNS cache cleared\" with title \"Quick Action\""
        
    elif [[ "$command" == *"powermetrics"* ]]; then
        local temp_output=$(timeout 3 eval "$command" 2>/dev/null | grep "CPU die temperature" | head -1)
        if [ -n "$temp_output" ]; then
            osascript -e "display notification \"$temp_output\" with title \"CPU Temperature\""
        else
            osascript -e "display notification \"Temperature data not available\" with title \"CPU Temperature\""
        fi
        
    elif [[ "$command" == *"df -h"* ]]; then
        local disk_output=$(eval "$command" | grep -E "^/dev/" | head -3 | awk '{print $5 " used on " $1}')
        osascript -e "display notification \"$disk_output\" with title \"Disk Usage\""
        
    else
        # Execute other actions
        eval "$command" &
        osascript -e "display notification \"Action executed\" with title \"Quick Action\""
    fi
}

# Get most used applications for dynamic shortcuts
get_most_used_apps() {
    if [ -f "$USAGE_LOG" ]; then
        local most_used=$(grep "|app|" "$USAGE_LOG" | tail -20 | cut -d'|' -f3 | sort | uniq -c | sort -nr | head -5)
        echo "$most_used"
    fi
}

# Update shortcuts display with usage analytics
update_shortcuts_display() {
    local most_used_apps=$(get_most_used_apps)
    
    sketchybar --trigger shortcuts_update \
               most_used_apps="$most_used_apps"
}

# Show usage statistics
show_usage_stats() {
    if [ -f "$USAGE_LOG" ]; then
        local total_usage=$(wc -l < "$USAGE_LOG" | tr -d ' ')
        local today_usage=$(grep "$(date +%Y-%m-%d)" "$USAGE_LOG" | wc -l | tr -d ' ')
        local most_used_today=$(grep "$(date +%Y-%m-%d)" "$USAGE_LOG" | cut -d'|' -f3 | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
        
        local message="Today: $today_usage commands. Most used: ${most_used_today:-none}. Total: $total_usage"
        osascript -e "display notification \"$message\" with title \"Shortcuts Usage\""
    else
        osascript -e "display notification \"No usage data available\" with title \"Shortcuts Usage\""
    fi
}

# Create custom shortcut
create_custom_shortcut() {
    local shortcut_name=$(osascript -e 'display dialog "Enter shortcut name:" default answer "" with title "Create Custom Shortcut"' 2>/dev/null | grep "text returned:" | cut -d':' -f2)
    local shortcut_command=$(osascript -e 'display dialog "Enter command:" default answer "" with title "Create Custom Shortcut"' 2>/dev/null | grep "text returned:" | cut -d':' -f2)
    
    if [ -n "$shortcut_name" ] && [ -n "$shortcut_command" ]; then
        local shortcuts_file="$SHORTCUTS_DIR/custom_shortcuts"
        echo "$shortcut_name|$shortcut_command" >> "$shortcuts_file"
        osascript -e "display notification \"Custom shortcut '$shortcut_name' created\" with title \"Shortcuts Manager\""
    fi
}

# Execute custom shortcut
execute_custom() {
    local shortcuts_file="$SHORTCUTS_DIR/custom_shortcuts"
    if [ -f "$shortcuts_file" ]; then
        local shortcuts_list=$(cat "$shortcuts_file" | cut -d'|' -f1 | nl -w2 -s'. ')
        local choice=$(osascript -e "display dialog \"Choose custom shortcut:\n$shortcuts_list\" default answer \"1\" with title \"Custom Shortcuts\"" 2>/dev/null | grep "text returned:" | cut -d':' -f2)
        
        if [ -n "$choice" ] && [ "$choice" -gt 0 ]; then
            local selected_command=$(sed -n "${choice}p" "$shortcuts_file" | cut -d'|' -f2)
            if [ -n "$selected_command" ]; then
                log_usage "custom" "$selected_command"
                eval "$selected_command" &
                osascript -e "display notification \"Custom shortcut executed\" with title \"Shortcuts Manager\""
            fi
        fi
    else
        osascript -e "display notification \"No custom shortcuts found\" with title \"Shortcuts Manager\""
    fi
}

# Handle different actions
case "$1" in
    "app")
        execute_app "$2"
        ;;
    "system")
        execute_system "$2"
        ;;
    "action")
        execute_action "$2"
        ;;
    "stats")
        show_usage_stats
        ;;
    "custom")
        execute_custom
        ;;
    "create")
        create_custom_shortcut
        ;;
    "update")
        update_shortcuts_display
        ;;
    "click")
        if [ "$BUTTON" = "right" ]; then
            # Right click shows options menu
            local choice=$(osascript -e 'display dialog "Shortcuts Manager Options:" buttons {"Usage Stats", "Custom Shortcuts", "Create Shortcut", "Cancel"} default button "Cancel"' 2>/dev/null)
            
            if [[ "$choice" == *"Usage Stats"* ]]; then
                show_usage_stats
            elif [[ "$choice" == *"Custom Shortcuts"* ]]; then
                execute_custom
            elif [[ "$choice" == *"Create Shortcut"* ]]; then
                create_custom_shortcut
            fi
        fi
        ;;
    *)
        # Default action
        update_shortcuts_display
        ;;
esac