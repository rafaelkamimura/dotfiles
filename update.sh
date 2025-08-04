#!/bin/bash

# SketchyBar Update and Migration Tools
# Handles configuration updates, migrations, and version upgrades

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$SCRIPT_DIR"
readonly LOGS_DIR="$CONFIG_DIR/logs"
readonly MIGRATION_DIR="$CONFIG_DIR/migrations"
readonly VERSION_FILE="$CONFIG_DIR/.version"
readonly UPDATE_LOG="$LOGS_DIR/update-$(date +%Y%m%d-%H%M%S).log"
readonly TEMP_DIR="$CONFIG_DIR/.update_tmp"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# Update sources configuration
readonly GIT_REPO="https://github.com/your-repo/sketchybar-config.git"  # Placeholder
readonly RELEASES_API="https://api.github.com/repos/your-repo/sketchybar-config/releases"  # Placeholder

# Initialize directories
init_dirs() {
    mkdir -p "$LOGS_DIR" "$MIGRATION_DIR" "$TEMP_DIR"
}

# Logging functions
log_update() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$UPDATE_LOG"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$UPDATE_LOG"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$UPDATE_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$UPDATE_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$UPDATE_LOG"
}

log_section() {
    echo -e "${PURPLE}=== $1 ===${NC}" | tee -a "$UPDATE_LOG"
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
    log_info "Version updated to $1"
}

compare_versions() {
    local version1="$1"
    local version2="$2"
    
    # Convert versions to comparable format
    local v1_major v1_minor v1_patch
    local v2_major v2_minor v2_patch
    
    IFS='.' read -r v1_major v1_minor v1_patch <<< "$version1"
    IFS='.' read -r v2_major v2_minor v2_patch <<< "$version2"
    
    # Compare major version
    if [ "$v1_major" -gt "$v2_major" ]; then
        echo "1"
    elif [ "$v1_major" -lt "$v2_major" ]; then
        echo "-1"
    # Compare minor version
    elif [ "$v1_minor" -gt "$v2_minor" ]; then
        echo "1"
    elif [ "$v1_minor" -lt "$v2_minor" ]; then
        echo "-1"
    # Compare patch version
    elif [ "$v1_patch" -gt "$v2_patch" ]; then
        echo "1"
    elif [ "$v1_patch" -lt "$v2_patch" ]; then
        echo "-1"
    else
        echo "0"
    fi
}

# Migration system
create_migration_template() {
    local migration_name="$1"
    local timestamp
    timestamp=$(date +%Y%m%d%H%M%S)
    local migration_file="$MIGRATION_DIR/${timestamp}_${migration_name}.sh"
    
    cat > "$migration_file" << 'EOF'
#!/bin/bash
# Migration: MIGRATION_NAME
# Created: TIMESTAMP
# Description: Brief description of what this migration does

set -euo pipefail

# Migration configuration
readonly CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly MIGRATION_NAME="MIGRATION_NAME"

# Logging
log_migration() {
    echo "[MIGRATION $MIGRATION_NAME] $1"
}

# Migration functions
migrate_up() {
    log_migration "Starting migration..."
    
    # Add your migration logic here
    # Example:
    # - Update configuration files
    # - Move files to new locations
    # - Convert data formats
    # - Update plugin configurations
    
    log_migration "Migration completed successfully"
}

migrate_down() {
    log_migration "Starting rollback..."
    
    # Add your rollback logic here
    # This should undo everything done in migrate_up
    
    log_migration "Rollback completed successfully"
}

# Main migration execution
main() {
    local direction="${1:-up}"
    
    case "$direction" in
        up)
            migrate_up
            ;;
        down)
            migrate_down
            ;;
        *)
            echo "Usage: $0 [up|down]"
            exit 1
            ;;
    esac
}

# Execute migration if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF
    
    # Replace placeholders
    sed -i '' "s/MIGRATION_NAME/$migration_name/g" "$migration_file"
    sed -i '' "s/TIMESTAMP/$(date)/g" "$migration_file"
    
    chmod +x "$migration_file"
    
    log_success "Created migration template: $migration_file"
    echo "$migration_file"
}

# Get list of migrations
get_migrations() {
    find "$MIGRATION_DIR" -name "*.sh" -type f | sort
}

get_applied_migrations() {
    if [ -f "$CONFIG_DIR/.migrations" ]; then
        cat "$CONFIG_DIR/.migrations"
    fi
}

mark_migration_applied() {
    local migration="$1"
    echo "$migration" >> "$CONFIG_DIR/.migrations"
}

mark_migration_unapplied() {
    local migration="$1"
    if [ -f "$CONFIG_DIR/.migrations" ]; then
        grep -v "$migration" "$CONFIG_DIR/.migrations" > "$CONFIG_DIR/.migrations.tmp" || true
        mv "$CONFIG_DIR/.migrations.tmp" "$CONFIG_DIR/.migrations"
    fi
}

# Run migrations
run_migration() {
    local migration_file="$1"
    local direction="${2:-up}"
    local migration_name
    migration_name=$(basename "$migration_file" .sh)
    
    log_info "Running migration: $migration_name ($direction)"
    
    if ! bash "$migration_file" "$direction"; then
        log_error "Migration failed: $migration_name"
        return 1
    fi
    
    if [ "$direction" = "up" ]; then
        mark_migration_applied "$migration_name"
    else
        mark_migration_unapplied "$migration_name"
    fi
    
    log_success "Migration completed: $migration_name"
}

run_pending_migrations() {
    log_section "Running Pending Migrations"
    
    local applied_migrations
    applied_migrations=$(get_applied_migrations)
    local migrations_run=0
    
    while IFS= read -r migration_file; do
        local migration_name
        migration_name=$(basename "$migration_file" .sh)
        
        if ! echo "$applied_migrations" | grep -q "$migration_name"; then
            run_migration "$migration_file" "up"
            ((migrations_run++))
        fi
    done < <(get_migrations)
    
    if [ $migrations_run -eq 0 ]; then
        log_info "No pending migrations"
    else
        log_success "Applied $migrations_run migrations"
    fi
}

rollback_migration() {
    local migration_name="$1"
    local migration_file="$MIGRATION_DIR/${migration_name}.sh"
    
    if [ ! -f "$migration_file" ]; then
        log_error "Migration not found: $migration_name"
        return 1
    fi
    
    log_info "Rolling back migration: $migration_name"
    run_migration "$migration_file" "down"
}

# Update checking
check_for_updates() {
    log_section "Checking for Updates"
    
    local current_version
    current_version=$(get_current_version)
    log_info "Current version: $current_version"
    
    # Check if git is available and we're in a git repository
    if command -v git >/dev/null 2>&1 && [ -d "$CONFIG_DIR/.git" ]; then
        check_git_updates
    else
        log_info "Git not available or not a git repository"
        check_manual_updates
    fi
}

check_git_updates() {
    log_info "Checking for updates via Git..."
    
    cd "$CONFIG_DIR"
    
    # Fetch latest changes
    if ! git fetch origin 2>/dev/null; then
        log_warning "Failed to fetch from remote repository"
        return 1
    fi
    
    # Check if there are new commits
    local local_hash
    local_hash=$(git rev-parse HEAD)
    local remote_hash
    remote_hash=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)
    
    if [ "$local_hash" != "$remote_hash" ]; then
        log_info "Updates available!"
        
        # Show what's new
        echo ""
        echo "New commits:"
        git log --oneline "$local_hash..$remote_hash"
        echo ""
        
        return 0
    else
        log_info "Configuration is up to date"
        return 1
    fi
}

check_manual_updates() {
    log_info "Manual update check not implemented"
    log_info "Please check the repository manually for updates"
}

# Update application
perform_update() {
    local update_type="${1:-auto}"
    
    log_section "Performing Update"
    
    # Create backup before update
    log_info "Creating backup before update..."
    "$CONFIG_DIR/deploy.sh" backup "pre-update-$(date +%Y%m%d-%H%M%S)"
    
    case "$update_type" in
        git)
            perform_git_update
            ;;
        manual)
            perform_manual_update
            ;;
        auto)
            if command -v git >/dev/null 2>&1 && [ -d "$CONFIG_DIR/.git" ]; then
                perform_git_update
            else
                perform_manual_update
            fi
            ;;
        *)
            log_error "Unknown update type: $update_type"
            return 1
            ;;
    esac
}

perform_git_update() {
    log_info "Performing Git update..."
    
    cd "$CONFIG_DIR"
    
    # Stash any local changes
    if ! git diff --quiet; then
        log_info "Stashing local changes..."
        git stash push -m "Auto-stash before update $(date)"
    fi
    
    # Pull latest changes
    if git pull origin main 2>/dev/null || git pull origin master 2>/dev/null; then
        log_success "Successfully pulled latest changes"
        
        # Run any pending migrations
        run_pending_migrations
        
        # Update version if available
        if [ -f "$CONFIG_DIR/.version" ]; then
            local new_version
            new_version=$(cat "$CONFIG_DIR/.version")
            log_info "Updated to version: $new_version"
        fi
        
        # Validate configuration
        if "$CONFIG_DIR/test.sh" basic >/dev/null 2>&1; then
            log_success "Configuration validation passed"
        else
            log_warning "Configuration validation failed - please check manually"
        fi
        
        # Restart SketchyBar
        "$CONFIG_DIR/deploy.sh" restart
        
        log_success "Update completed successfully"
    else
        log_error "Failed to pull latest changes"
        return 1
    fi
}

perform_manual_update() {
    log_info "Manual update process:"
    echo ""
    echo "1. Download the latest configuration from your source"
    echo "2. Extract to a temporary directory"
    echo "3. Run: $0 install-update /path/to/new/config"
    echo ""
}

# Install update from directory
install_update() {
    local update_source="$1"
    
    if [ ! -d "$update_source" ]; then
        log_error "Update source directory not found: $update_source"
        return 1
    fi
    
    log_section "Installing Update from $update_source"
    
    # Validate update source
    if [ ! -f "$update_source/sketchybarrc" ] || [ ! -f "$update_source/variables.sh" ]; then
        log_error "Invalid update source - missing required files"
        return 1
    fi
    
    # Create backup
    "$CONFIG_DIR/deploy.sh" backup "pre-manual-update-$(date +%Y%m%d-%H%M%S)"
    
    # Copy new files
    log_info "Copying updated files..."
    rsync -av --exclude='backups/' --exclude='logs/' --exclude='.migrations' \
          --exclude='.version' "$update_source/" "$CONFIG_DIR/"
    
    # Run migrations
    run_pending_migrations
    
    # Validate and restart
    if "$CONFIG_DIR/test.sh" basic >/dev/null 2>&1; then
        "$CONFIG_DIR/deploy.sh" restart
        log_success "Manual update completed successfully"
    else
        log_error "Update validation failed"
        return 1
    fi
}

# Show update status
show_update_status() {
    log_section "Update Status"
    
    local current_version
    current_version=$(get_current_version)
    echo "Current Version: $current_version"
    echo "Last Update Check: $(stat -f%Sm "$UPDATE_LOG" 2>/dev/null || echo "Never")"
    
    # Show applied migrations
    echo ""
    echo "Applied Migrations:"
    if [ -f "$CONFIG_DIR/.migrations" ]; then
        cat "$CONFIG_DIR/.migrations" | sed 's/^/  - /'
    else
        echo "  None"
    fi
    
    # Show available migrations
    echo ""
    echo "Available Migrations:"
    local applied_migrations
    applied_migrations=$(get_applied_migrations)
    
    while IFS= read -r migration_file; do
        local migration_name
        migration_name=$(basename "$migration_file" .sh)
        
        if echo "$applied_migrations" | grep -q "$migration_name"; then
            echo "  ✓ $migration_name (applied)"
        else
            echo "  ✗ $migration_name (pending)"
        fi
    done < <(get_migrations)
}

# Configuration upgrade utilities
upgrade_configuration() {
    local target_version="${1:-latest}"
    
    log_section "Configuration Upgrade to $target_version"
    
    local current_version
    current_version=$(get_current_version)
    
    # Create upgrade plan
    local upgrade_plan
    upgrade_plan=$(create_upgrade_plan "$current_version" "$target_version")
    
    if [ -z "$upgrade_plan" ]; then
        log_info "No upgrade needed"
        return 0
    fi
    
    echo "Upgrade Plan:"
    echo "$upgrade_plan"
    echo ""
    
    read -p "Proceed with upgrade? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        execute_upgrade_plan "$upgrade_plan"
    else
        log_info "Upgrade cancelled"
    fi
}

create_upgrade_plan() {
    local from_version="$1"
    local to_version="$2"
    
    # This is a placeholder for upgrade planning logic
    # In a real implementation, this would analyze the version differences
    # and create a step-by-step upgrade plan
    
    echo "1. Backup current configuration"
    echo "2. Update core files"
    echo "3. Run migrations"
    echo "4. Validate configuration"
    echo "5. Restart SketchyBar"
}

execute_upgrade_plan() {
    local plan="$1"
    
    log_info "Executing upgrade plan..."
    
    # Create backup
    "$CONFIG_DIR/deploy.sh" backup "pre-upgrade-$(date +%Y%m%d-%H%M%S)"
    
    # Run migrations
    run_pending_migrations
    
    # Validate configuration
    if "$CONFIG_DIR/test.sh" all >/dev/null 2>&1; then
        "$CONFIG_DIR/deploy.sh" restart
        log_success "Upgrade completed successfully"
    else
        log_error "Upgrade validation failed"
        return 1
    fi
}

# Cleanup old versions
cleanup_old_versions() {
    log_section "Cleaning Up Old Versions"
    
    # Clean up old backups (keep last 5)
    "$CONFIG_DIR/deploy.sh" cleanup
    
    # Clean up old logs
    find "$LOGS_DIR" -name "update-*.log" -type f -mtime +30 -delete
    
    # Clean up temp files
    rm -rf "$TEMP_DIR"
    
    log_success "Cleanup completed"
}

# Usage function
usage() {
    cat << EOF
SketchyBar Update and Migration Tools

Usage: $0 <command> [options]

Commands:
    check                     Check for available updates
    update [git|manual|auto]  Perform update (default: auto)
    install-update <dir>      Install update from directory
    status                    Show update status
    migrate                   Run pending migrations
    rollback <migration>      Rollback specific migration
    create-migration <name>   Create new migration template
    upgrade [version]         Upgrade configuration to version
    cleanup                   Clean up old versions and logs
    help                      Show this help message

Migration Commands:
    list-migrations           List all migrations
    applied-migrations        Show applied migrations
    pending-migrations        Show pending migrations

Examples:
    $0 check                  # Check for updates
    $0 update                 # Update configuration
    $0 migrate                # Run pending migrations
    $0 create-migration theme_update  # Create migration template
    $0 rollback 20240101120000_theme_update  # Rollback migration

EOF
}

# Main function
main() {
    local command="${1:-check}"
    
    # Initialize directories
    init_dirs
    
    case "$command" in
        check)
            check_for_updates
            ;;
        update)
            perform_update "${2:-auto}"
            ;;
        install-update)
            if [ -z "${2:-}" ]; then
                log_error "Update source directory required"
                usage
                exit 1
            fi
            install_update "$2"
            ;;
        status)
            show_update_status
            ;;
        migrate)
            run_pending_migrations
            ;;
        rollback)
            if [ -z "${2:-}" ]; then
                log_error "Migration name required"
                usage
                exit 1
            fi
            rollback_migration "$2"
            ;;
        create-migration)
            if [ -z "${2:-}" ]; then
                log_error "Migration name required"
                usage
                exit 1
            fi
            create_migration_template "$2"
            ;;
        list-migrations)
            log_section "Available Migrations"
            get_migrations | while read -r migration; do
                echo "  - $(basename "$migration" .sh)"
            done
            ;;
        applied-migrations)
            log_section "Applied Migrations"
            get_applied_migrations | while read -r migration; do
                echo "  - $migration"
            done
            ;;
        pending-migrations)
            log_section "Pending Migrations"
            local applied_migrations
            applied_migrations=$(get_applied_migrations)
            
            get_migrations | while read -r migration_file; do
                local migration_name
                migration_name=$(basename "$migration_file" .sh)
                
                if ! echo "$applied_migrations" | grep -q "$migration_name"; then
                    echo "  - $migration_name"
                fi
            done
            ;;
        upgrade)
            upgrade_configuration "${2:-latest}"
            ;;
        cleanup)
            cleanup_old_versions
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

# Cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

# Run main function with all arguments
main "$@"