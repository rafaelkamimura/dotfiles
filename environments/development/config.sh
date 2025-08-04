#!/bin/bash
# Development Environment Configuration

# Theme settings
export THEME_NAME="Development"
export BAR_OPACITY="0.95"
export ITEM_SPACING="8"
export ANIMATION_SPEED="0.1"

# Widget settings
export SHOW_WEATHER="true"
export SHOW_BATTERY="true"
export SHOW_NETWORK="true"
export SHOW_CPU="true"
export SHOW_MEMORY="true"

# Update intervals (faster for development)
export WEATHER_UPDATE_INTERVAL="300"   # 5 minutes
export SYSTEM_UPDATE_INTERVAL="2"      # 2 seconds
export NETWORK_UPDATE_INTERVAL="1"     # 1 second

# External services
export WEATHER_API_KEY=""
export WEATHER_LOCATION="San Francisco,CA"

# Developer options
export DEBUG_MODE="true"
export PERFORMANCE_MONITORING="true"
export LOG_LEVEL="debug"
