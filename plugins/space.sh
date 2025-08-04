#!/bin/bash

# Enhanced space script with animations
source "$CONFIG_DIR/colors.sh" 2>/dev/null || true
source "$HOME/.config/sketchybar/variables.sh"

update_space() {
  SPACE_ID=$(echo "$INFO" | jq -r '.space // empty')
  
  # Get windows for this space with more details
  WINDOWS=$(yabai -m query --windows --space $SPACE_ID 2>/dev/null)
  
  if [ "$WINDOWS" = "" ] || [ "$WINDOWS" = "null" ]; then
    icon_strip=""
  else
    # Group apps and create icon strip with grouping
    APPS=$(echo "$WINDOWS" | jq -r '.[].app' | sort -u)
    icon_strip=""
    app_count=0
    
    if [ "$APPS" != "" ]; then
      # Smart grouping: prioritize important apps, group similar ones
      priority_apps=""
      other_apps=""
      
      # Categorize apps by priority
      while IFS= read -r app; do
        case "$app" in
          "Google Chrome"|"Arc"|"Safari"|"Firefox"|"Code"|"Visual Studio Code"|"Terminal"|"iTerm2"|"Discord"|"Slack"|"Spotify"|"Finder")
            priority_apps+="$app"$'\n'
            ;;
          *)
            other_apps+="$app"$'\n'
            ;;
        esac
      done <<< "$APPS"
      
      # Show up to 3 apps total, prioritizing important ones
      display_apps=""
      if [ "$priority_apps" != "" ]; then
        display_apps=$(echo "$priority_apps" | head -2)
      fi
      
      # Fill remaining slots with other apps if needed
      remaining_slots=$((3 - $(echo "$display_apps" | wc -l | tr -d ' ')))
      if [ $remaining_slots -gt 0 ] && [ "$other_apps" != "" ]; then
        additional_apps=$(echo "$other_apps" | head -$remaining_slots)
        if [ "$display_apps" != "" ]; then
          display_apps+=$'\n'"$additional_apps"
        else
          display_apps="$additional_apps"
        fi
      fi
      
      # Build icon strip
      while IFS= read -r app; do
        if [ "$app" != "" ]; then
          app_icon=$(~/.config/sketchybar/plugins/icon_map.sh "$app")
          if [ "$icon_strip" = "" ]; then
            icon_strip="$app_icon"
          else
            icon_strip+="  $app_icon"
          fi
          app_count=$((app_count + 1))
        fi
      done <<< "$display_apps"
      
      # Add "+" if more apps exist
      total_apps=$(echo "$APPS" | wc -l | tr -d ' ')
      if [ $total_apps -gt 3 ]; then
        icon_strip+="  +"
      fi
    fi
  fi

  # DRAMATIC animations with highly visible feedback
  if [ "$SELECTED" = "true" ]; then
    # Add dynamic indicator based on app count
    if [ $app_count -gt 0 ]; then
      indicator="●"
    else
      indicator="○"
    fi
    
    sketchybar --animate elastic 30 \
               --set $NAME background.drawing=on \
                           background.color=0xff89b4fa \
                           background.height=$WIDGET_HEIGHT \
                           background.border_color=0xff74c7ec \
                           background.border_width=3 \
                           background.shadow.drawing=on \
                           background.shadow.color=0x8089b4fa \
                           background.shadow.angle=270 \
                           background.shadow.distance=8 \
                           label.color=0xff11111b \
                           icon.color=0xff11111b \
                           icon="$SID $indicator" \
                           label="$icon_strip" \
                           icon.highlight=on \
                           icon.font="SF Pro:Black:16.0" \
                           label.font="sketchybar-app-font:Regular:16.0"
  else
    # Subtle indicator for inactive spaces
    if [ $app_count -gt 0 ]; then
      indicator="●"
      bg_color=0xff45475a
      height=$((WIDGET_HEIGHT - 4))
    else
      indicator="○"  
      bg_color=0xff313244
      height=$((WIDGET_HEIGHT - 6))
    fi
    
    sketchybar --animate elastic 25 \
               --set $NAME background.drawing=on \
                           background.color=$bg_color \
                           background.height=$height \
                           background.border_color=0xff585b70 \
                           background.border_width=1 \
                           background.shadow.drawing=off \
                           label.color=0xffcdd6f4 \
                           icon.color=0xffbac2de \
                           icon="$SID $indicator" \
                           label="$icon_strip" \
                           icon.highlight=off \
                           icon.font="SF Pro:Bold:14.0" \
                           label.font="sketchybar-app-font:Regular:14.0"
  fi
}

mouse_clicked() {
  # Dramatic click animation
  sketchybar --animate elastic 15 \
             --set $NAME background.height=$((WIDGET_HEIGHT + 2)) \
                         background.border_width=4 \
                         background.shadow.distance=12
  
  # Quick bounce back
  sleep 0.1
  sketchybar --animate elastic 15 \
             --set $NAME background.height=$WIDGET_HEIGHT \
                         background.border_width=3 \
                         background.shadow.distance=8
  
  if [ "$BUTTON" = "right" ]; then
    yabai -m space --destroy $SID
    sketchybar --trigger windows_on_spaces
  else
    yabai -m space --focus $SID 2>/dev/null
  fi
}

mouse_entered() {
  if [ "$SELECTED" != "true" ]; then
    sketchybar --animate elastic 20 \
               --set $NAME background.color=0xff74c7ec \
                           background.border_color=0xff89b4fa \
                           background.border_width=2 \
                           background.height=$((WIDGET_HEIGHT - 2)) \
                           background.shadow.drawing=on \
                           background.shadow.color=0x4074c7ec \
                           background.shadow.angle=270 \
                           background.shadow.distance=4 \
                           icon.color=0xff11111b \
                           label.color=0xff11111b
  fi
}

mouse_exited() {
  if [ "$SELECTED" != "true" ]; then
    # Determine background color and height based on app count
    if [ $app_count -gt 0 ]; then
      bg_color=0xff45475a
      height=$((WIDGET_HEIGHT - 4))
    else
      bg_color=0xff313244
      height=$((WIDGET_HEIGHT - 6))
    fi
    
    sketchybar --animate elastic 20 \
               --set $NAME background.color=$bg_color \
                           background.border_color=0xff585b70 \
                           background.border_width=1 \
                           background.height=$height \
                           background.shadow.drawing=off \
                           icon.color=0xffbac2de \
                           label.color=0xffcdd6f4
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "mouse.entered") mouse_entered ;;
  "mouse.exited") mouse_exited ;;
  *) update_space ;;
esac