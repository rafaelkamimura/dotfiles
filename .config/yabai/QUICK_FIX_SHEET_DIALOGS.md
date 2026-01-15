# Quick Fix: Sheet-Style Dialogs (Claude File Picker)

## TL;DR - The Problem

Claude Desktop's file picker is a **sheet dialog** that slides down from the window's title bar. On macOS Tahoe, yabai **cannot control these** without the scripting addition (which is broken).

**Sheet dialogs follow the parent window's position** - so if Claude is off to the side, the file picker will be too!

---

## ✅ SOLUTION: Center the Parent Window First

### Before Opening File Picker in Claude:

1. **Focus Claude window**
2. **Press `Shift + Alt + C`** (new keybind!)
3. **Then** open the file picker
4. File picker will now appear centered! ✨

### The Keybind

```bash
# Added to ~/.skhdrc
shift + lalt - c : yabai -m window --grid 8:8:1:1:6:6
```

This centers the **parent window** (Claude), which causes the sheet dialog to also appear centered.

---

## 🎯 Workflow

```
┌─────────────────────────────────────┐
│ Bad: Claude off to the side         │
│ → File picker also off to the side  │
└─────────────────────────────────────┘

Press: Shift + Alt + C

┌─────────────────────────────────────┐
│ Good: Claude centered               │
│ → File picker now centered!         │
└─────────────────────────────────────┘
```

---

## 🔑 All Dialog-Related Keybinds

| Keybind | Purpose | When to Use |
|---------|---------|-------------|
| `Ctrl + Alt + C` | Center floating windows | For Finder, standalone dialogs |
| `Shift + Alt + C` | **Center parent window** | **BEFORE opening Claude file picker** |
| `Shift + Ctrl + Alt + C` | Emergency force center | When things are really stuck |

---

## 🤖 Alternative: Auto-Center Claude

If you want Claude **always centered** (so dialogs are always centered):

**Edit `~/.config/yabai/yabairc`:**

Find this line (around line 133):
```bash
# yabai -m rule --add app="^Claude$" grid=6:6:1:1:4:4
```

**Uncomment it:**
```bash
yabai -m rule --add app="^Claude$" grid=6:6:1:1:4:4
```

**Then restart yabai:**
```bash
yabai --restart-service
```

Now Claude will **always** open centered, so file pickers will always be centered too!

---

## 🔍 Why This Happens

### Sheet vs. Standalone Dialogs

**Sheet Dialog** (Claude uses this):
- Part of the parent window
- Slides down from title bar
- **Cannot move independently**
- Follows parent position
- Needs scripting addition to control

**Standalone Dialog** (Finder uses this):
- Separate floating window
- Can move independently
- **Yabai can control it** ✅
- Already working with our rules!

### macOS Tahoe Limitation

On macOS Tahoe 26.0+, the scripting addition is **broken**. This means:
- ❌ Sheet dialogs cannot be moved by yabai
- ❌ Cannot manipulate dialogs attached to windows
- ✅ Standalone dialogs still work fine
- ✅ All normal tiling works fine

**Workaround:** Control the parent window's position instead!

---

## 📋 Testing

1. **Test standalone dialogs (should work automatically):**
   ```bash
   open ~  # Finder window should center
   ```

2. **Test Claude file picker (needs manual centering):**
   - Open Claude
   - Press `Shift + Alt + C` (center parent)
   - Now open file picker
   - Should appear centered!

3. **Verify keybind works:**
   ```bash
   # Check skhd is running
   ps aux | grep skhd

   # Should see:
   # nagawa ... /opt/homebrew/bin/skhd
   ```

---

## 🐛 Troubleshooting

### Keybind not working?

Reload skhd:
```bash
launchctl unload ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
launchctl load ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
```

### Claude not centering?

Try the emergency keybind:
```bash
Shift + Ctrl + Alt + C
```

### Want to check if a dialog is a sheet?

```bash
yabai -m query --windows | jq '.[] | {app, title, subrole}'
```

Look for `"subrole": "AXSheet"` - that's a sheet dialog!

---

## 📚 More Info

For technical details and alternatives, see:
- `~/.config/yabai/SHEET_DIALOG_LIMITATION.md`

---

**Quick Summary:**
- Sheet dialogs follow parent window
- Use `Shift + Alt + C` before opening file picker in Claude
- Or auto-center Claude by uncommenting rule in yabairc

**That's it!** 🎉
