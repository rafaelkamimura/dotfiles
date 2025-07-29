#!/bin/bash

# Workspace overview showing all spaces with their apps
update_workspace_overview() {
    # Get current space and only show spaces with windows + current space
    CURRENT_SPACE=$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index')
    SPACES=$(yabai -m query --spaces 2>/dev/null)
    
    if [ "$SPACES" = "" ] || [ "$SPACES" = "null" ]; then
        sketchybar --set $NAME drawing=off
        return
    fi
    
    overview_text=""
    space_count=$(echo "$SPACES" | jq length)
    
    # Only show first 5 spaces to prevent overflow
    max_spaces=5
    if [ $space_count -gt $max_spaces ]; then
        space_count=$max_spaces
    fi
    
    for ((i=0; i<space_count; i++)); do
        space_info=$(echo "$SPACES" | jq -r ".[$i]")
        space_id=$(echo "$space_info" | jq -r '.index')
        space_focused=$(echo "$space_info" | jq -r '.["has-focus"]')
        
        # Get windows for this space
        windows=$(yabai -m query --windows --space $space_id 2>/dev/null)
        
        if [ "$windows" != "" ] && [ "$windows" != "null" ]; then
            # Get first 2 apps only to save space
            apps=$(echo "$windows" | jq -r '.[].app' | sort -u | head -2)
            app_icons=""
            app_count=0
            
            while IFS= read -r app; do
                if [ "$app" != "" ] && [ $app_count -lt 2 ]; then
                    app_icon=$(~/.config/sketchybar/plugins/icon_map.sh "$app")
                    app_icons+="$app_icon"
                    app_count=$((app_count + 1))
                fi
            done <<< "$apps"
            
            # Add "+" if more apps exist
            total_apps=$(echo "$windows" | jq -r '.[].app' | sort -u | wc -l | tr -d ' ')
            if [ $total_apps -gt 2 ]; then
                app_icons+="+"
            fi
            
            # Format space display - more compact
            if [ "$space_focused" = "true" ]; then
                overview_text+="●$space_id$app_icons "
            else
                overview_text+="○$space_id$app_icons "
            fi
        else
            # Only show current space if empty
            if [ "$space_focused" = "true" ]; then
                overview_text+="●$space_id "
            fi
        fi
    done
    
    sketchybar --set $NAME label="$overview_text" drawing=on
}

case "$SENDER" in
    "windows_on_spaces"|"space_change"|"forced") 
        update_workspace_overview
        ;;
    *)
        update_workspace_overview
        ;;
esac