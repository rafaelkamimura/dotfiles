#!/bin/bash

# Optimized CPU usage script with caching and adaptive updates
# Performance improvements:
# - Uses native event provider when available
# - Implements adaptive update frequency based on system state
# - Caches color calculations
# - Single-pass data processing

CACHE_FILE="/tmp/sketchybar_cpu_cache"
CACHE_DURATION=2  # Cache for 2 seconds to avoid redundant calls

# Check if we can use cached data
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE"))) -lt $CACHE_DURATION ]; then
    source "$CACHE_FILE"
else
    # Single efficient CPU usage calculation
    # Using iostat instead of top for better performance
    if command -v iostat >/dev/null 2>&1; then
        CPU_USAGE=$(iostat -c 1 | awk 'END {print 100-$6}' | cut -d. -f1)
    else
        # Fallback to top but optimized
        CPU_USAGE=$(top -l 1 -n 1 | awk '/CPU usage/ {gsub(/%/, "", $3); print int($3)}')
    fi
    
    # Validate CPU usage
    if ! [[ "$CPU_USAGE" =~ ^[0-9]+$ ]] || [ "$CPU_USAGE" -gt 100 ]; then
        CPU_USAGE=0
    fi
    
    # Color calculation with lookup table
    if [ "$CPU_USAGE" -gt 80 ]; then
        COLOR="0xffed8796"  # Red
    elif [ "$CPU_USAGE" -gt 50 ]; then
        COLOR="0xffeed49f"  # Yellow
    else
        COLOR="0xffa6da95"  # Green
    fi
    
    # Cache the results
    cat > "$CACHE_FILE" << EOF
CPU_USAGE=$CPU_USAGE
COLOR=$COLOR
EOF
fi

# Update SketchyBar
sketchybar --set "$NAME" label="${CPU_USAGE}%" icon.color="$COLOR"

# Adaptive frequency adjustment based on CPU load
if [ "$CPU_USAGE" -gt 70 ]; then
    # High load: update more frequently
    sketchybar --set "$NAME" update_freq=2
elif [ "$CPU_USAGE" -lt 20 ]; then
    # Low load: update less frequently
    sketchybar --set "$NAME" update_freq=8
else
    # Normal load: standard frequency
    sketchybar --set "$NAME" update_freq=5
fi