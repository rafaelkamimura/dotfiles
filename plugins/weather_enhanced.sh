#!/bin/bash

# Enhanced weather with dynamic colors and better info
LOCATION="San Francisco"  # Change to your location
API_KEY="your_api_key"    # Add your OpenWeatherMap API key if you have one

# Try to get weather data (fallback to mock data if no API)
if [ -n "$API_KEY" ] && [ "$API_KEY" != "your_api_key" ]; then
    WEATHER_DATA=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=$LOCATION&appid=$API_KEY&units=metric")
    TEMP=$(echo $WEATHER_DATA | jq -r '.main.temp' | cut -d. -f1)
    CONDITION=$(echo $WEATHER_DATA | jq -r '.weather[0].main')
else
    # Mock data for demo
    TEMP="22"
    CONDITIONS=("Clear" "Clouds" "Rain" "Snow" "Thunderstorm")
    CONDITION=${CONDITIONS[$((RANDOM % ${#CONDITIONS[@]}))]}
fi

# Dynamic icons and colors based on weather
case "$CONDITION" in
    "Clear"|"Sunny")
        ICON="☀️"
        BORDER_COLOR=0xfff9e2af  # Yellow
        SHADOW_COLOR=0x80f9e2af
        ;;
    "Clouds"|"Overcast")
        ICON="☁️"
        BORDER_COLOR=0xff6c7086  # Gray
        SHADOW_COLOR=0x806c7086
        ;;
    "Rain"|"Drizzle")
        ICON="🌧️"
        BORDER_COLOR=0xff89b4fa  # Blue
        SHADOW_COLOR=0x8089b4fa
        ;;
    "Snow")
        ICON="❄️"
        BORDER_COLOR=0xffcdd6f4  # Light blue
        SHADOW_COLOR=0x80cdd6f4
        ;;
    "Thunderstorm")
        ICON="⛈️"
        BORDER_COLOR=0xfff38ba8  # Red
        SHADOW_COLOR=0x80f38ba8
        ;;
    *)
        ICON="🌤️"
        BORDER_COLOR=0xffa6e3a1  # Green
        SHADOW_COLOR=0x80a6e3a1
        ;;
esac

# Update the weather group colors dynamically
sketchybar --set weather_group background.border_color=$BORDER_COLOR \
                               background.shadow.color=$SHADOW_COLOR

# Set the weather display
sketchybar --set $NAME icon="$ICON" \
                       label="${TEMP}°"