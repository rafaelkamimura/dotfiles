#!/bin/bash

# SketchyBar Configuration Management System
# Master script that orchestrates all deployment, testing, monitoring, and maintenance tools

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$SCRIPT_DIR"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Tool paths
readonly DEPLOY_SCRIPT="$CONFIG_DIR/deploy.sh"
readonly TEST_SCRIPT="$CONFIG_DIR/test.sh"
readonly INSTALL_SCRIPT="$CONFIG_DIR/install.sh"
readonly CONFIG_SCRIPT="$CONFIG_DIR/config.sh"
readonly MONITOR_SCRIPT="$CONFIG_DIR/monitor.sh"
readonly UPDATE_SCRIPT="$CONFIG_DIR/update.sh"

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

log_header() {
    echo -e "${CYAN}$1${NC}"
}

# Check if required scripts exist
check_prerequisites() {
    local missing_scripts=()
    
    local required_scripts=(
        "$DEPLOY_SCRIPT:Deployment"
        "$TEST_SCRIPT:Testing"
        "$INSTALL_SCRIPT:Installation" 
        "$CONFIG_SCRIPT:Configuration"
        "$MONITOR_SCRIPT:Monitoring"
        "$UPDATE_SCRIPT:Updates"
    )
    
    for script_info in "${required_scripts[@]}"; do
        local script_path="${script_info%:*}"
        local script_name="${script_info#*:}"
        
        if [ ! -f "$script_path" ]; then
            missing_scripts+=("$script_name ($script_path)")
        elif [ ! -x "$script_path" ]; then
            log_warning "$script_name script is not executable: $script_path"
            chmod +x "$script_path" 2>/dev/null || true
        fi
    done
    
    if [ ${#missing_scripts[@]} -gt 0 ]; then
        log_error "Missing required scripts:"
        for script in "${missing_scripts[@]}"; do
            echo "  - $script"
        done
        return 1
    fi
    
    return 0
}

# Dashboard function - shows overall system status
show_dashboard() {
    clear
    log_header "╔══════════════════════════════════════════════════════════════════════════════╗"
    log_header "║                        SketchyBar Management Dashboard                       ║"
    log_header "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # System Status
    log_section "System Status"
    
    # SketchyBar Status
    if pgrep -x sketchybar >/dev/null; then
        local pid
        pid=$(pgrep -x sketchybar)
        local uptime
        uptime=$(ps -o etime= -p "$pid" | tr -d ' ')
        echo -e "SketchyBar:      ${GREEN}Running${NC} (PID: $pid, Uptime: $uptime)"
    else
        echo -e "SketchyBar:      ${RED}Not Running${NC}"
    fi
    
    # Configuration Version
    local version="Unknown"
    if [ -f "$CONFIG_DIR/.version" ]; then
        version=$(cat "$CONFIG_DIR/.version")
    fi
    echo "Version:         $version"
    
    # Environment and Profile
    local environment="default"
    local profile="default"
    if [ -f "$CONFIG_DIR/.current_environment" ]; then
        environment=$(cat "$CONFIG_DIR/.current_environment")
    fi
    if [ -f "$CONFIG_DIR/.current_profile" ]; then
        profile=$(cat "$CONFIG_DIR/.current_profile")
    fi
    echo "Environment:     $environment"
    echo "Profile:         $profile"
    
    # Monitoring Status
    if [ -f "$CONFIG_DIR/monitoring/monitor.pid" ] && kill -0 "$(cat "$CONFIG_DIR/monitoring/monitor.pid")" 2>/dev/null; then
        echo -e "Monitoring:      ${GREEN}Active${NC}"
    else
        echo -e "Monitoring:      ${YELLOW}Inactive${NC}"
    fi
    
    # Health Status
    if [ -f "$CONFIG_DIR/monitoring/metrics.json" ]; then
        local health_status
        health_status=$(jq -r '.health_status // "unknown"' "$CONFIG_DIR/monitoring/metrics.json" 2>/dev/null || echo "unknown")
        case "$health_status" in
            healthy)
                echo -e "Health:          ${GREEN}Healthy${NC}"
                ;;
            warning)
                echo -e "Health:          ${YELLOW}Warning${NC}"
                ;;
            critical)
                echo -e "Health:          ${RED}Critical${NC}"
                ;;
            *)
                echo -e "Health:          ${YELLOW}Unknown${NC}"
                ;;
        esac
    else
        echo -e "Health:          ${YELLOW}Unknown${NC}"
    fi
    
    echo ""
    
    # Recent Activity
    log_section "Recent Activity"
    
    # Show last 3 log entries from each system
    if [ -d "$CONFIG_DIR/logs" ]; then
        echo "Recent Deployments:"
        find "$CONFIG_DIR/logs" -name "deploy-*.log" -type f -exec basename {} \; | sort -r | head -3 | sed 's/^/  - /'
        
        echo "Recent Tests:"
        find "$CONFIG_DIR/logs" -name "test-*.log" -type f -exec basename {} \; | sort -r | head -3 | sed 's/^/  - /'
        
        if [ -f "$CONFIG_DIR/monitoring/alerts.json" ]; then
            local alert_count
            alert_count=$(jq length "$CONFIG_DIR/monitoring/alerts.json" 2>/dev/null || echo "0")
            echo "Recent Alerts:   $alert_count total"
        fi
    fi
    
    echo ""
    
    # Quick Actions
    log_section "Quick Actions"
    echo "1. Deploy Configuration        6. Run Health Check"
    echo "2. Run Tests                   7. Check for Updates"
    echo "3. Switch Environment          8. View Logs"
    echo "4. Start/Stop Monitoring       9. Open Configuration"
    echo "5. Restart SketchyBar          0. Exit"
    echo ""
}

# Interactive menu
interactive_menu() {
    while true; do
        show_dashboard
        
        read -p "Select an action (1-9, 0 to exit): " -n 1 -r
        echo ""
        echo ""
        
        case $REPLY in
            1)
                log_section "Deploy Configuration"
                "$DEPLOY_SCRIPT" deploy
                ;;
            2)
                log_section "Run Tests"
                "$TEST_SCRIPT" all --report
                ;;
            3)
                log_section "Switch Environment"
                "$CONFIG_SCRIPT" list-envs
                echo ""
                read -p "Enter environment name: " env_name
                if [ -n "$env_name" ]; then
                    "$CONFIG_SCRIPT" switch-env "$env_name"
                fi
                ;;
            4)
                log_section "Monitoring Control"
                if [ -f "$CONFIG_DIR/monitoring/monitor.pid" ] && kill -0 "$(cat "$CONFIG_DIR/monitoring/monitor.pid")" 2>/dev/null; then
                    echo "Monitoring is currently running."
                    read -p "Stop monitoring? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        "$MONITOR_SCRIPT" stop
                    fi
                else
                    echo "Monitoring is not running."
                    read -p "Start monitoring? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        "$MONITOR_SCRIPT" start
                    fi
                fi
                ;;
            5)
                log_section "Restart SketchyBar"
                "$DEPLOY_SCRIPT" restart
                ;;
            6)
                log_section "Health Check"
                "$MONITOR_SCRIPT" check
                ;;
            7)
                log_section "Check for Updates"
                "$UPDATE_SCRIPT" check
                ;;
            8)
                log_section "View Logs"
                select_and_view_log
                ;;
            9)
                log_section "Open Configuration"
                if command -v code >/dev/null 2>&1; then
                    code "$CONFIG_DIR"
                elif command -v open >/dev/null 2>&1; then
                    open "$CONFIG_DIR"
                else
                    echo "Configuration directory: $CONFIG_DIR"
                fi
                ;;
            0)
                log_info "Goodbye!"
                exit 0
                ;;
            *)
                log_error "Invalid option: $REPLY"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..." -r
    done
}

# Log viewer helper
select_and_view_log() {
    if [ ! -d "$CONFIG_DIR/logs" ]; then
        log_warning "No logs directory found"
        return
    fi
    
    local log_files
    mapfile -t log_files < <(find "$CONFIG_DIR/logs" -name "*.log" -type f | sort -r)
    
    if [ ${#log_files[@]} -eq 0 ]; then
        log_warning "No log files found"
        return
    fi
    
    echo "Available log files:"
    for i in "${!log_files[@]}"; do
        local log_file="${log_files[$i]}"
        local log_name
        log_name=$(basename "$log_file")
        echo "$((i + 1)). $log_name"
    done
    
    echo ""
    read -p "Select log file (1-${#log_files[@]}): " -r log_choice
    
    if [[ "$log_choice" =~ ^[0-9]+$ ]] && [ "$log_choice" -ge 1 ] && [ "$log_choice" -le ${#log_files[@]} ]; then
        local selected_log="${log_files[$((log_choice - 1))]}"
        echo ""
        log_section "Log: $(basename "$selected_log")"
        tail -50 "$selected_log"
    else
        log_error "Invalid selection"
    fi
}

# System initialization
initialize_system() {
    log_section "System Initialization"
    
    # Check if this is a fresh installation
    if [ ! -f "$CONFIG_DIR/.version" ]; then
        log_info "Fresh installation detected"
        
        # Run initial setup
        if "$INSTALL_SCRIPT" install; then
            log_success "Initial setup completed"
        else
            log_error "Initial setup failed"
            return 1
        fi
    fi
    
    # Initialize default environments and profiles
    "$CONFIG_SCRIPT" current >/dev/null 2>&1 || true
    
    # Ensure directories exist
    mkdir -p "$CONFIG_DIR/logs" "$CONFIG_DIR/backups" "$CONFIG_DIR/monitoring"
    
    log_success "System initialization completed"
}

# Comprehensive system check
system_check() {
    log_section "System Check"
    
    local issues=0
    
    # Check prerequisites
    if ! check_prerequisites; then
        ((issues++))
    fi
    
    # Check SketchyBar installation
    if ! command -v sketchybar >/dev/null 2>&1; then
        log_error "SketchyBar not installed"
        ((issues++))
    fi
    
    # Check configuration integrity
    if ! "$TEST_SCRIPT" basic >/dev/null 2>&1; then
        log_error "Configuration validation failed"
        ((issues++))
    fi
    
    # Check dependencies
    local missing_deps=()
    local optional_deps=("yabai" "jq" "curl" "lua" "bc")
    
    for dep in "${optional_deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_warning "Optional dependencies missing: ${missing_deps[*]}"
    fi
    
    if [ $issues -eq 0 ]; then
        log_success "System check passed"
        return 0
    else
        log_error "System check found $issues issues"
        return 1
    fi
}

# Quick setup for new users
quick_setup() {
    log_section "Quick Setup"
    
    echo "This will set up SketchyBar with recommended settings."
    echo ""
    
    read -p "Continue with quick setup? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Quick setup cancelled"
        return 0
    fi
    
    # Install dependencies
    log_info "Installing dependencies..."
    "$INSTALL_SCRIPT" install --no-optional
    
    # Run initial tests
    log_info "Running configuration tests..."
    "$TEST_SCRIPT" basic
    
    # Deploy configuration
    log_info "Deploying configuration..."
    "$DEPLOY_SCRIPT" deploy
    
    # Start monitoring
    log_info "Starting monitoring..."
    "$MONITOR_SCRIPT" start
    
    log_success "Quick setup completed!"
    echo ""
    echo "SketchyBar should now be running with your configuration."
    echo "Use '$0 dashboard' to access the management interface."
}

# Usage function
usage() {
    cat << EOF
SketchyBar Configuration Management System

Usage: $0 <command> [options]

Commands:
    dashboard              Interactive management dashboard
    init                   Initialize system (first-time setup)
    check                  Perform comprehensive system check
    quick-setup            Quick setup for new users
    
    deploy [options]       Deploy configuration (proxy to deploy.sh)
    test [options]         Run tests (proxy to test.sh)
    install [options]      Install dependencies (proxy to install.sh)
    config [options]       Manage environments/profiles (proxy to config.sh)
    monitor [options]      Control monitoring (proxy to monitor.sh)
    update [options]       Handle updates (proxy to update.sh)
    
    status                 Show overall system status
    logs                   View recent logs
    cleanup               Clean up old files and logs
    backup                Create full system backup
    help                  Show this help message

Examples:
    $0 dashboard          # Open interactive dashboard
    $0 quick-setup        # Set up everything quickly
    $0 deploy             # Deploy current configuration
    $0 test all           # Run all tests
    $0 config switch-env development  # Switch to dev environment
    $0 monitor start      # Start monitoring daemon

Proxy Commands:
    All deployment, testing, installation, configuration, monitoring, and update
    commands are proxied to their respective specialized scripts with full
    argument forwarding.

EOF
}

# Status summary
show_status() {
    log_section "SketchyBar System Status"
    
    echo "Configuration: $CONFIG_DIR"
    echo "Version: $(cat "$CONFIG_DIR/.version" 2>/dev/null || echo "Unknown")"
    echo ""
    
    # Service status
    if pgrep -x sketchybar >/dev/null; then
        echo -e "SketchyBar: ${GREEN}Running${NC}"
    else
        echo -e "SketchyBar: ${RED}Not Running${NC}"
    fi
    
    if [ -f "$CONFIG_DIR/monitoring/monitor.pid" ] && kill -0 "$(cat "$CONFIG_DIR/monitoring/monitor.pid")" 2>/dev/null; then
        echo -e "Monitoring: ${GREEN}Active${NC}"
    else
        echo -e "Monitoring: ${YELLOW}Inactive${NC}"
    fi
    
    # Quick health check
    echo ""
    if "$TEST_SCRIPT" basic >/dev/null 2>&1; then
        echo -e "Configuration: ${GREEN}Valid${NC}"
    else
        echo -e "Configuration: ${RED}Invalid${NC}"
    fi
    
    # Disk usage
    local config_size
    config_size=$(du -sh "$CONFIG_DIR" 2>/dev/null | cut -f1)
    echo "Disk Usage: $config_size"
    
    # Recent activity
    echo ""
    echo "Recent Activity:"
    if [ -d "$CONFIG_DIR/logs" ]; then
        find "$CONFIG_DIR/logs" -name "*.log" -type f -mtime -1 | wc -l | xargs -I {} echo "  Log files today: {}"
    fi
    
    if [ -f "$CONFIG_DIR/monitoring/alerts.json" ]; then
        local recent_alerts
        recent_alerts=$(jq '[.[] | select((.timestamp | fromdateiso8601) > (now - 86400))] | length' "$CONFIG_DIR/monitoring/alerts.json" 2>/dev/null || echo "0")
        echo "  Alerts today: $recent_alerts"
    fi
}

# Main function
main() {
    local command="${1:-dashboard}"
    
    # Handle proxy commands first
    case "$command" in
        deploy)
            shift
            exec "$DEPLOY_SCRIPT" "$@"
            ;;
        test)
            shift
            exec "$TEST_SCRIPT" "$@"
            ;;
        install)
            shift
            exec "$INSTALL_SCRIPT" "$@"
            ;;
        config)
            shift
            exec "$CONFIG_SCRIPT" "$@"
            ;;
        monitor)
            shift
            exec "$MONITOR_SCRIPT" "$@"
            ;;
        update)
            shift
            exec "$UPDATE_SCRIPT" "$@"
            ;;
    esac
    
    # Handle direct commands
    case "$command" in
        dashboard)
            if ! check_prerequisites; then
                log_error "Prerequisites check failed"
                exit 1
            fi
            interactive_menu
            ;;
        init)
            initialize_system
            ;;
        check)
            system_check
            ;;
        quick-setup)
            quick_setup
            ;;
        status)
            show_status
            ;;
        logs)
            select_and_view_log
            ;;
        cleanup)
            log_info "Cleaning up system..."
            "$DEPLOY_SCRIPT" cleanup
            "$UPDATE_SCRIPT" cleanup
            log_success "Cleanup completed"
            ;;
        backup)
            log_info "Creating full system backup..."
            "$DEPLOY_SCRIPT" backup "full-backup-$(date +%Y%m%d-%H%M%S)"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            log_error "Unknown command: $command"
            echo ""
            usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"