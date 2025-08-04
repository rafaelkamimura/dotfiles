#!/bin/bash

# Enhanced App Dock - Shows actual app icons for open applications
# Uses the new app icon system with native macOS icons, SF Symbols, and fallbacks
source "$HOME/.config/sketchybar/variables.sh"

# Configuration
ICON_SYSTEM="$HOME/.config/sketchybar/plugins/app_icon_system.sh"
PREFER_NATIVE_ICONS=true  # Set to false to prefer SF Symbols over extracted icons

# Get list of apps using osascript
get_running_apps() {
    osascript -e 'tell application "System Events" to return name of every application process whose background only is false' 2>/dev/null | tr ',' '\n' | sed 's/^ *//' | head -8
}

# Get front app
get_front_app() {
    osascript -e 'tell application "System Events" to return name of first application process whose frontmost is true' 2>/dev/null
}

# Function to get icon information for an app
get_app_icon_info() {
    local app_name="$1"
    
    if [ -x "$ICON_SYSTEM" ]; then
        # Use the new comprehensive icon system
        "$ICON_SYSTEM" "$app_name" "$PREFER_NATIVE_ICONS"
    else
        # Fallback to old icon map system
        "$HOME/.config/sketchybar/plugins/icon_map.sh" "$app_name" 2>/dev/null || echo ""
    fi
}

# Function to determine if an icon is a file path
is_icon_file() {
    local icon="$1"
    [[ "$icon" == *"/"* ]] && [ -f "$icon" ]
}

# Function to get icon properties based on icon type
get_icon_properties() {
    local icon="$1"
    
    if is_icon_file "$icon"; then
        # For image files, optimize settings for better display
        echo "icon.font='SF Pro:Regular:16.0' icon.drawing=on"
    elif [[ "$icon" == :*: ]]; then
        # Nerd Font icon
        echo "icon.font='Hack Nerd Font:Regular:18.0'"
    else
        # SF Symbol, emoji, or other text
        echo "icon.font='SF Pro:Regular:18.0'"
    fi
}

# Create app items with enhanced icon system
update_app_dock() {
    # Clean up existing app dock items
    sketchybar --remove '/app_dock\..*/' >/dev/null 2>&1

    local apps front_app counter
    apps=$(get_running_apps)
    front_app=$(get_front_app)
    counter=1
    
    # Create items for each app
    while IFS= read -r app_name; do
        if [ -n "$app_name" ] && [ "$counter" -le 8 ]; then
            local item_name="app_dock.$counter"
            local app_icon
            
            # Get the app icon using the reliable emoji system
            app_icon=$("$HOME/.config/sketchybar/plugins/icon_map.sh" "$app_name")
            
            # Fallback if no icon found
            if [ -z "$app_icon" ]; then
                app_icon="📱"
            fi
            
            # Determine colors based on app state with better contrast
            local bg_color icon_color border_color
            if [ "$app_name" = "$front_app" ]; then
                bg_color=$BLUE
                icon_color=$BLACK
                border_color=$BLUE
            else
                bg_color=$SURFACE0
                icon_color=$WHITE
                border_color=$SURFACE1
            fi
            
            # Use standard font for emoji icons
            local icon_font="SF Pro:Regular:16.0"
            
            # Add the app item with simple reliable configuration
            sketchybar --add item "$item_name" left \
                       --set "$item_name" \
                             icon="$app_icon" \
                             icon.font="$icon_font" \
                             icon.color="$icon_color" \
                             icon.padding_left=6 \
                             icon.padding_right=6 \
                             label.drawing=off \
                             background.drawing=on \
                             background.color="$bg_color" \
                             background.corner_radius=$CORNER_RADIUS \
                             background.height=$WIDGET_HEIGHT \
                             background.border_width=1 \
                             background.border_color="$border_color" \
                             padding_left=2 \
                             padding_right=2 \
                             width=34 \
                             click_script="osascript -e 'tell application \"$app_name\" to activate'" \
                       --subscribe "$item_name" mouse.clicked
            
            counter=$((counter + 1))
        fi
    done <<< "$apps"
}

# Main execution
if [ "$SENDER" = "routine" ] || [ "$SENDER" = "app_dock_update" ] || [ -z "$SENDER" ]; then
    update_app_dock
fi