# SketchyBar Theming Guide

## Theme System Overview

The configuration uses a centralized theming system in `variables.sh` based on the **Catppuccin Mocha** color palette, adapted for a darker, cleaner aesthetic.

## Color Palette

### Base Colors (Catppuccin Mocha)
```bash
# Primary Colors
export BLACK=0xff11111b      # Deep black base
export WHITE=0xffcdd6f4      # High contrast white text
export RED=0xfff38ba8        # Error/danger states
export GREEN=0xffa6e3a1      # Success/positive states
export BLUE=0xff89b4fa       # Primary accent color
export YELLOW=0xfff9e2af     # Warning states
export ORANGE=0xfffab387     # Secondary accent
export MAGENTA=0xffcba6f7    # Tertiary accent
export GREY=0xff6c7086       # Muted elements
```

### Surface Colors
```bash
export BASE=0xff1e1e2e       # Primary background
export MANTLE=0xff181825     # Secondary background
export CRUST=0xff11111b      # Deepest background
export SURFACE0=0xff313244   # Elevated surface
export SURFACE1=0xff45475a   # Border color
export SURFACE2=0xff585b70   # Higher contrast borders
```

### Semantic Colors
```bash
export BAR_COLOR=0xee11111b          # Bar background (with transparency)
export ITEM_BG_COLOR=0xff1e1e2e      # Widget background
export ACCENT_COLOR=$BLUE            # Primary accent
export HOVER_COLOR=0xff45475a        # Hover states
export ICON_COLOR=$WHITE             # Icon color
export LABEL_COLOR=$WHITE            # Text color
```

## Typography

### Font Configuration
```bash
export FONT="SF Pro"                 # System font family
export NERD_FONT="sketchybar-app-font"  # Icon font for apps
```

### Font Usage Patterns
- **Icons:** `$FONT:Bold:14.0` or `$FONT:Bold:16.0`
- **Labels:** `$FONT:Semibold:13.0` or `$FONT:Bold:12.0`
- **App Icons:** `$NERD_FONT:Regular:16.0`

## Layout Constants

### Spacing System
```bash
export PADDINGS=6            # General widget padding
export ICON_PADDINGS=8       # Icon-specific padding
export LABEL_PADDINGS=8      # Label-specific padding
```

### Visual Properties
```bash
export CORNER_RADIUS=12      # Widget corner radius
export BORDER_WIDTH=1        # Border thickness
export SHADOW=on             # Enable shadows
```

### Popup Styling
```bash
export POPUP_BACKGROUND_COLOR=$SURFACE0    # Popup background
export POPUP_BORDER_COLOR=$SURFACE1        # Popup border
export POPUP_CORNER_RADIUS=10              # Popup corner radius
```

## Widget Color Assignments

### Left Side Widgets
- **Apple Menu:** Icon = `$BLUE` (primary accent)
- **Workspaces:** Icons = `$ICON_COLOR` (white)
- **Front App:** Icons/Labels = `$ICON_COLOR`/`$LABEL_COLOR`

### Right Side Widgets
- **CPU Monitor:** Icon = `$BLUE` (matches system theme)
- **Clock:** Icon = `$ORANGE` (warm accent for time)
- **Calendar:** Icon = `$GREEN` (positive/active indication)

## Customization Guide

### Changing the Theme
1. **Edit Color Values:** Modify hex values in `variables.sh`
2. **Reload Configuration:** Run `sketchybar --reload`
3. **Test Changes:** Verify all widgets update correctly

### Creating Color Variants

#### Light Theme Adaptation
```bash
# Light theme alternatives (commented in variables.sh)
export BLACK=0xffe1e1e6      # Light background
export WHITE=0xff181825      # Dark text
export BAR_COLOR=0xeee1e1e6  # Light bar
```

#### Custom Accent Colors
```bash
# Purple accent theme
export ACCENT_COLOR=$MAGENTA
export BLUE=$MAGENTA         # Override blue with purple
```

#### High Contrast Mode
```bash
# Increase contrast
export ITEM_BG_COLOR=0xff000000    # Pure black backgrounds
export BORDER_WIDTH=2              # Thicker borders
export WHITE=0xffffffff            # Pure white text
```

### Per-Widget Color Customization

#### Individual Widget Colors
Edit specific widget files in `items/` to override theme colors:

```bash
# In items/cpu.sh - Custom red CPU indicator
--set cpu icon.color=0xfff38ba8  # Red instead of blue
```

#### Icon Color Patterns
- **System widgets:** Use `$BLUE` for consistency
- **Time widgets:** Use `$ORANGE` for warmth
- **Status widgets:** Use `$GREEN` for positive states
- **Interactive widgets:** Use `$ACCENT_COLOR`

## Dark Theme Best Practices

### Contrast Guidelines
- **Text on Background:** White (`$WHITE`) on dark (`$BASE`)
- **Icons on Background:** High contrast colors on dark surfaces
- **Borders:** Subtle but visible (`$SURFACE1`)

### Visual Hierarchy
- **Primary Elements:** Full opacity colors
- **Secondary Elements:** Slightly transparent or muted
- **Disabled/Inactive:** `$GREY` or reduced opacity

### Accessibility Considerations
- **Color Blindness:** Don't rely solely on color for information
- **Contrast Ratios:** Maintain WCAG AA compliance where possible
- **Focus Indicators:** Clear hover and active states

## Theme Switching

### Runtime Theme Changes
```bash
# Quick theme switch (requires restart)
sed -i '' 's/export BLUE=0xff89b4fa/export BLUE=0xfff38ba8/' variables.sh
sketchybar --reload
```

### Theme Presets
Create alternative theme files:
- `variables-light.sh`
- `variables-contrast.sh`
- `variables-minimal.sh`

Switch by changing the source line in `sketchybarrc`:
```bash
source "$HOME/.config/sketchybar/variables-light.sh"
```

## Color Testing

### Visual Testing
1. Load configuration with `sketchybar --reload`
2. Check all widgets for proper color application
3. Test hover states and interactions
4. Verify popup menus (Apple menu)

### Color Picker Integration
Use macOS Color Picker to get hex values:
1. Open Digital Color Meter
2. Hold Shift+Command+C to copy hex values
3. Convert to SketchyBar format: `0xffRRGGBB`

## Advanced Theming

### Dynamic Color System
The modular architecture supports runtime color changes:

```bash
# Plugin script example for dynamic colors
CPU_USAGE=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
if [ $CPU_USAGE -gt 80 ]; then
    COLOR=$RED
elif [ $CPU_USAGE -gt 50 ]; then
    COLOR=$YELLOW  
else
    COLOR=$GREEN
fi
sketchybar --set cpu icon.color=$COLOR
```

### Gradient Effects
While SketchyBar doesn't support gradients, create visual depth with:
- Layered backgrounds with different opacities
- Subtle shadow effects
- Border color variations

### Theme Integration
Match macOS system appearance:
- Monitor system dark/light mode
- Adjust transparency based on wallpaper
- Coordinate with terminal and editor themes