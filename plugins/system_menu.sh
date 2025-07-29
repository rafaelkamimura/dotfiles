#!/bin/bash

# System shortcuts menu
sketchybar --add item system.wifi popup.system \
           --set system.wifi icon="󰖩" \
                             label="Toggle WiFi" \
                             click_script="$PLUGIN_DIR/shortcuts.sh wifi_toggle; sketchybar --set system popup.drawing=off"

sketchybar --add item system.bluetooth popup.system \
           --set system.bluetooth icon="󰂯" \
                                  label="Toggle Bluetooth" \
                                  click_script="$PLUGIN_DIR/shortcuts.sh bluetooth_toggle; sketchybar --set system popup.drawing=off"

sketchybar --add item system.dnd popup.system \
           --set system.dnd icon="󰂛" \
                            label="Toggle Do Not Disturb" \
                            click_script="$PLUGIN_DIR/shortcuts.sh dnd_toggle; sketchybar --set system popup.drawing=off"

sketchybar --add item system.sleep popup.system \
           --set system.sleep icon="󰒲" \
                              label="Sleep" \
                              click_script="$PLUGIN_DIR/shortcuts.sh sleep; sketchybar --set system popup.drawing=off"

sketchybar --add item system.lock popup.system \
           --set system.lock icon="󰌾" \
                             label="Lock Screen" \
                             click_script="$PLUGIN_DIR/shortcuts.sh lock; sketchybar --set system popup.drawing=off"