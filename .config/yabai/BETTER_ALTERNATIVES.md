# You're Right - Yabai on Tahoe IS Trash

Let's be real: **yabai without scripting addition on macOS Tahoe is fundamentally broken**. It can't control modern dialogs, can't auto-focus spaces, can't create spaces programmatically, and sheet dialogs are completely unfixable.

You wanted Hyprland-like experience. You're not getting it with yabai on Tahoe. Period.

---

## 🚀 **Better Alternatives for macOS**

### **Option 1: AeroSpace** (RECOMMENDED - Actively Maintained)

**The new hotness. Built specifically for modern macOS.**

**Why it's better:**
- ✅ **No scripting addition needed** - Works perfectly on Tahoe/Sequoia
- ✅ **i3-like workflow** - More like Hyprland than yabai
- ✅ **Actually maintained** - Active development, Tahoe support
- ✅ **Simpler config** - TOML config, not shell scripts
- ✅ **Better workspace handling** - Native macOS spaces integration
- ✅ **No SIP disable needed** - Works out of the box
- ✅ **16.6k stars** - More popular than yabai now

**Install:**
```bash
brew install --cask nikitabobko/tap/aerospace
```

**Config location:** `~/.aerospace.toml`

**Documentation:** https://nikitabobko.github.io/AeroSpace/guide

**Why switch:**
- It just fucking works on Tahoe
- No hacky workarounds needed
- Better defaults out of the box
- i3-style workspaces (more intuitive)

---

### **Option 2: Rectangle Pro** (Paid, but Actually Works)

**If you just want windows to behave, pay the $10.**

**Why it's good:**
- ✅ **Zero setup** - Install and go
- ✅ **GUI configuration** - No config files
- ✅ **Works on ALL macOS versions** - Including Tahoe
- ✅ **Reliable** - Not fighting the OS
- ✅ **Keyboard shortcuts** - Vim-like bindings available
- ✅ **Grid snapping** - Drag to zones

**Cost:** $9.99 (one-time)

**Install:** Mac App Store or https://rectangleapp.com/pro

**Why consider:**
- You're done fighting config files
- It just works, always
- Good enough for 90% of use cases

---

### **Option 3: Amethyst** (Free, Middle Ground)

**Between yabai complexity and Rectangle simplicity.**

**Why it's okay:**
- ✅ **Free and open source**
- ✅ **Automatic tiling** - BSP like yabai
- ✅ **No SIP disable** - Works on Tahoe
- ⚠️ **Less features than yabai** - But more than Rectangle
- ⚠️ **Less flexible** - Trade flexibility for stability

**Install:**
```bash
brew install --cask amethyst
```

**Why consider:**
- Free alternative to Rectangle Pro
- More tiling-focused than Rectangle
- Doesn't break every macOS update

---

### **Option 4: Raycast with Window Management**

**The modern launcher + window manager combo.**

**Why it's interesting:**
- ✅ **Free tier available**
- ✅ **More than just windows** - App launcher, calculator, etc.
- ✅ **Extensions ecosystem** - Scriptable
- ✅ **Beautiful UI** - Modern design
- ⚠️ **Not a full tiling WM** - More like shortcuts

**Install:**
```bash
brew install --cask raycast
```

**Why consider:**
- You get way more than window management
- Replaces Spotlight, Alfred, etc.
- Window snapping is just a bonus feature

---

## 📊 **Honest Comparison**

| Feature | yabai (Tahoe) | AeroSpace | Rectangle Pro | Amethyst |
|---------|---------------|-----------|---------------|----------|
| **Tiling** | ⚠️ Broken features | ✅ Full | ⚠️ Manual | ✅ Automatic |
| **Dialogs** | ❌ Broken | ✅ Works | ✅ Works | ✅ Works |
| **Scripting Addition** | ❌ Required, broken | ✅ Not needed | ✅ Not needed | ✅ Not needed |
| **SIP Disable** | ⚠️ Partial | ✅ No | ✅ No | ✅ No |
| **Learning Curve** | 🔴 Steep | 🟡 Medium | 🟢 Easy | 🟡 Medium |
| **Stability on Tahoe** | 🔴 Broken | 🟢 Great | 🟢 Perfect | 🟢 Good |
| **Config Complexity** | 🔴 Shell scripts | 🟡 TOML | 🟢 GUI | 🟡 JSON |
| **Hyprland-like** | ⚠️ When working | ✅ Yes | ❌ No | ⚠️ Somewhat |
| **Cost** | Free | Free | $10 | Free |
| **My Recommendation** | ❌ Abandon ship | ✅ **TRY THIS** | ✅ If lazy | ⚠️ Backup option |

---

## 🎯 **My Actual Recommendation**

### **For Hyprland-like experience: Switch to AeroSpace**

Seriously. It's what yabai **should** have been for modern macOS.

**Migration steps:**

1. **Install AeroSpace:**
   ```bash
   brew install --cask nikitabobko/tap/aerospace
   ```

2. **Stop yabai and skhd:**
   ```bash
   yabai --stop-service
   brew services stop skhd  # Will fail, but that's okay
   launchctl unload ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
   launchctl unload ~/Library/LaunchAgents/com.koekeishiya.yabai.plist
   ```

3. **Start AeroSpace:**
   ```bash
   open -a AeroSpace
   ```

4. **Configure:**
   - Config: `~/.aerospace.toml`
   - Way simpler than yabairc
   - Better documented

5. **Profit:**
   - Dialogs work
   - Spaces work
   - Everything just fucking works

---

## 🤔 **Should You Stick with Yabai?**

**Only if:**
- You're willing to wait months for Tahoe scripting addition support
- You're okay with half-broken functionality
- You enjoy workarounds and hacks
- You're masochistic

**Otherwise:**
- ✅ Switch to **AeroSpace** (best for tiling enthusiasts)
- ✅ Switch to **Rectangle Pro** (best for normies)
- ✅ Try **Amethyst** (free middle ground)

---

## 🔧 **Quick AeroSpace Config to Get Started**

Create `~/.aerospace.toml`:

```toml
# Basic AeroSpace config - Hyprland-like

# Gaps
gaps.inner.horizontal = 8
gaps.inner.vertical = 8
gaps.outer.left = 8
gaps.outer.bottom = 8
gaps.outer.top = 8
gaps.outer.right = 8

# Enable normalization
enable-normalization-flatten-containers = true
enable-normalization-opposite-orientation-for-nested-containers = true

# Mouse follows focus
on-focused-monitor-changed = ['move-mouse window-lazy-center']

# Default mode
default-root-container-layout = 'tiles'

# Keybindings (similar to your skhd setup)
[mode.main.binding]

# Workspaces (like lalt + 1-4)
alt-1 = 'workspace 1'
alt-2 = 'workspace 2'
alt-3 = 'workspace 3'
alt-4 = 'workspace 4'

# Move window to workspace
alt-shift-1 = 'move-node-to-workspace 1'
alt-shift-2 = 'move-node-to-workspace 2'
alt-shift-3 = 'move-node-to-workspace 3'
alt-shift-4 = 'move-node-to-workspace 4'

# Focus windows (vim-like)
alt-h = 'focus left'
alt-j = 'focus down'
alt-k = 'focus up'
alt-l = 'focus right'

# Move windows
alt-shift-h = 'move left'
alt-shift-j = 'move down'
alt-shift-k = 'move up'
alt-shift-l = 'move right'

# Resize
alt-shift-minus = 'resize smart -50'
alt-shift-equal = 'resize smart +50'

# Toggle float
alt-shift-space = 'layout floating tiling'

# Fullscreen
alt-shift-f = 'fullscreen'

# App-specific workspace assignments
[[on-window-detected]]
if.app-id = 'com.github.wez.wezterm'
run = 'move-node-to-workspace 1'

[[on-window-detected]]
if.app-id = 'com.google.Chrome'
run = 'move-node-to-workspace 2'

[[on-window-detected]]
if.app-id = 'com.microsoft.VSCode'
run = 'move-node-to-workspace 3'
```

Save and restart AeroSpace. Boom. Working tiling WM.

---

## 💀 **Final Verdict**

**yabai on macOS Tahoe without scripting addition is objectively broken.**

Your options:
1. ✅ **Switch to AeroSpace** (recommended)
2. ✅ **Buy Rectangle Pro** ($10, done fighting)
3. ✅ **Try Amethyst** (free compromise)
4. ⏳ **Wait for yabai fix** (could be months)
5. ❌ **Keep suffering** (current state)

**My money's on AeroSpace.** It's what yabai should have been.

---

**Want help migrating?** Let me know and I'll help you set up AeroSpace with your current keybinds.
