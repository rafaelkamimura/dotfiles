#!/bin/bash

# Network speed monitoring
INTERFACE=$(route get default | grep interface | awk '{print $2}')

if [ -z "$INTERFACE" ]; then
    sketchybar --set $NAME drawing=off
    exit 0
fi

# Get network stats
STATS_FILE="/tmp/network_stats_$INTERFACE"
CURRENT_TIME=$(date +%s)

# Read current bytes
RX_BYTES=$(netstat -ibn | grep -e "$INTERFACE" | head -1 | awk '{print $7}')
TX_BYTES=$(netstat -ibn | grep -e "$INTERFACE" | head -1 | awk '{print $10}')

if [ -f "$STATS_FILE" ]; then
    # Read previous stats
    PREV_DATA=$(cat "$STATS_FILE")
    PREV_TIME=$(echo "$PREV_DATA" | cut -d' ' -f1)
    PREV_RX=$(echo "$PREV_DATA" | cut -d' ' -f2)
    PREV_TX=$(echo "$PREV_DATA" | cut -d' ' -f3)
    
    # Calculate time difference
    TIME_DIFF=$((CURRENT_TIME - PREV_TIME))
    
    if [ $TIME_DIFF -gt 0 ]; then
        # Calculate speeds in bytes per second
        RX_SPEED=$(((RX_BYTES - PREV_RX) / TIME_DIFF))
        TX_SPEED=$(((TX_BYTES - PREV_TX) / TIME_DIFF))
        
        # Convert to human readable format
        if [ $RX_SPEED -gt 1048576 ]; then
            RX_DISPLAY="$(($RX_SPEED / 1048576))MB/s"
        elif [ $RX_SPEED -gt 1024 ]; then
            RX_DISPLAY="$(($RX_SPEED / 1024))KB/s"
        else
            RX_DISPLAY="${RX_SPEED}B/s"
        fi
        
        if [ $TX_SPEED -gt 1048576 ]; then
            TX_DISPLAY="$(($TX_SPEED / 1048576))MB/s"
        elif [ $TX_SPEED -gt 1024 ]; then
            TX_DISPLAY="$(($TX_SPEED / 1024))KB/s"
        else
            TX_DISPLAY="${TX_SPEED}B/s"
        fi
        
        sketchybar --set $NAME icon="󰓅" \
                          label="↓$RX_DISPLAY ↑$TX_DISPLAY"
    fi
fi

# Save current stats
echo "$CURRENT_TIME $RX_BYTES $TX_BYTES" > "$STATS_FILE"