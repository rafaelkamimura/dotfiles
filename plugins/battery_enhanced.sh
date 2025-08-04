#!/bin/bash

# Enhanced battery monitoring with health metrics and power consumption trends

BATTERY_DIR="$HOME/.config/sketchybar/battery_data"
POWER_LOG="$BATTERY_DIR/power_history"

# Create battery directory if it doesn't exist
mkdir -p "$BATTERY_DIR"

# Get detailed battery information
get_battery_info() {
    # Use system_profiler for detailed battery info
    local battery_info=$(system_profiler SPPowerDataType 2>/dev/null)
    local pmset_info=$(pmset -g batt 2>/dev/null)
    
    # Basic battery percentage and charging status
    local percentage=$(echo "$pmset_info" | grep -Eo "\d+%" | cut -d% -f1)
    local charging=$(echo "$pmset_info" | grep -c "AC Power")
    
    # Default values
    local health_status="Normal"
    local cycle_count="0"
    local max_capacity="100"
    local temperature="35"
    local power_watts="5.0"
    local time_remaining="??:??"
    local power_source="Battery"
    
    if [ -n "$battery_info" ]; then
        # Extract health status
        health_status=$(echo "$battery_info" | grep "Condition:" | awk -F': ' '{print $2}' | head -1)
        if [ -z "$health_status" ]; then
            health_status="Normal"
        fi
        
        # Extract cycle count
        cycle_count=$(echo "$battery_info" | grep "Cycle Count:" | awk -F': ' '{print $2}' | head -1)
        if [ -z "$cycle_count" ]; then
            cycle_count="0"
        fi
        
        # Extract maximum capacity
        max_capacity=$(echo "$battery_info" | grep "Maximum Capacity:" | awk -F': ' '{print $2}' | sed 's/%//' | head -1)
        if [ -z "$max_capacity" ]; then
            max_capacity="100"
        fi
    fi
    
    # Get power consumption (Apple Silicon Macs)
    if command -v powermetrics >/dev/null 2>&1; then
        local power_output=$(timeout 3 sudo powermetrics -n 1 -i 1000 --samplers cpu_power,gpu_power 2>/dev/null)
        if [ -n "$power_output" ]; then
            power_watts=$(echo "$power_output" | grep "Power:" | awk '{sum += $2} END {printf "%.1f", sum/1000}')
        fi
    fi
    
    # Fallback power estimation based on CPU usage
    if [ -z "$power_watts" ] || [ "$power_watts" = "0.0" ]; then
        local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
        if [ -n "$cpu_usage" ]; then
            power_watts=$(echo "scale=1; 5 + ($cpu_usage * 0.1)" | bc -l 2>/dev/null)
        else
            power_watts="5.0"
        fi
    fi
    
    # Get battery temperature (if available)
    if command -v istats >/dev/null 2>&1; then
        temperature=$(istats battery temp --value-only 2>/dev/null | cut -d'.' -f1)
    else
        # Estimate temperature based on power consumption
        local power_num=$(echo "$power_watts" | cut -d'.' -f1)
        if [ "$power_num" -gt 15 ]; then
            temperature="42"
        elif [ "$power_num" -gt 10 ]; then
            temperature="38"
        else
            temperature="35"
        fi
    fi
    
    # Calculate time remaining
    if [ "$charging" -gt 0 ]; then
        # Charging
        local charge_time=$(echo "$pmset_info" | grep -o "([^)]*)" | head -1 | tr -d '()')
        if [[ "$charge_time" =~ ^[0-9]+:[0-9]+$ ]]; then
            time_remaining="$charge_time"
            power_source="AC Power"
        else
            time_remaining="Calculating..."
            power_source="AC Power"
        fi
    else
        # Discharging
        local discharge_time=$(echo "$pmset_info" | grep -o "([^)]*)" | head -1 | tr -d '()')
        if [[ "$discharge_time" =~ ^[0-9]+:[0-9]+$ ]]; then
            time_remaining="$discharge_time"
        else
            # Estimate based on percentage and power consumption
            if [ "$percentage" -gt 0 ] && [ "${power_watts%.*}" -gt 0 ]; then
                local remaining_wh=$(echo "scale=2; $percentage * 0.5" | bc -l 2>/dev/null) # Rough estimate
                local hours=$(echo "scale=1; $remaining_wh / $power_watts" | bc -l 2>/dev/null)
                local hours_int=$(echo "$hours" | cut -d'.' -f1)
                local minutes=$(echo "scale=0; ($hours - $hours_int) * 60" | bc -l 2>/dev/null)
                time_remaining=$(printf "%02d:%02d" "${hours_int:-0}" "${minutes:-0}")
            else
                time_remaining="??:??"
            fi
        fi
        power_source="Battery"
    fi
    
    # Determine if charging
    local is_charging="false"
    if [ "$charging" -gt 0 ]; then
        is_charging="true"
    fi
    
    # Log power consumption for trend analysis
    local current_time=$(date +%s)
    echo "$current_time:$power_watts" >> "$POWER_LOG"
    
    # Keep only last 100 entries
    tail -100 "$POWER_LOG" > "$POWER_LOG.tmp" && mv "$POWER_LOG.tmp" "$POWER_LOG"
    
    # Return all data in colon-separated format
    echo "${percentage:-50}:$is_charging:$health_status:$cycle_count:$temperature:$power_watts:$time_remaining:$max_capacity:$power_source"
}

# Check for low battery and send warnings
check_battery_warnings() {
    local percentage=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
    local charging=$(pmset -g batt | grep -c "AC Power")
    
    if [ "$charging" -eq 0 ] && [ -n "$percentage" ]; then
        if [ "$percentage" -le 10 ]; then
            # Critical battery level
            sketchybar --trigger battery_warning level="critical" percentage="$percentage"
            
            # Show system notification
            osascript -e "display notification \"Battery critically low: ${percentage}%\" with title \"Battery Warning\" sound name \"Sosumi\""
            
        elif [ "$percentage" -le 20 ]; then
            # Low battery level
            sketchybar --trigger battery_warning level="low" percentage="$percentage"
        fi
    fi
}

# Show quick battery status on hover
show_hover_info() {
    local info=$(get_battery_info)
    local percentage=$(echo "$info" | cut -d':' -f1)
    local is_charging=$(echo "$info" | cut -d':' -f2)
    local health=$(echo "$info" | cut -d':' -f3)
    local power_watts=$(echo "$info" | cut -d':' -f6)
    
    local status_text="$percentage%"
    if [ "$is_charging" = "true" ]; then
        status_text="$status_text (Charging)"
    else
        status_text="$status_text (${power_watts}W)"
    fi
    
    # Quick notification
    osascript -e "display notification \"$status_text, Health: $health\" with title \"Battery Status\""
}

# Get battery temperature specifically
get_battery_temperature() {
    if command -v istats >/dev/null 2>&1; then
        istats battery temp --value-only 2>/dev/null | cut -d'.' -f1
    else
        # Fallback: estimate based on system activity
        local cpu_temp=$(sudo powermetrics -n 1 -i 1000 --samplers smc 2>/dev/null | grep "CPU die temperature" | awk '{print $4}' | cut -d'.' -f1)
        if [ -n "$cpu_temp" ]; then
            # Battery temp is typically 5-10 degrees lower than CPU
            local battery_temp=$((cpu_temp - 8))
            echo "${battery_temp:-35}"
        else
            echo "35"
        fi
    fi
}

# Optimize power consumption suggestions
get_power_optimization_tips() {
    local power_watts=$(echo "$(get_battery_info)" | cut -d':' -f6)
    local power_num=$(echo "$power_watts" | cut -d'.' -f1)
    
    if [ "$power_num" -gt 15 ]; then
        echo "High power usage detected. Consider:"
        echo "• Reducing screen brightness"
        echo "• Closing unnecessary applications"
        echo "• Enabling Low Power Mode"
    elif [ "$power_num" -gt 10 ]; then
        echo "Moderate power usage. Tips:"
        echo "• Check Activity Monitor for power-hungry apps"
        echo "• Disable unnecessary background processes"
    else
        echo "Power usage is optimal"
    fi
}

# Handle different actions
case "$1" in
    "update")
        info=$(get_battery_info)
        echo "$info"
        check_battery_warnings
        ;;
    "hover")
        show_hover_info
        ;;
    "click")
        if [ "$BUTTON" = "left" ]; then
            # Open System Preferences - Battery
            open "/System/Library/PreferencePanes/EnergySaver.prefPane"
        elif [ "$BUTTON" = "right" ]; then
            # Open Activity Monitor - Energy tab
            open -a "Activity Monitor"
            osascript -e 'tell application "System Events" to tell process "Activity Monitor" to click menu item "Energy" of menu "View" of menu bar 1'
        fi
        ;;
    "temperature")
        get_battery_temperature
        ;;
    "optimize")
        get_power_optimization_tips
        ;;
    *)
        # Default action
        get_battery_info
        ;;
esac