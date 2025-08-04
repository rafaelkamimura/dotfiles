#!/bin/bash
# Performance Environment Configuration

# Theme settings
export THEME_NAME="Performance"
export BAR_OPACITY="0.85"
export ITEM_SPACING="4"
export ANIMATION_SPEED="0.5"

# Widget settings
export SHOW_WEATHER="true"
export SHOW_BATTERY="true"
export SHOW_NETWORK="true"
export SHOW_CPU="true"
export SHOW_MEMORY="true"

# Update intervals (optimized for performance)
export WEATHER_UPDATE_INTERVAL="3600"  # 1 hour
export SYSTEM_UPDATE_INTERVAL="8"      # 8 seconds
export NETWORK_UPDATE_INTERVAL="5"     # 5 seconds

# External services
export WEATHER_API_KEY=""
export WEATHER_LOCATION="Los Angeles,CA"

# Developer options
export DEBUG_MODE="false"
export PERFORMANCE_MONITORING="true"
