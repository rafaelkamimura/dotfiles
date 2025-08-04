#!/bin/bash

# Media information (center)
sketchybar --add item media center                            \
           --set media icon="󰝚"                              \
                       icon.font="$FONT:Regular:15.0"         \
                       icon.y_offset=0                    \
                       icon.color=$ICON_COLOR                \
                       label.font="$FONT:Semibold:13.0"     \
                       label.color=$LABEL_COLOR              \
                       label.max_chars=30                    \
                       background.drawing=on                 \
                       background.color=$ITEM_BG_COLOR       \
                       background.corner_radius=$CORNER_RADIUS \
                       background.border_width=$BORDER_WIDTH \
                       background.border_color=$SURFACE1     \
                       padding_left=$PADDINGS                \
                       padding_right=$PADDINGS               \
                       y_offset=0                            \
                       scroll_texts=on                       \
                       script="$PLUGIN_DIR/media.sh"        \
           --subscribe media media_change