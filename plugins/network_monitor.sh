#!/bin/bash

# Enhanced network monitoring with real-time speed tracking and connection quality

NETWORK_DIR="$HOME/.config/sketchybar/network_data"
SPEED_FILE="$NETWORK_DIR/speed_data"
USAGE_FILE="$NETWORK_DIR/daily_usage"

# Create network directory if it doesn't exist
mkdir -p "$NETWORK_DIR"

# Get primary network interface
get_primary_interface() {
    # Get the interface used for the default route
    route get default 2>/dev/null | grep interface | awk '{print $2}' | head -1
}

# Get network interface statistics
get_interface_stats() {
    local interface="$1"
    if [ -n "$interface" ]; then
        netstat -ibn | grep "^$interface" | head -1
    fi
}

# Calculate network speeds
calculate_speeds() {
    local interface=$(get_primary_interface)
    
    if [ -z "$interface" ]; then
        echo "0:0:KB/s:KB/s"
        return
    fi
    
    local current_stats=$(get_interface_stats "$interface")
    local current_time=$(date +%s)
    
    if [ -z "$current_stats" ]; then
        echo "0:0:KB/s:KB/s"
        return
    fi
    
    # Extract bytes in and bytes out
    local bytes_in=$(echo "$current_stats" | awk '{print $7}')
    local bytes_out=$(echo "$current_stats" | awk '{print $10}')
    
    # Read previous values
    if [ -f "$SPEED_FILE" ]; then
        local prev_data=$(cat "$SPEED_FILE")
        local prev_time=$(echo "$prev_data" | cut -d':' -f1)
        local prev_bytes_in=$(echo "$prev_data" | cut -d':' -f2)
        local prev_bytes_out=$(echo "$prev_data" | cut -d':' -f3)
        
        # Calculate time difference
        local time_diff=$((current_time - prev_time))
        
        if [ $time_diff -gt 0 ] && [ $time_diff -lt 10 ]; then
            # Calculate speed (bytes per second)
            local bytes_in_diff=$((bytes_in - prev_bytes_in))
            local bytes_out_diff=$((bytes_out - prev_bytes_out))
            
            # Handle counter wraparound
            if [ $bytes_in_diff -lt 0 ]; then
                bytes_in_diff=0
            fi
            if [ $bytes_out_diff -lt 0 ]; then
                bytes_out_diff=0
            fi
            
            local download_bps=$((bytes_in_diff / time_diff))
            local upload_bps=$((bytes_out_diff / time_diff))
            
            # Convert to appropriate units
            local download_speed download_unit
            local upload_speed upload_unit
            
            if [ $download_bps -gt 1048576 ]; then
                download_speed=$(echo "scale=1; $download_bps / 1048576" | bc -l 2>/dev/null)
                download_unit="MB/s"
            elif [ $download_bps -gt 1024 ]; then
                download_speed=$(echo "scale=1; $download_bps / 1024" | bc -l 2>/dev/null)
                download_unit="KB/s"
            else
                download_speed="$download_bps"
                download_unit="B/s"
            fi
            
            if [ $upload_bps -gt 1048576 ]; then
                upload_speed=$(echo "scale=1; $upload_bps / 1048576" | bc -l 2>/dev/null)
                upload_unit="MB/s"
            elif [ $upload_bps -gt 1024 ]; then
                upload_speed=$(echo "scale=1; $upload_bps / 1024" | bc -l 2>/dev/null)
                upload_unit="KB/s"
            else
                upload_speed="$upload_bps"
                upload_unit="B/s"
            fi
            
            echo "${upload_speed:-0}:${download_speed:-0}:$upload_unit:$download_unit"
        else
            echo "0:0:KB/s:KB/s"
        fi
    else
        echo "0:0:KB/s:KB/s"
    fi
    
    # Save current stats for next calculation
    echo "$current_time:$bytes_in:$bytes_out" > "$SPEED_FILE"
}

# Get WiFi signal strength
get_wifi_signal() {
    local interface=$(get_primary_interface)
    
    if [[ "$interface" =~ ^en[0-9]+$ ]]; then
        # WiFi interface
        local signal_info=$(airport -I 2>/dev/null)
        if [ -n "$signal_info" ]; then
            local rssi=$(echo "$signal_info" | grep " RSSI:" | awk '{print $2}')
            local noise=$(echo "$signal_info" | grep " noise:" | awk '{print $2}')
            
            if [ -n "$rssi" ] && [ -n "$noise" ]; then
                # Convert RSSI to percentage (rough approximation)
                # RSSI ranges from about -30 (excellent) to -90 (poor)
                local signal_percent=$(echo "scale=0; (($rssi + 90) * 100) / 60" | bc -l 2>/dev/null)
                
                # Clamp to 0-100 range
                if [ "${signal_percent%.*}" -lt 0 ]; then
                    signal_percent=0
                elif [ "${signal_percent%.*}" -gt 100 ]; then
                    signal_percent=100
                fi
                
                echo "${signal_percent:-50}"
            else
                echo "50"  # Default moderate signal
            fi
        else
            echo "0"  # No WiFi info available
        fi
    else
        echo "100"  # Ethernet connection - assume full signal
    fi
}

# Get connection type
get_connection_type() {
    local interface=$(get_primary_interface)
    
    if [ -z "$interface" ]; then
        echo "Disconnected"
        return
    fi
    
    case "$interface" in
        en0|en1) 
            # Check if it's WiFi or Ethernet
            if networksetup -getairportnetwork "$interface" >/dev/null 2>&1; then
                echo "WiFi"
            else
                echo "Ethernet"
            fi
            ;;
        bridge*|utun*|ipsec*)
            echo "VPN"
            ;;
        *)
            echo "Other"
            ;;
    esac
}

# Get IP address
get_ip_address() {
    local interface=$(get_primary_interface)
    
    if [ -n "$interface" ]; then
        ifconfig "$interface" 2>/dev/null | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -1
    else
        echo "N/A"
    fi
}

# Test ping latency
get_ping_latency() {
    # Quick ping test to a reliable server
    local ping_result=$(ping -c 1 -W 2000 8.8.8.8 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}' | cut -d. -f1)
    
    if [ -n "$ping_result" ] && [ "$ping_result" -gt 0 ]; then
        echo "$ping_result"
    else
        # Fallback ping test
        local ping_result2=$(ping -c 1 -W 2000 1.1.1.1 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}' | cut -d. -f1)
        echo "${ping_result2:-999}"
    fi
}

# Calculate daily data usage
get_daily_usage() {
    local interface=$(get_primary_interface)
    local today=$(date +%Y-%m-%d)
    
    if [ -z "$interface" ]; then
        echo "0 MB"
        return
    fi
    
    local current_stats=$(get_interface_stats "$interface")
    if [ -z "$current_stats" ]; then
        echo "0 MB"
        return
    fi
    
    local bytes_in=$(echo "$current_stats" | awk '{print $7}')
    local bytes_out=$(echo "$current_stats" | awk '{print $10}')
    local total_bytes=$((bytes_in + bytes_out))
    
    # Check if we have data for today
    if [ -f "$USAGE_FILE" ]; then
        local stored_date=$(head -1 "$USAGE_FILE" | cut -d':' -f1)
        local stored_start_bytes=$(head -1 "$USAGE_FILE" | cut -d':' -f2)
        
        if [ "$stored_date" = "$today" ]; then
            # Same day, calculate difference
            local usage_bytes=$((total_bytes - stored_start_bytes))
            
            # Handle counter reset
            if [ $usage_bytes -lt 0 ]; then
                usage_bytes=$total_bytes
            fi
            
            # Convert to MB
            local usage_mb=$(echo "scale=0; $usage_bytes / 1048576" | bc -l 2>/dev/null)
            echo "${usage_mb:-0} MB"
        else
            # New day, reset counter
            echo "$today:$total_bytes" > "$USAGE_FILE"
            echo "0 MB"
        fi
    else
        # First time, initialize
        echo "$today:$total_bytes" > "$USAGE_FILE"
        echo "0 MB"
    fi
}

# Check if connected to network
is_connected() {
    local interface=$(get_primary_interface)
    
    if [ -n "$interface" ]; then
        # Check if interface is up and has an IP
        local ip=$(get_ip_address)
        if [ "$ip" != "N/A" ] && [ -n "$ip" ]; then
            echo "true"
        else
            echo "false"
        fi
    else
        echo "false"
    fi
}

# Main update function
update_network() {
    local speeds=$(calculate_speeds)
    local upload_speed=$(echo "$speeds" | cut -d':' -f1)
    local download_speed=$(echo "$speeds" | cut -d':' -f2)
    local upload_unit=$(echo "$speeds" | cut -d':' -f3)
    local download_unit=$(echo "$speeds" | cut -d':' -f4)
    
    local connection_type=$(get_connection_type)
    local signal_strength=$(get_wifi_signal)
    local connected=$(is_connected)
    local ip_address=$(get_ip_address)
    local ping_latency=$(get_ping_latency)
    local data_usage=$(get_daily_usage)
    
    # Update SketchyBar
    sketchybar --trigger network_update \
               upload_speed="$upload_speed" \
               download_speed="$download_speed" \
               upload_unit="$upload_unit" \
               download_unit="$download_unit" \
               connection_type="$connection_type" \
               signal_strength="$signal_strength" \
               is_connected="$connected" \
               ip_address="$ip_address" \
               ping_latency="$ping_latency" \
               data_usage_today="$data_usage"
}

# Handle different actions
case "$1" in
    "init")
        # Initialize speed tracking
        calculate_speeds >/dev/null
        update_network
        ;;
    "update")
        update_network
        ;;
    "click")
        # Handle click events
        if [ "$BUTTON" = "left" ]; then
            # Open Network preferences
            open "/System/Library/PreferencePanes/Network.prefPane"
        elif [ "$BUTTON" = "right" ]; then
            # Open Network Utility
            open -a "Network Utility"
        fi
        ;;
    *)
        # Default action
        update_network
        ;;
esac