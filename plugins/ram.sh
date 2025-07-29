#!/bin/bash

# Enhanced RAM usage
MEMORY_PRESSURE=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print 100-$5}' | sed 's/%//' 2>/dev/null)

if [ -z "$MEMORY_PRESSURE" ]; then
    # Fallback method
    MEMORY_PRESSURE=$(vm_stat | awk '
    /Pages free/ { free = $3 }
    /Pages active/ { active = $3 }
    /Pages inactive/ { inactive = $3 }
    /Pages speculative/ { speculative = $3 }
    /Pages wired down/ { wired = $4 }
    END {
        total = free + active + inactive + speculative + wired
        used = total - free
        printf "%.0f", (used / total) * 100
    }')
fi

# Color based on usage
if (( $(echo "$MEMORY_PRESSURE > 80" | bc -l) )); then
    COLOR=0xffed8796  # Red
elif (( $(echo "$MEMORY_PRESSURE > 60" | bc -l) )); then
    COLOR=0xffeed49f  # Yellow
else
    COLOR=0xffa6da95  # Green
fi

sketchybar --set $NAME label="${MEMORY_PRESSURE}%" \
                      icon.color=$COLOR