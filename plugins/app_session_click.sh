#!/bin/bash

# App Session Click Handler - Handle clicks on app session items
# Provides app switching, context menus, and hover effects

source "$HOME/.config/sketchybar/variables.sh"

# Get app name and state from environment variables
ENV_VAR_BASE="SKETCHYBAR_${NAME//./_}"
APP_NAME=$(eval echo \$${ENV_VAR_BASE}_APP_NAME)
APP_STATE=$(eval echo \$${ENV_VAR_BASE}_APP_STATE)

# Fallback: try to extract from item name if env vars not available
if [ -z "$APP_NAME" ]; then
    # Extract app name from item name (remove prefix and convert underscores back)
    APP_NAME=$(echo "$NAME" | sed "s/^app_session\.app\.//" | sed 's/_/ /g' | sed 's/\b\w/\U&/g')
    APP_STATE="normal"  # Default state
fi

# Animation function for click feedback
animate_click() {
    local item_name="$1"
    
    # Quick scale animation for click feedback
    sketchybar --animate elastic 10 \
               --set "$item_name" background.height=$((WIDGET_HEIGHT + 4)) \
                                  background.border_width=3
    
    # Return to normal quickly
    sleep 0.1
    sketchybar --animate elastic 10 \
               --set "$item_name" background.height=$WIDGET_HEIGHT \
                                  background.border_width=2
}

# Show application context menu
show_context_menu() {
    local app_name="$1"
    
    # Create context menu items
    local menu_items="Activate|Minimize|Hide|Show All Windows|Quit"
    
    # Use AppleScript to show context menu (simplified approach)
    local choice
    choice=$(osascript -e "
        set menuList to {\"Activate\", \"Minimize\", \"Hide\", \"Show All Windows\", \"Quit\"}
        set selectedItem to choose from list menuList with prompt \"$app_name Options:\" default items {\"Activate\"}
        if selectedItem is not false then
            return item 1 of selectedItem
        else
            return \"Cancel\"
        end if
    " 2>/dev/null)
    
    case "$choice" in
        "Activate")
            activate_application "$app_name"
            ;;
        "Minimize")
            minimize_application "$app_name"
            ;;
        "Hide")
            hide_application "$app_name"
            ;;
        "Show All Windows")
            show_all_windows "$app_name"
            ;;
        "Quit")
            quit_application "$app_name"
            ;;
    esac
}

# Activate application
activate_application() {
    local app_name="$1"
    
    osascript -e "
        tell application \"$app_name\" to activate
    " 2>/dev/null
    
    # Trigger app session update
    $HOME/.config/sketchybar/plugins/app_session.sh update &
}

# Minimize application
minimize_application() {
    local app_name="$1"
    
    osascript -e "
        tell application \"System Events\"
            tell process \"$app_name\"
                try
                    set visible to false
                end try
            end tell
        end tell
    " 2>/dev/null
    
    # Trigger app session update
    $HOME/.config/sketchybar/plugins/app_session.sh update &
}

# Hide application
hide_application() {
    local app_name="$1"
    
    osascript -e "
        tell application \"$app_name\"
            try
                set visible to false
            end try
        end tell
    " 2>/dev/null
    
    # Trigger app session update
    $HOME/.config/sketchybar/plugins/app_session.sh update &
}

# Show all windows of application
show_all_windows() {
    local app_name="$1"
    
    osascript -e "
        tell application \"$app_name\"
            activate
        end tell
        tell application \"System Events\"
            tell process \"$app_name\"
                try
                    set visible to true
                    # Bring all windows to front
                    set allWindows to every window
                    repeat with theWindow in allWindows
                        try
                            perform action \"AXRaise\" of theWindow
                        end try
                    end repeat
                end try
            end tell
        end tell
    " 2>/dev/null
    
    # Trigger app session update
    $HOME/.config/sketchybar/plugins/app_session.sh update &
}

# Quit application
quit_application() {
    local app_name="$1"
    
    # Confirm quit for important applications
    case "$app_name" in
        "Finder"|"System Preferences"|"System Settings")
            # Don't quit system apps
            echo "Cannot quit system application: $app_name"
            return
            ;;
    esac
    
    osascript -e "
        tell application \"$app_name\" to quit
    " 2>/dev/null
    
    # Trigger app session update after a short delay
    sleep 0.5
    $HOME/.config/sketchybar/plugins/app_session.sh update &
}

# Handle mouse hover enter
mouse_entered() {
    local current_bg_color
    local hover_color
    
    # Get current background color and determine hover color
    case "$APP_STATE" in
        "active")
            hover_color=0xff74c7ec  # Lighter blue for active
            ;;
        *)
            hover_color=$HOVER_COLOR  # Standard hover color
            ;;
    esac
    
    # Hover animation
    sketchybar --animate elastic 15 \
               --set "$NAME" background.color="$hover_color" \
                             background.border_width=2 \
                             background.height=$((WIDGET_HEIGHT + 2))
}

# Handle mouse hover exit
mouse_exited() {
    # Restore original state colors
    local bg_color icon_alpha label_alpha height border_width
    
    case "$APP_STATE" in
        "active")
            bg_color=$BLUE
            icon_alpha=1.0
            label_alpha=1.0
            height=$WIDGET_HEIGHT
            border_width=2
            ;;
        "normal")
            bg_color=$SURFACE1
            icon_alpha=1.0
            label_alpha=1.0
            height=$((WIDGET_HEIGHT - 2))
            border_width=1
            ;;
        "minimized")
            bg_color=$GREY
            icon_alpha=0.7
            label_alpha=0.7
            height=$((WIDGET_HEIGHT - 4))
            border_width=1
            ;;
        "hidden")
            bg_color=$SURFACE0
            icon_alpha=0.5
            label_alpha=0.5
            height=$((WIDGET_HEIGHT - 6))
            border_width=1
            ;;
        *)
            bg_color=$SURFACE1
            icon_alpha=1.0
            label_alpha=1.0
            height=$((WIDGET_HEIGHT - 2))
            border_width=1
            ;;
    esac
    
    # Return to normal state
    sketchybar --animate elastic 15 \
               --set "$NAME" background.color="$bg_color" \
                             background.border_width="$border_width" \
                             background.height="$height"
}

# Handle different events
case "$SENDER" in
    "mouse.clicked")
        if [ -n "$APP_NAME" ]; then
            # Animate click
            animate_click "$NAME"
            
            case "$BUTTON" in
                "left")
                    # Left click: activate application
                    activate_application "$APP_NAME"
                    ;;
                "right")
                    # Right click: show context menu
                    show_context_menu "$APP_NAME"
                    ;;
                "middle")
                    # Middle click: minimize/restore
                    if [ "$APP_STATE" = "minimized" ] || [ "$APP_STATE" = "hidden" ]; then
                        activate_application "$APP_NAME"
                    else
                        minimize_application "$APP_NAME"
                    fi
                    ;;
            esac
        fi
        ;;
    "mouse.entered")
        mouse_entered
        ;;
    "mouse.exited")
        mouse_exited
        ;;
esac