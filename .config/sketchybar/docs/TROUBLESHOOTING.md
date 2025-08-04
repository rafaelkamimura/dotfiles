# SketchyBar Troubleshooting Guide

## Common Issues and Solutions

### Configuration Issues

#### SketchyBar Not Loading
**Problem:** Configuration doesn't load or widgets don't appear

**Solutions:**
1. **Check configuration syntax:**
   ```bash
   # Test configuration manually
   bash -n ~/.config/sketchybar/sketchybarrc
   ```

2. **Verify file permissions:**
   ```bash
   chmod +x ~/.config/sketchybar/sketchybarrc
   chmod +x ~/.config/sketchybar/variables.sh
   chmod +x ~/.config/sketchybar/items/*.sh
   chmod +x ~/.config/sketchybar/plugins/*.sh
   ```

3. **Check SketchyBar service:**
   ```bash
   brew services restart sketchybar
   ```

4. **View logs:**
   ```bash
   tail -f /opt/homebrew/var/log/sketchybar.log
   ```

#### Variables Not Loading
**Problem:** Colors or constants from `variables.sh` not applied

**Solutions:**
1. **Verify sourcing in `sketchybarrc`:**
   ```bash
   source "$HOME/.config/sketchybar/variables.sh"
   ```

2. **Check variable export statements:**
   ```bash
   # Variables must be exported
   export ITEM_BG_COLOR=0xff1e1e2e
   ```

3. **Test variable loading:**
   ```bash
   source ~/.config/sketchybar/variables.sh
   echo $ITEM_BG_COLOR
   ```

#### Individual Widget Not Appearing
**Problem:** Specific widget missing from bar

**Solutions:**
1. **Check item file sourcing:**
   ```bash
   # Verify line exists in sketchybarrc
   source "$HOME/.config/sketchybar/items/widget_name.sh"
   ```

2. **Test widget file independently:**
   ```bash
   source ~/.config/sketchybar/variables.sh
   bash ~/.config/sketchybar/items/widget_name.sh
   ```

3. **Check widget syntax:**
   ```bash
   # Verify proper sketchybar command structure
   sketchybar --add item widget_name position
   ```

### Plugin Script Issues

#### Scripts Not Executing
**Problem:** Widget data not updating or scripts failing

**Solutions:**
1. **Verify script permissions:**
   ```bash
   chmod +x ~/.config/sketchybar/plugins/script_name.sh
   ```

2. **Test script manually:**
   ```bash
   cd ~/.config/sketchybar/plugins
   ./script_name.sh
   ```

3. **Check script dependencies:**
   ```bash
   # Ensure required commands exist
   which jq    # JSON processing
   which bc    # Calculator
   which curl  # Network requests
   ```

4. **Debug script execution:**
   ```bash
   # Add debug output to script
   echo "DEBUG: Script starting" >> /tmp/sketchybar_debug.log
   ```

#### Apple Menu Not Working
**Problem:** Apple menu popup not appearing or actions failing

**Solutions:**
1. **Check popup configuration:**
   ```bash
   sketchybar --query apple.logo | jq '.popup'
   ```

2. **Verify plugin script:**
   ```bash
   bash ~/.config/sketchybar/plugins/apple.sh
   ```

3. **Test popup toggle:**
   ```bash
   sketchybar --set apple.logo popup.drawing=toggle
   ```

### Visual Issues

#### Colors Not Applied
**Problem:** Widgets using wrong colors or default colors

**Solutions:**
1. **Check color format:**
   ```bash
   # Must be in format 0xffRRGGBB or 0xaaRRGGBB
   export WHITE=0xffcdd6f4  # Correct
   export WHITE=cdd6f4      # Incorrect
   ```

2. **Verify variable expansion:**
   ```bash
   # Test color variable
   echo $WHITE
   sketchybar --set test_item icon.color=$WHITE
   ```

3. **Check alpha channel:**
   ```bash
   # 0xff = fully opaque, 0x00 = fully transparent
   export BAR_COLOR=0xee11111b  # Slightly transparent
   ```

#### Widgets Overlapping or Misaligned
**Problem:** Layout issues with widget positioning

**Solutions:**
1. **Check padding values:**
   ```bash
   # Adjust padding in variables.sh
   export PADDINGS=6  # Reduce if too spaced
   ```

2. **Verify widget order:**
   ```bash
   # Items are positioned in order they're added
   # Check sequence in sketchybarrc
   ```

3. **Test bracket grouping:**
   ```bash
   # Remove brackets temporarily to isolate issue
   # sketchybar --remove bracket group_name
   ```

#### Fonts Not Loading
**Problem:** Icons or text displaying incorrectly

**Solutions:**
1. **Verify SF Symbols availability:**
   ```bash
   # Test SF Symbol rendering
   sketchybar --set test_item icon="􀣺"
   ```

2. **Check font specification:**
   ```bash
   # Correct format: "Family:Style:Size"
   icon.font="SF Pro:Bold:16.0"
   ```

3. **Install required fonts:**
   ```bash
   # Install sketchybar-app-font if needed
   brew tap homebrew/cask-fonts
   brew install font-sketchybar-app-font
   ```

### Performance Issues

#### High CPU Usage
**Problem:** SketchyBar consuming excessive resources

**Solutions:**
1. **Check update frequencies:**
   ```bash
   # Reduce frequency for non-critical widgets
   update_freq=30  # Instead of update_freq=1
   ```

2. **Use conditional updates:**
   ```bash
   # Add to widget configuration
   updates=when_shown
   ```

3. **Optimize plugin scripts:**
   ```bash
   # Cache expensive operations
   # Avoid unnecessary external command calls
   ```

#### Slow Startup
**Problem:** Configuration takes long to load

**Solutions:**
1. **Profile startup time:**
   ```bash
   time sketchybar --reload
   ```

2. **Minimize expensive operations in scripts:**
   ```bash
   # Move heavy computation to background processes
   # Use simple initial values, update later
   ```

3. **Reduce number of widgets:**
   ```bash
   # Comment out non-essential widgets temporarily
   # source "$HOME/.config/sketchybar/items/optional_widget.sh"
   ```

### System Integration Issues

#### Workspace Detection Not Working
**Problem:** Space indicators not updating correctly

**Solutions:**
1. **Check yabai integration:**
   ```bash
   # Verify yabai is running
   yabai --check-sa
   ```

2. **Test space detection:**
   ```bash
   # Test space script manually
   bash ~/.config/sketchybar/plugins/space.sh
   ```

3. **Verify event subscriptions:**
   ```bash
   # Check space event subscription
   sketchybar --query space.1 | jq '.events'
   ```

#### Front App Detection Issues
**Problem:** Current app not displaying correctly

**Solutions:**
1. **Check app detection:**
   ```bash
   # Test current app detection
   osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'
   ```

2. **Update icon mapping:**
   ```bash
   # Add missing apps to plugins/icon_map.sh
   ```

3. **Test app switch events:**
   ```bash
   # Monitor front_app_switched events
   sketchybar --query front_app | jq '.events'
   ```

## Debugging Tools

### Configuration Testing
```bash
# Test specific widget
sketchybar --add item test_widget right --set test_widget label="Test"

# Query widget state
sketchybar --query widget_name

# Remove test widget
sketchybar --remove item test_widget
```

### Log Monitoring
```bash
# Monitor SketchyBar logs
tail -f /opt/homebrew/var/log/sketchybar.log

# Monitor system logs
log show --predicate 'subsystem == "sketchybar"' --info --last 5m
```

### Script Debugging
```bash
# Add debug output to scripts
echo "DEBUG: $VARIABLE_NAME = $VALUE" >> /tmp/debug.log

# Test script isolation
PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
NAME="test_widget"
source ~/.config/sketchybar/variables.sh
bash "$PLUGIN_DIR/script_name.sh"
```

## Maintenance Tasks

### Regular Cleanup
```bash
# Clean old log files
rm /tmp/sketchybar_debug.log

# Reset configuration
sketchybar --reload

# Restart service
brew services restart sketchybar
```

### Backup Configuration
```bash
# Create backup before major changes
cp -r ~/.config/sketchybar ~/.config/sketchybar.backup

# Version control recommended
cd ~/.config/sketchybar
git init
git add .
git commit -m "Working configuration"
```

### Performance Monitoring
```bash
# Monitor SketchyBar process
top -pid $(pgrep sketchybar)

# Check memory usage
ps aux | grep sketchybar

# Monitor script execution
time bash ~/.config/sketchybar/plugins/script_name.sh
```

## Getting Help

### Community Resources
- **GitHub Issues:** Check existing issues and solutions
- **Documentation:** Official SketchyBar documentation
- **Examples:** Community configuration examples

### Diagnostic Information
When seeking help, provide:
- macOS version: `sw_vers`
- SketchyBar version: `sketchybar --version`
- Configuration files (sanitized)
- Error logs
- Steps to reproduce

### Common Error Messages

#### "command not found: sketchybar"
```bash
# Install or reinstall SketchyBar
brew install sketchybar
```

#### "No such file or directory"
```bash
# Check file paths in configuration
# Ensure all referenced files exist
ls -la ~/.config/sketchybar/items/
```

#### "Permission denied"
```bash
# Fix file permissions
chmod +x ~/.config/sketchybar/sketchybarrc
```

#### "Variable not found"
```bash
# Check variable sourcing and export statements
source ~/.config/sketchybar/variables.sh
```