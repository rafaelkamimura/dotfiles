# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a premium SketchyBar configuration for macOS featuring dynamic animations, contextual theming, and intelligent workspace management. The configuration uses both shell scripts and Lua modules for maximum flexibility.

## Architecture

### Configuration Structure
- **Primary config**: `sketchybarrc` - Main bash configuration with visual styling and widget setup
- **Lua config**: `init.lua` - Alternative Lua-based configuration entry point
- **Plugin scripts**: `plugins/` - All widget functionality and interactions
- **Helper modules**: `helpers/` - Lua utilities and C extensions
- **Items**: `items/` - Lua widget definitions (alternative to bash approach)

### Dual Configuration System
The repository supports both bash (`sketchybarrc`) and Lua (`init.lua`) configuration approaches:
- The bash config in `sketchybarrc` is the primary, actively used configuration
- The Lua config provides an alternative modular approach
- Both can coexist but typically only one is active

## Common Commands

### Installation & Setup
```bash
# Make all scripts executable
chmod +x ~/.config/sketchybar/plugins/*.sh
chmod +x ~/.config/sketchybar/sketchybarrc

# Start/restart SketchyBar
brew services restart sketchybar

# Check logs
tail -f /opt/homebrew/var/log/sketchybar.log
```

### Development & Testing
```bash
# Reload configuration (after changes)
sketchybar --reload

# Update all widgets
sketchybar --update

# Test individual plugin
bash ~/.config/sketchybar/plugins/weather.sh

# Debug specific item
sketchybar --query item_name
```

### Building C Extensions
```bash
# Build all helpers (event providers, menus)
cd helpers && make

# Build specific components
cd helpers/event_providers && make
cd helpers/menus && make
```

## Key Components

### Widget Categories
1. **Left Side**: Apple menu, workspaces, front app display
2. **Center**: Media information
3. **Right Side**: Three grouped sections:
   - Weather group (dynamic colors)
   - System status group (battery, volume, network, CPU/RAM)
   - Time/date group (contextual theming)

### Plugin Architecture
- **Core plugins**: Handle basic functionality (space.sh, clock.sh, battery.sh)
- **Enhanced plugins**: Advanced features (weather_enhanced.sh, system_stats.sh)
- **Hover effects**: Interactive animations (*_hover.sh files)
- **System integration**: Deep macOS integration (yabai.sh, shortcuts.sh)

### Theming System
- **Catppuccin Mocha** color palette throughout
- **Performance-reactive colors**: System load affects widget colors
- **Contextual theming**: Time-based and condition-based color changes
- **Dynamic shadows and borders**: Respond to hover and system state

## Configuration Patterns

### Adding New Widgets
1. Create plugin script in `plugins/`
2. Add sketchybar item configuration in `sketchybarrc`
3. Set appropriate update frequency and event subscriptions
4. Follow existing naming conventions (lowercase with underscores)

### Color Usage
- All colors are defined as hex values with alpha channel (0xffRRGGBB)
- Primary palette defined in `sketchybarrc` header
- Consistent white text (0xffcdd6f4) across all elements
- Use performance-based colors for system monitoring widgets

### Plugin Script Structure
- Use bash with proper error handling
- Export variables for SketchyBar communication
- Include click handlers for interactive elements
- Follow existing patterns for icon/label formatting

## Backup System

The configuration includes automatic backups in `backups/` with timestamped directories. When making significant changes, the system creates recovery points before modifications.

## Customization Points

### Weather Configuration
- Update location in `plugins/weather_enhanced.sh`
- Modify weather API endpoints as needed

### App Icon Mapping
- Extend `plugins/icon_map.sh` for new applications
- Icons use SF Symbols and Unicode characters

### Workspace Behavior
- Modify space configuration in `sketchybarrc` (lines 144-167)
- Adjust `plugins/space.sh` for custom workspace logic

### System Integration
- Yabai integration through `plugins/yabai.sh`
- Custom shortcuts in `plugins/shortcuts.sh`
- System menu interactions in `plugins/system_menu.sh`