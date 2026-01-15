# Link Opening Test File

This file contains various types of links to test the gx.nvim functionality.

## Web URLs

Basic HTTP/HTTPS links:
- https://github.com/chrishrb/gx.nvim
- http://example.com
- https://www.google.com/search?q=neovim
- https://neovim.io/doc/user/
- https://lazyvim.org/installation

## GitHub Links

Repository links:
- chrishrb/gx.nvim
- nvim-lua/plenary.nvim
- LazyVim/LazyVim
- folke/lazy.nvim

Issue and PR links:
- https://github.com/neovim/neovim/issues/123
- https://github.com/folke/lazy.nvim/pull/456

## Plugin Configurations

Lazy.nvim format:
```lua
{ "chrishrb/gx.nvim" }
{ "nvim-lua/plenary.nvim" }
{ "folke/lazy.nvim" }
```

Packer format:
```lua
use "chrishrb/gx.nvim"
use "nvim-lua/plenary.nvim"
```

## Package Manager Links

NPM packages (package.json format):
```json
{
  "dependencies": {
    "lodash": "^4.17.21",
    "express": "^4.18.0",
    "react": "^18.2.0"
  }
}
```

Homebrew (Brewfile format):
```ruby
brew "neovim"
brew "git"
cask "visual-studio-code"
cask "google-chrome"
```

## Language-specific Links

Go imports:
```go
import "github.com/gin-gonic/gin"
import "fmt"
import "github.com/gorilla/mux"
```

Rust crates (Cargo.toml format):
```toml
[dependencies]
serde = "1.0"
tokio = "1.0"
clap = "4.0"
```

## File Paths

Local file paths:
- /Users/nagawa/.config/nvim/init.lua
- ~/.config/nvim/lua/config/options.lua
- ./README.md
- ../projects/

## Markdown Links

Standard markdown links:
- [Neovim](https://neovim.io)
- [LazyVim Documentation](https://lazyvim.org)
- [gx.nvim Repository](https://github.com/chrishrb/gx.nvim)

## Search Fallback

Text that should trigger web search:
- neovim tutorial
- lua programming guide
- "how to configure neovim"

## Special Formats

FTP links:
- ftp://ftp.example.com/files/

SSH links:
- ssh://user@hostname

Git repositories:
- git://github.com/user/repo

## Testing Instructions

1. **Position cursor** on any link above
2. **Press `gx`** to test keyboard opening
3. **Use Shift+Click** to test mouse opening
4. **Select text** and press `gx` to test visual mode
5. **Try different link types** to test various handlers

## Expected Behaviors

- **Web URLs**: Should open in default browser
- **GitHub links**: Should navigate to GitHub pages
- **Plugin links**: Should open plugin repositories
- **Package links**: Should open package registry pages
- **File paths**: Should open in file manager or editor
- **Search terms**: Should open web search results

---

*Use this file to test all link opening functionality after configuration.*