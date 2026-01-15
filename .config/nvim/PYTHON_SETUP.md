# Python LSP and Ruff Configuration for Neovim/LazyVim

This document describes the Python development environment configured for Neovim with LazyVim.

## Overview

The configuration provides:
- **Pyright LSP** for intelligent code completion, jump-to-definition, and type checking
- **Ruff** as the primary linter and formatter
- **Auto-formatting on save** with PEP8 compliance (120 character line length)
- **Import organization** and sorting
- **Python debugging** support with DAP
- **Custom keymaps** for Python development

## Installed Tools

### Language Servers
- **Pyright**: Microsoft's Python language server for type checking and IntelliSense
- **Ruff LSP**: Fast Python linter and formatter

### Formatters & Linters
- **Ruff**: Primary formatter and linter (globally installed via pipx)
- **Black**: Backup formatter (installed via Mason)
- **isort**: Backup import sorter (installed via Mason)

## Features

### 1. Auto-formatting on Save
- Python files are automatically formatted with Ruff when saved
- Line length set to 120 characters (modern PEP8 standard)
- Import sorting and organization included

### 2. LSP Features
- **Jump to definition**: `gd` or `<leader>gd`
- **Hover documentation**: `K`
- **Find references**: `gr` or `<leader>gr`
- **Rename symbol**: `<leader>cr`
- **Code actions**: `<leader>ca`
- **Diagnostics**: `<leader>cd`

### 3. Python-specific Keymaps
| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>lf` | Format file | Format current Python file with Ruff |
| `<leader>lo` | Organize imports | Sort and organize imports |
| `<leader>rr` | Run file | Execute current Python file |
| `<leader>rp` | Python REPL | Open Python interactive shell |
| `<leader>rt` | Run tests | Run pytest on current file |
| `<leader>rT` | Run all tests | Run all pytest tests |

### 4. Ruff Configuration
The global Ruff configuration is located at `~/.config/ruff.toml` with the following settings:

- **Line length**: 120 characters
- **Target Python version**: 3.8+
- **Enabled rules**: 
  - pycodestyle (E, W)
  - Pyflakes (F)
  - isort (I)
  - pyupgrade (UP)
  - flake8-bugbear (B)
  - flake8-comprehensions (C4)
  - flake8-simplify (SIM)
  - And more...

## File Structure

```
~/.config/nvim/
├── lua/
│   ├── config/
│   │   ├── autocmds.lua      # Auto-format on save configuration
│   │   └── keymaps.lua       # Python-specific keymaps
│   └── plugins/
│       └── python.lua        # Python plugin configurations
├── lazyvim.json              # LazyVim extras (includes Python)
└── PYTHON_SETUP.md          # This documentation
~/.config/ruff.toml           # Global Ruff configuration
```

## Testing the Setup

1. Open a Python file in Neovim
2. Verify LSP is working:
   - Type checking should appear in real-time
   - Hover over functions/variables with `K` to see documentation
   - Use `gd` to jump to definitions
3. Test formatting:
   - Make some formatting changes
   - Save the file (`:w`) - it should auto-format
4. Test linting:
   - Add some unused imports or style violations
   - You should see diagnostics in the gutter and on the line

## Troubleshooting

### LSP Not Working
1. Check if Pyright is installed: `:Mason` and look for pyright
2. Check LSP status: `:LspInfo` in a Python file
3. Restart LSP: `:LspRestart`

### Formatting Not Working
1. Verify Ruff is available: `:!which ruff` should show `/Users/nagawa/.local/bin/ruff`
2. Check formatting command: `:ConformInfo` in a Python file
3. Manual format: `<leader>lf` or `:lua LazyVim.format()`

### Import Organization Issues
1. Try manual organization: `<leader>lo`
2. Check if Ruff LSP is running: `:LspInfo`
3. Verify Ruff configuration: `:!ruff check --show-settings`

## Commands

### Useful Vim Commands
- `:Mason` - Open Mason package manager
- `:LspInfo` - Show LSP information for current buffer
- `:ConformInfo` - Show formatter information
- `:Lazy` - Open Lazy plugin manager
- `:checkhealth` - Check Neovim health (includes LSP)

### Ruff Commands (Terminal)
```bash
# Check file for issues
ruff check file.py

# Fix issues automatically
ruff check --fix file.py

# Format file
ruff format file.py

# Check configuration
ruff check --show-settings
```

## Additional Notes

- The configuration is designed to work seamlessly with LazyVim
- Auto-formatting only applies to Python files (*.py)
- Spell checking is enabled for Python comments and docstrings
- The setup supports both virtual environments and global Python installations
- Debugging support is configured but requires additional setup for specific projects

## Future Enhancements

Consider adding:
- **pytest integration** with test discovery and running
- **mypy** for stricter type checking
- **poetry/pipenv** integration for dependency management
- **Jupyter notebook** support
- **Django/Flask** specific configurations