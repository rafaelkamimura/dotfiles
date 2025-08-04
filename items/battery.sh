#!/bin/bash

# Battery monitoring
sketchybar --add item battery right                           \
           --set battery icon="􀋊"                             \
                         icon.font="$FONT:Regular:15.0"        \
                         icon.padding_left=$ICON_PADDINGS_NORMAL \
                         icon.padding_right=$ICON_PADDINGS_NORMAL \
                         icon.y_offset=0                     \
                         icon.color=$ICON_COLOR              \
                         label.font="$FONT:Semibold:13.0"    \
                         label.color=$LABEL_COLOR             \
                         label.padding_left=$LABEL_PADDINGS_TIGHT \
                         label.padding_right=$LABEL_PADDINGS_NORMAL \
                         background.drawing=on                \
                         background.color=$ITEM_BG_COLOR      \
                         background.corner_radius=$CORNER_RADIUS \
                         background.border_width=$BORDER_WIDTH \
                         background.border_color=$SURFACE1    \
                         padding_left=$PADDINGS_NORMAL        \
                         padding_right=$WIDGET_GAP_NORMAL     \
                         y_offset=0                           \
                         update_freq=30                       \
                         script="$PLUGIN_DIR/battery.sh"     \
           --subscribe battery system_woke power_source_change