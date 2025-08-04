# SketchyBar Architecture Guide

## System Overview

This SketchyBar configuration follows a **modular architecture** inspired by the MiragianCycle dotfiles approach, optimized for maintainability and extensibility.

## Core Components

### 1. Orchestrator (`sketchybarrc`)
**Role:** Main configuration entry point and system coordinator
- Sets global bar properties (height, position, colors)
- Defines default styling for all widgets
- Sources individual item configurations
- Manages bracket groupings
- Enables hotloading and triggers updates

### 2. Theme System (`variables.sh`)
**Role:** Centralized color and design constant management
- Catppuccin Mocha color palette definitions
- Typography settings (SF Pro font family)
- Layout constants (padding, corner radius, borders)
- Popup styling configuration
- Easy theme switching capability

### 3. Widget Items (`items/`)
**Role:** Individual widget configuration files
- Self-contained widget definitions
- Consistent styling patterns
- Event subscriptions and interactions
- Plugin script associations

### 4. Dynamic Behavior (`plugins/`)
**Role:** Runtime data collection and widget updates
- System information gathering
- Event handling and user interactions
- Data formatting and display logic
- External service integrations

## Data Flow

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   sketchybarrc  │───▶│ variables.sh │───▶│   items/*.sh    │
│  (orchestrator) │    │   (theming)  │    │   (widgets)     │
└─────────────────┘    └──────────────┘    └─────────────────┘
         │                                           │
         ▼                                           ▼
┌─────────────────┐                      ┌─────────────────┐
│ sketchybar CLI  │◀────────────────────▶│ plugins/*.sh    │
│   (rendering)   │                      │  (data/events)  │
└─────────────────┘                      └─────────────────┘
```

## Widget Lifecycle

1. **Initialization:** `sketchybarrc` sources theme and item configurations
2. **Registration:** Each item file registers widgets with SketchyBar
3. **Event Binding:** Widgets subscribe to system events and user interactions
4. **Runtime Updates:** Plugin scripts provide dynamic data updates
5. **Rendering:** SketchyBar renders widgets with applied styling

## Current Widget Inventory

### Left Side
- **Apple Menu** (`items/apple.sh`) - System controls with popup menu
- **Workspaces** (`items/spaces.sh`) - Virtual desktop indicators
- **Front App** (`items/front_app.sh`) - Current application display

### Right Side  
- **CPU Monitor** (`items/cpu.sh`) - System performance indicator
- **Time Group** (bracket) - Grouped time/date widgets
  - **Clock** (`items/clock.sh`) - Current time display
  - **Calendar** (`items/calendar.sh`) - Date information

## Adding New Widgets

### Step 1: Create Item Configuration
```bash
# Create new widget file
touch items/my_widget.sh
chmod +x items/my_widget.sh
```

### Step 2: Define Widget
```bash
#!/bin/bash
# items/my_widget.sh

sketchybar --add item my_widget right \
           --set my_widget icon="􀊫" \
                           icon.color=$ICON_COLOR \
                           label.color=$LABEL_COLOR \
                           background.drawing=on \
                           background.color=$ITEM_BG_COLOR \
                           script="$PLUGIN_DIR/my_widget.sh"
```

### Step 3: Create Plugin Script
```bash
#!/bin/bash
# plugins/my_widget.sh

# Collect data
DATA=$(some_command)

# Update widget
sketchybar --set my_widget label="$DATA"
```

### Step 4: Register in Orchestrator
```bash
# Add to sketchybarrc
source "$HOME/.config/sketchybar/items/my_widget.sh"
```

## Configuration Patterns

### Standard Widget Structure
```bash
sketchybar --add item WIDGET_NAME POSITION \
           --set WIDGET_NAME icon="ICON" \
                             icon.color=$ICON_COLOR \
                             label.color=$LABEL_COLOR \
                             background.drawing=on \
                             background.color=$ITEM_BG_COLOR \
                             background.corner_radius=$CORNER_RADIUS \
                             padding_left=$PADDINGS \
                             padding_right=$PADDINGS \
                             script="$PLUGIN_DIR/WIDGET_NAME.sh"
```

### Bracket Grouping
```bash
sketchybar --add bracket GROUP_NAME widget1 widget2 \
           --set GROUP_NAME background.drawing=on \
                            background.color=$SURFACE0 \
                            background.corner_radius=15
```

## Plugin Script Patterns

### Basic Update Script
```bash
#!/bin/bash
# Get data
VALUE=$(command_to_get_data)

# Update widget
sketchybar --set $NAME label="$VALUE"
```

### Event-Driven Script
```bash
#!/bin/bash
case "$SENDER" in
  "mouse.clicked")
    # Handle click
    ;;
  "system_woke")
    # Handle wake event
    ;;
esac
```

## Performance Considerations

- **Updates:** Use `updates=when_shown` for non-critical widgets
- **Frequencies:** Set appropriate `update_freq` values (3s for CPU, 300s for calendar)
- **Batching:** Group related sketchybar commands for efficiency
- **Event Subscriptions:** Only subscribe to necessary events

## Maintenance Benefits

1. **Isolation:** Each widget can be modified independently
2. **Debugging:** Easy to disable specific widgets by commenting source lines
3. **Testing:** Individual widget files can be tested in isolation
4. **Theming:** Global changes via `variables.sh` affect all widgets
5. **Version Control:** Clear change tracking per widget component

## Future Extensibility

The modular architecture supports easy addition of:
- Media controls (`items/media.sh`)
- Weather widgets (`items/weather.sh`)
- System statistics (`items/system_stats.sh`)
- Network monitoring (`items/network.sh`)
- Custom application integrations

Each addition follows the same pattern: item configuration + plugin script + orchestrator registration.