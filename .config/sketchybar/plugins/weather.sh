#!/bin/bash

# Superior weather widget with location detection
get_weather() {
    # Try to get location automatically
    LOCATION=$(curl -s "https://ipapi.co/city" 2>/dev/null | head -1)
    
    # Fallback locations
    if [ -z "$LOCATION" ] || [ "$LOCATION" = "null" ]; then
        LOCATION="Tokyo"
    fi
    
    # Get weather data with more details
    WEATHER_DATA=$(curl -s "wttr.in/${LOCATION}?format=%C+%t+%f+%h+%w" 2>/dev/null | head -1)
    
    if [ -n "$WEATHER_DATA" ] && [ "$WEATHER_DATA" != "Unknown location" ]; then
        CONDITION=$(echo "$WEATHER_DATA" | awk '{print $1}')
        TEMP=$(echo "$WEATHER_DATA" | awk '{print $2}')
        FEELS_LIKE=$(echo "$WEATHER_DATA" | awk '{print $3}')
        HUMIDITY=$(echo "$WEATHER_DATA" | awk '{print $4}')
        
        # Enhanced weather condition mapping
        case "$CONDITION" in
            "Clear"|"Sunny") 
                ICON="☀️"
                COLOR="0xffeed49f" ;;
            "Partly"*|"Cloudy") 
                ICON="⛅"
                COLOR="0xffcad3f5" ;;
            "Overcast") 
                ICON="☁️"
                COLOR="0xff939ab7" ;;
            "Mist"|"Fog") 
                ICON="🌫️"
                COLOR="0xff939ab7" ;;
            "Light"*"rain"|"Drizzle") 
                ICON="🌦️"
                COLOR="0xff8aadf4" ;;
            "Rain"|"Heavy"*"rain") 
                ICON="🌧️"
                COLOR="0xff8aadf4" ;;
            "Snow"|"Blizzard") 
                ICON="❄️"
                COLOR="0xffcad3f5" ;;
            "Thunder"*|"Storm") 
                ICON="⛈️"
                COLOR="0xffed8796" ;;
            *) 
                ICON="🌤️"
                COLOR="0xffcad3f5" ;;
        esac
        
        # Click handler for detailed weather
        if [ "$SENDER" = "mouse.clicked" ]; then
            if [ "$BUTTON" = "left" ]; then
                # Show detailed weather in notification
                osascript -e "display notification \"Feels like: $FEELS_LIKE, Humidity: $HUMIDITY\" with title \"Weather in $LOCATION\""
            elif [ "$BUTTON" = "right" ]; then
                # Open weather app
                open "https://weather.com/weather/today/l/$LOCATION"
            fi
        fi
        
        sketchybar --set $NAME icon="$ICON" \
                              label="$TEMP" \
                              icon.color=$COLOR \
                              drawing=on
    else
        sketchybar --set $NAME drawing=off
    fi
}

get_weather