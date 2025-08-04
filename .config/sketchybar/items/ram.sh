#!/bin/bash

# RAM monitoring
sketchybar --add item ram right                               \
           --set ram icon="󰍛"                                \
                     icon.font="$FONT:Regular:15.0"           \
                     icon.y_offset=0                        \
                     icon.color=$ICON_COLOR                  \
                     label.font="$FONT:Semibold:13.0"       \
                     label.color=$LABEL_COLOR                \
                     background.drawing=on                   \
                     background.color=$ITEM_BG_COLOR         \
                     background.corner_radius=$CORNER_RADIUS \
                     background.border_width=$BORDER_WIDTH   \
                     background.border_color=$SURFACE1       \
                     padding_left=$PADDINGS                  \
                     padding_right=$PADDINGS                 \
                     y_offset=0                              \
                     update_freq=5                           \
                     script="$PLUGIN_DIR/ram.sh"