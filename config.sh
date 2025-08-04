#!/bin/bash

# SketchyBar Environment-Specific Configuration Manager
# Handles multiple environments, profiles, and configuration switching

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$SCRIPT_DIR"
readonly ENVIRONMENTS_DIR="$CONFIG_DIR/environments"
readonly PROFILES_DIR="$CONFIG_DIR/profiles"
readonly CURRENT_ENV_FILE="$CONFIG_DIR/.current_environment"
readonly CURRENT_PROFILE_FILE="$CONFIG_DIR/.current_profile"
readonly LOGS_DIR="$CONFIG_DIR/logs"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# Initialize directories
init_dirs() {
    mkdir -p "$ENVIRONMENTS_DIR" "$PROFILES_DIR" "$LOGS_DIR"
}

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

# Environment management functions
get_current_environment() {
    if [ -f "$CURRENT_ENV_FILE" ]; then
        cat "$CURRENT_ENV_FILE"
    else
        echo "default"
    fi
}

get_current_profile() {
    if [ -f "$CURRENT_PROFILE_FILE" ]; then
        cat "$CURRENT_PROFILE_FILE"
    else
        echo "default"
    fi
}

set_current_environment() {
    echo "$1" > "$CURRENT_ENV_FILE"
}

set_current_profile() {
    echo "$1" > "$CURRENT_PROFILE_FILE"
}

# Create default environments if they don't exist
create_default_environments() {
    log_info "Creating default environments..."
    
    # Default environment
    if [ ! -d "$ENVIRONMENTS_DIR/default" ]; then
        mkdir -p "$ENVIRONMENTS_DIR/default"
        
        cat > "$ENVIRONMENTS_DIR/default/config.sh" << 'EOF'
#!/bin/bash
# Default Environment Configuration

# Theme settings
export THEME_NAME="Default Dark"
export BAR_OPACITY="0.9"
export ITEM_SPACING="5"
export ANIMATION_SPEED="0.3"

# Widget settings
export SHOW_WEATHER="true"
export SHOW_BATTERY="true"
export SHOW_NETWORK="true"
export SHOW_CPU="true"
export SHOW_MEMORY="true"

# Update intervals (seconds)
export WEATHER_UPDATE_INTERVAL="1800"  # 30 minutes
export SYSTEM_UPDATE_INTERVAL="5"      # 5 seconds
export NETWORK_UPDATE_INTERVAL="3"     # 3 seconds

# External services
export WEATHER_API_KEY=""
export WEATHER_LOCATION="New York,NY"

# Developer options
export DEBUG_MODE="false"
export PERFORMANCE_MONITORING="false"
EOF
        
        log_success "Created default environment"
    fi
    
    # Development environment
    if [ ! -d "$ENVIRONMENTS_DIR/development" ]; then
        mkdir -p "$ENVIRONMENTS_DIR/development"
        
        cat > "$ENVIRONMENTS_DIR/development/config.sh" << 'EOF'
#!/bin/bash
# Development Environment Configuration

# Theme settings
export THEME_NAME="Development"
export BAR_OPACITY="0.95"
export ITEM_SPACING="8"
export ANIMATION_SPEED="0.1"

# Widget settings
export SHOW_WEATHER="true"
export SHOW_BATTERY="true"
export SHOW_NETWORK="true"
export SHOW_CPU="true"
export SHOW_MEMORY="true"

# Update intervals (faster for development)
export WEATHER_UPDATE_INTERVAL="300"   # 5 minutes
export SYSTEM_UPDATE_INTERVAL="2"      # 2 seconds
export NETWORK_UPDATE_INTERVAL="1"     # 1 second

# External services
export WEATHER_API_KEY=""
export WEATHER_LOCATION="San Francisco,CA"

# Developer options
export DEBUG_MODE="true"
export PERFORMANCE_MONITORING="true"
export LOG_LEVEL="debug"
EOF
        
        log_success "Created development environment"
    fi
    
    # Minimal environment
    if [ ! -d "$ENVIRONMENTS_DIR/minimal" ]; then
        mkdir -p "$ENVIRONMENTS_DIR/minimal"
        
        cat > "$ENVIRONMENTS_DIR/minimal/config.sh" << 'EOF'
#!/bin/bash
# Minimal Environment Configuration

# Theme settings
export THEME_NAME="Minimal"
export BAR_OPACITY="0.8"
export ITEM_SPACING="3"
export ANIMATION_SPEED="0.2"

# Widget settings (minimal set)
export SHOW_WEATHER="false"
export SHOW_BATTERY="true"
export SHOW_NETWORK="false"
export SHOW_CPU="false"
export SHOW_MEMORY="false"

# Update intervals
export SYSTEM_UPDATE_INTERVAL="10"     # 10 seconds

# External services
export WEATHER_API_KEY=""
export WEATHER_LOCATION=""

# Developer options
export DEBUG_MODE="false"
export PERFORMANCE_MONITORING="false"
EOF
        
        log_success "Created minimal environment"
    fi
    
    # Performance environment
    if [ ! -d "$ENVIRONMENTS_DIR/performance" ]; then
        mkdir -p "$ENVIRONMENTS_DIR/performance"
        
        cat > "$ENVIRONMENTS_DIR/performance/config.sh" << 'EOF'
#!/bin/bash
# Performance Environment Configuration

# Theme settings
export THEME_NAME="Performance"
export BAR_OPACITY="0.85"
export ITEM_SPACING="4"
export ANIMATION_SPEED="0.5"

# Widget settings
export SHOW_WEATHER="true"
export SHOW_BATTERY="true"
export SHOW_NETWORK="true"
export SHOW_CPU="true"
export SHOW_MEMORY="true"

# Update intervals (optimized for performance)
export WEATHER_UPDATE_INTERVAL="3600"  # 1 hour
export SYSTEM_UPDATE_INTERVAL="8"      # 8 seconds
export NETWORK_UPDATE_INTERVAL="5"     # 5 seconds

# External services
export WEATHER_API_KEY=""
export WEATHER_LOCATION="Los Angeles,CA"

# Developer options
export DEBUG_MODE="false"
export PERFORMANCE_MONITORING="true"
EOF
        
        log_success "Created performance environment"
    fi
}

# Create default profiles
create_default_profiles() {
    log_info "Creating default profiles..."
    
    # Work profile
    if [ ! -d "$PROFILES_DIR/work" ]; then
        mkdir -p "$PROFILES_DIR/work"
        
        cat > "$PROFILES_DIR/work/config.sh" << 'EOF'
#!/bin/bash
# Work Profile Configuration

# Workspace-specific settings
export WORKSPACE_NAMES=("Work" "Email" "Docs" "Chat" "Dev")
export DEFAULT_WORKSPACE="Work"

# Productivity features
export SHOW_PRODUCTIVITY_TIMER="true"
export SHOW_CALENDAR="true"
export SHOW_SHORTCUTS="true"

# Notification settings
export NOTIFICATION_LEVEL="minimal"
export FOCUS_MODE="true"

# Color overrides for work theme
export ACCENT_COLOR="0xff89b4fa"  # Blue
export URGENT_COLOR="0xfff38ba8"  # Red
EOF
        
        log_success "Created work profile"
    fi
    
    # Gaming profile
    if [ ! -d "$PROFILES_DIR/gaming" ]; then
        mkdir -p "$PROFILES_DIR/gaming"
        
        cat > "$PROFILES_DIR/gaming/config.sh" << 'EOF'
#!/bin/bash
# Gaming Profile Configuration

# Workspace-specific settings
export WORKSPACE_NAMES=("Game" "Discord" "Browser" "Stream")
export DEFAULT_WORKSPACE="Game"

# Gaming-specific features
export SHOW_PRODUCTIVITY_TIMER="false"
export SHOW_CALENDAR="false"
export SHOW_SHORTCUTS="false"
export SHOW_PERFORMANCE_MONITOR="true"

# Notification settings
export NOTIFICATION_LEVEL="none"
export FOCUS_MODE="true"

# Color overrides for gaming theme
export ACCENT_COLOR="0xffa6e3a1"  # Green
export URGENT_COLOR="0xfffab387"  # Orange

# Performance optimizations
export REDUCE_ANIMATIONS="true"
export MINIMAL_UPDATES="true"
EOF
        
        log_success "Created gaming profile"
    fi
    
    # Presentation profile
    if [ ! -d "$PROFILES_DIR/presentation" ]; then
        mkdir -p "$PROFILES_DIR/presentation"
        
        cat > "$PROFILES_DIR/presentation/config.sh" << 'EOF'
#!/bin/bash
# Presentation Profile Configuration

# Workspace-specific settings
export WORKSPACE_NAMES=("Present" "Notes" "Browser")
export DEFAULT_WORKSPACE="Present"

# Presentation-specific features
export SHOW_PRODUCTIVITY_TIMER="false"
export SHOW_CALENDAR="false"
export SHOW_SHORTCUTS="false"
export SHOW_CLOCK="true"

# Notification settings
export NOTIFICATION_LEVEL="none"
export FOCUS_MODE="true"

# Visual settings for presentations
export BAR_OPACITY="0.7"
export MINIMAL_DISPLAY="true"

# Color overrides
export ACCENT_COLOR="0xfffff9e2af"  # Yellow
EOF
        
        log_success "Created presentation profile"
    fi
}

# List available environments
list_environments() {
    log_section "Available Environments"
    
    local current_env
    current_env=$(get_current_environment)
    
    if [ -d "$ENVIRONMENTS_DIR" ]; then
        for env_dir in "$ENVIRONMENTS_DIR"/*; do
            if [ -d "$env_dir" ]; then
                local env_name
                env_name=$(basename "$env_dir")
                
                if [ "$env_name" = "$current_env" ]; then
                    echo -e "  ${GREEN}* $env_name${NC} (current)"
                else
                    echo "  - $env_name"
                fi
                
                # Show description if available
                if [ -f "$env_dir/description.txt" ]; then
                    echo "    $(cat "$env_dir/description.txt")"
                fi
            fi
        done
    else
        log_warning "No environments directory found"
    fi
}

# List available profiles
list_profiles() {
    log_section "Available Profiles"
    
    local current_profile
    current_profile=$(get_current_profile)
    
    if [ -d "$PROFILES_DIR" ]; then
        for profile_dir in "$PROFILES_DIR"/*; do
            if [ -d "$profile_dir" ]; then
                local profile_name
                profile_name=$(basename "$profile_dir")
                
                if [ "$profile_name" = "$current_profile" ]; then
                    echo -e "  ${GREEN}* $profile_name${NC} (current)"
                else
                    echo "  - $profile_name"
                fi
                
                # Show description if available
                if [ -f "$profile_dir/description.txt" ]; then
                    echo "    $(cat "$profile_dir/description.txt")"
                fi
            fi
        done
    else
        log_warning "No profiles directory found"
    fi
}

# Switch environment
switch_environment() {
    local env_name="$1"
    local env_dir="$ENVIRONMENTS_DIR/$env_name"
    
    if [ ! -d "$env_dir" ]; then
        log_error "Environment not found: $env_name"
        return 1
    fi
    
    if [ ! -f "$env_dir/config.sh" ]; then
        log_error "Environment configuration not found: $env_dir/config.sh"
        return 1
    fi
    
    log_info "Switching to environment: $env_name"
    
    # Create backup of current configuration
    "$CONFIG_DIR/deploy.sh" backup "pre-env-switch-$(date +%Y%m%d-%H%M%S)"
    
    # Set current environment
    set_current_environment "$env_name"
    
    # Apply environment configuration
    apply_configuration
    
    log_success "Switched to environment: $env_name"
}

# Switch profile
switch_profile() {
    local profile_name="$1"
    local profile_dir="$PROFILES_DIR/$profile_name"
    
    if [ ! -d "$profile_dir" ]; then
        log_error "Profile not found: $profile_name"
        return 1
    fi
    
    if [ ! -f "$profile_dir/config.sh" ]; then
        log_error "Profile configuration not found: $profile_dir/config.sh"
        return 1
    fi
    
    log_info "Switching to profile: $profile_name"
    
    # Create backup of current configuration
    "$CONFIG_DIR/deploy.sh" backup "pre-profile-switch-$(date +%Y%m%d-%H%M%S)"
    
    # Set current profile
    set_current_profile "$profile_name"
    
    # Apply configuration
    apply_configuration
    
    log_success "Switched to profile: $profile_name"
}

# Apply current configuration
apply_configuration() {
    log_info "Applying configuration..."
    
    local current_env
    local current_profile
    current_env=$(get_current_environment)
    current_profile=$(get_current_profile)
    
    # Create combined configuration file
    local combined_config="$CONFIG_DIR/.env_config"
    
    cat > "$combined_config" << EOF
#!/bin/bash
# Combined Environment and Profile Configuration
# Generated: $(date)
# Environment: $current_env
# Profile: $current_profile

EOF
    
    # Source environment configuration
    local env_config="$ENVIRONMENTS_DIR/$current_env/config.sh"
    if [ -f "$env_config" ]; then
        echo "# Environment Configuration ($current_env)" >> "$combined_config"
        cat "$env_config" >> "$combined_config"
        echo "" >> "$combined_config"
    fi
    
    # Source profile configuration
    local profile_config="$PROFILES_DIR/$current_profile/config.sh"
    if [ -f "$profile_config" ]; then
        echo "# Profile Configuration ($current_profile)" >> "$combined_config"
        cat "$profile_config" >> "$combined_config"
        echo "" >> "$combined_config"
    fi
    
    # Make the combined config executable
    chmod +x "$combined_config"
    
    # Update variables.sh to source the combined config
    if ! grep -q "source.*\.env_config" "$CONFIG_DIR/variables.sh"; then
        echo "" >> "$CONFIG_DIR/variables.sh"
        echo "# Source environment-specific configuration" >> "$CONFIG_DIR/variables.sh"
        echo "if [ -f \"$CONFIG_DIR/.env_config\" ]; then" >> "$CONFIG_DIR/variables.sh"
        echo "    source \"$CONFIG_DIR/.env_config\"" >> "$CONFIG_DIR/variables.sh"
        echo "fi" >> "$CONFIG_DIR/variables.sh"
    fi
    
    # Restart SketchyBar to apply changes
    if pgrep -x sketchybar >/dev/null; then
        log_info "Restarting SketchyBar to apply changes..."
        "$CONFIG_DIR/deploy.sh" restart
    fi
    
    log_success "Configuration applied successfully"
}

# Create new environment
create_environment() {
    local env_name="$1"
    local env_dir="$ENVIRONMENTS_DIR/$env_name"
    
    if [ -d "$env_dir" ]; then
        log_error "Environment already exists: $env_name"
        return 1
    fi
    
    log_info "Creating new environment: $env_name"
    
    mkdir -p "$env_dir"
    
    # Copy from default environment as template
    if [ -f "$ENVIRONMENTS_DIR/default/config.sh" ]; then
        cp "$ENVIRONMENTS_DIR/default/config.sh" "$env_dir/config.sh"
    else
        cat > "$env_dir/config.sh" << 'EOF'
#!/bin/bash
# Custom Environment Configuration

# Theme settings
export THEME_NAME="Custom"
export BAR_OPACITY="0.9"
export ITEM_SPACING="5"
export ANIMATION_SPEED="0.3"

# Widget settings
export SHOW_WEATHER="true"
export SHOW_BATTERY="true"
export SHOW_NETWORK="true"
export SHOW_CPU="true"
export SHOW_MEMORY="true"

# Update intervals (seconds)
export WEATHER_UPDATE_INTERVAL="1800"
export SYSTEM_UPDATE_INTERVAL="5"
export NETWORK_UPDATE_INTERVAL="3"

# External services
export WEATHER_API_KEY=""
export WEATHER_LOCATION=""

# Developer options
export DEBUG_MODE="false"
export PERFORMANCE_MONITORING="false"
EOF
    fi
    
    # Create description file
    echo "Custom environment: $env_name" > "$env_dir/description.txt"
    
    log_success "Created environment: $env_name"
    log_info "Edit $env_dir/config.sh to customize the environment"
}

# Create new profile
create_profile() {
    local profile_name="$1"
    local profile_dir="$PROFILES_DIR/$profile_name"
    
    if [ -d "$profile_dir" ]; then
        log_error "Profile already exists: $profile_name"
        return 1
    fi
    
    log_info "Creating new profile: $profile_name"
    
    mkdir -p "$profile_dir"
    
    cat > "$profile_dir/config.sh" << 'EOF'
#!/bin/bash
# Custom Profile Configuration

# Workspace-specific settings
export WORKSPACE_NAMES=("Main" "Secondary")
export DEFAULT_WORKSPACE="Main"

# Feature toggles
export SHOW_PRODUCTIVITY_TIMER="true"
export SHOW_CALENDAR="true"
export SHOW_SHORTCUTS="true"

# Notification settings
export NOTIFICATION_LEVEL="normal"
export FOCUS_MODE="false"

# Color overrides
export ACCENT_COLOR=""
export URGENT_COLOR=""
EOF
    
    # Create description file
    echo "Custom profile: $profile_name" > "$profile_dir/description.txt"
    
    log_success "Created profile: $profile_name"
    log_info "Edit $profile_dir/config.sh to customize the profile"
}

# Show current configuration
show_current() {
    log_section "Current Configuration"
    
    local current_env
    local current_profile
    current_env=$(get_current_environment)
    current_profile=$(get_current_profile)
    
    echo "Environment: $current_env"
    echo "Profile: $current_profile"
    echo ""
    
    # Show combined configuration
    if [ -f "$CONFIG_DIR/.env_config" ]; then
        echo "Active Configuration Variables:"
        echo "------------------------------"
        grep "^export" "$CONFIG_DIR/.env_config" | head -20
        echo ""
    fi
    
    # Show SketchyBar status
    if pgrep -x sketchybar >/dev/null; then
        echo "SketchyBar Status: Running"
    else
        echo "SketchyBar Status: Not running"
    fi
}

# Export configuration
export_config() {
    local export_name="$1"
    local export_file="$CONFIG_DIR/exports/$export_name-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    mkdir -p "$(dirname "$export_file")"
    
    log_info "Exporting configuration to: $export_file"
    
    # Create temporary export directory
    local temp_dir
    temp_dir=$(mktemp -d)
    local export_dir="$temp_dir/sketchybar-config"
    
    mkdir -p "$export_dir"
    
    # Copy current environment and profile
    local current_env
    local current_profile
    current_env=$(get_current_environment)
    current_profile=$(get_current_profile)
    
    cp -r "$ENVIRONMENTS_DIR/$current_env" "$export_dir/environment"
    cp -r "$PROFILES_DIR/$current_profile" "$export_dir/profile"
    
    # Copy core configuration files
    cp "$CONFIG_DIR/variables.sh" "$export_dir/"
    cp "$CONFIG_DIR/sketchybarrc" "$export_dir/"
    
    # Create export metadata
    cat > "$export_dir/export_info.txt" << EOF
Export Name: $export_name
Export Date: $(date)
Environment: $current_env
Profile: $current_profile
SketchyBar Version: $(sketchybar --version 2>/dev/null || echo "unknown")
System: $(uname -s) $(uname -r)
EOF
    
    # Create archive
    cd "$temp_dir"
    tar -czf "$export_file" sketchybar-config/
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "Configuration exported to: $export_file"
}

# Import configuration
import_config() {
    local import_file="$1"
    
    if [ ! -f "$import_file" ]; then
        log_error "Import file not found: $import_file"
        return 1
    fi
    
    log_info "Importing configuration from: $import_file"
    
    # Create backup before import
    "$CONFIG_DIR/deploy.sh" backup "pre-import-$(date +%Y%m%d-%H%M%S)"
    
    # Extract to temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    
    cd "$temp_dir"
    if ! tar -xzf "$import_file"; then
        log_error "Failed to extract import file"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Check if it's a valid export
    if [ ! -d "sketchybar-config" ] || [ ! -f "sketchybar-config/export_info.txt" ]; then
        log_error "Invalid import file format"
        rm -rf "$temp_dir"
        return 1
    fi
    
    local import_dir="$temp_dir/sketchybar-config"
    
    # Show import information
    echo "Import Information:"
    cat "$import_dir/export_info.txt"
    echo ""
    
    read -p "Continue with import? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Import cancelled"
        rm -rf "$temp_dir"
        return 0
    fi
    
    # Import environment and profile
    if [ -d "$import_dir/environment" ]; then
        local env_name="imported-$(date +%Y%m%d-%H%M%S)"
        cp -r "$import_dir/environment" "$ENVIRONMENTS_DIR/$env_name"
        log_success "Imported environment as: $env_name"
    fi
    
    if [ -d "$import_dir/profile" ]; then
        local profile_name="imported-$(date +%Y%m%d-%H%M%S)"
        cp -r "$import_dir/profile" "$PROFILES_DIR/$profile_name"
        log_success "Imported profile as: $profile_name"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "Configuration imported successfully"
}

# Usage function
usage() {
    cat << EOF
SketchyBar Environment and Profile Configuration Manager

Usage: $0 <command> [arguments]

Environment Commands:
    list-envs                 List available environments
    switch-env <name>         Switch to environment
    create-env <name>         Create new environment
    current                   Show current configuration

Profile Commands:
    list-profiles             List available profiles  
    switch-profile <name>     Switch to profile
    create-profile <name>     Create new profile

Configuration Commands:
    apply                     Apply current environment and profile
    export <name>             Export current configuration
    import <file>             Import configuration from file
    reset                     Reset to default configuration

Examples:
    $0 list-envs              # List all environments
    $0 switch-env development # Switch to development environment
    $0 switch-profile work    # Switch to work profile
    $0 create-env testing     # Create new testing environment
    $0 export my-config       # Export current configuration
    $0 current                # Show current configuration

EOF
}

# Main function
main() {
    local command="${1:-}"
    
    if [ -z "$command" ]; then
        usage
        exit 1
    fi
    
    # Initialize directories
    init_dirs
    
    # Create default environments and profiles if they don't exist
    create_default_environments
    create_default_profiles
    
    case "$command" in
        list-envs|list-environments)
            list_environments
            ;;
        list-profiles)
            list_profiles
            ;;
        switch-env|switch-environment)
            if [ -z "${2:-}" ]; then
                log_error "Environment name required"
                usage
                exit 1
            fi
            switch_environment "$2"
            ;;
        switch-profile)
            if [ -z "${2:-}" ]; then
                log_error "Profile name required"
                usage
                exit 1
            fi
            switch_profile "$2"
            ;;
        create-env|create-environment)
            if [ -z "${2:-}" ]; then
                log_error "Environment name required"
                usage
                exit 1
            fi
            create_environment "$2"
            ;;
        create-profile)
            if [ -z "${2:-}" ]; then
                log_error "Profile name required"
                usage
                exit 1
            fi
            create_profile "$2"
            ;;
        current)
            show_current
            ;;
        apply)
            apply_configuration
            ;;
        export)
            if [ -z "${2:-}" ]; then
                log_error "Export name required"
                usage
                exit 1
            fi
            export_config "$2"
            ;;
        import)
            if [ -z "${2:-}" ]; then
                log_error "Import file required"
                usage
                exit 1
            fi
            import_config "$2"
            ;;
        reset)
            log_info "Resetting to default configuration..."
            set_current_environment "default"
            set_current_profile "default"
            apply_configuration
            log_success "Reset to default configuration"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            log_error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"