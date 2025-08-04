#!/bin/bash

# App Session Manager - Dynamic Application Session Bar
# Manages all open applications with proper state visualization

source "$HOME/.config/sketchybar/variables.sh"

# Configuration
APP_SESSION_PREFIX="app_session"
APP_SESSION_ITEM_PREFIX="app_session.app"
MAX_APP_NAME_LENGTH=20
CACHE_FILE="/tmp/sketchybar_app_session_cache"

# App state colors (using theme colors)
ACTIVE_APP_COLOR=$BLUE           # 0xff89b4fa - Bright blue for focused app
NORMAL_APP_COLOR=$SURFACE1       # 0xff45475a - Normal state
MINIMIZED_APP_COLOR=$GREY        # 0xff6c7086 - Dimmed for minimized
HIDDEN_APP_COLOR=$SURFACE0       # 0xff313244 - Very dim for hidden
APP_BORDER_ACTIVE=$BLUE          # 0xff89b4fa - Active border
APP_BORDER_NORMAL=$SURFACE2      # 0xff585b70 - Normal border

# Get all non-background applications using AppleScript
get_all_apps() {
    # Get front app first
    local front_app
    front_app=$(osascript -e 'tell application "System Events" to return name of first application process whose frontmost is true' 2>/dev/null)
    
    # Get all app names
    local all_apps
    all_apps=$(osascript -e 'tell application "System Events" to return name of every application process whose background only is false' 2>/dev/null | tr ',' '\n' | sed 's/^ *//')
    
    # Process each app and determine state
    echo "$all_apps" | while IFS= read -r app_name; do
        if [ -n "$app_name" ] && [ "$app_name" != "" ]; then
            # Determine app state
            if [ "$app_name" = "$front_app" ]; then
                echo "${app_name}|active|1"
            else
                # For now, assume normal state with 1 window for simplicity
                # Can be enhanced later with more detailed window detection
                echo "${app_name}|normal|1"
            fi
        fi
    done
}

# Get current front application
get_front_app() {
    osascript -e 'tell application "System Events" to return name of first application process whose frontmost is true' 2>/dev/null
}

# Initialize app session bar
init_app_session() {
    echo "Initializing app session bar..."
    
    # Clear existing app items
    clear_app_items
    
    # Get all apps and create items
    update_app_session
    
    local final_count
    final_count=$(count_app_items)
    echo "App session bar initialized with $final_count apps"
}

# Clear all existing app session items
clear_app_items() {
    # Get list of existing app session items
    existing_items=$(sketchybar --query bar | jq -r '.items[]' | grep "^$APP_SESSION_ITEM_PREFIX" 2>/dev/null || true)
    
    if [ -n "$existing_items" ]; then
        echo "$existing_items" | while read -r item; do
            if [ -n "$item" ]; then
                sketchybar --remove "$item" 2>/dev/null || true
            fi
        done
    fi
}

# Count current app session items
count_app_items() {
    sketchybar --query bar 2>/dev/null | jq -r '.items[]' | grep -c "^$APP_SESSION_ITEM_PREFIX" 2>/dev/null || echo "0"
}

# Update entire app session
update_app_session() {
    local current_apps_data
    local cached_apps_data=""
    
    # Get current app data
    current_apps_data=$(get_all_apps)
    
    # Read cached data if exists
    if [ -f "$CACHE_FILE" ]; then
        cached_apps_data=$(cat "$CACHE_FILE")
    fi
    
    # Only update if apps have changed
    if [ "$current_apps_data" != "$cached_apps_data" ]; then
        echo "Apps changed, updating session bar..."
        
        # Clear existing items
        clear_app_items
        
        # Process each app (avoid subshell to ensure items are created)
        if [ -n "$current_apps_data" ]; then
            # Use process substitution instead of pipeline to avoid subshell
            while IFS='|' read -r app_name app_state window_count; do
                if [ -n "$app_name" ] && [ "$app_name" != "" ]; then
                    create_app_item "$app_name" "$app_state" "$window_count"
                fi
            done <<< "$current_apps_data"
        fi
        
        # Cache the current state
        echo "$current_apps_data" > "$CACHE_FILE"
        
        # Trigger bar update
        sketchybar --update
    fi
}

# Create or update individual app item
create_app_item() {
    local app_name="$1"
    local app_state="$2"
    local window_count="$3"
    
    # Clean app name for item ID (remove spaces and special chars)
    local clean_name=$(echo "$app_name" | sed 's/[^a-zA-Z0-9]/_/g' | tr '[:upper:]' '[:lower:]')
    local item_name="${APP_SESSION_ITEM_PREFIX}.${clean_name}"
    
    # Get app icon
    local app_icon
    app_icon=$(~/.config/sketchybar/plugins/icon_map.sh "$app_name")
    
    # Truncate long app names for display
    local display_name="$app_name"
    if [ ${#display_name} -gt $MAX_APP_NAME_LENGTH ]; then
        display_name="${display_name:0:$MAX_APP_NAME_LENGTH}..."
    fi
    
    # Determine colors and styling based on app state
    local bg_color icon_color label_color border_color border_width height
    
    case "$app_state" in
        "active")
            bg_color=$ACTIVE_APP_COLOR
            icon_color=$BLACK
            label_color=$BLACK
            border_color=$APP_BORDER_ACTIVE
            border_width=2
            height=$WIDGET_HEIGHT
            ;;
        "normal")
            bg_color=$NORMAL_APP_COLOR
            icon_color=$WHITE
            label_color=$WHITE
            border_color=$APP_BORDER_NORMAL
            border_width=1
            height=$((WIDGET_HEIGHT - 2))
            ;;
        "minimized")
            bg_color=$MINIMIZED_APP_COLOR
            icon_color=0xff9399b2  # Dimmed white
            label_color=0xff9399b2
            border_color=$APP_BORDER_NORMAL
            border_width=1
            height=$((WIDGET_HEIGHT - 4))
            ;;
        "hidden")
            bg_color=$HIDDEN_APP_COLOR
            icon_color=0xff6c7086  # Very dimmed
            label_color=0xff6c7086
            border_color=$APP_BORDER_NORMAL
            border_width=1
            height=$((WIDGET_HEIGHT - 6))
            ;;
        *)
            bg_color=$NORMAL_APP_COLOR
            icon_color=$WHITE
            label_color=$WHITE
            border_color=$APP_BORDER_NORMAL
            border_width=1
            height=$((WIDGET_HEIGHT - 2))
            ;;
    esac
    
    # Add window count indicator for apps with multiple windows
    local window_indicator=""
    if [ "$window_count" -gt 1 ]; then
        window_indicator="[$window_count]"
    fi
    
    # Create/update the app item
    sketchybar --add item "$item_name" left \
               --set "$item_name" \
                     associated_display=active \
                     icon="$app_icon" \
                     icon.font="$NERD_FONT:Regular:16.0" \
                     icon.color="$icon_color" \
                     icon.padding_left=$ICON_PADDINGS_NORMAL \
                     icon.padding_right=2 \
                     label="$window_indicator" \
                     label.font="$FONT:Medium:10.0" \
                     label.color="$label_color" \
                     label.padding_left=0 \
                     label.padding_right=$LABEL_PADDINGS_TIGHT \
                     background.color="$bg_color" \
                     background.height="$height" \
                     background.corner_radius=$CORNER_RADIUS \
                     background.border_width="$border_width" \
                     background.border_color="$border_color" \
                     background.drawing=on \
                     padding_left=$WIDGET_GAP_SMALL \
                     padding_right=$WIDGET_GAP_SMALL \
                     script="$HOME/.config/sketchybar/plugins/app_session_click.sh" \
               --subscribe "$item_name" mouse.clicked mouse.entered mouse.exited
    
    # Store app metadata in environment variables for the click script
    export "SKETCHYBAR_${item_name//./_}_APP_NAME"="$app_name"
    export "SKETCHYBAR_${item_name//./_}_APP_STATE"="$app_state"
}

# Update single app state (called when specific app changes)
update_app_state() {
    local target_app="$1"
    local new_state="$2"
    
    if [ -n "$target_app" ]; then
        local clean_name=$(echo "$target_app" | sed 's/[^a-zA-Z0-9]/_/g' | tr '[:upper:]' '[:lower:]')
        local item_name="${APP_SESSION_ITEM_PREFIX}.${clean_name}"
        
        # Check if item exists, if not create it, otherwise update
        if sketchybar --query "$item_name" >/dev/null 2>&1; then
            # Update existing item with new state
            update_app_session
        else
            # Item doesn't exist, refresh entire session
            update_app_session
        fi
    fi
}

# Handle different events
case "$1" in
    "init")
        init_app_session
        ;;
    "update")
        update_app_session
        ;;
    "app_switched")
        update_app_session  # Full update when apps switch
        ;;
    "refresh")
        init_app_session
        ;;
    *)
        # Default: update session
        update_app_session
        ;;
esac