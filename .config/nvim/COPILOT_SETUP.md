# GitHub Copilot Setup for Neovim/LazyVim

This guide explains how to set up and use GitHub Copilot in your Neovim configuration.

## Authentication Setup

### 1. GitHub Copilot Subscription
First, ensure you have an active GitHub Copilot subscription:
- Visit [https://github.com/features/copilot](https://github.com/features/copilot)
- Subscribe to GitHub Copilot (Individual or Business plan)

### 2. Authentication in Neovim
After starting Neovim with the new configuration, authenticate with GitHub:

```vim
:Copilot setup
```

This will:
1. Open a browser window for GitHub authentication
2. Provide a device code for verification
3. Complete the authentication process

Alternatively, you can use:
```vim
:Copilot auth
```

### 3. Verify Installation
Check if Copilot is working:
```vim
:Copilot status
```

## Features and Keybindings

### Inline Suggestions
- **Alt+l**: Accept the current suggestion
- **Alt+w**: Accept only the next word
- **Alt+j**: Accept only the current line
- **Alt+]**: Show next suggestion
- **Alt+[**: Show previous suggestion
- **Ctrl+]**: Dismiss current suggestion

### Copilot Panel
- **Alt+Enter**: Open Copilot suggestions panel
- **gr**: Refresh suggestions in panel
- **[[** / **]]**: Navigate between suggestions
- **Enter**: Accept suggestion from panel

### Copilot Chat Commands
- **&lt;leader&gt;cc**: Open Copilot Chat (normal mode)
- **&lt;leader&gt;cc**: Explain selection (visual mode)
- **&lt;leader&gt;cr**: Review selection (visual mode)
- **&lt;leader&gt;cf**: Fix selection (visual mode)
- **&lt;leader&gt;co**: Optimize selection (visual mode)
- **&lt;leader&gt;cd**: Document selection (visual mode)
- **&lt;leader&gt;ct**: Generate tests for selection (visual mode)
- **&lt;leader&gt;cp**: Toggle Copilot Chat

### Copilot Control
- **&lt;leader&gt;cs**: Check Copilot status
- **&lt;leader&gt;ce**: Enable Copilot
- **&lt;leader&gt;cD**: Disable Copilot

## Integration Details

### Completion Engine Integration
This setup integrates Copilot with your existing blink.cmp completion engine:
- Copilot suggestions appear in the completion menu
- Higher priority than other completion sources
- Seamless integration with existing completion workflow

### Python Development Optimization
Special optimizations for Python development:
- Enhanced language server configuration (Pyright)
- Additional Python tools via Mason
- Python-specific treesitter parsers
- Optimal Copilot settings for Python

### Supported File Types
Copilot is enabled for:
- Python (.py)
- JavaScript/TypeScript (.js, .ts, .jsx, .tsx)
- Lua (.lua)
- Go (.go)
- Rust (.rs)
- Java (.java)
- C/C++ (.c, .cpp, .h, .hpp)

Disabled for:
- YAML files
- Markdown files
- Git commit messages
- Help files

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   ```vim
   :Copilot auth
   ```

2. **Copilot Not Working**
   ```vim
   :Copilot status
   :Copilot enable
   ```

3. **Node.js Version**
   Ensure Node.js version is 18.x or higher:
   ```bash
   node --version
   ```

4. **Check Plugin Installation**
   ```vim
   :Lazy
   ```
   Verify that copilot plugins are installed.

### Reset Copilot
If you encounter persistent issues:
```vim
:Copilot disable
:Copilot enable
```

Or restart Neovim and re-authenticate:
```vim
:Copilot setup
```

## Usage Tips

1. **Best Practices**
   - Let Copilot observe your coding patterns for better suggestions
   - Use descriptive comments to guide suggestions
   - Review suggestions before accepting

2. **Productivity Tips**
   - Use Alt+w to accept just the next word for partial suggestions
   - Use Copilot Chat for code explanation and optimization
   - Leverage the panel view for multiple suggestion options

3. **Python-Specific Tips**
   - Add type hints for better Copilot suggestions
   - Use docstrings to guide function implementations
   - Leverage Copilot Chat for test generation

## Configuration Files

The Copilot setup includes these configuration files:
- `/lua/plugins/copilot.lua` - Main Copilot configuration
- `/lua/plugins/blink-cmp.lua` - Completion engine integration
- `/lua/plugins/python.lua` - Python development enhancements
- `/lua/config/keymaps.lua` - Copilot keybindings

## Next Steps

1. Restart Neovim to load the new configuration
2. Run `:Lazy sync` to install new plugins
3. Authenticate with `:Copilot setup`
4. Test suggestions in a Python file
5. Explore Copilot Chat features

Enjoy coding with GitHub Copilot!