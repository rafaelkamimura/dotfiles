# Sheet Dialog Limitation on macOS Tahoe

## The Problem

File picker dialogs in modern macOS apps (like Claude Desktop) use **sheet-style dialogs** that:
- Slide down from the parent window's title bar
- Are NOT separate windows (they're part of the parent window)
- Cannot be moved or manipulated by yabai without scripting addition
- Follow the parent window's position

**This is a macOS Tahoe (26.0+) limitation** - the scripting addition is broken, so yabai cannot control these dialogs.

## Why This Happens

### Sheet vs. Dialog Windows

**Sheet Dialogs** (What Claude uses):
- Attached to parent window
- Subrole: `AXSheet` (not `AXDialog`)
- Cannot be moved independently
- Controlled by the parent window's position
- **CANNOT be managed by yabai without scripting addition**

**Standalone Dialogs** (What Finder uses):
- Separate floating window
- Subrole: `AXDialog`
- Can be moved independently
- **CAN be managed by yabai**

## Current Status on macOS Tahoe

### ❌ What DOESN'T Work (Without Scripting Addition)
- Moving sheet-style dialogs (Claude file picker)
- Centering sheet-style dialogs
- Resizing sheet-style dialogs
- Any manipulation of attached sheets

### ✅ What DOES Work
- Managing standalone floating dialogs (Finder, System Settings)
- Centering Finder "Open/Save" dialogs
- All tiled window management
- Keyboard shortcuts for normal windows

## Workarounds

### Option 1: Position the Parent Window (BEST OPTION)

Since sheet dialogs follow the parent, center the parent window:

**Add to `~/.skhdrc`:**
```bash
# Center the focused window (will center dialogs too)
shift + lalt - c : yabai -m window --grid 8:8:1:1:6:6
```

**Workflow:**
1. Before opening file picker in Claude
2. Press `Shift + Alt + C` to center Claude window
3. Now open file picker - it will appear centered!

### Option 2: Use Apps with Standalone Dialogs

Some apps use standalone dialogs instead of sheets:
- Finder (already works!)
- Safari (works!)
- System Settings (works!)

### Option 3: Re-enable Scripting Addition (RISKY!)

⚠️ **WARNING**: Scripting addition is broken on Tahoe and may cause instability!

If you really need it:

```bash
# 1. Configure sudo access
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai

# 2. Add to yabairc (UNCOMMENT AT YOUR OWN RISK)
# sudo yabai --load-sa
# yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
```

**Risks:**
- May crash on Tahoe (known issue)
- Needs to be updated after every yabai upgrade
- Requires partial SIP disable (already done)

### Option 4: Wait for Official Fix

The yabai developer is working on Tahoe support. Check:
https://github.com/koekeishiya/yabai/issues

## Identifying Sheet vs. Dialog Windows

To check if a window is a sheet:

```bash
# While dialog is open, in another terminal:
yabai -m query --windows | jq '.[] | select(.app == "Claude") | {title, subrole, "is-floating": ."is-floating"}'
```

Look for:
- `"subrole": "AXSheet"` → **Cannot be controlled** (without scripting addition)
- `"subrole": "AXDialog"` → **Can be controlled** ✅

## Recommended Solution

**Until Tahoe scripting addition is fixed:**

1. **Position parent windows strategically**
   ```bash
   # Add to skhdrc for quick parent centering
   shift + lalt - c : yabai -m window --grid 8:8:1:1:6:6
   ```

2. **Keep Claude window centered by default**
   ```bash
   # Add to yabairc
   yabai -m rule --add app="^Claude$" grid=4:4:1:1:2:2
   ```

3. **Use the emergency center keybind BEFORE opening dialogs**
   - Press `Shift + Alt + C` to center Claude
   - Then open file picker
   - Dialog will appear in centered position

## Technical Details

### Why Scripting Addition is Required

The scripting addition injects code into Dock.app that allows yabai to:
- Create/destroy spaces
- Move windows between spaces
- **Control sheet-style dialogs**
- Auto-focus spaces when switching

Without it, yabai can only:
- Tile windows in current space
- Resize/move standalone windows
- Float/unfloat normal windows
- Apply rules to standalone dialogs

### Current Tahoe Status

As of **yabai v7.1.16** on **macOS 26.0.1**:
- ✅ Core BSP tiling works
- ✅ Standalone dialogs work
- ❌ Scripting addition broken
- ❌ Sheet dialogs cannot be controlled
- ⏳ Fix in progress (check GitHub issues)

## Alternative: Use System File Picker

Some apps let you use the old-style system file picker instead of sheets:

**Try this AppleScript workaround** (app-specific):
```applescript
tell application "System Events"
    keystroke "o" using {command down, shift down}
end tell
```

Some apps use Cmd+Shift+O for "Open in Finder" which triggers standalone dialog.

---

**Last Updated:** 2025-11-10
**macOS Version:** Tahoe 26.0.1
**Yabai Version:** 7.1.16

**Status:** Waiting for official Tahoe scripting addition support
