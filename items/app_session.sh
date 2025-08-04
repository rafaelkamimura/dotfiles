#!/bin/bash

# App Session - Dynamic Application Dock
# Creates a dynamic session bar showing all open applications with proper states

# Source configuration
source "$HOME/.config/sketchybar/variables.sh"

# App Session Container - Invisible container for organizing app items
sketchybar --add item app_session.container left \
           --set app_session.container drawing=off \
                                       associated_display=active \
                                       position=left \
                                       padding_left=$WIDGET_GAP_LARGE \
                                       padding_right=$WIDGET_GAP_NORMAL

# Initialize dynamic app session tracking
# This script will be called to populate apps dynamically
$HOME/.config/sketchybar/plugins/app_session.sh init

# Subscribe to application switching events to update states
sketchybar --add event app_switched \
           --add event app_minimized \
           --add event app_unhidden \
           --add event app_hidden \
           --add event app_launched \
           --add event app_terminated

echo "App session bar initialized"