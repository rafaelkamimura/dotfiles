# SketchyBar Configuration Documentation

## Documentation Overview

This documentation provides comprehensive guidance for understanding, customizing, and maintaining the SketchyBar configuration.

## Quick Navigation

### 📋 [MEMORY.md](MEMORY.md)
**Configuration history and major changes**
- Transformation log from monolithic to modular architecture
- User requirements and implementation decisions
- Files modified and functionality preserved
- Reference to MiragianCycle inspiration

### 🏗️ [ARCHITECTURE.md](ARCHITECTURE.md)
**System design and modular structure**
- Component overview (orchestrator, theming, widgets, plugins)
- Data flow and widget lifecycle
- Adding new widgets and configuration patterns
- Performance considerations and maintenance benefits

### 🎨 [THEMING.md](THEMING.md)
**Color schemes and visual customization**
- Catppuccin Mocha color palette definitions
- Typography and layout constants
- Theme switching and customization guide
- Dark theme best practices and accessibility

### 🔧 [WIDGETS.md](WIDGETS.md)
**Individual widget configuration and creation**
- Current widget inventory and customization options
- Standard widget patterns and properties
- Creating new widgets step-by-step
- Interactive elements and grouping techniques

### 🚨 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
**Common issues and debugging solutions**
- Configuration, plugin, and visual issue resolution
- Performance optimization and debugging tools
- Maintenance tasks and community resources
- Error message reference

## Configuration Structure

```
~/.config/sketchybar/
├── sketchybarrc          # Main orchestrator (66 lines)
├── variables.sh          # Centralized theming
├── items/               # Widget configurations
│   ├── apple.sh         # Apple menu with system controls
│   ├── spaces.sh        # Workspace indicators
│   ├── front_app.sh     # Current application display
│   ├── cpu.sh           # CPU monitoring
│   ├── clock.sh         # Time display
│   └── calendar.sh      # Date display
├── plugins/             # Dynamic behavior scripts (preserved)
└── docs/               # This documentation
```

## Quick Start

### Basic Usage
```bash
# Reload configuration
sketchybar --reload

# Query widget state
sketchybar --query widget_name

# Manual widget update
sketchybar --update
```

### Common Customizations

#### Change Colors
1. Edit `variables.sh` color definitions
2. Reload with `sketchybar --reload`

#### Add New Widget
1. Create `items/new_widget.sh`
2. Create `plugins/new_widget.sh` (if needed)
3. Add source line to `sketchybarrc`
4. Reload configuration

#### Modify Existing Widget
1. Edit appropriate file in `items/`
2. Reload configuration
3. Check logs if issues occur

## Key Features

### ✅ Implemented
- **Apple Menu:** Complete system controls (sleep, restart, shutdown, etc.)
- **Workspace Indicators:** 10 virtual desktop spaces
- **Current App Display:** Shows active application with icons
- **CPU Monitoring:** System performance indicator
- **Time/Date Display:** Clock and calendar widgets
- **Modular Architecture:** Easy customization and maintenance
- **Dark Theme:** Catppuccin Mocha color scheme
- **Interactive Elements:** Hover effects and click handlers

### 🔄 Easily Addable
- Media controls (Spotify, Music, etc.)
- Weather information
- System statistics (memory, network, battery)
- Custom application integrations
- Additional system monitoring

## Design Philosophy

### Minimalism
- Clean, uncluttered interface
- Essential widgets only
- Consistent visual hierarchy

### Modularity
- Self-contained widget files
- Easy addition/removal of components
- Clear separation of concerns

### Dark Aesthetic
- Deep black base colors
- High contrast white text
- Subtle accent colors
- Professional appearance

## Maintenance

### Regular Tasks
- Monitor configuration performance
- Update plugin scripts as needed
- Review logs for errors
- Backup configuration before changes

### When Issues Occur
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review recent changes in [MEMORY.md](MEMORY.md)
3. Test individual components
4. Consult community resources

## Contributing

### Adding Documentation
- Follow existing documentation patterns
- Include code examples
- Update this README when adding new docs
- Maintain clear cross-references

### Configuration Improvements
- Test changes thoroughly
- Document modifications in MEMORY.md
- Consider backward compatibility
- Share useful additions with community

## Support

### Self-Help Resources
1. **Documentation:** Start with relevant doc file above
2. **Logs:** Check `/opt/homebrew/var/log/sketchybar.log`
3. **Testing:** Use individual widget files for isolation
4. **Community:** GitHub issues and discussions

### Getting Help
When seeking assistance, provide:
- macOS and SketchyBar versions
- Relevant configuration files
- Error messages and logs
- Steps to reproduce issue

---

*This configuration is inspired by the MiragianCycle dotfiles and adapted for a darker, cleaner aesthetic with maintained Apple ecosystem integration.*