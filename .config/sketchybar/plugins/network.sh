#!/bin/bash

# Superior network widget with signal strength and speed
get_wifi_info() {
    # Get WiFi interface
    WIFI_INTERFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/ { getline; print $NF }')
    
    # Check if WiFi is on and connected
    WIFI_POWER=$(networksetup -getairportpower "$WIFI_INTERFACE" 2>/dev/null | awk '{print $4}')
    
    if [ "$WIFI_POWER" != "On" ]; then
        echo "OFF|📶|0xffed8796|WiFi Off"
        return
    fi
    
    # Get connection status
    WIFI_STATUS=$(ifconfig "$WIFI_INTERFACE" 2>/dev/null | grep "status:" | awk '{print $2}')
    
    if [ "$WIFI_STATUS" != "active" ]; then
        echo "DISCONNECTED|📶|0xffeed49f|Searching..."
        return
    fi
    
    # Get SSID cleanly
    SSID=$(system_profiler SPAirPortDataType 2>/dev/null | awk '/Current Network Information:/ {getline; getline; print}' | sed 's/.*: //' | head -1)
    
    # Fallback SSID method
    if [ -z "$SSID" ]; then
        SSID_RAW=$(networksetup -getairportnetwork "$WIFI_INTERFACE" 2>/dev/null)
        SSID=$(echo "$SSID_RAW" | sed 's/Current Wi-Fi Network: //' | sed 's/You are not associated.*//' | xargs)
    fi
    
    # Clean up SSID
    if [ -z "$SSID" ] || [[ "$SSID" == *"not associated"* ]] || [[ "$SSID" == *"AirPort"* ]]; then
        SSID="Unknown"
    fi
    
    # Get signal strength
    RSSI=$(system_profiler SPAirPortDataType 2>/dev/null | awk '/Signal \/ Noise:/ {print $4}' | head -1)
    
    # Determine signal strength icon and color
    if [ -n "$RSSI" ] && [ "$RSSI" -gt -50 ]; then
        SIGNAL_ICON="📶"
        COLOR="0xffa6da95"  # Green - Excellent
    elif [ -n "$RSSI" ] && [ "$RSSI" -gt -60 ]; then
        SIGNAL_ICON="📶"
        COLOR="0xffeed49f"  # Yellow - Good
    elif [ -n "$RSSI" ] && [ "$RSSI" -gt -70 ]; then
        SIGNAL_ICON="📶"
        COLOR="0xfff5a97f"  # Orange - Fair
    else
        SIGNAL_ICON="📶"
        COLOR="0xffed8796"  # Red - Poor
    fi
    
    echo "CONNECTED|$SIGNAL_ICON|$COLOR|$SSID"
}

# Get network info
NETWORK_INFO=$(get_wifi_info)
STATUS=$(echo "$NETWORK_INFO" | cut -d'|' -f1)
ICON=$(echo "$NETWORK_INFO" | cut -d'|' -f2)
COLOR=$(echo "$NETWORK_INFO" | cut -d'|' -f3)
LABEL=$(echo "$NETWORK_INFO" | cut -d'|' -f4)

# Handle click events for network management
if [ "$SENDER" = "mouse.clicked" ]; then
    if [ "$BUTTON" = "right" ]; then
        # Right click - toggle WiFi
        if [ "$STATUS" = "OFF" ]; then
            networksetup -setairportpower "$WIFI_INTERFACE" on
        else
            networksetup -setairportpower "$WIFI_INTERFACE" off
        fi
        sleep 1
        # Refresh after toggle
        NETWORK_INFO=$(get_wifi_info)
        STATUS=$(echo "$NETWORK_INFO" | cut -d'|' -f1)
        ICON=$(echo "$NETWORK_INFO" | cut -d'|' -f2)
        COLOR=$(echo "$NETWORK_INFO" | cut -d'|' -f3)
        LABEL=$(echo "$NETWORK_INFO" | cut -d'|' -f4)
    elif [ "$BUTTON" = "left" ]; then
        # Left click - open Network preferences
        open "x-apple.systempreferences:com.apple.preference.network"
    fi
fi

sketchybar --set $NAME icon="$ICON" \
                      label="$LABEL" \
                      icon.color=$COLOR