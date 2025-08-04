# Enhanced SketchyBar Widgets

This document describes the modern, enhanced widgets implemented for SketchyBar with advanced functionality, smooth animations, and comprehensive system integration.

## Overview

The enhanced widget collection provides:
- **Modern UI/UX**: Smooth animations, hover effects, and contextual information
- **Comprehensive Monitoring**: Detailed system metrics beyond basic functionality
- **Smart Interactions**: Left/right click handlers, popup menus, and contextual actions
- **Integration**: Deep macOS API integration and third-party service support
- **Productivity Focus**: Tools designed to enhance workflow and system awareness

## Enhanced Widgets

### 1. System Monitor Widget (`system_monitor.lua`)

**Location**: `/items/widgets/system_monitor.lua`
**Plugin**: `/plugins/system_monitor.sh`

#### Features:
- **Multi-metric Monitoring**: CPU, Memory, GPU, Temperature, Disk I/O, Power consumption
- **Real-time Updates**: 5-second refresh cycle with efficient data collection
- **Color-coded Status**: Visual indicators for system health (green/yellow/orange/red)
- **Interactive Popup**: Detailed breakdown of all metrics
- **Apple Silicon Support**: Optimized for both Intel and Apple Silicon Macs

#### Interactions:
- **Left Click**: Toggle detailed popup
- **Hover**: Visual feedback with border highlight
- **Auto-update**: Refreshes on system wake

#### Metrics Displayed:
- CPU usage percentage with color coding
- Memory usage in GB
- GPU utilization (Apple Silicon)
- CPU temperature in Celsius
- Disk I/O speed in MB/s
- Power consumption in Watts

---

### 2. Productivity Timer Widget (`productivity_timer.lua`)

**Location**: `/items/widgets/productivity_timer.lua`
**Plugin**: `/plugins/productivity_timer.sh`

#### Features:
- **Pomodoro Technique**: 25-minute work sessions with 5/15-minute breaks
- **Smart Progression**: Automatic transition between work and break sessions
- **Session Tracking**: Daily statistics and completion counts
- **Background Processing**: Continues timing even when popup is closed
- **Visual Progress**: Real-time progress bar and time remaining
- **Audio Notifications**: System sounds for session completion

#### Interactions:
- **Left Click**: Toggle control popup
- **Start/Stop Button**: Control timer state
- **Reset Button**: Reset current session
- **Skip Button**: Move to next session type
- **Hover**: Quick status preview

#### Data Persistence:
- Session state stored in `~/.config/sketchybar/timer_data/`
- Daily statistics reset automatically
- Background timer process management

---

### 3. Network Monitor Widget (`network_monitor.lua`)

**Location**: `/items/widgets/network_monitor.lua`
**Plugin**: `/plugins/network_monitor.sh`

#### Features:
- **Real-time Speed Graphs**: Upload and download speed visualization
- **Connection Quality**: Signal strength and latency monitoring
- **Network Information**: IP address, connection type, data usage
- **Multi-interface Support**: WiFi, Ethernet, VPN detection
- **Daily Usage Tracking**: Bandwidth consumption monitoring

#### Interactions:
- **Left Click**: Open Network Preferences
- **Right Click**: Open Network Utility
- **Popup**: Detailed network information and speed graphs
- **Hover**: Connection status preview

#### Displayed Information:
- Upload/download speeds with units
- Connection type (WiFi/Ethernet/VPN)
- Signal strength (WiFi)
- IP address
- Ping latency
- Daily data usage

---

### 4. Enhanced Battery Widget (`battery_enhanced.lua`)

**Location**: `/items/widgets/battery_enhanced.lua`
**Plugin**: `/plugins/battery_enhanced.sh`

#### Features:
- **Health Monitoring**: Battery condition and cycle count tracking
- **Temperature Monitoring**: Battery thermal status
- **Power Consumption**: Real-time power draw analysis
- **Capacity Tracking**: Maximum capacity degradation monitoring
- **Charging Optimization**: Power source and charging status
- **Trend Analysis**: Power consumption history graphing

#### Interactions:
- **Left Click**: Open Energy Saver preferences
- **Right Click**: Open Activity Monitor (Energy tab)
- **Popup**: Comprehensive battery health information
- **Hover**: Quick battery status

#### Health Metrics:
- Battery condition status
- Cycle count vs. maximum (typically 1000)
- Current capacity vs. design capacity
- Battery temperature
- Time remaining estimates
- Power consumption trends

---

### 5. Comprehensive Weather Widget (`weather_comprehensive.lua`)

**Location**: `/items/widgets/weather_comprehensive.lua`
**Plugin**: `/plugins/weather_comprehensive.sh`

#### Features:
- **Multi-source Data**: Integration with multiple weather APIs
- **Hourly Forecasts**: Next 6 hours weather preview
- **3-day Forecast**: Extended weather outlook
- **Air Quality Monitoring**: AQI data and health recommendations
- **Severe Weather Alerts**: Real-time weather warnings
- **Location Detection**: Automatic location detection with fallbacks

#### Interactions:
- **Left Click**: Open Weather app/preferences
- **Right Click**: Open weather website
- **Popup**: Detailed weather information and forecasts
- **Weather Alerts**: Visual and audio notifications

#### API Configuration:
Set up API keys in `~/.config/sketchybar/weather_data/api_keys`:
- OpenWeatherMap API
- WeatherAPI
- AirVisual API (for air quality)

#### Displayed Information:
- Current temperature and conditions
- Feels-like temperature
- Humidity and pressure
- Wind speed and direction
- UV index with safety levels
- Air quality index
- Hourly and daily forecasts

---

### 6. Smart Calendar Widget (`calendar_smart.lua`)

**Location**: `/items/widgets/calendar_smart.lua`
**Plugin**: `/plugins/calendar_smart.sh`

#### Features:
- **Event Integration**: macOS Calendar app integration via AppleScript
- **Meeting Preparation**: Pre-meeting checklists and reminders
- **Next Event Preview**: Upcoming event details and countdown
- **Schedule Overview**: Daily and weekly event summaries
- **Time Zone Support**: Multi-timezone display
- **Meeting Reminders**: Automatic notifications at 15, 5, 1 minute intervals

#### Interactions:
- **Left Click**: Open Calendar app
- **Right Click**: Open Fantastical (if available)
- **Popup**: Detailed schedule and upcoming events
- **Meeting Alerts**: System notifications for upcoming meetings

#### Calendar Features:
- Today's event count
- Weekly schedule summary
- Next event countdown
- Meeting preparation status
- Upcoming events list (next 5)
- Time zone information

---

### 7. Shortcuts Manager Widget (`shortcuts_manager.lua`)

**Location**: `/items/widgets/shortcuts_manager.lua`
**Plugin**: `/plugins/shortcuts_manager.sh`

#### Features:
- **Application Shortcuts**: Quick access to frequently used apps
- **System Functions**: Common system operations (sleep, restart, lock)
- **Quick Actions**: Utility functions (IP copy, DNS flush, disk usage)
- **Usage Analytics**: Track most-used shortcuts
- **Custom Shortcuts**: User-defined commands and scripts
- **Safety Confirmations**: Confirmation dialogs for destructive actions

#### Categories:
1. **Applications**: Activity Monitor, Terminal, System Preferences, Calculator, TextEdit, Finder
2. **System Functions**: Lock Screen, Sleep, Restart, Empty Trash, Toggle WiFi, Screenshot
3. **Quick Actions**: Copy IP, Show/Hide Hidden Files, Clear DNS Cache, CPU Temperature, Disk Usage

#### Interactions:
- **Left Click**: Toggle shortcuts popup
- **Right Click**: Options menu (stats, custom shortcuts, create shortcut)
- **Individual Items**: Execute corresponding command
- **Usage Tracking**: Maintains usage statistics in `~/.config/sketchybar/shortcuts_data/`

---

## Animation Framework (`helpers/animations.lua`)

### Features:
- **Easing Functions**: Linear, ease-in, ease-out, ease-in-out, bounce, elastic
- **Color Interpolation**: Smooth color transitions between states
- **Property Animation**: Animate any numeric widget property
- **Hover Effects**: Standardized hover interactions
- **Chain/Parallel**: Complex animation sequences
- **Loading States**: Spinner and pulse animations

### Usage Examples:
```lua
local animations = require("helpers.animations")

-- Color transition
animations.color_transition(widget, "icon.color", colors.red, colors.green, 0.5)

-- Hover effect
local hover = animations.hover_effect(widget, colors.blue)
widget:subscribe("mouse.entered", hover.enter)
widget:subscribe("mouse.exited", hover.exit)

-- Pulse notification
animations.pulse(widget, colors.orange, colors.red, 1.0, 3)
```

---

## Installation and Configuration

### 1. Widget Integration
The enhanced widgets are automatically loaded via `/items/widgets/init.lua`. They coexist with original widgets for compatibility.

### 2. Permissions Required
Some widgets require additional macOS permissions:
- **Calendar Widget**: Calendar app access
- **System Monitor**: Accessibility permissions for powermetrics
- **Weather Widget**: Network access for API calls

### 3. API Configuration
For full weather functionality, configure API keys:
```bash
# Edit the API keys file
vim ~/.config/sketchybar/weather_data/api_keys
```

### 4. Customization
Each widget supports customization through:
- Color scheme modifications in `colors.lua`
- Update frequencies in widget definitions
- Feature toggles in plugin scripts

---

## Performance Considerations

### Optimization Features:
- **Efficient Caching**: API responses and system data cached appropriately
- **Smart Updates**: Only update changed values
- **Background Processing**: Heavy operations run in background
- **Memory Management**: Automatic cleanup of temporary data

### Resource Usage:
- **CPU Impact**: Minimal, with most widgets updating every 30-60 seconds
- **Memory Usage**: Small data files for state persistence
- **Network Usage**: Weather widget only (configurable intervals)

---

## Troubleshooting

### Common Issues:

1. **Weather Widget Not Working**
   - Check API keys configuration
   - Verify network connectivity
   - Check location detection

2. **Calendar Widget No Events**
   - Grant Calendar app permissions
   - Check Calendar app has events
   - Verify AppleScript execution

3. **System Monitor High CPU**
   - Reduce update frequency in widget definition
   - Check powermetrics permissions

4. **Animations Not Smooth**
   - Reduce animation complexity
   - Check system performance
   - Update SketchyBar to latest version

### Debug Mode:
Enable debug logging by setting environment variables in plugin scripts:
```bash
export SKETCHYBAR_DEBUG=1
```

---

## Future Enhancements

### Planned Features:
- **Spotify/Music Integration**: Now playing widget with controls
- **Stock Market Ticker**: Real-time stock prices
- **Cryptocurrency Monitor**: Crypto price tracking
- **System Load Balancer**: Automatic performance optimization
- **Voice Control**: Siri integration for widget control
- **Custom Themes**: Per-widget color customization

### Community Contributions:
The widget framework is designed for extensibility. New widgets can be added by:
1. Creating widget Lua file in `/items/widgets/`
2. Creating corresponding plugin script in `/plugins/`
3. Adding require statement to `init.lua`
4. Following established patterns for consistency

---

## Credits and License

These enhanced widgets were created to demonstrate modern SketchyBar capabilities with focus on:
- User experience improvements
- System integration depth
- Performance optimization
- Maintainable code patterns

The implementation showcases advanced Lua scripting techniques and comprehensive shell script integration for macOS system monitoring and control.