#!/bin/bash

# Front app display
sketchybar --add item front_app left                       \
           --set front_app icon.font="$FONT:Regular:15.0"      \
                           icon.y_offset=0                  \
                           icon.color=$ICON_COLOR           \
                           icon.padding_left=$ICON_PADDINGS \
                           icon.padding_right=$ICON_PADDINGS \
                           label.color=$LABEL_COLOR         \
                           label.font="$FONT:Semibold:13.0" \
                           label.padding_left=$LABEL_PADDINGS \
                           label.padding_right=$LABEL_PADDINGS \
                           y_offset=0                       \
                           background.drawing=on            \
                           background.color=$ITEM_BG_COLOR  \
                           background.corner_radius=$CORNER_RADIUS \
                           background.border_width=$BORDER_WIDTH \
                           background.border_color=$SURFACE1 \
                           padding_left=$PADDINGS           \
                           padding_right=$PADDINGS          \
                           script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched