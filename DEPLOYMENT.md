# SketchyBar Automated Deployment and Management System

A comprehensive deployment, testing, and management system for SketchyBar configurations that provides enterprise-grade automation, monitoring, and maintenance capabilities.

## Features

### 🚀 Deployment & Version Control
- **Automated deployments** with version bumping and rollback capabilities
- **Backup and restore** system with timestamped snapshots
- **Configuration validation** before deployment
- **Zero-downtime deployments** with health checks

### 🧪 Testing & Validation
- **Comprehensive test suite** covering syntax, dependencies, and integration
- **Performance testing** for plugins and components
- **Security scanning** for potential vulnerabilities
- **HTML test reports** with detailed metrics

### 📦 Dependency Management
- **Automatic dependency detection** and installation
- **Multi-platform support** (Homebrew, MacPorts)
- **Font management** and Nerd Font installation
- **Native helper compilation** for optimal performance

### 🌍 Environment Management
- **Multiple environments** (default, development, minimal, performance)
- **Profile system** for different use cases (work, gaming, presentation)
- **Configuration switching** with automatic backup
- **Import/export** functionality for sharing configurations

### 📊 Monitoring & Health Checks
- **Continuous monitoring** daemon with alerting
- **Performance metrics** collection and analysis
- **Health status** tracking with automatic recovery
- **HTML reports** with charts and analytics

### 🔄 Updates & Migrations
- **Automatic update checking** via Git or manual methods
- **Migration system** for configuration upgrades
- **Version management** with semantic versioning
- **Rollback support** for failed updates

## Quick Start

### 1. Initial Setup
```bash
# Quick setup for new users
./manage.sh quick-setup

# Or manual initialization
./manage.sh init
```

### 2. Basic Operations
```bash
# Deploy current configuration
./manage.sh deploy

# Run comprehensive tests
./manage.sh test all --report

# Check system health
./manage.sh monitor check

# Interactive dashboard
./manage.sh dashboard
```

## Script Overview

### Main Management Script
- **`manage.sh`** - Master script that orchestrates all tools
  - Interactive dashboard for easy management
  - Proxy commands to specialized tools
  - System initialization and health checks

### Core Tools

#### `deploy.sh` - Deployment & Version Control
```bash
# Deploy with version bump
./deploy.sh deploy [major|minor|patch]

# Create backup
./deploy.sh backup [name]

# Restore from backup
./deploy.sh restore <backup_name>

# Rollback to previous version
./deploy.sh rollback

# Show deployment status
./deploy.sh status
```

#### `test.sh` - Testing Framework
```bash
# Run all tests
./test.sh all

# Run specific test suite
./test.sh [basic|syntax|config|performance|security|integration]

# Generate HTML report
./test.sh all --report

# Verbose output
./test.sh config --verbose
```

#### `install.sh` - Dependency Management
```bash
# Full installation
./install.sh install

# Install only dependencies
./install.sh deps

# Install fonts
./install.sh fonts

# Validate installation
./install.sh validate
```

#### `config.sh` - Environment Management
```bash
# List environments
./config.sh list-envs

# Switch environment
./config.sh switch-env development

# Create new environment
./config.sh create-env testing

# Switch profile
./config.sh switch-profile work

# Show current configuration
./config.sh current
```

#### `monitor.sh` - Monitoring System
```bash
# Start monitoring daemon
./monitor.sh start

# Check health once
./monitor.sh check

# Show monitoring status
./monitor.sh status

# Generate report
./monitor.sh report
```

#### `update.sh` - Update Management
```bash
# Check for updates
./update.sh check

# Perform update
./update.sh update

# Run migrations
./update.sh migrate

# Create migration
./update.sh create-migration theme_update
```

## Environment System

### Predefined Environments

#### Default Environment
- Standard configuration with balanced performance
- All widgets enabled
- Regular update intervals
- Suitable for daily use

#### Development Environment
- Enhanced debugging and logging
- Faster update intervals for testing
- Performance monitoring enabled
- Debug mode active

#### Minimal Environment
- Reduced widget set for performance
- Longer update intervals
- Minimal visual effects
- Battery-optimized settings

#### Performance Environment
- Optimized for resource usage
- Cached data where possible
- Reduced animation effects
- Performance monitoring active

### Profile System

#### Work Profile
- Productivity-focused widgets
- Calendar and timer integration
- Notification management
- Focus mode capabilities

#### Gaming Profile
- Performance monitoring
- Minimal distractions
- Gaming-optimized colors
- Reduced system overhead

#### Presentation Profile
- Clean, minimal interface
- Essential information only  
- Professional appearance
- Distraction-free mode

## Monitoring & Alerting

### Health Checks
- **SketchyBar Process**: Running status and responsiveness
- **Configuration Integrity**: File presence and syntax validation
- **Dependencies**: Required and optional dependency status
- **Resource Usage**: Memory and CPU consumption monitoring
- **Disk Space**: Available storage and log file sizes

### Performance Metrics
- Memory usage tracking over time
- CPU utilization monitoring
- Plugin execution time analysis
- System response time measurement

### Alert System
- **Critical Alerts**: Process failures, missing files
- **Warning Alerts**: Performance issues, disk space
- **Info Alerts**: Successful operations, recoveries
- **Cooldown Period**: Prevents alert spam

### Automatic Recovery
- SketchyBar process restart on failure
- Memory leak detection and restart
- Log cleanup on disk space issues
- Configuration rollback on validation failure

## Migration System

### Creating Migrations
```bash
# Create new migration
./update.sh create-migration add_new_widget

# Edit the generated migration file
# migrations/20240101120000_add_new_widget.sh
```

### Migration Structure
```bash
#!/bin/bash
# Migration: add_new_widget
# Description: Adds new weather widget to configuration

migrate_up() {
    # Forward migration logic
    log_migration "Adding weather widget configuration..."
    # Add your changes here
}

migrate_down() {
    # Rollback logic
    log_migration "Removing weather widget configuration..."
    # Undo your changes here
}
```

### Running Migrations
```bash
# Run pending migrations
./update.sh migrate

# Rollback specific migration
./update.sh rollback 20240101120000_add_new_widget
```

## Directory Structure

```
~/.config/sketchybar/
├── manage.sh              # Master management script
├── deploy.sh              # Deployment and version control
├── test.sh                # Testing framework
├── install.sh             # Dependency management
├── config.sh              # Environment management
├── monitor.sh             # Monitoring system
├── update.sh              # Update management
├── backups/               # Configuration backups
├── logs/                  # System logs
├── monitoring/            # Monitoring data and metrics
├── migrations/            # Database-style migrations
├── environments/          # Environment configurations
├── profiles/              # User profiles
└── exports/               # Configuration exports
```

## Best Practices

### Development Workflow
1. **Create Feature Branch**: Use git branches for major changes
2. **Test Thoroughly**: Run full test suite before deployment
3. **Create Migration**: Write migration for configuration changes
4. **Deploy Gradually**: Test in development environment first
5. **Monitor Closely**: Watch health metrics after deployment

### Backup Strategy
- **Automatic Backups**: Created before every deployment
- **Named Backups**: Create manual backups before major changes
- **Retention Policy**: Keep last 10 backups automatically
- **Full Exports**: Export complete configurations for sharing

### Performance Optimization
- **Plugin Profiling**: Monitor plugin execution times
- **Resource Monitoring**: Track memory and CPU usage
- **Update Intervals**: Balance freshness with performance
- **Cleanup Routines**: Regular log and backup cleanup

### Security Considerations
- **Script Validation**: All scripts checked for syntax errors
- **Permission Management**: Proper file permissions enforced
- **Dangerous Pattern Detection**: Scans for potentially unsafe code
- **Dependency Verification**: Validates all external dependencies

## Troubleshooting

### Common Issues

#### SketchyBar Won't Start
```bash
# Check configuration
./test.sh basic

# View recent logs
./manage.sh logs

# Restart with clean configuration
./deploy.sh rollback
```

#### High Resource Usage
```bash
# Check performance metrics
./monitor.sh status

# Run performance tests
./test.sh performance

# Switch to minimal environment
./config.sh switch-env minimal
```

#### Configuration Errors
```bash
# Validate configuration
./test.sh syntax

# Check for missing dependencies
./install.sh validate

# Restore from backup
./deploy.sh list-backups
./deploy.sh restore <backup_name>
```

### Log Files
- **Deployment**: `logs/deploy-YYYYMMDD-HHMMSS.log`
- **Testing**: `logs/test-YYYYMMDD-HHMMSS.log`
- **Monitoring**: `logs/health-YYYYMMDD.log`
- **Updates**: `logs/update-YYYYMMDD-HHMMSS.log`

### Getting Help
```bash
# General help
./manage.sh help

# Specific tool help
./deploy.sh help
./test.sh help
./monitor.sh help
```

## Advanced Usage

### Custom Environments
```bash
# Create custom environment
./config.sh create-env production

# Edit environment configuration
# environments/production/config.sh

# Switch to custom environment
./config.sh switch-env production
```

### Automation Integration
```bash
# Use in scripts
if ./test.sh basic; then
    ./deploy.sh deploy
else
    echo "Tests failed, deployment aborted"
    exit 1
fi

# Cron job for monitoring
# 0 * * * * /path/to/sketchybar/monitor.sh check
```

### CI/CD Integration
```bash
# GitHub Actions example
- name: Test SketchyBar Configuration
  run: |
    cd ~/.config/sketchybar
    ./test.sh all
    
- name: Deploy Configuration
  run: |
    cd ~/.config/sketchybar
    ./deploy.sh deploy
```

This deployment system provides a robust, professional-grade solution for managing SketchyBar configurations with enterprise-level features including automated testing, monitoring, version control, and maintenance capabilities.