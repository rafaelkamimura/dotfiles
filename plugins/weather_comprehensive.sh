#!/bin/bash

# Comprehensive weather widget with forecasts, air quality, and severe weather alerts
# Uses multiple weather APIs for complete data coverage

WEATHER_DIR="$HOME/.config/sketchybar/weather_data"
CACHE_FILE="$WEATHER_DIR/weather_cache"
LOCATION_FILE="$WEATHER_DIR/location"
API_KEY_FILE="$WEATHER_DIR/api_keys"

# Create weather directory if it doesn't exist
mkdir -p "$WEATHER_DIR"

# Weather API endpoints and keys (user should configure these)
setup_api_keys() {
    if [ ! -f "$API_KEY_FILE" ]; then
        cat > "$API_KEY_FILE" << 'EOF'
# Weather API Keys - Replace with your actual keys
# Get free keys from:
# OpenWeatherMap: https://openweathermap.org/api
# WeatherAPI: https://www.weatherapi.com/
# AirVisual: https://www.iqair.com/air-pollution-data-api

OPENWEATHER_API_KEY=""
WEATHERAPI_KEY=""
AIRVISUAL_API_KEY=""
EOF
        echo "Please configure API keys in $API_KEY_FILE"
        return 1
    fi
    
    source "$API_KEY_FILE"
    return 0
}

# Get current location
detect_location() {
    # Try multiple methods to get location
    local location=""
    
    # Method 1: IP-based location
    location=$(curl -s "https://ipapi.co/city" 2>/dev/null | head -1)
    
    # Method 2: macOS location services (if available)
    if [ -z "$location" ] || [ "$location" = "null" ]; then
        if command -v whereami >/dev/null 2>&1; then
            location=$(whereami 2>/dev/null | head -1)
        fi
    fi
    
    # Method 3: Cached location
    if [ -z "$location" ] || [ "$location" = "null" ]; then
        if [ -f "$LOCATION_FILE" ]; then
            location=$(cat "$LOCATION_FILE")
        fi
    fi
    
    # Fallback
    if [ -z "$location" ] || [ "$location" = "null" ]; then
        location="New York"
    fi
    
    # Cache the location
    echo "$location" > "$LOCATION_FILE"
    echo "$location"
}

# Get comprehensive weather data
get_weather_data() {
    setup_api_keys || return 1
    
    local location=$(detect_location)
    local cache_time=300  # 5 minutes cache
    
    # Check cache freshness
    if [ -f "$CACHE_FILE" ]; then
        local cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
        if [ $cache_age -lt $cache_time ]; then
            cat "$CACHE_FILE"
            return 0
        fi
    fi
    
    # Get coordinates for location
    local coords=""
    if [ -n "$OPENWEATHER_API_KEY" ]; then
        coords=$(curl -s "http://api.openweathermap.org/geo/1.0/direct?q=${location}&limit=1&appid=${OPENWEATHER_API_KEY}" 2>/dev/null)
        if [ -n "$coords" ] && [ "$coords" != "[]" ]; then
            local lat=$(echo "$coords" | grep -o '"lat":[^,]*' | cut -d':' -f2)
            local lon=$(echo "$coords" | grep -o '"lon":[^,]*' | cut -d':' -f2)
        fi
    fi
    
    # Primary weather data from OpenWeatherMap
    local weather_data=""
    if [ -n "$OPENWEATHER_API_KEY" ] && [ -n "$lat" ] && [ -n "$lon" ]; then
        weather_data=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${OPENWEATHER_API_KEY}&units=metric" 2>/dev/null)
    fi
    
    # Fallback to wttr.in if OpenWeatherMap fails
    if [ -z "$weather_data" ] || [[ "$weather_data" == *"error"* ]]; then
        local wttr_data=$(curl -s "https://wttr.in/${location}?format=j1" 2>/dev/null)
        if [ -n "$wttr_data" ]; then
            weather_data="$wttr_data"
        fi
    fi
    
    # Air quality data
    local air_quality=""
    if [ -n "$AIRVISUAL_API_KEY" ] && [ -n "$lat" ] && [ -n "$lon" ]; then
        air_quality=$(curl -s "http://api.airvisual.com/v2/nearest_city?lat=${lat}&lon=${lon}&key=${AIRVISUAL_API_KEY}" 2>/dev/null)
    fi
    
    # Forecast data
    local forecast_data=""
    if [ -n "$OPENWEATHER_API_KEY" ] && [ -n "$lat" ] && [ -n "$lon" ]; then
        forecast_data=$(curl -s "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=${OPENWEATHER_API_KEY}&units=metric" 2>/dev/null)
    fi
    
    # Parse and format weather data
    parse_weather_data "$weather_data" "$air_quality" "$forecast_data" "$location"
}

# Parse weather data from APIs
parse_weather_data() {
    local weather_data="$1"
    local air_quality="$2"
    local forecast_data="$3"
    local location="$4"
    
    # Default values
    local temperature="??"
    local condition="Unknown"
    local icon="🌤️"
    local feels_like="??"
    local humidity="??"
    local pressure="????"
    local wind_speed="??"
    local wind_direction="??"
    local uv_index="??"
    local uv_description=""
    local aqi="??"
    local aqi_description="Unknown"
    local weather_alert="None"
    
    # Parse OpenWeatherMap data
    if [[ "$weather_data" == *"main"* ]]; then
        temperature=$(echo "$weather_data" | grep -o '"temp":[^,]*' | cut -d':' -f2 | cut -d'.' -f1)
        feels_like=$(echo "$weather_data" | grep -o '"feels_like":[^,]*' | cut -d':' -f2 | cut -d'.' -f1)
        humidity=$(echo "$weather_data" | grep -o '"humidity":[^,]*' | cut -d':' -f2)
        pressure=$(echo "$weather_data" | grep -o '"pressure":[^,]*' | cut -d':' -f2)
        wind_speed=$(echo "$weather_data" | grep -o '"speed":[^,]*' | cut -d':' -f2)
        
        # Weather condition
        local main_weather=$(echo "$weather_data" | grep -o '"main":"[^"]*' | cut -d'"' -f4 | head -1)
        condition="$main_weather"
        
        # Convert to appropriate icon
        case "$main_weather" in
            "Clear") icon="☀️" ;;
            "Clouds") icon="☁️" ;;
            "Rain") icon="🌧️" ;;
            "Drizzle") icon="🌦️" ;;
            "Thunderstorm") icon="⛈️" ;;
            "Snow") icon="❄️" ;;
            "Mist"|"Fog") icon="🌫️" ;;
            *) icon="🌤️" ;;
        esac
        
        # Format temperature
        if [ -n "$temperature" ]; then
            temperature="${temperature}°C"
        fi
        if [ -n "$feels_like" ]; then
            feels_like="${feels_like}°C"
        fi
        
        # Format wind
        if [ -n "$wind_speed" ]; then
            wind_speed=$(echo "scale=0; $wind_speed * 3.6" | bc -l 2>/dev/null)  # Convert m/s to km/h
            wind_speed="${wind_speed:-0} km/h"
        fi
        
    # Parse wttr.in data as fallback
    elif [[ "$weather_data" == *"current_condition"* ]]; then
        temperature=$(echo "$weather_data" | grep -o '"temp_C":"[^"]*' | cut -d'"' -f4 | head -1)
        feels_like=$(echo "$weather_data" | grep -o '"FeelsLikeC":"[^"]*' | cut -d'"' -f4 | head -1)
        humidity=$(echo "$weather_data" | grep -o '"humidity":"[^"]*' | cut -d'"' -f4 | head -1)
        pressure=$(echo "$weather_data" | grep -o '"pressure":"[^"]*' | cut -d'"' -f4 | head -1)
        wind_speed=$(echo "$weather_data" | grep -o '"windspeedKmph":"[^"]*' | cut -d'"' -f4 | head -1)
        
        if [ -n "$temperature" ]; then
            temperature="${temperature}°C"
        fi
        if [ -n "$feels_like" ]; then
            feels_like="${feels_like}°C"
        fi
        if [ -n "$wind_speed" ]; then
            wind_speed="${wind_speed} km/h"
        fi
        
        # Get weather description
        condition=$(echo "$weather_data" | grep -o '"weatherDesc":\[{"value":"[^"]*' | cut -d'"' -f6 | head -1)
        
        # Simple icon mapping for wttr.in
        case "$condition" in
            *"Clear"*|*"Sunny"*) icon="☀️" ;;
            *"Partly cloudy"*) icon="⛅" ;;
            *"Cloudy"*|*"Overcast"*) icon="☁️" ;;
            *"Rain"*) icon="🌧️" ;;
            *"Drizzle"*) icon="🌦️" ;;
            *"Thunder"*) icon="⛈️" ;;
            *"Snow"*) icon="❄️" ;;
            *"Mist"*|*"Fog"*) icon="🌫️" ;;
            *) icon="🌤️" ;;
        esac
    fi
    
    # Parse air quality data
    if [[ "$air_quality" == *"data"* ]]; then
        aqi=$(echo "$air_quality" | grep -o '"aqius":[^,]*' | cut -d':' -f2)
        
        # Convert AQI to description
        if [ -n "$aqi" ] && [ "$aqi" -ne 0 ]; then
            if [ "$aqi" -le 50 ]; then
                aqi_description="Good"
            elif [ "$aqi" -le 100 ]; then
                aqi_description="Moderate"
            elif [ "$aqi" -le 150 ]; then
                aqi_description="Unhealthy for Sensitive"
            elif [ "$aqi" -le 200 ]; then
                aqi_description="Unhealthy"
            else
                aqi_description="Hazardous"
            fi
        fi
    fi
    
    # Estimate UV index based on time and weather
    local hour=$(date +%H)
    if [ "$hour" -ge 10 ] && [ "$hour" -le 16 ]; then
        if [[ "$condition" == *"Clear"* ]] || [[ "$condition" == *"Sunny"* ]]; then
            uv_index="7"
            uv_description="High"
        elif [[ "$condition" == *"Partly"* ]]; then
            uv_index="5"
            uv_description="Moderate"
        else
            uv_index="2"
            uv_description="Low"
        fi
    else
        uv_index="0"
        uv_description="None"
    fi
    
    # Check for severe weather alerts (simplified)
    if [[ "$condition" == *"Thunder"* ]] || [[ "$condition" == *"Storm"* ]]; then
        weather_alert="Thunderstorm Warning"
    elif [[ "$condition" == *"Snow"* ]] && [[ "$temperature" == *"-"* ]]; then
        weather_alert="Winter Weather Advisory"
    fi
    
    # Cache the results
    local result="temperature:${temperature}|condition:${condition}|weather_icon:${icon}|feels_like:${feels_like}|humidity:${humidity}|pressure:${pressure}|wind_speed:${wind_speed}|wind_direction:${wind_direction}|uv_index:${uv_index}|uv_description:${uv_description}|air_quality_index:${aqi}|air_quality_desc:${aqi_description}|location:${location}|weather_alert:${weather_alert}"
    
    echo "$result" > "$CACHE_FILE"
    echo "$result"
}

# Get hourly forecast
get_hourly_forecast() {
    setup_api_keys || return 1
    
    local location=$(detect_location)
    
    # This would require parsing forecast API data
    # For now, return sample data
    for i in {1..6}; do
        local hour_offset=$((i))
        local time_label="+${hour_offset}h:"
        local temp=$((22 - i))
        echo "hour_${i}=${time_label}|🌤️|${temp}°"
    done
}

# Get daily forecast
get_daily_forecast() {
    setup_api_keys || return 1
    
    # Sample 3-day forecast
    echo "day_1=Today|⛅|25°|15°"
    echo "day_2=Tomorrow|🌧️|20°|12°"
    echo "day_3=Day 3|☀️|28°|18°"
}

# Send weather update to SketchyBar
update_weather_display() {
    local weather_data=$(get_weather_data)
    
    if [ -n "$weather_data" ]; then
        # Parse the pipe-separated data
        local temp=$(echo "$weather_data" | grep -o 'temperature:[^|]*' | cut -d':' -f2)
        local condition=$(echo "$weather_data" | grep -o 'condition:[^|]*' | cut -d':' -f2)
        local icon=$(echo "$weather_data" | grep -o 'weather_icon:[^|]*' | cut -d':' -f2)
        local feels_like=$(echo "$weather_data" | grep -o 'feels_like:[^|]*' | cut -d':' -f2)
        local humidity=$(echo "$weather_data" | grep -o 'humidity:[^|]*' | cut -d':' -f2)
        local pressure=$(echo "$weather_data" | grep -o 'pressure:[^|]*' | cut -d':' -f2)
        local wind_speed=$(echo "$weather_data" | grep -o 'wind_speed:[^|]*' | cut -d':' -f2)
        local wind_dir=$(echo "$weather_data" | grep -o 'wind_direction:[^|]*' | cut -d':' -f2)
        local uv=$(echo "$weather_data" | grep -o 'uv_index:[^|]*' | cut -d':' -f2)
        local uv_desc=$(echo "$weather_data" | grep -o 'uv_description:[^|]*' | cut -d':' -f2)
        local aqi=$(echo "$weather_data" | grep -o 'air_quality_index:[^|]*' | cut -d':' -f2)
        local aqi_desc=$(echo "$weather_data" | grep -o 'air_quality_desc:[^|]*' | cut -d':' -f2)
        local location=$(echo "$weather_data" | grep -o 'location:[^|]*' | cut -d':' -f2)
        local alert=$(echo "$weather_data" | grep -o 'weather_alert:[^|]*' | cut -d':' -f2)
        
        # Update main weather display
        sketchybar --trigger weather_update \
                   temperature="$temp" \
                   condition="$condition" \
                   weather_icon="$icon" \
                   feels_like="$feels_like" \
                   humidity="$humidity" \
                   pressure="$pressure" \
                   wind_speed="$wind_speed" \
                   wind_direction="$wind_dir" \
                   uv_index="$uv" \
                   uv_description="$uv_desc" \
                   air_quality_index="$aqi" \
                   air_quality_desc="$aqi_desc" \
                   location="$location" \
                   weather_alert="$alert"
        
        # Update forecasts
        get_hourly_forecast | while read -r line; do
            if [ -n "$line" ]; then
                local hour_id=$(echo "$line" | cut -d'=' -f1)
                local hour_data=$(echo "$line" | cut -d'=' -f2)
                sketchybar --trigger hourly_forecast "$hour_id=$hour_data"
            fi
        done
        
        get_daily_forecast | while read -r line; do
            if [ -n "$line" ]; then
                local day_id=$(echo "$line" | cut -d'=' -f1)
                local day_data=$(echo "$line" | cut -d'=' -f2)
                sketchybar --trigger daily_forecast "$day_id=$day_data"
            fi
        done
        
        # Send alert if necessary
        if [ "$alert" != "None" ]; then
            local alert_type="info"
            if [[ "$alert" == *"Warning"* ]] || [[ "$alert" == *"Watch"* ]]; then
                alert_type="severe"
            fi
            
            sketchybar --trigger weather_alert \
                       alert_type="$alert_type" \
                       alert_message="$alert"
        fi
    fi
}

# Show hover information
show_hover_info() {
    local weather_data=$(get_weather_data)
    
    if [ -n "$weather_data" ]; then
        local temp=$(echo "$weather_data" | grep -o 'temperature:[^|]*' | cut -d':' -f2)
        local condition=$(echo "$weather_data" | grep -o 'condition:[^|]*' | cut -d':' -f2)
        local feels_like=$(echo "$weather_data" | grep -o 'feels_like:[^|]*' | cut -d':' -f2)
        local location=$(echo "$weather_data" | grep -o 'location:[^|]*' | cut -d':' -f2)
        
        local message="$temp $condition in $location (feels like $feels_like)"
        osascript -e "display notification \"$message\" with title \"Weather Update\""
    fi
}

# Handle different actions
case "$1" in
    "init")
        setup_api_keys
        update_weather_display
        ;;
    "update")
        update_weather_display
        ;;
    "hover")
        show_hover_info
        ;;
    "click")
        if [ "$BUTTON" = "left" ]; then
            # Open default weather app
            open "x-apple.systempreferences:com.apple.preference.datetime"
        elif [ "$BUTTON" = "right" ]; then
            # Open weather website
            local location=$(detect_location)
            open "https://weather.com/weather/today/l/$location"
        fi
        ;;
    *)
        # Default action
        update_weather_display
        ;;
esac