#!/bin/bash

# SketchyBar Dependency Management and Installation Script
# Comprehensive dependency checking, installation, and environment setup

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$SCRIPT_DIR"
readonly LOGS_DIR="$CONFIG_DIR/logs"
readonly INSTALL_LOG="$LOGS_DIR/install-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# System information
readonly OS_NAME=$(uname -s)
readonly OS_VERSION=$(uname -r)
readonly ARCH=$(uname -m)

# Initialize directories
init_dirs() {
    mkdir -p "$LOGS_DIR"
}

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$INSTALL_LOG"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$INSTALL_LOG"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$INSTALL_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$INSTALL_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$INSTALL_LOG"
}

log_section() {
    echo -e "${PURPLE}=== $1 ===${NC}" | tee -a "$INSTALL_LOG"
}

# System compatibility check
check_system_compatibility() {
    log_section "System Compatibility Check"
    
    if [ "$OS_NAME" != "Darwin" ]; then
        log_error "SketchyBar only supports macOS (Darwin). Current OS: $OS_NAME"
        return 1
    fi
    
    # Check macOS version
    local macos_version
    macos_version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "$macos_version" | cut -d. -f1)
    
    if [ "$major_version" -lt 12 ]; then
        log_warning "macOS version $macos_version detected. SketchyBar works best on macOS 12+ (Monterey)"
    else
        log_success "macOS version $macos_version is compatible"
    fi
    
    # Check architecture
    if [ "$ARCH" = "arm64" ]; then
        log_info "Apple Silicon (ARM64) detected"
    elif [ "$ARCH" = "x86_64" ]; then
        log_info "Intel (x86_64) detected"
    else
        log_warning "Unknown architecture: $ARCH"
    fi
    
    return 0
}

# Package manager detection and installation
detect_package_manager() {
    if command -v brew >/dev/null 2>&1; then
        echo "brew"
    elif command -v port >/dev/null 2>&1; then
        echo "port"
    else
        echo "none"
    fi
}

install_homebrew() {
    log_info "Homebrew not found. Installing Homebrew..."
    
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_error "Failed to install Homebrew"
        return 1
    fi
    
    # Add Homebrew to PATH
    if [ "$ARCH" = "arm64" ]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    log_success "Homebrew installed successfully"
    return 0
}

# Core dependencies
install_core_dependencies() {
    log_section "Installing Core Dependencies"
    
    local package_manager
    package_manager=$(detect_package_manager)
    
    if [ "$package_manager" = "none" ]; then
        log_warning "No package manager found. Installing Homebrew..."
        if ! install_homebrew; then
            log_error "Failed to install package manager"
            return 1
        fi
        package_manager="brew"
    fi
    
    local core_deps=()
    
    # Check and install SketchyBar
    if ! command -v sketchybar >/dev/null 2>&1; then
        log_info "SketchyBar not found. Adding to installation list..."
        core_deps+=("sketchybar")
    else
        log_success "SketchyBar already installed: $(sketchybar --version)"
    fi
    
    # Check and install dependencies based on package manager
    case "$package_manager" in
        brew)
            install_brew_dependencies "${core_deps[@]}"
            ;;
        port)
            install_port_dependencies "${core_deps[@]}"
            ;;
        *)
            log_error "Unsupported package manager: $package_manager"
            return 1
            ;;
    esac
}

install_brew_dependencies() {
    local deps=("$@")
    
    if [ ${#deps[@]} -eq 0 ]; then
        log_info "All core dependencies already installed"
        return 0
    fi
    
    log_info "Installing dependencies with Homebrew: ${deps[*]}"
    
    # Update Homebrew
    log_info "Updating Homebrew..."
    if ! brew update; then
        log_warning "Failed to update Homebrew, continuing anyway..."
    fi
    
    # Install dependencies
    for dep in "${deps[@]}"; do
        log_info "Installing $dep..."
        if brew install "$dep"; then
            log_success "Successfully installed $dep"
        else
            log_error "Failed to install $dep"
            return 1
        fi
    done
}

install_port_dependencies() {
    local deps=("$@")
    
    if [ ${#deps[@]} -eq 0 ]; then
        log_info "All core dependencies already installed"
        return 0
    fi
    
    log_info "Installing dependencies with MacPorts: ${deps[*]}"
    
    # Update MacPorts
    log_info "Updating MacPorts..."
    if ! sudo port selfupdate; then
        log_warning "Failed to update MacPorts, continuing anyway..."
    fi
    
    # Install dependencies
    for dep in "${deps[@]}"; do
        log_info "Installing $dep..."
        if sudo port install "$dep"; then
            log_success "Successfully installed $dep"
        else
            log_error "Failed to install $dep"
            return 1
        fi
    done
}

# Optional dependencies
install_optional_dependencies() {
    log_section "Installing Optional Dependencies"
    
    local package_manager
    package_manager=$(detect_package_manager)
    
    local optional_deps=()
    local descriptions=()
    
    # Check yabai
    if ! command -v yabai >/dev/null 2>&1; then
        log_info "yabai not found (optional: required for workspace management)"
        optional_deps+=("yabai")
        descriptions+=("Window manager for workspace features")
    fi
    
    # Check jq
    if ! command -v jq >/dev/null 2>&1; then
        log_info "jq not found (optional: required for JSON processing in some plugins)"
        optional_deps+=("jq")
        descriptions+=("JSON processor for plugin data parsing")
    fi
    
    # Check curl
    if ! command -v curl >/dev/null 2>&1; then
        log_info "curl not found (optional: required for weather and network plugins)"
        optional_deps+=("curl")
        descriptions+=("HTTP client for external API calls")
    fi
    
    # Check lua
    if ! command -v lua >/dev/null 2>&1; then
        log_info "lua not found (optional: required for Lua configuration validation)"
        optional_deps+=("lua")
        descriptions+=("Lua interpreter for configuration validation")
    fi
    
    # Check bc
    if ! command -v bc >/dev/null 2>&1; then
        log_info "bc not found (optional: required for mathematical calculations in plugins)"
        optional_deps+=("bc")
        descriptions+=("Calculator for performance measurements")
    fi
    
    if [ ${#optional_deps[@]} -eq 0 ]; then
        log_success "All optional dependencies already installed"
        return 0
    fi
    
    # Ask user if they want to install optional dependencies
    echo
    echo "The following optional dependencies are not installed:"
    for i in "${!optional_deps[@]}"; do
        echo "  - ${optional_deps[$i]}: ${descriptions[$i]}"
    done
    echo
    
    read -p "Install optional dependencies? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        case "$package_manager" in
            brew)
                install_brew_dependencies "${optional_deps[@]}"
                ;;
            port)
                install_port_dependencies "${optional_deps[@]}"
                ;;
        esac
    else
        log_info "Skipping optional dependencies"
    fi
}

# Font installation
install_fonts() {
    log_section "Font Installation"
    
    local font_dir="$HOME/Library/Fonts"
    local fonts_to_install=()
    
    # Check for SF Pro (system font, usually already available)
    if ! system_profiler SPFontsDataType | grep -q "SF Pro"; then
        log_warning "SF Pro font not found. This is unusual for macOS systems."
    else
        log_success "SF Pro font available"
    fi
    
    # Check for Nerd Font
    if ! fc-list 2>/dev/null | grep -q "Nerd Font"; then
        log_info "Nerd Font not found. Installing Hack Nerd Font..."
        fonts_to_install+=("font-hack-nerd-font")
    else
        log_success "Nerd Font already installed"
    fi
    
    # Install fonts via Homebrew cask
    if [ ${#fonts_to_install[@]} -gt 0 ] && command -v brew >/dev/null 2>&1; then
        log_info "Installing fonts: ${fonts_to_install[*]}"
        
        for font in "${fonts_to_install[@]}"; do
            if brew install --cask "$font"; then
                log_success "Successfully installed $font"
            else
                log_warning "Failed to install $font"
            fi
        done
    fi
}

# Build native helpers
build_native_helpers() {
    log_section "Building Native Helpers"
    
    # Check if make is available
    if ! command -v make >/dev/null 2>&1; then
        log_error "make not found. Please install Xcode Command Line Tools:"
        log_error "  xcode-select --install"
        return 1
    fi
    
    # Build event providers
    if [ -d "$CONFIG_DIR/helpers/event_providers" ]; then
        log_info "Building event providers..."
        cd "$CONFIG_DIR/helpers/event_providers"
        
        if make clean && make; then
            log_success "Event providers built successfully"
        else
            log_warning "Failed to build event providers (some features may not work)"
        fi
        
        cd "$CONFIG_DIR"
    fi
    
    # Build menu helpers
    if [ -d "$CONFIG_DIR/helpers/menus" ]; then
        log_info "Building menu helpers..."
        cd "$CONFIG_DIR/helpers/menus"
        
        if make clean && make; then
            log_success "Menu helpers built successfully"
        else
            log_warning "Failed to build menu helpers (some features may not work)"
        fi
        
        cd "$CONFIG_DIR"
    fi
}

# Configuration setup
setup_configuration() {
    log_section "Configuration Setup"
    
    # Make scripts executable
    log_info "Setting executable permissions..."
    find "$CONFIG_DIR" -name "*.sh" -type f -exec chmod +x {} \;
    chmod +x "$CONFIG_DIR/sketchybarrc"
    
    # Create necessary directories
    mkdir -p "$CONFIG_DIR/logs" "$CONFIG_DIR/backups"
    
    # Initialize version file
    if [ ! -f "$CONFIG_DIR/.version" ]; then
        echo "1.0.0" > "$CONFIG_DIR/.version"
        log_info "Initialized version file"
    fi
    
    log_success "Configuration setup completed"
}

# Environment configuration
setup_environment() {
    log_section "Environment Setup"
    
    # Check shell configuration
    local shell_config=""
    if [ -n "${ZSH_VERSION:-}" ]; then
        shell_config="$HOME/.zshrc"
    elif [ -n "${BASH_VERSION:-}" ]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [ -n "$shell_config" ]; then
        # Add configuration directory to PATH if not already there
        if ! grep -q "sketchybar" "$shell_config" 2>/dev/null; then
            cat >> "$shell_config" << EOF

# SketchyBar configuration
export SKETCHYBAR_CONFIG_DIR="$CONFIG_DIR"
alias sketchybar-deploy="$CONFIG_DIR/deploy.sh"
alias sketchybar-test="$CONFIG_DIR/test.sh"
alias sketchybar-install="$CONFIG_DIR/install.sh"
EOF
            log_info "Added SketchyBar aliases to $shell_config"
        fi
    fi
    
    # Set up launch agent (optional)
    setup_launch_agent
}

setup_launch_agent() {
    local launch_agents_dir="$HOME/Library/LaunchAgents"
    local plist_file="$launch_agents_dir/com.user.sketchybar.plist"
    
    read -p "Set up SketchyBar to start automatically at login? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$launch_agents_dir"
        
        cat > "$plist_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.sketchybar</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/sketchybar</string>
        <string>--config</string>
        <string>$CONFIG_DIR/sketchybarrc</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF
        
        # Load the launch agent
        if launchctl load "$plist_file"; then
            log_success "Launch agent installed and loaded"
        else
            log_warning "Failed to load launch agent"
        fi
    else
        log_info "Skipping launch agent setup"
    fi
}

# System validation
validate_installation() {
    log_section "Installation Validation"
    
    local validation_errors=0
    
    # Check core dependencies
    local core_commands=("sketchybar")
    for cmd in "${core_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            log_success "$cmd is available"
        else
            log_error "$cmd is not available"
            ((validation_errors++))
        fi
    done
    
    # Test configuration loading
    if "$CONFIG_DIR/test.sh" basic --verbose >/dev/null 2>&1; then
        log_success "Configuration validation passed"
    else
        log_error "Configuration validation failed"
        ((validation_errors++))
    fi
    
    # Test SketchyBar startup
    log_info "Testing SketchyBar startup..."
    if timeout 10s sketchybar --config "$CONFIG_DIR/sketchybarrc" >/dev/null 2>&1; then
        log_success "SketchyBar started successfully"
        pkill -TERM sketchybar 2>/dev/null || true
    else
        log_error "SketchyBar failed to start"
        ((validation_errors++))
    fi
    
    if [ $validation_errors -eq 0 ]; then
        log_success "Installation validation passed"
        return 0
    else
        log_error "Installation validation failed with $validation_errors errors"
        return 1
    fi
}

# Generate installation report
generate_installation_report() {
    local report_file="$LOGS_DIR/install-report-$(date +%Y%m%d-%H%M%S).html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>SketchyBar Installation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { color: #333; border-bottom: 2px solid #ddd; padding-bottom: 10px; }
        .section { margin: 20px 0; padding: 15px; background: #f5f5f5; border-radius: 5px; }
        .success { color: #28a745; }
        .error { color: #dc3545; }
        .warning { color: #ffc107; }
        pre { background: #f8f9fa; padding: 10px; border-radius: 3px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>SketchyBar Installation Report</h1>
        <p>Generated: $(date)</p>
        <p>System: $OS_NAME $OS_VERSION ($ARCH)</p>
        <p>Configuration: $CONFIG_DIR</p>
    </div>
    
    <div class="section">
        <h2>System Information</h2>
        <ul>
            <li><strong>OS:</strong> $(sw_vers -productName) $(sw_vers -productVersion)</li>
            <li><strong>Architecture:</strong> $ARCH</li>
            <li><strong>Package Manager:</strong> $(detect_package_manager)</li>
            <li><strong>Shell:</strong> $SHELL</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>Installed Dependencies</h2>
        <ul>
            <li>SketchyBar: $(command -v sketchybar >/dev/null && sketchybar --version || echo "Not installed")</li>
            <li>yabai: $(command -v yabai >/dev/null && echo "Installed" || echo "Not installed")</li>
            <li>jq: $(command -v jq >/dev/null && jq --version || echo "Not installed")</li>
            <li>curl: $(command -v curl >/dev/null && curl --version | head -1 || echo "Not installed")</li>
            <li>lua: $(command -v lua >/dev/null && lua -v || echo "Not installed")</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>Installation Log</h2>
        <pre>$(cat "$INSTALL_LOG")</pre>
    </div>
</body>
</html>
EOF
    
    log_info "Installation report generated: $report_file"
}

# Uninstall function
uninstall() {
    log_section "SketchyBar Configuration Uninstall"
    
    echo "This will remove the SketchyBar configuration but keep the SketchyBar binary itself."
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Uninstall cancelled"
        return 0
    fi
    
    # Stop SketchyBar
    if pgrep -x sketchybar >/dev/null; then
        log_info "Stopping SketchyBar..."
        pkill -TERM sketchybar
        sleep 2
    fi
    
    # Remove launch agent
    local plist_file="$HOME/Library/LaunchAgents/com.user.sketchybar.plist"
    if [ -f "$plist_file" ]; then
        log_info "Removing launch agent..."
        launchctl unload "$plist_file" 2>/dev/null || true
        rm -f "$plist_file"
    fi
    
    # Create final backup
    "$CONFIG_DIR/deploy.sh" backup "final-backup-$(date +%Y%m%d-%H%M%S)"
    
    log_success "Uninstall completed. Configuration backed up."
}

# Usage function
usage() {
    cat << EOF
SketchyBar Dependency Management and Installation Script

Usage: $0 <command> [options]

Commands:
    install            Full installation (dependencies, fonts, configuration)
    deps              Install only dependencies
    fonts             Install only fonts
    build             Build native helpers
    setup             Setup configuration and environment
    validate          Validate installation
    uninstall         Remove configuration (keeps SketchyBar binary)
    report            Generate installation report
    help              Show this help message

Options:
    --force           Force reinstallation of components
    --no-optional     Skip optional dependencies
    --verbose         Enable verbose output

Examples:
    $0 install                    # Full installation
    $0 deps --no-optional         # Install only required dependencies
    $0 validate                   # Validate current installation

EOF
}

# Main function
main() {
    local command="${1:-install}"
    local force=false
    local no_optional=false
    local verbose=false
    
    # Parse options
    shift || true
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force=true
                shift
                ;;
            --no-optional)
                no_optional=true
                shift
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Initialize
    init_dirs
    
    # Set verbose mode
    if [ "$verbose" = true ]; then
        set -x
    fi
    
    log_info "Starting SketchyBar installation process"
    log_info "Command: $command"
    
    # Check system compatibility first
    if ! check_system_compatibility; then
        exit 1
    fi
    
    # Execute command
    case "$command" in
        install)
            install_core_dependencies
            if [ "$no_optional" = false ]; then
                install_optional_dependencies
            fi
            install_fonts
            build_native_helpers
            setup_configuration
            setup_environment
            if validate_installation; then
                log_success "Installation completed successfully!"
                generate_installation_report
            else
                log_error "Installation validation failed"
                exit 1
            fi
            ;;
        deps)
            install_core_dependencies
            if [ "$no_optional" = false ]; then
                install_optional_dependencies
            fi
            ;;
        fonts)
            install_fonts
            ;;
        build)
            build_native_helpers
            ;;
        setup)
            setup_configuration
            setup_environment
            ;;
        validate)
            validate_installation
            ;;
        uninstall)
            uninstall
            ;;
        report)
            generate_installation_report
            ;;
        help)
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