# Floating Window Centering Fix

## Problem
Floating windows (like Finder dialogs, file pickers, preferences) were appearing at fixed screen positions instead of being centered above the current workspace. **This was especially bad for native macOS file dialogs (Save/Open panels) which would appear way off to the side.**

## Solution Applied

### 1. Native Dialog Detection (CRITICAL FIX!)

Added special rules to detect macOS native file dialogs by their accessibility role:

```bash
# Native macOS file dialogs have subrole "AXDialog"
yabai -m rule --add subrole="^AXDialog$" manage=off grid=8:8:1:1:6:6
yabai -m rule --add subrole="^AXSystemDialog$" manage=off grid=8:8:1:1:6:6
```

**Location:** `~/.config/yabai/yabairc` (lines 75-76)

These rules **MUST be placed BEFORE** other app-specific rules to take priority!

### 2. Automatic Centering via Enhanced Signals

Added signals that automatically center any floating window when created:

```bash
# Auto-center floating windows (including Finder dialogs)
yabai -m signal --add event=window_created \
    action='
        yabai -m query --windows --window $YABAI_WINDOW_ID | \
        jq -er ".\"is-floating\" == true" && \
        yabai -m window $YABAI_WINDOW_ID --grid 8:8:1:1:6:6
    '
```

**Location:** `~/.config/yabai/yabairc` (lines 115-122)

### 2. Application-Specific Rules

Added grid positioning to all floating window rules:

```bash
# Finder - centered at 75% size
yabai -m rule --add app="^Finder$" manage=off grid=8:8:1:1:6:6

# Safari dialogs - centered at 75% size
yabai -m rule --add app="^Safari$" title="^(Preferences|Settings)" manage=off grid=8:8:1:1:6:6

# Common file dialogs - centered
yabai -m rule --add title="^(Open|Save|Choose|Import|Export)$" manage=off grid=8:8:1:1:6:6

# Preferences windows - centered
yabai -m rule --add title="^(Preferences|Settings)$" manage=off grid=8:8:1:1:6:6
```

**Location:** `~/.config/yabai/yabairc` (lines 72-91)

### 3. Manual Center Keybinds

Added keyboard shortcuts to manually center windows:

```bash
# Center floating window: ctrl + lalt - c
ctrl + lalt - c : yabai -m window --grid 8:8:1:1:6:6

# Emergency dialog fix - Force center ANY window: shift + ctrl + lalt - c
shift + ctrl + lalt - c : yabai -m window --grid 8:8:1:1:6:6
```

**Location:** `~/.skhdrc` (lines 82, 85)

**When to use:**
- `Ctrl + Alt + C` - Normal center for floating windows
- `Shift + Ctrl + Alt + C` - **Emergency fix** when dialogs are stuck off-screen

### 4. Helper Script

Created a helper script for custom centering:

```bash
~/.config/yabai/center-floating-window.sh [grid_spec]
```

**Examples:**
```bash
# Center at 75% size (default)
~/.config/yabai/center-floating-window.sh

# Center at 50% size (smaller)
~/.config/yabai/center-floating-window.sh 6:6:1:1:4:4

# Center at 90% size (larger)
~/.config/yabai/center-floating-window.sh 10:10:0:0:10:10
```

## Grid System Explained

Yabai uses a grid system: `rows:cols:start-x:start-y:width:height`

**Common presets:**

| Grid Spec | Size | Position | Description |
|-----------|------|----------|-------------|
| `8:8:1:1:6:6` | 75% | Centered | Default - most dialogs |
| `6:6:1:1:4:4` | 66% | Centered | Smaller dialogs |
| `10:10:1:1:8:8` | 80% | Centered | Large preferences |
| `4:4:1:1:2:2` | 50% | Centered | Compact windows |
| `12:12:2:2:8:8` | 66% | Centered | Extra precise |

**Grid format breakdown:**
```
8:8:1:1:6:6
│ │ │ │ │ └─ height: 6 units
│ │ │ │ └─── width: 6 units
│ │ │ └───── start-y: 1 unit from top
│ │ └─────── start-x: 1 unit from left
│ └───────── columns: 8 total
└─────────── rows: 8 total
```

In this example, the window takes up 6/8 (75%) of the screen, starting 1 unit from the edges.

## Testing

### Automated Test
```bash
~/.config/yabai/test-dialog-centering.sh
```

### Manual Tests

1. **Native File Picker** (THE MAIN FIX!)
   - Open Claude Desktop
   - Click to upload a file
   - File picker should appear **CENTERED** at 75% size
   - NOT off to the side like before!

2. **Finder**
   - Open Finder (Cmd+N)
   - Should center automatically

3. **Any Save Dialog**
   - In any app, press Cmd+S
   - Save dialog should be centered

4. **System Settings**
   - Open System Settings
   - Should center automatically

5. **Emergency Keybind**
   - If any dialog appears off-screen
   - Press `Shift + Ctrl + Alt + C`
   - Should snap to center immediately

## Troubleshooting

### Window not centering automatically?
```bash
# Check if signal is loaded
yabai -m signal --list

# Restart yabai
yabai --restart-service
```

### Need different size/position?
Edit `~/.config/yabai/yabairc` and change the grid values:
- Line 73: Finder
- Line 76: Safari
- Line 88: Common dialogs
- Line 121: Auto-center signal

### Manual center not working?
```bash
# Check skhd is running
ps aux | grep skhd

# Reload skhd
launchctl unload ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
launchctl load ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
```

## Advanced Customization

### Center specific app at custom size

Add to `~/.config/yabai/yabairc`:

```bash
# Example: Center Calculator at 30% size
yabai -m rule --add app="^Calculator$" manage=off grid=10:10:3:3:4:4
```

### Different sizes for different dialog types

```bash
# Small confirmation dialogs (40%)
yabai -m rule --add title="^(Confirm|Alert|Warning)$" manage=off grid=5:5:1:1:3:3

# Large preview windows (90%)
yabai -m rule --add title="^(Preview|Quick Look)$" manage=off grid=10:10:0:0:10:10
```

### Center on specific display

```bash
# Force window to display 2, centered
yabai -m rule --add app="^MyApp$" manage=off display=2 grid=8:8:1:1:6:6
```

## Files Modified

1. `~/.config/yabai/yabairc` - Main config with rules and signals
2. `~/.skhdrc` - Added Ctrl+Alt+C keybind
3. `~/.config/yabai/center-floating-window.sh` - Helper script (NEW)

## Resources

- [Yabai Grid Documentation](https://github.com/koekeishiya/yabai/wiki/Commands#window)
- [Yabai Signals](https://github.com/koekeishiya/yabai/wiki/Commands#signals)
- [skhd Configuration](https://github.com/koekeishiya/skhd)

---

**Last Updated:** 2025-11-10
**macOS Version:** Tahoe 26.0.1
**Yabai Version:** 7.1.16
