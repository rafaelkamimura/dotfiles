#!/bin/bash

# Apple Menu - Integrated system controls
sketchybar --add item apple.logo left                      \
           --set apple.logo icon="􀣺"                       \
                            icon.font="$FONT:Regular:15.0"  \
                            icon.color=$BLUE               \
                            icon.y_offset=0                \
                            label.drawing=off              \
                            background.drawing=on          \
                            background.color=$ITEM_BG_COLOR \
                            background.corner_radius=$CORNER_RADIUS \
                            background.border_width=$BORDER_WIDTH \
                            background.border_color=$SURFACE1 \
                            padding_left=$PADDINGS         \
                            padding_right=$PADDINGS        \
                            y_offset=0                     \
                            popup.background.color=$POPUP_BACKGROUND_COLOR \
                            popup.background.corner_radius=$POPUP_CORNER_RADIUS \
                            popup.background.border_width=$BORDER_WIDTH \
                            popup.background.border_color=$POPUP_BORDER_COLOR \
                            click_script="$PLUGIN_DIR/apple.sh" \
           --subscribe apple.logo mouse.clicked mouse.entered mouse.exited

# Apple menu items
sketchybar --add item apple.about popup.apple.logo        \
           --add item apple.activity popup.apple.logo     \
           --add item apple.preferences popup.apple.logo  \
           --add item apple.separator1 popup.apple.logo   \
           --add item apple.sleep popup.apple.logo        \
           --add item apple.lock popup.apple.logo         \
           --add item apple.separator2 popup.apple.logo   \
           --add item apple.restart popup.apple.logo      \
           --add item apple.shutdown popup.apple.logo     \
           --set apple.about icon="ℹ️"                     \
                             label="About This Mac"        \
                             click_script="system_profiler SPSoftwareDataType | head -10 | osascript -e 'display dialog (do shell script \"cat\") with title \"About This Mac\"'" \
           --set apple.activity icon="📊"                  \
                                label="Activity Monitor"   \
                                click_script="open -a 'Activity Monitor'; sketchybar --set apple.logo popup.drawing=off" \
           --set apple.preferences icon="⚙️"               \
                                   label="System Preferences" \
                                   click_script="open -a 'System Preferences'; sketchybar --set apple.logo popup.drawing=off" \
           --set apple.separator1 icon="─────────────────" \
                                  label.drawing=off        \
                                  background.drawing=off   \
           --set apple.sleep icon="😴"                     \
                             label="Sleep"                 \
                             click_script="pmset sleepnow; sketchybar --set apple.logo popup.drawing=off" \
           --set apple.lock icon="🔒"                      \
                            label="Lock Screen"            \
                            click_script="/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend; sketchybar --set apple.logo popup.drawing=off" \
           --set apple.separator2 icon="─────────────────" \
                                  label.drawing=off        \
                                  background.drawing=off   \
           --set apple.restart icon="🔄"                   \
                               label="Restart"             \
                               click_script="osascript -e 'tell app \"System Events\" to restart'; sketchybar --set apple.logo popup.drawing=off" \
           --set apple.shutdown icon="⏻"                   \
                                label="Shut Down"          \
                                click_script="osascript -e 'tell app \"System Events\" to shut down'; sketchybar --set apple.logo popup.drawing=off"