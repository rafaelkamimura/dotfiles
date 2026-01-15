#!/bin/bash

# Center Floating Window Helper Script
# Usage: ./center-floating-window.sh [grid_spec]
# Default grid: 8:8:1:1:6:6 (centered, 75% size)

GRID="${1:-8:8:1:1:6:6}"

# Check if window is floating
IS_FLOATING=$(yabai -m query --windows --window | jq -r '."is-floating"')

if [[ "$IS_FLOATING" == "true" ]]; then
    yabai -m window --grid "$GRID"
    echo "Window centered with grid: $GRID"
else
    echo "Current window is not floating. Toggle it first with:"
    echo "  yabai -m window --toggle float"
fi
