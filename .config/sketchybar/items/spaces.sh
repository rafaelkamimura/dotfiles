#!/bin/bash

# Workspace indicators
SPACE_SIDS=(1 2 3 4 5 6 7 8 9 10)

for sid in "${SPACE_SIDS[@]}"
do
  sketchybar --add space space.$sid left                    \
             --set space.$sid space=$sid                     \
                              icon=$sid                      \
                              icon.font="$FONT:Regular:15.0" \
                              icon.padding_left=$ICON_PADDINGS \
                              icon.padding_right=$ICON_PADDINGS \
                              icon.color=$ICON_COLOR         \
                              icon.y_offset=0                \
                              label.drawing=off              \
                              background.drawing=on          \
                              background.height=28           \
                              background.corner_radius=$CORNER_RADIUS \
                              background.color=$ITEM_BG_COLOR \
                              background.border_width=$BORDER_WIDTH \
                              background.border_color=$SURFACE1 \
                              padding_left=$PADDINGS         \
                              padding_right=$PADDINGS        \
                              y_offset=0                     \
                              script="$PLUGIN_DIR/space.sh"  \
             --subscribe space.$sid mouse.clicked mouse.entered mouse.exited
done