# External Link Opening in Neovim

This document describes the external link opening functionality configured in this Neovim setup using the `gx.nvim` plugin.

## Features

### Supported Link Types
- **HTTP/HTTPS URLs**: `https://example.com`, `http://github.com/user/repo`
- **GitHub Links**: Repository URLs, issues, pull requests, commits
- **Plugin Links**: Lazy.nvim plugin specs, Packer plugin definitions
- **Package Managers**: npm packages in package.json, Homebrew formulas in Brewfile
- **Language-specific**: 
  - Go packages from import statements (opens pkg.go.dev)
  - Rust crates from Cargo.toml (opens crates.io)
- **File Paths**: Local file paths and directories
- **Search Fallback**: If no specific handler matches, performs web search

### Input Methods

#### Keyboard Shortcuts
| Keymap | Mode | Description |
|--------|------|-------------|
| `gx` | Normal/Visual | Open link under cursor (standard Vim keybind) |
| `<leader>ox` | Normal/Visual | Open link under cursor |
| `<leader>ol` | Normal/Visual | Open link under cursor (alternative) |
| `gl` | Normal/Visual | Open link under cursor (quick alternative) |

#### Mouse Support
| Mouse Action | Description |
|--------------|-------------|
| `Shift+Click` | Open link at click position |
| `Middle Click` | Open link at click position (alternative) |

### Smart Link Detection

The plugin automatically detects various link formats:

#### Web URLs
```
https://github.com/chrishrb/gx.nvim
http://example.com/path?param=value
ftp://ftp.example.com
```

#### GitHub References
```
chrishrb/gx.nvim                    # Opens GitHub repository
https://github.com/user/repo/issues/123  # Opens specific issue
user/repo#123                       # Opens issue/PR #123
```

#### Plugin Configurations
```lua
{ "chrishrb/gx.nvim" }              # Opens plugin repository
use "nvim-lua/plenary.nvim"         # Packer format
```

#### Package Files
```json
// package.json
"lodash": "^4.17.21"                # Opens npm package page
```

```ruby
# Brewfile
brew "neovim"                       # Opens Homebrew formula
cask "visual-studio-code"           # Opens Homebrew cask
```

#### Language-specific Links
```go
// Go import
import "github.com/gin-gonic/gin"   # Opens pkg.go.dev
```

```toml
# Cargo.toml
serde = "1.0"                       # Opens crates.io
```

## Configuration

### Plugin Setup
The `gx.nvim` plugin is configured in `/lua/plugins/gx.lua` with the following features:

- **macOS Integration**: Uses `open` command with `--background` flag
- **Smart Handler Selection**: Shows prompt when multiple handlers match
- **Extensible**: Easy to add custom link patterns
- **Netrw Disabled**: Replaces netrw's gx functionality

### Mouse Configuration
Mouse support is enabled in `/lua/config/options.lua`:

```lua
vim.opt.mouse = "a"                 -- Enable mouse in all modes
vim.opt.mousemodel = "extend"       -- Enable extend selection
vim.opt.mousetime = 500             -- Double-click detection time
```

### Custom Keybindings
Additional keybindings are configured in `/lua/config/keymaps.lua` for:
- Alternative link opening shortcuts
- Mouse scroll behavior optimization
- Middle mouse button support

## Usage Examples

### Basic Usage
1. **Position cursor** on any link or URL
2. **Press `gx`** to open in your default browser
3. **Or use Shift+Click** for mouse-based opening

### Visual Selection
1. **Select text** containing a link
2. **Press `gx`** or `<leader>ol` to open

### Multiple Matches
When multiple handlers could apply to the same text:
1. A **selection prompt** appears
2. **Choose the appropriate handler** (e.g., GitHub repo vs web search)
3. The link opens with your selected handler

## Browser Integration

### macOS (Default)
- Uses the `open` command
- Opens in your **default browser**
- **Background opening** keeps Neovim focused
- Supports all browsers (Safari, Chrome, Firefox, etc.)

### Custom Browser
To use a specific browser, modify the configuration in `gx.lua`:

```lua
open_browser_app = "google-chrome-stable", -- Linux
-- or
open_browser_app = "/Applications/Firefox.app/Contents/MacOS/firefox", -- macOS
```

## Terminal Compatibility

### Supported Terminals
- **Ghostty**: Full mouse support including Shift+Click
- **iTerm2**: Full mouse support
- **Terminal.app**: Full mouse support
- **WezTerm**: Full mouse support with bypass_mouse_reporting_modifiers
- **Alacritty**: Full mouse support
- **Kitty**: Full mouse support

### SSH/Remote Sessions
When using Neovim over SSH:
- **Keyboard shortcuts** work normally
- **Mouse support** depends on terminal's forwarding capabilities
- Consider using **keyboard-only** workflows for reliability

## Troubleshooting

### Common Issues

#### Links not opening
1. **Check cursor position**: Ensure cursor is on or near the link
2. **Try visual selection**: Select the entire link and press `gx`
3. **Check error messages**: Use `:messages` to see any error output

#### Mouse clicks not working
1. **Verify mouse support**: Check `:echo &mouse` shows `a`
2. **Terminal compatibility**: Ensure your terminal supports mouse events
3. **Try keyboard alternative**: Use `gx` instead of mouse clicks

#### Wrong application opens
1. **Check default browser**: Verify system default browser settings
2. **Custom browser config**: Modify `open_browser_app` in gx.lua
3. **macOS specific**: Use `open -a "Browser Name" url` format

### Debug Information
```vim
:echo &mouse                        " Should show 'a'
:echo &mousemodel                   " Should show 'extend'
:Browse                             " Test command directly
:messages                           " View recent messages
```

## Extending Functionality

### Adding Custom Handlers
Add custom link handlers in the `gx.lua` configuration:

```lua
handlers = {
  -- Custom Jira ticket handler
  jira = {
    name = "jira",
    handle = function(mode, line, _)
      local ticket = require("gx.helper").find(line, mode, "(%u+-%d+)")
      if ticket and #ticket < 20 then
        return "https://jira.company.com/browse/" .. ticket
      end
    end,
  },
  
  -- Custom internal documentation
  docs = {
    name = "internal_docs",
    handle = function(mode, line, _)
      local doc_id = require("gx.helper").find(line, mode, "DOC%-(%d+)")
      if doc_id then
        return "https://docs.company.com/doc/" .. doc_id
      end
    end,
  },
}
```

### File-specific Handlers
Restrict handlers to specific file types:

```lua
markdown_links = {
  name = "markdown",
  filetype = { "markdown", "md" },
  handle = function(mode, line, _)
    -- Custom markdown link handling
  end,
}
```

## Performance

The plugin is optimized for:
- **Lazy loading**: Only loads when needed
- **Pattern matching**: Efficient regex patterns
- **Background opening**: Doesn't block Neovim
- **Memory usage**: Minimal footprint

## Security Considerations

- **Untrusted content**: Be cautious with links from untrusted sources
- **Local file access**: Plugin can open local files and directories
- **Shell execution**: Uses system commands for opening browsers
- **Network requests**: Links open in browser, following normal browser security

---

*This documentation was generated for the gx.nvim plugin integration in LazyVim.*