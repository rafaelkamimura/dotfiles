# Premium SketchyBar Configuration

A professional, feature-rich SketchyBar setup with dynamic animations, contextual theming, and intelligent workspace management.

## ✨ Features

### 🖥️ Dynamic Workspaces
- **Smart app grouping** with priority system (browsers, editors, terminals first)
- **Visual indicators** showing occupied vs empty spaces
- **App icons** with 80+ application mappings
- **Dramatic hover animations** with elastic transitions
- **Click animations** with bounce effects

### 🌈 Three-Section Right Side
1. **Weather Group** - Dynamic colors based on conditions
2. **System Status** - Performance-reactive colors (CPU/RAM, Network, Volume, Battery)
3. **Time/Date Group** - Contextual theming based on time of day

### 🎨 Visual Design
- **Catppuccin Mocha** color scheme throughout
- **36px bar height** with 18px corner radius
- **Dynamic shadows** and borders that respond to interactions
- **Consistent white text** across all elements
- **Performance-based colors** (green/yellow/red for system load)

### ⏰ Enhanced Date/Time
- **Contextual icons** that change throughout the day (☀️🌤️🌅🌙)
- **Smart formatting** (12-hour format, no leading zeros)
- **Hover details** showing full date, timezone, system uptime
- **Special time displays** (Noon, Midnight)

## 🚀 Installation

### Prerequisites
```bash
# Install SketchyBar
brew install sketchybar

# Install dependencies
brew install yabai skhd jq
```

### Setup
```bash
# Backup existing config (if any)
mv ~/.config/sketchybar ~/.config/sketchybar.backup

# Clone this configuration
git clone <your-repo-url> ~/.config/sketchybar

# Make scripts executable
chmod +x ~/.config/sketchybar/plugins/*.sh
chmod +x ~/.config/sketchybar/sketchybarrc

# Start SketchyBar
brew services start sketchybar
```

## 🎯 Key Components

### Main Configuration
- `sketchybarrc` - Main configuration file
- `plugins/` - All widget scripts and hover effects

### Core Plugins
- `space.sh` - Workspace management with app icons
- `clock.sh` - Enhanced time display with context
- `calendar.sh` - Date display with event integration
- `system_stats.sh` - Combined CPU/RAM monitoring
- `weather_enhanced.sh` - Dynamic weather with color theming

### Hover Effects
- `apple_hover.sh` - Apple logo interactions
- `status_hover.sh` - System status group effects
- `time_hover.sh` - Time group contextual colors
- `weather_hover.sh` - Weather group animations

## 🎨 Customization

### Colors
Edit the color variables in `sketchybarrc`:
```bash
export BLUE=0xff89b4fa      # Accent color
export WHITE=0xffcdd6f4     # Text color
export ITEM_BG_COLOR=0xff313244  # Widget backgrounds
```

### Weather
Update location in `plugins/weather_enhanced.sh`:
```bash
LOCATION="Your City"  # Change to your location
```

### App Icons
Add new app mappings in `plugins/icon_map.sh`:
```bash
"Your App") echo "🎯";;
```

## 🔧 Troubleshooting

### SketchyBar not starting
```bash
# Check if running
brew services list | grep sketchybar

# Restart service
brew services restart sketchybar

# Check logs
tail -f /opt/homebrew/var/log/sketchybar.log
```

### Permissions
```bash
# Make all scripts executable
find ~/.config/sketchybar/plugins -name "*.sh" -exec chmod +x {} \;
```

## 📝 Version History

- **v1.0** - Initial premium configuration with dynamic workspaces and three-section design

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This configuration is open source and available under the MIT License.

---

🤖 *Generated with [opencode](https://opencode.ai)*