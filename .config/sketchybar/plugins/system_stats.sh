#!/bin/bash

# Combined CPU and RAM display
CPU_PERCENT=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
RAM_PERCENT=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print 100-$5}' | sed 's/%//')

# Fallback if commands fail
if [ -z "$CPU_PERCENT" ]; then
    CPU_PERCENT=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
fi

if [ -z "$RAM_PERCENT" ]; then
    RAM_PERCENT=$(vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("%.0f\n", $2 * $size / 1048576) if $1 eq "active" or $1 eq "inactive" or $1 eq "occupied by compressor" or $1 eq "wired down"' | awk '{s+=$1} END {printf "%.0f", s*100/('$(sysctl -n hw.memsize)'/1048576)}')
fi

# Color coding based on usage
if [ "${CPU_PERCENT%.*}" -gt 80 ]; then
    CPU_COLOR=0xfff38ba8  # Red
elif [ "${CPU_PERCENT%.*}" -gt 50 ]; then
    CPU_COLOR=0xfff9e2af  # Yellow
else
    CPU_COLOR=0xffa6e3a1  # Green
fi

if [ "${RAM_PERCENT%.*}" -gt 80 ]; then
    RAM_COLOR=0xfff38ba8  # Red
elif [ "${RAM_PERCENT%.*}" -gt 50 ]; then
    RAM_COLOR=0xfff9e2af  # Yellow
else
    RAM_COLOR=0xffa6e3a1  # Green
fi

sketchybar --set $NAME label="CPU ${CPU_PERCENT%.*}% RAM ${RAM_PERCENT%.*}%" \
                       icon.color=$CPU_COLOR