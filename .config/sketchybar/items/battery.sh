#!/bin/bash

# Battery monitoring
sketchybar --add item battery right                           \
           --set battery icon="􀋊"                             \
                         icon.font="$FONT:Regular:15.0"        \
                         icon.y_offset=0                     \
                         icon.color=$ICON_COLOR              \
                         label.font="$FONT:Semibold:13.0"    \
                         label.color=$LABEL_COLOR             \
                         background.drawing=on                \
                         background.color=$ITEM_BG_COLOR      \
                         background.corner_radius=$CORNER_RADIUS \
                         background.border_width=$BORDER_WIDTH \
                         background.border_color=$SURFACE1    \
                         padding_left=$PADDINGS               \
                         padding_right=$PADDINGS              \
                         y_offset=0                           \
                         update_freq=30                       \
                         script="$PLUGIN_DIR/battery.sh"     \
           --subscribe battery system_woke power_source_change