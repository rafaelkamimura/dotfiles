# Widget Configuration Guide

## Overview

This guide covers the configuration and customization of individual widgets in the modular SketchyBar setup. Each widget is defined in its own file within the `items/` directory.

## Current Widget Inventory

### Left Side Widgets

#### Apple Menu (`items/apple.sh`)
**Purpose:** System control menu with popup functionality

**Configuration:**
```bash
# Main menu icon
icon="􀣺"                    # Apple logo SF Symbol
icon.color=$BLUE            # Blue accent color
click_script="$PLUGIN_DIR/apple.sh"  # Toggle popup

# Popup menu items
- About This Mac
- Activity Monitor  
- System Preferences
- Sleep
- Lock Screen
- Restart
- Shut Down
```

**Customization Options:**
- Change icon color by modifying `icon.color`
- Add new menu items by extending the popup configuration
- Modify click actions in `plugins/apple.sh`

#### Workspaces (`items/spaces.sh`)
**Purpose:** Virtual desktop indicators (spaces 1-10)

**Configuration:**
```bash
# Space indicators
SPACE_SIDS=(1 2 3 4 5 6 7 8 9 10)
icon=$sid                   # Space number as icon
script="$PLUGIN_DIR/space.sh"  # Handles active/inactive states
```

**Customization Options:**
- Modify `SPACE_SIDS` array to change number of spaces
- Update `space.sh` plugin for custom space names/icons
- Adjust hover effects and click behaviors

#### Front App (`items/front_app.sh`)
**Purpose:** Display currently active application

**Configuration:**
```bash
icon.font="$NERD_FONT:Regular:16.0"  # App icon font
script="$PLUGIN_DIR/front_app.sh"    # Updates on app switch
```

**Customization Options:**
- Modify icon mapping in `plugins/icon_map.sh`
- Change update frequency for app detection
- Add click actions for app-specific behaviors

### Right Side Widgets

#### CPU Monitor (`items/cpu.sh`)
**Purpose:** System CPU usage display

**Configuration:**
```bash
icon="􀧓"                    # CPU SF Symbol
icon.color=$BLUE            # Blue indicator
update_freq=3               # Update every 3 seconds
script="$PLUGIN_DIR/cpu.sh" # CPU data collection
```

**Customization Options:**
- Change update frequency (1-30 seconds recommended)
- Modify color based on CPU load (edit plugin script)
- Add memory usage display

#### Clock (`items/clock.sh`)
**Purpose:** Current time display

**Configuration:**
```bash
icon="􀐫"                    # Clock SF Symbol
icon.color=$ORANGE          # Orange accent
update_freq=10              # Update every 10 seconds
click_script="$PLUGIN_DIR/zen.sh"  # Click action
```

**Customization Options:**
- Change time format in `plugins/clock.sh`
- Modify update frequency (10-60 seconds)
- Add timezone support
- Customize click actions

#### Calendar (`items/calendar.sh`)
**Purpose:** Date information display

**Configuration:**
```bash
icon="􀉉"                    # Calendar SF Symbol
icon.color=$GREEN           # Green indicator
update_freq=300             # Update every 5 minutes
click_script="open -a Calendar"  # Open Calendar app
```

**Customization Options:**
- Change date format in `plugins/calendar.sh`
- Add calendar event integration
- Modify click action to different calendar app
- Show additional date information

## Widget Configuration Patterns

### Standard Widget Structure
Every widget follows this basic pattern:

```bash
#!/bin/bash
# items/widget_name.sh

sketchybar --add item WIDGET_NAME POSITION \
           --set WIDGET_NAME icon="ICON" \
                             icon.font="$FONT:Style:Size" \
                             icon.color=$COLOR \
                             label.font="$FONT:Style:Size" \
                             label.color=$LABEL_COLOR \
                             background.drawing=on \
                             background.color=$ITEM_BG_COLOR \
                             background.corner_radius=$CORNER_RADIUS \
                             background.border_width=$BORDER_WIDTH \
                             background.border_color=$SURFACE1 \
                             padding_left=$PADDINGS \
                             padding_right=$PADDINGS \
                             script="$PLUGIN_DIR/widget_name.sh" \
                             update_freq=SECONDS \
                             click_script="ACTION_SCRIPT"
```

### Widget Positions
- `left` - Left side of the bar
- `center` - Center of the bar (respects notch)
- `right` - Right side of the bar
- `popup.PARENT_NAME` - Inside a popup menu

### Common Properties

#### Visual Properties
```bash
background.drawing=on/off           # Show/hide background
background.color=$COLOR             # Background color
background.corner_radius=NUMBER     # Rounded corners
background.border_width=NUMBER      # Border thickness
background.border_color=$COLOR      # Border color
```

#### Icon Configuration
```bash
icon="SYMBOL"                       # SF Symbol or text
icon.font="FAMILY:STYLE:SIZE"      # Font specification  
icon.color=$COLOR                   # Icon color
icon.padding_left/right=NUMBER      # Icon spacing
```

#### Label Configuration
```bash
label="TEXT"                        # Label text
label.font="FAMILY:STYLE:SIZE"     # Font specification
label.color=$COLOR                  # Text color
label.padding_left/right=NUMBER     # Label spacing
```

#### Update Configuration
```bash
script="PATH_TO_SCRIPT"            # Data update script
update_freq=SECONDS                # Update interval
click_script="PATH_TO_SCRIPT"      # Click handler
```

## Creating New Widgets

### Step 1: Create Widget File
```bash
touch items/my_widget.sh
chmod +x items/my_widget.sh
```

### Step 2: Define Widget Configuration
```bash
#!/bin/bash
# items/my_widget.sh

sketchybar --add item my_widget right \
           --set my_widget icon="􀊫" \
                           icon.color=$BLUE \
                           label="Loading..." \
                           background.drawing=on \
                           background.color=$ITEM_BG_COLOR \
                           script="$PLUGIN_DIR/my_widget.sh" \
                           update_freq=5
```

### Step 3: Create Plugin Script
```bash
#!/bin/bash
# plugins/my_widget.sh

# Collect your data
DATA=$(command_to_get_data)

# Format the data
FORMATTED_DATA=$(echo "$DATA" | format_command)

# Update the widget
sketchybar --set $NAME label="$FORMATTED_DATA"
```

### Step 4: Register Widget
Add to `sketchybarrc`:
```bash
source "$HOME/.config/sketchybar/items/my_widget.sh"
```

## Widget Grouping

### Creating Brackets
Group related widgets visually:

```bash
# Add bracket after creating widgets
sketchybar --add bracket group_name widget1 widget2 widget3 \
           --set group_name background.drawing=on \
                            background.color=$SURFACE0 \
                            background.corner_radius=15 \
                            background.border_width=2 \
                            background.border_color=$SURFACE2
```

### Example: Media Group
```bash
# Create media widgets
source items/spotify.sh
source items/volume.sh

# Group them
sketchybar --add bracket media_group spotify volume \
           --set media_group background.drawing=on \
                             background.color=$SURFACE0
```

## Interactive Widgets

### Click Handlers
```bash
click_script="$PLUGIN_DIR/widget_click.sh"

# In plugin script:
case "$BUTTON" in
  "left") 
    # Left click action
    ;;
  "right")
    # Right click action  
    ;;
esac
```

### Hover Effects
```bash
script="$PLUGIN_DIR/widget_hover.sh"

# In plugin script:
case "$SENDER" in
  "mouse.entered")
    sketchybar --set $NAME background.color=$HOVER_COLOR
    ;;
  "mouse.exited")
    sketchybar --set $NAME background.color=$ITEM_BG_COLOR
    ;;
esac
```

### Popup Menus
```bash
# Main widget
sketchybar --add item main_widget left \
           --set main_widget popup.background.color=$POPUP_BACKGROUND_COLOR

# Popup items
sketchybar --add item popup_item1 popup.main_widget \
           --add item popup_item2 popup.main_widget \
           --set popup_item1 label="Option 1" \
           --set popup_item2 label="Option 2"
```

## Common Widget Patterns

### System Information Widget
```bash
# CPU, Memory, Disk usage pattern
icon="􀧓"
script="$PLUGIN_DIR/system_info.sh"
update_freq=3
```

### Application Integration Widget  
```bash
# Spotify, Music, etc.
icon="􀎶"
script="$PLUGIN_DIR/app_integration.sh"
update_freq=1
click_script="open -a 'Application'"
```

### Network Status Widget
```bash
# WiFi, VPN, connectivity
icon="􀙇"
script="$PLUGIN_DIR/network_status.sh"  
update_freq=5
```

### Weather Widget
```bash
# Weather information
icon="􀇔" 
script="$PLUGIN_DIR/weather.sh"
update_freq=1800  # 30 minutes
```

## Widget Styling Best Practices

### Consistency Guidelines
- Use theme colors from `variables.sh`
- Follow padding standards (`$PADDINGS`)
- Apply consistent corner radius (`$CORNER_RADIUS`)
- Use appropriate font sizes (12-16pt range)

### Icon Selection
- Prefer SF Symbols for system consistency
- Use appropriate semantic icons
- Maintain visual weight balance
- Consider accessibility

### Update Frequencies
- **Real-time data:** 1-3 seconds (CPU, network)
- **Moderate updates:** 5-30 seconds (battery, volume)
- **Slow updates:** 5-30 minutes (weather, calendar)
- **Event-driven:** Subscribe to system events when possible

### Performance Optimization
- Use `updates=when_shown` for non-critical widgets
- Minimize script execution complexity
- Cache expensive operations
- Batch multiple sketchybar commands