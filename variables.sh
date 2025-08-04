#!/bin/bash

# Darker Catppuccin Mocha Theme - Enhanced for Premium Look
# Color Palette
export BLACK=0xff11111b
export WHITE=0xffcdd6f4
export RED=0xfff38ba8
export GREEN=0xffa6e3a1
export BLUE=0xff89b4fa
export YELLOW=0xfff9e2af
export ORANGE=0xfffab387
export MAGENTA=0xffcba6f7
export GREY=0xff6c7086
export TRANSPARENT=0x00000000

# Surface Colors (Catppuccin Mocha)
export BASE=0xff1e1e2e
export MANTLE=0xff181825
export CRUST=0xff11111b
export SURFACE0=0xff313244
export SURFACE1=0xff45475a
export SURFACE2=0xff585b70

# Theme Colors
export BAR_COLOR=0xee11111b
export ITEM_BG_COLOR=0xff1e1e2e
export ACCENT_COLOR=$BLUE
export HOVER_COLOR=0xff45475a
export ICON_COLOR=$WHITE
export LABEL_COLOR=$WHITE

# Typography
export FONT="SF Pro"
export NERD_FONT="Hack Nerd Font"

# Layout Constants - Optimized for 38px bar height
# Widget padding (internal content spacing) - Optimized for better alignment
export PADDINGS_TIGHT=2      # For small widgets like spaces, apple logo - tighter
export PADDINGS_NORMAL=4     # For standard widgets - reduced
export PADDINGS_WIDE=6       # For wider content widgets like front_app, media - reduced

# Icon and label specific padding - Optimized for perfect alignment
export ICON_PADDINGS_TIGHT=2    # Icons with no labels - tighter
export ICON_PADDINGS_NORMAL=3   # Icons with labels - reduced
export LABEL_PADDINGS_TIGHT=3   # Compact labels - reduced
export LABEL_PADDINGS_NORMAL=4  # Standard labels - reduced
export LABEL_PADDINGS_WIDE=5    # Wide labels like media - reduced

# Inter-widget spacing (gaps between widgets) - Optimized for tighter layout
export WIDGET_GAP_SMALL=1      # Within groups (like spaces) - tighter
export WIDGET_GAP_NORMAL=3     # Between regular widgets - reduced 
export WIDGET_GAP_LARGE=6      # Between widget groups - reduced

# Group bracket spacing
export GROUP_PADDING=6         # Internal padding for grouped brackets

export CORNER_RADIUS=12
export BORDER_WIDTH=1
export SHADOW=on

# Alignment Constants
export BAR_HEIGHT=38
export WIDGET_HEIGHT=36
export WIDGET_MARGIN=1  # (38-36)/2 = 1px margin top/bottom for perfect centering

# Popup Styling
export POPUP_BACKGROUND_COLOR=$SURFACE0
export POPUP_BORDER_COLOR=$SURFACE1
export POPUP_CORNER_RADIUS=10