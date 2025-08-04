# SketchyBar Performance Optimization Plan

## High Priority Optimizations

### 1. Implement Intelligent Update Frequencies

#### Current vs Optimized Update Intervals:
- **CPU**: 3s → 5s (33% reduction) + adaptive throttling when inactive
- **Weather**: 600s → 1800s (3x less frequent) + location caching
- **Clock**: 10s → 60s for minutes, 1s only when seconds are shown
- **Network**: Event-driven + 30s fallback for signal strength
- **Battery**: Event-driven only (pmset events)

#### Implementation:
```bash
# Adaptive CPU monitoring
if [ "$(pmset -g powerstate IODisplayWrangler | grep ON)" ]; then
    UPDATE_FREQ=5
else
    UPDATE_FREQ=30  # Slower when display is off
fi
```

### 2. Cache Expensive Operations

#### Weather Caching:
```bash
# Cache location for 24 hours
LOCATION_CACHE="/tmp/sketchybar_location"
if [ ! -f "$LOCATION_CACHE" ] || [ $(($(date +%s) - $(stat -f %m "$LOCATION_CACHE"))) -gt 86400 ]; then
    curl -s "https://ipapi.co/city" > "$LOCATION_CACHE"
fi
LOCATION=$(cat "$LOCATION_CACHE")
```

#### Network Interface Caching:
```bash
# Cache WiFi interface detection
WIFI_CACHE="/tmp/sketchybar_wifi_interface"
if [ ! -f "$WIFI_CACHE" ]; then
    networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/ { getline; print $NF }' > "$WIFI_CACHE"
fi
WIFI_INTERFACE=$(cat "$WIFI_CACHE")
```

### 3. Replace Shell-Heavy Operations

#### CPU Monitoring with Native Event Provider:
Use the existing C event provider instead of shell `top` command:
```bash
# Replace current CPU item with event-driven approach
~/.config/sketchybar/helpers/event_providers/cpu_load/cpu_load cpu_update 5.0 &
```

#### Icon Mapping Optimization:
Convert icon mapping to hash lookup instead of case statement:
```bash
# Create associative array (bash 4+)
declare -A APP_ICONS=(
    ["Arc"]="󰖟"
    ["Safari"]="󰀹"
    ["Google Chrome"]="󰊯"
    # ... etc
)
echo "${APP_ICONS[$1]:-}"
```

### 4. Network Request Optimization

#### HTTP Connection Reuse:
```bash
# Use curl with connection reuse for weather
curl -s --keepalive-time 60 --max-time 10 "wttr.in/${LOCATION}?format=%C+%t"
```

#### Parallel Processing for Independent Updates:
```bash
# Update multiple widgets in parallel
{
    ~/.config/sketchybar/plugins/weather.sh &
    ~/.config/sketchybar/plugins/battery.sh &
    ~/.config/sketchybar/plugins/network.sh &
    wait
}
```

## Medium Priority Optimizations

### 5. Event-Driven Architecture

#### Replace Polling with Events:
- **Battery**: Use `pmset` scheduled events instead of polling
- **Network**: Use `SCNetworkReachability` callbacks
- **Volume**: Use `coreaudiod` events
- **Front App**: Already event-driven (✓)

### 6. Memory Optimization

#### Reduce Shell Script Memory:
```bash
# Instead of multiple variables and subshells
CPU_USAGE=$(top -l 1 | awk '/CPU usage/ {print $3}' | tr -d '%')

# Use single awk pass
eval $(top -l 1 | awk '/CPU usage/ {
    gsub(/%/, "", $3)
    printf "CPU_USAGE=%s\n", $3
}')
```

#### String Processing Optimization:
```bash
# Instead of multiple sed/awk calls
echo "$WEATHER_DATA" | awk '{print $1}' | sed 's/pattern//'

# Use single awk
echo "$WEATHER_DATA" | awk '{gsub(/pattern/, "", $1); print $1}'
```

### 7. Space Management Optimization

#### Intelligent Window Querying:
```bash
# Cache window list and only update on window events
if [ "$SENDER" = "window_focused" ] || [ "$SENDER" = "space_changed" ]; then
    WINDOWS=$(yabai -m query --windows --space $SPACE_ID)
    echo "$WINDOWS" > "/tmp/space_${SPACE_ID}_windows"
else
    WINDOWS=$(cat "/tmp/space_${SPACE_ID}_windows" 2>/dev/null || echo "[]")
fi
```

## Low Priority Optimizations

### 8. Configuration Structure

#### Consolidate Update Frequencies:
Group widgets by update frequency:
- **1s**: Seconds display (when visible)
- **5s**: CPU, RAM, volume
- **30s**: Network signal, battery percentage
- **300s**: Weather, calendar
- **Event-driven**: Front app, spaces, media

#### Lazy Loading:
```bash
# Only load widgets when they become visible
sketchybar --set widget updates=when_shown
```

## Performance Monitoring

### Benchmarking Script:
```bash
#!/bin/bash
# benchmark_sketchybar.sh

echo "=== SketchyBar Performance Benchmark ==="
start_time=$(date +%s.%N)

# Time individual plugins
for plugin in cpu ram network weather; do
    plugin_start=$(date +%s.%N)
    ~/.config/sketchybar/plugins/${plugin}.sh > /dev/null 2>&1
    plugin_end=$(date +%s.%N)
    plugin_time=$(echo "$plugin_end - $plugin_start" | bc)
    echo "${plugin}: ${plugin_time}s"
done

end_time=$(date +%s.%N)
total_time=$(echo "$end_time - $start_time" | bc)
echo "Total: ${total_time}s"
```

## Expected Performance Improvements

- **CPU Usage**: 40-60% reduction in script execution overhead
- **Network Requests**: 70% reduction in API calls through caching
- **Memory Usage**: 30-40% reduction in shell script memory
- **Update Latency**: 50% improvement in widget refresh times
- **Battery Life**: 15-20% improvement through reduced CPU wake-ups

## Implementation Priority

1. **Week 1**: Implement caching for weather and network interface detection
2. **Week 2**: Optimize update frequencies and add adaptive throttling  
3. **Week 3**: Replace heavy shell operations with native event providers
4. **Week 4**: Implement parallel processing and connection reuse