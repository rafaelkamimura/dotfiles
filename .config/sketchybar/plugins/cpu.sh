#!/bin/bash

# Enhanced CPU usage
CPU_USAGE=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')

if [ -z "$CPU_USAGE" ]; then
    CPU_USAGE="0"
fi

# Color based on usage
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    COLOR=0xffed8796  # Red
elif (( $(echo "$CPU_USAGE > 50" | bc -l) )); then
    COLOR=0xffeed49f  # Yellow
else
    COLOR=0xffa6da95  # Green
fi

sketchybar --set $NAME label="${CPU_USAGE}%" \
                      icon.color=$COLOR