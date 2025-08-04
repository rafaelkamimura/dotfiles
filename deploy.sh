#!/bin/bash

# SketchyBar Deployment and Management System
# Comprehensive automation for configuration deployment, backup, and rollback

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$SCRIPT_DIR"
readonly BACKUP_DIR="$CONFIG_DIR/backups"
readonly LOGS_DIR="$CONFIG_DIR/logs"
readonly TEMP_DIR="$CONFIG_DIR/.tmp"
readonly VERSION_FILE="$CONFIG_DIR/.version"
readonly STATE_FILE="$CONFIG_DIR/.deploy_state"
readonly LOCK_FILE="$CONFIG_DIR/.deploy.lock"

# Logging
readonly LOG_FILE="$LOGS_DIR/deploy-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Initialize directories
init_dirs() {
    mkdir -p "$BACKUP_DIR" "$LOGS_DIR" "$TEMP_DIR"
}

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Lock management
acquire_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid
        lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            log_error "Another deployment is running (PID: $lock_pid)"
            exit 1
        fi
        log_warning "Removing stale lock file"
        rm -f "$LOCK_FILE"
    fi
    echo $$ > "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"; exit' INT TERM EXIT
}

# Version management
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

set_version() {
    echo "$1" > "$VERSION_FILE"
    log_info "Version set to $1"
}

increment_version() {
    local current_version
    current_version=$(get_current_version)
    local IFS='.'
    read -ra version_parts <<< "$current_version"
    
    case "$1" in
        major)
            version_parts[0]=$((version_parts[0] + 1))
            version_parts[1]=0
            version_parts[2]=0
            ;;
        minor)
            version_parts[1]=$((version_parts[1] + 1))
            version_parts[2]=0
            ;;
        patch|*)
            version_parts[2]=$((version_parts[2] + 1))
            ;;
    esac
    
    local new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"
    set_version "$new_version"
    echo "$new_version"
}

# Backup functions
create_backup() {
    local backup_name="${1:-backup-$(date +%Y%m%d-%H%M%S)}"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log_info "Creating backup: $backup_name"
    mkdir -p "$backup_path"
    
    # Copy all configuration files except backups and logs
    rsync -av --exclude='backups/' --exclude='logs/' --exclude='.tmp/' \
          --exclude='*.log' --exclude='.deploy*' "$CONFIG_DIR/" "$backup_path/"
    
    # Create backup metadata
    cat > "$backup_path/.backup_info" << EOF
backup_name=$backup_name
backup_date=$(date -Iseconds)
backup_version=$(get_current_version)
backup_user=$USER
backup_hostname=$(hostname)
sketchybar_version=$(sketchybar --version 2>/dev/null || echo "unknown")
EOF
    
    log_success "Backup created: $backup_path"
    echo "$backup_path"
}

list_backups() {
    log_info "Available backups:"
    if [ -d "$BACKUP_DIR" ]; then
        for backup in "$BACKUP_DIR"/*; do
            if [ -d "$backup" ] && [ -f "$backup/.backup_info" ]; then
                local backup_name
                local backup_date
                local backup_version
                backup_name=$(basename "$backup")
                backup_date=$(grep "backup_date=" "$backup/.backup_info" | cut -d= -f2)
                backup_version=$(grep "backup_version=" "$backup/.backup_info" | cut -d= -f2)
                echo "  - $backup_name (v$backup_version, $backup_date)"
            fi
        done
    else
        log_warning "No backups directory found"
    fi
}

restore_backup() {
    local backup_name="$1"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$backup_path" ]; then
        log_error "Backup not found: $backup_name"
        return 1
    fi
    
    log_info "Restoring from backup: $backup_name"
    
    # Create a backup of current state before restore
    create_backup "pre-restore-$(date +%Y%m%d-%H%M%S)"
    
    # Stop SketchyBar
    stop_sketchybar
    
    # Restore files
    rsync -av --exclude='.backup_info' --exclude='backups/' --exclude='logs/' \
          "$backup_path/" "$CONFIG_DIR/"
    
    # Update version from backup
    if [ -f "$backup_path/.backup_info" ]; then
        local backup_version
        backup_version=$(grep "backup_version=" "$backup_path/.backup_info" | cut -d= -f2)
        set_version "$backup_version"
    fi
    
    # Validate and start
    if validate_configuration; then
        start_sketchybar
        log_success "Successfully restored from backup: $backup_name"
    else
        log_error "Configuration validation failed after restore"
        return 1
    fi
}

# SketchyBar control functions
stop_sketchybar() {
    log_info "Stopping SketchyBar..."
    if pgrep -x "sketchybar" > /dev/null; then
        pkill -TERM sketchybar || true
        sleep 2
        if pgrep -x "sketchybar" > /dev/null; then
            pkill -KILL sketchybar || true
            sleep 1
        fi
    fi
    log_info "SketchyBar stopped"
}

start_sketchybar() {
    log_info "Starting SketchyBar..."
    cd "$CONFIG_DIR"
    nohup sketchybar --config "$CONFIG_DIR/sketchybarrc" > "$LOGS_DIR/sketchybar.log" 2>&1 &
    sleep 3
    if pgrep -x "sketchybar" > /dev/null; then
        log_success "SketchyBar started successfully"
    else
        log_error "Failed to start SketchyBar"
        return 1
    fi
}

restart_sketchybar() {
    stop_sketchybar
    start_sketchybar
}

# Configuration validation
validate_configuration() {
    log_info "Validating configuration..."
    
    local errors=0
    
    # Check required files
    local required_files=(
        "sketchybarrc"
        "variables.sh"
        "init.lua"
        "settings.lua"
        "colors.lua"
        "bar.lua"
        "default.lua"
        "icons.lua"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$CONFIG_DIR/$file" ]; then
            log_error "Required file missing: $file"
            ((errors++))
        fi
    done
    
    # Check required directories
    local required_dirs=(
        "plugins"
        "items"
        "helpers"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$CONFIG_DIR/$dir" ]; then
            log_error "Required directory missing: $dir"
            ((errors++))
        fi
    done
    
    # Validate shell scripts syntax
    while IFS= read -r -d '' script; do
        if ! bash -n "$script" 2>/dev/null; then
            log_error "Syntax error in script: $script"
            ((errors++))
        fi
    done < <(find "$CONFIG_DIR" -name "*.sh" -type f -print0)
    
    # Validate Lua files syntax
    if command -v lua >/dev/null 2>&1; then
        while IFS= read -r -d '' lua_file; do
            if ! lua -l "$lua_file" 2>/dev/null; then
                log_error "Syntax error in Lua file: $lua_file"
                ((errors++))
            fi
        done < <(find "$CONFIG_DIR" -name "*.lua" -type f -print0)
    fi
    
    # Check for executable permissions on required scripts
    local executable_files=(
        "sketchybarrc"
        "variables.sh"
    )
    
    for file in "${executable_files[@]}"; do
        if [ -f "$CONFIG_DIR/$file" ] && [ ! -x "$CONFIG_DIR/$file" ]; then
            log_warning "Setting executable permission on $file"
            chmod +x "$CONFIG_DIR/$file"
        fi
    done
    
    if [ $errors -eq 0 ]; then
        log_success "Configuration validation passed"
        return 0
    else
        log_error "Configuration validation failed with $errors errors"
        return 1
    fi
}

# Deployment functions
deploy() {
    local version_bump="${1:-patch}"
    
    log_info "Starting deployment process..."
    
    # Validate configuration before deployment
    if ! validate_configuration; then
        log_error "Pre-deployment validation failed"
        return 1
    fi
    
    # Create backup
    local backup_path
    backup_path=$(create_backup "pre-deploy-$(date +%Y%m%d-%H%M%S)")
    
    # Update version
    local new_version
    new_version=$(increment_version "$version_bump")
    
    # Record deployment state
    cat > "$STATE_FILE" << EOF
deployment_date=$(date -Iseconds)
deployment_version=$new_version
deployment_user=$USER
deployment_backup=$backup_path
EOF
    
    # Restart SketchyBar with new configuration
    if restart_sketchybar; then
        log_success "Deployment completed successfully (v$new_version)"
        
        # Clean up old backups (keep last 10)
        cleanup_old_backups
    else
        log_error "Deployment failed, attempting rollback..."
        rollback
        return 1
    fi
}

rollback() {
    log_info "Starting rollback process..."
    
    if [ ! -f "$STATE_FILE" ]; then
        log_error "No deployment state found for rollback"
        return 1
    fi
    
    local backup_path
    backup_path=$(grep "deployment_backup=" "$STATE_FILE" | cut -d= -f2)
    
    if [ -n "$backup_path" ] && [ -d "$backup_path" ]; then
        local backup_name
        backup_name=$(basename "$backup_path")
        restore_backup "$backup_name"
        log_success "Rollback completed"
    else
        log_error "Rollback backup not found: $backup_path"
        return 1
    fi
}

# Maintenance functions
cleanup_old_backups() {
    log_info "Cleaning up old backups..."
    
    # Keep only the last 10 backups
    local backup_count
    backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup-*" | wc -l)
    
    if [ "$backup_count" -gt 10 ]; then
        find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup-*" -printf '%T@ %p\n' | \
        sort -n | head -n $((backup_count - 10)) | cut -d' ' -f2- | \
        while read -r backup_dir; do
            log_info "Removing old backup: $(basename "$backup_dir")"
            rm -rf "$backup_dir"
        done
    fi
}

cleanup_logs() {
    log_info "Cleaning up old logs..."
    
    # Remove logs older than 30 days
    find "$LOGS_DIR" -name "*.log" -type f -mtime +30 -delete
}

# Health check function
health_check() {
    log_info "Performing health check..."
    
    local issues=0
    
    # Check if SketchyBar is running
    if ! pgrep -x "sketchybar" > /dev/null; then
        log_warning "SketchyBar is not running"
        ((issues++))
    else
        log_success "SketchyBar is running (PID: $(pgrep -x sketchybar))"
    fi
    
    # Check configuration validity
    if ! validate_configuration; then
        log_error "Configuration validation failed"
        ((issues++))
    fi
    
    # Check disk space
    local available_space
    available_space=$(df "$CONFIG_DIR" | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt 1048576 ]; then # Less than 1GB
        log_warning "Low disk space: $(df -h "$CONFIG_DIR" | awk 'NR==2 {print $4}') available"
        ((issues++))
    fi
    
    # Check for required dependencies
    local dependencies=("sketchybar" "bash" "rsync")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log_error "Missing dependency: $dep"
            ((issues++))
        fi
    done
    
    if [ $issues -eq 0 ]; then
        log_success "Health check passed"
        return 0
    else
        log_warning "Health check found $issues issues"
        return 1
    fi
}

# Update function
update() {
    log_info "Checking for updates..."
    
    # This is a placeholder for future update functionality
    # Could integrate with git or package managers
    log_info "Update functionality not implemented yet"
}

# Usage function
usage() {
    cat << EOF
SketchyBar Deployment and Management System

Usage: $0 <command> [options]

Commands:
    deploy [major|minor|patch]   Deploy configuration (default: patch version bump)
    rollback                     Rollback to previous deployment
    backup [name]                Create a backup with optional name
    restore <backup_name>        Restore from specific backup
    list-backups                 List available backups
    validate                     Validate current configuration
    health-check                 Perform system health check
    start                        Start SketchyBar
    stop                         Stop SketchyBar
    restart                      Restart SketchyBar
    status                       Show SketchyBar status
    cleanup                      Clean up old backups and logs
    update                       Check for and apply updates
    version                      Show current version
    help                         Show this help message

Examples:
    $0 deploy                    # Deploy with patch version bump
    $0 deploy minor              # Deploy with minor version bump
    $0 backup my-backup          # Create named backup
    $0 restore backup-20240101   # Restore specific backup
    $0 health-check              # Check system health

EOF
}

# Status function  
status() {
    log_info "SketchyBar Status:"
    
    if pgrep -x "sketchybar" > /dev/null; then
        local pid
        pid=$(pgrep -x sketchybar)
        echo "  Status: Running (PID: $pid)"
        echo "  Uptime: $(ps -o etime= -p "$pid" | tr -d ' ')"
    else
        echo "  Status: Not running"
    fi
    
    echo "  Version: $(get_current_version)"
    echo "  Config: $CONFIG_DIR"
    echo "  Logs: $LOGS_DIR"
    echo "  Backups: $(find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup-*" 2>/dev/null | wc -l) available"
}

# Main function
main() {
    init_dirs
    acquire_lock
    
    case "${1:-}" in
        deploy)
            deploy "${2:-patch}"
            ;;
        rollback)
            rollback
            ;;
        backup)
            create_backup "$2"
            ;;
        restore)
            if [ -z "${2:-}" ]; then
                log_error "Backup name required for restore"
                usage
                exit 1
            fi
            restore_backup "$2"
            ;;
        list-backups)
            list_backups
            ;;
        validate)
            validate_configuration
            ;;
        health-check)
            health_check
            ;;
        start)
            start_sketchybar
            ;;
        stop)
            stop_sketchybar
            ;;
        restart)
            restart_sketchybar
            ;;
        status)
            status
            ;;
        cleanup)
            cleanup_old_backups
            cleanup_logs
            ;;
        update)
            update
            ;;
        version)
            echo "$(get_current_version)"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            log_error "Unknown command: ${1:-}"
            usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"