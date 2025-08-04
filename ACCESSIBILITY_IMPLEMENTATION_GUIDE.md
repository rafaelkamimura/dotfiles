# SketchyBar Accessibility Implementation Guide

This guide provides step-by-step instructions for implementing the accessibility improvements identified in the accessibility audit report.

## Quick Start: Enable Accessibility Features

### 1. Replace Color Configuration
```bash
# Backup existing colors
cp colors.lua colors_original.lua

# Use accessible colors (choose one)
cp colors_accessible.lua colors.lua
```

### 2. Enable Motion-Reduced Animations
```bash
# Backup existing animations
cp helpers/animations.lua helpers/animations_original.lua

# Use accessible animations
cp helpers/animations_accessible.lua helpers/animations.lua
```

### 3. Add Keyboard Navigation
```bash
# Add keyboard navigation to your init.lua
echo 'local keyboard_nav = require("helpers.keyboard_navigation")' >> init.lua
echo 'keyboard_nav.init()' >> init.lua
```

## Implementation Phases

### Phase 1: Critical Fixes (Immediate)

#### Fix Color Contrast Issues
1. **Update colors.lua with accessible contrast ratios**
   ```lua
   -- Replace problematic grey color
   grey = 0xffb0b0b0,  -- Was 0xff7f8490 (insufficient contrast)
   ```

2. **Add alternative status indicators beyond color**
   ```lua
   -- Example: Battery with text indicators
   if charge <= 20 then
     label = charge .. "% LOW"
     border_color = colors.red
   end
   ```

#### Add Keyboard Navigation Foundation
1. **Include keyboard navigation helper**
   ```lua
   local keyboard_nav = require("helpers.keyboard_navigation")
   ```

2. **Register widgets as focusable**
   ```lua
   keyboard_nav.register_focusable(battery_widget, {
     name = "battery",
     description = "Battery status indicator",
     activate_handler = function()
       battery_widget:set({ popup = { drawing = "toggle" } })
     end
   })
   ```

### Phase 2: Screen Reader Support

#### Add VoiceOver Integration
1. **Install accessibility announcements**
   ```lua
   -- Announce important status changes
   local function announce_status(message)
     sbar.exec('say "' .. message .. '"')
   end
   ```

2. **Add text alternatives for icons**
   ```lua
   -- Example: Volume widget
   volume_widget:set({
     icon = icons.volume._100,
     -- Add hidden label for screen readers
     accessibility_label = "Volume at 100 percent"
   })
   ```

#### Implement Semantic Markup
```lua
-- Add ARIA-like properties to widgets
local accessible_widget = {
  role = "button",
  aria_label = "Battery status: 85% charged",
  aria_description = "Click to view battery details"
}
```

### Phase 3: Advanced Accessibility Features

#### Motion Sensitivity Support
1. **Detect system preferences**
   ```lua
   local function detect_reduce_motion()
     sbar.exec('defaults read com.apple.universalaccess reduceMotion', function(result)
       motion_preferences.reduce_motion = result:match("1") ~= nil
     end)
   end
   ```

2. **Provide animation alternatives**
   ```lua
   if motion_preferences.reduce_motion then
     -- Instant state change
     widget:set({ background = { color = new_color } })
   else
     -- Smooth animation
     animate_color_transition(widget, old_color, new_color)
   end
   ```

#### High Contrast Mode Support
```lua
local function apply_high_contrast_theme()
  return {
    black = 0xff000000,    -- Pure black
    white = 0xffffffff,    -- Pure white
    backgrounds = 0xff000000,
    borders = 0xffffffff
  }
end
```

## Widget-Specific Accessibility Improvements

### Battery Widget
```lua
-- Use the provided battery_accessible.lua example
local battery = require("items.widgets.battery_accessible")

-- Features included:
-- - WCAG compliant colors and contrast
-- - Keyboard navigation support
-- - Screen reader announcements
-- - Alternative status indicators
-- - Touch-friendly sizing (44px minimum)
```

### Volume Widget
```lua
-- Accessible volume implementation
local volume_accessible = sbar.add("item", "volume_accessible", {
  icon = {
    string = icons.volume._100,
    font = { size = 16.0 },  -- Minimum readable size
    color = colors.white
  },
  label = {
    string = "100%",
    font = { size = 16.0 }
  },
  background = {
    height = 44,  -- WCAG minimum touch target
    color = colors.bg1
  }
})

-- Add keyboard support
keyboard_nav.register_focusable(volume_accessible, {
  name = "volume_control",
  description = "Volume control slider",
  keyboard_hint = "Arrow keys to adjust, Space to mute",
  activate_handler = function()
    volume_accessible:set({ popup = { drawing = "toggle" } })
  end
})
```

### Spaces Widget
```lua
-- Accessible workspace indicator
for i = 1, 10 do
  local space = sbar.add("space", "space." .. i, {
    space = i,
    icon = {
      string = tostring(i),
      font = { size = 16.0 },  -- Increased for readability
      color = colors.white
    },
    background = {
      height = 44,  -- Touch-friendly
      color = colors.bg1,
      border_width = 2,
      border_color = colors.transparent
    }
  })
  
  -- Add descriptive labeling
  keyboard_nav.register_focusable(space, {
    name = "workspace_" .. i,
    description = "Workspace " .. i,
    aria_label = "Switch to workspace " .. i,
    activate_handler = function()
      sbar.exec("yabai -m space --focus " .. i)
    end
  })
end
```

## System Integration

### macOS Accessibility Services
```bash
# Enable accessibility permissions for SketchyBar
sudo tccutil reset Accessibility
# Then manually grant permission in System Preferences
```

### Global Keyboard Shortcuts
Create `/usr/local/bin/sketchybar-accessibility` script:
```bash
#!/bin/bash
# Global keyboard shortcuts for SketchyBar accessibility

case "$1" in
  "toggle-navigation")
    # Toggle keyboard navigation
    sketchybar --trigger toggle_keyboard_nav
    ;;
  "next-element")
    # Focus next element
    sketchybar --trigger focus_next
    ;;
  "prev-element")
    # Focus previous element
    sketchybar --trigger focus_prev
    ;;
  "activate")
    # Activate focused element
    sketchybar --trigger activate_focused
    ;;
esac
```

### BetterTouchTool Integration (Optional)
```json
{
  "BTTTriggerType": 0,
  "BTTGenericActionConfig": {
    "BTTShellTaskDefinition": "/usr/local/bin/sketchybar-accessibility toggle-navigation"
  },
  "BTTShortcutKeyCode": 40,
  "BTTShortcutModifierKeys": 1179648,
  "BTTTriggerName": "Toggle SketchyBar Keyboard Navigation"
}
```

## Testing and Validation

### Manual Testing Checklist
- [ ] All text meets 4.5:1 contrast ratio (use Color Oracle)
- [ ] Can navigate all widgets using Tab key
- [ ] Screen reader announces all status changes
- [ ] All interactive elements are 44px minimum
- [ ] High contrast mode works properly
- [ ] Reduced motion preferences are respected
- [ ] All widgets work without mouse

### Automated Testing
```bash
# Color contrast testing
python3 -c "
import subprocess
# Test contrast ratios programmatically
# (Implementation would use color analysis tools)
"

# Screen reader testing
osascript -e 'tell application "VoiceOver Utility" to set enabled of VoiceOver to true'
# Test with VoiceOver enabled
```

### User Testing
1. **Recruit users with disabilities**
   - Visual impairments
   - Motor impairments  
   - Cognitive disabilities

2. **Test scenarios**
   - Navigate using only keyboard
   - Use with screen reader
   - Test with 200% zoom
   - Use with reduced motion enabled

## Maintenance

### Regular Accessibility Audits
```bash
# Monthly accessibility check script
#!/bin/bash
echo "Running accessibility audit..."

# Check color contrast
python3 check_contrast.py

# Validate ARIA attributes
node validate_accessibility.js

# Test keyboard navigation
./test_keyboard_nav.sh
```

### Keeping Up with Standards
- Monitor WCAG guideline updates
- Test with new assistive technologies
- Gather user feedback regularly
- Update documentation as needed

## Troubleshooting

### Common Issues

#### "Keyboard navigation not working"
```bash
# Check if accessibility permissions are granted
tccutil list | grep Accessibility

# Reset and regrant permissions if needed
sudo tccutil reset Accessibility
```

#### "Screen reader not announcing changes"
```bash
# Check if VoiceOver is enabled
defaults read com.apple.universalaccess voiceOverOnOffKey

# Test say command
say "Testing screen reader integration"
```

#### "Colors still have poor contrast"
```bash
# Verify color values
python3 -c "
color = 0xff7f8490
r, g, b = (color >> 16) & 255, (color >> 8) & 255, color & 255
print(f'RGB: {r}, {g}, {b}')
"
```

## Resources

### WCAG 2.1 Guidelines
- [Web Content Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [macOS Accessibility Guidelines](https://developer.apple.com/accessibility/mac/)

### Testing Tools
- **Color Oracle**: Colorblind simulator
- **Colour Contrast Analyser**: WCAG contrast testing
- **VoiceOver**: macOS built-in screen reader
- **Accessibility Inspector**: macOS developer tool

### Community Resources
- [SketchyBar Accessibility Issues](https://github.com/FelixKratz/SketchyBar/issues)
- [macOS Accessibility Community](https://developer.apple.com/forums/tags/accessibility)

## Contributing

To contribute accessibility improvements:

1. **Test thoroughly** with assistive technologies
2. **Follow WCAG guidelines** for all changes
3. **Document accessibility features** in code comments
4. **Include test cases** for accessibility features
5. **Gather feedback** from users with disabilities

---

For questions or issues with accessibility features, please consult the main ACCESSIBILITY_AUDIT_REPORT.md file or open an issue in the SketchyBar repository.