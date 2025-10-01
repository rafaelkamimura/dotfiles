# Yabai Configuration & Keybinds

## Overview
This directory contains the yabai window manager configuration with optimized settings for sketchybar integration.

## Configuration Files
- `yabairc` - Main configuration file with window management settings and sketchybar integration

## Key Features
- **Binary Space Partitioning (BSP)** layout
- **Visual window borders** with rounded corners
- **Sketchybar integration** with real-time space/window updates
- **Mouse controls** with `fn` modifier for moving/resizing
- **Window opacity** and smooth animations
- **App exclusions** for problematic applications
- **Rule-based space assignment** for automatic window organization

## Space Assignment

### Prerequisites
**IMPORTANT**: Spaces must be manually created first in Mission Control before rules work:
1. Open Mission Control (swipe up with 3-4 fingers or `F3`)
2. Click `+` in top-right to create spaces (create at least 5 spaces)
3. Restart yabai to apply rules

### Default Space Layout
| Space | Purpose | Applications |
|-------|---------|--------------|
| **1** | Terminals | Ghostty, iTerm2, Terminal, Alacritty, kitty, WezTerm |
| **2** | Browsers | Safari, Chrome, Firefox, Brave, Arc, Edge |
| **3** | Development | VS Code, Xcode, IntelliJ IDEA, PyCharm, WebStorm, Sublime Text |
| **4** | Communication | Slack, Discord, Telegram, WhatsApp, Signal, Teams, Zoom |
| **5** | Media & Design | Spotify, Music, Photos, Pixelmator, Affinity, Photoshop, Figma |

### How It Works
- When you open an app, yabai automatically sends it to its designated space
- If the space doesn't exist, the app opens in the current space
- Use `ctrl + arrow keys` or gestures to switch between spaces
- Apps not in the rules will tile normally in the current space

### Customizing Space Rules
Edit `~/.config/yabai/yabairc` to modify space assignments:
```bash
# Example: Move all terminals to space 1
yabai -m rule --add app="^(Ghostty|iTerm2)$" space=1
```

### macOS Sequoia Limitations
⚠️ Due to disabled scripting addition:
- ❌ Cannot auto-create new spaces
- ❌ Cannot auto-focus spaces when apps open
- ✅ Can route apps to pre-existing spaces
- ✅ Manual space switching still works (ctrl+arrows)

## Keybinds (skhd)

### Navigation (`lalt + ...`)
| Key | Action |
|-----|--------|
| `lalt + 1-4` | Focus space 1-4 on current display |
| `lalt + j` | Focus window west (or display west) |
| `lalt + k` | Focus window south (or display south) |
| `lalt + l` | Focus window north (or display north) |
| `lalt + ö` | Focus window east (or display east) |
| `lalt + h` | Focus first window |
| `lalt + ä` | Focus last window |
| `lalt + space` | Toggle window float |
| `lalt + f` | Zoom window to parent node |
| `lalt + s` | Insert window east + open new window |
| `lalt + v` | Insert window south + open new window |

### Window Movement (`shift + lalt + ...`)
| Key | Action |
|-----|--------|
| `shift + lalt + f` | Toggle zoom fullscreen |
| `shift + lalt + j` | Move window west (or to west display) |
| `shift + lalt + k` | Move window south (or to south display) |
| `shift + lalt + l` | Move window north (or to north display) |
| `shift + lalt + ö` | Move window east (or to east display) |
| `shift + lalt + s` | Toggle split orientation |
| `shift + lalt + 1-4` | Send window to space 1-4 on current display |
| `shift + lalt + p` | Send window to previous space and follow |
| `shift + lalt + n` | Send window to next space and follow |
| `shift + lalt + x` | Mirror space on X-axis |
| `shift + lalt + y` | Mirror space on Y-axis |
| `shift + lalt + space` | Toggle sketchybar visibility |

### Window Stacking (`shift + ctrl + ...`)
| Key | Action |
|-----|--------|
| `shift + ctrl + j` | Stack window to the west |
| `shift + ctrl + k` | Stack window to the south |
| `shift + ctrl + l` | Stack window to the north |
| `shift + ctrl + ö` | Stack window to the east |
| `shift + ctrl + n` | Focus next window in stack |
| `shift + ctrl + p` | Focus previous window in stack |

### Window Resizing (`ctrl + lalt + ...`)
| Key | Action |
|-----|--------|
| `ctrl + lalt + j` | Resize window left |
| `ctrl + lalt + k` | Resize window down |
| `ctrl + lalt + l` | Resize window up |
| `ctrl + lalt + ö` | Resize window right |
| `ctrl + lalt + e` | Balance all windows |
| `ctrl + lalt + g` | Toggle gaps and padding |

### Window Insertion (`shift + ctrl + lalt + ...`)
| Key | Action |
|-----|--------|
| `shift + ctrl + lalt + j` | Set insertion point west |
| `shift + ctrl + lalt + k` | Set insertion point south |
| `shift + ctrl + lalt + l` | Set insertion point north |
| `shift + ctrl + lalt + ö` | Set insertion point east |
| `shift + ctrl + lalt + s` | Set insertion point stack |

## Mouse Controls
- **`fn + left click`** - Move window
- **`fn + right click`** - Resize window
- **Mouse drag** - Swap windows

## Configuration Details

### Window Settings
- **Layout**: Binary Space Partitioning (BSP)
- **Split Ratio**: 50%
- **Window Gap**: 15px
- **Padding**: Top 45px, Others 15px (optimized for sketchybar)
- **Border Width**: 2px with 12px radius
- **Active Border**: `#775759`
- **Normal Border**: `#553c54`

### Opacity & Animation
- **Active Window**: 100% opacity
- **Normal Windows**: 80% opacity
- **Animation Duration**: 0.5s with ease_out_quint easing

### Sketchybar Integration
Automatic signals trigger sketchybar updates for:
- Space changes
- Window creation/destruction
- Window movement

### Excluded Applications
Apps that don't work well with tiling:
- System apps (Calculator, System Preferences, etc.)
- Media apps (VLC, Photo Booth)
- Utility apps (Alfred, Activity Monitor, etc.)
- Development tools with floating panels

## Restart Commands
```bash
# Restart yabai
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.koekeishiya.yabai.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.koekeishiya.yabai.plist

# Restart skhd  
brew services restart skhd
```