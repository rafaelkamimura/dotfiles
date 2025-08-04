#!/bin/bash

# SketchyBar Configuration Testing Framework
# Comprehensive testing and validation system

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$SCRIPT_DIR"
readonly TEST_DIR="$CONFIG_DIR/tests"
readonly TEMP_TEST_DIR="$CONFIG_DIR/.test_tmp"
readonly TEST_LOG="$CONFIG_DIR/logs/test-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Initialize test environment
init_test_env() {
    mkdir -p "$(dirname "$TEST_LOG")" "$TEMP_TEST_DIR"
    echo "SketchyBar Test Suite - $(date)" > "$TEST_LOG"
}

# Logging functions
test_log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$TEST_LOG"
}

test_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$TEST_LOG"
}

test_success() {
    echo -e "${GREEN}[PASS]${NC} $1" | tee -a "$TEST_LOG"
    ((TESTS_PASSED++))
}

test_failure() {
    echo -e "${RED}[FAIL]${NC} $1" | tee -a "$TEST_LOG"
    ((TESTS_FAILED++))
}

test_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$TEST_LOG"
}

test_section() {
    echo -e "${PURPLE}=== $1 ===${NC}" | tee -a "$TEST_LOG"
}

# Test execution wrapper
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    ((TESTS_RUN++))
    test_info "Running: $test_name"
    
    if $test_function; then
        test_success "$test_name"
        return 0
    else
        test_failure "$test_name"
        return 1
    fi
}

# File structure tests
test_required_files() {
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
            test_failure "Required file missing: $file"
            return 1
        fi
    done
    
    return 0
}

test_required_directories() {
    local required_dirs=(
        "plugins"
        "items"
        "helpers"
        "backups"
        "logs"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$CONFIG_DIR/$dir" ]; then
            test_failure "Required directory missing: $dir"
            return 1
        fi
    done
    
    return 0
}

test_file_permissions() {
    local executable_files=(
        "sketchybarrc"
        "variables.sh"
        "deploy.sh"
    )
    
    for file in "${executable_files[@]}"; do
        if [ -f "$CONFIG_DIR/$file" ] && [ ! -x "$CONFIG_DIR/$file" ]; then
            test_failure "File not executable: $file"
            return 1
        fi
    done
    
    # Check plugin scripts
    while IFS= read -r -d '' plugin; do
        if [ ! -x "$plugin" ]; then
            test_failure "Plugin not executable: $(basename "$plugin")"
            return 1
        fi
    done < <(find "$CONFIG_DIR/plugins" -name "*.sh" -type f -print0 2>/dev/null)
    
    return 0
}

# Syntax validation tests
test_shell_script_syntax() {
    local errors=0
    
    while IFS= read -r -d '' script; do
        if ! bash -n "$script" 2>/tmp/syntax_error; then
            test_failure "Syntax error in $(basename "$script"): $(cat /tmp/syntax_error)"
            ((errors++))
        fi
    done < <(find "$CONFIG_DIR" -name "*.sh" -type f -print0)
    
    rm -f /tmp/syntax_error
    return $errors
}

test_lua_syntax() {
    if ! command -v lua >/dev/null 2>&1; then
        test_warning "Lua not available, skipping Lua syntax tests"
        return 0
    fi
    
    local errors=0
    
    while IFS= read -r -d '' lua_file; do
        if ! lua -l "$(basename "$lua_file" .lua)" 2>/tmp/lua_error; then
            test_failure "Lua syntax error in $(basename "$lua_file"): $(cat /tmp/lua_error)"
            ((errors++))
        fi
    done < <(find "$CONFIG_DIR" -name "*.lua" -type f -print0)
    
    rm -f /tmp/lua_error
    return $errors
}

# Configuration validation tests
test_variables_loading() {
    # Test if variables.sh can be sourced without errors
    if ! bash -c "source '$CONFIG_DIR/variables.sh'" 2>/tmp/var_error; then
        test_failure "Error loading variables.sh: $(cat /tmp/var_error)"
        rm -f /tmp/var_error
        return 1
    fi
    
    # Test if required variables are defined
    local required_vars=(
        "BAR_COLOR"
        "ITEM_BG_COLOR"
        "ACCENT_COLOR"
        "ICON_COLOR"
        "LABEL_COLOR"
        "FONT"
    )
    
    for var in "${required_vars[@]}"; do
        if ! bash -c "source '$CONFIG_DIR/variables.sh'; [ -n \"\${$var:-}\" ]"; then
            test_failure "Required variable not defined: $var"
            return 1
        fi
    done
    
    rm -f /tmp/var_error
    return 0
}

test_plugin_dependencies() {
    local missing_deps=0
    
    # Check for common dependencies used by plugins
    local commands=(
        "sketchybar"
        "yabai"
        "jq"
        "curl"
        "pmset"
        "system_profiler"
    )
    
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            case "$cmd" in
                "sketchybar")
                    test_failure "Critical dependency missing: $cmd"
                    ((missing_deps++))
                    ;;
                "yabai")
                    test_warning "Optional dependency missing: $cmd (required for workspace features)"
                    ;;
                *)
                    test_warning "Optional dependency missing: $cmd"
                    ;;
            esac
        fi
    done
    
    return $missing_deps
}

# Runtime tests
test_sketchybar_config_load() {
    # Test if sketchybarrc can be parsed without errors
    local test_output
    test_output=$(mktemp)
    
    if ! bash -n "$CONFIG_DIR/sketchybarrc" 2>"$test_output"; then
        test_failure "sketchybarrc syntax error: $(cat "$test_output")"
        rm -f "$test_output"
        return 1
    fi
    
    rm -f "$test_output"
    return 0
}

test_dry_run_config() {
    # Attempt a dry run of the configuration
    test_info "Performing dry run of configuration..."
    
    # Create a temporary test script that sources the config without actually running sketchybar
    cat > "$TEMP_TEST_DIR/dry_run.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

# Mock sketchybar command for dry run
sketchybar() {
    echo "sketchybar $*" >> /tmp/sketchybar_dry_run.log
    return 0
}

# Source variables and config
source "$1/variables.sh"
source "$1/sketchybarrc"
EOF
    
    chmod +x "$TEMP_TEST_DIR/dry_run.sh"
    
    if "$TEMP_TEST_DIR/dry_run.sh" "$CONFIG_DIR" 2>/tmp/dry_run_error; then
        test_info "Dry run completed successfully"
        rm -f /tmp/sketchybar_dry_run.log /tmp/dry_run_error
        return 0
    else
        test_failure "Dry run failed: $(cat /tmp/dry_run_error)"
        rm -f /tmp/sketchybar_dry_run.log /tmp/dry_run_error
        return 1
    fi
}

# Performance tests
test_plugin_performance() {
    test_info "Testing plugin performance..."
    
    local slow_plugins=()
    
    # Test each plugin's execution time
    while IFS= read -r -d '' plugin; do
        local plugin_name
        plugin_name=$(basename "$plugin")
        
        local start_time
        start_time=$(date +%s.%N)
        
        if timeout 5s bash "$plugin" >/dev/null 2>&1; then
            local end_time
            end_time=$(date +%s.%N)
            local duration
            duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
            
            # Check if plugin takes more than 1 second
            if (( $(echo "$duration > 1.0" | bc -l 2>/dev/null || echo 0) )); then
                slow_plugins+=("$plugin_name (${duration}s)")
            fi
        else
            test_warning "Plugin timeout or error: $plugin_name"
        fi
    done < <(find "$CONFIG_DIR/plugins" -name "*.sh" -type f -print0 2>/dev/null)
    
    if [ ${#slow_plugins[@]} -gt 0 ]; then
        test_warning "Slow plugins detected:"
        for plugin in "${slow_plugins[@]}"; do
            echo "  - $plugin" | tee -a "$TEST_LOG"
        done
    fi
    
    return 0
}

# Security tests
test_security_issues() {
    local issues=0
    
    # Check for potentially dangerous patterns
    local dangerous_patterns=(
        "eval.*\$"
        "rm -rf \$"
        "sudo.*\$"
        "curl.*|.*sh"
        "wget.*|.*sh"
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if grep -r "$pattern" "$CONFIG_DIR" --exclude-dir=backups --exclude-dir=logs >/dev/null 2>&1; then
            test_warning "Potentially dangerous pattern found: $pattern"
            ((issues++))
        fi
    done
    
    # Check file permissions for sensitive files
    if [ -f "$CONFIG_DIR/.env" ]; then
        local perms
        perms=$(stat -f "%A" "$CONFIG_DIR/.env" 2>/dev/null || stat -c "%a" "$CONFIG_DIR/.env" 2>/dev/null)
        if [ "$perms" != "600" ] && [ "$perms" != "0600" ]; then
            test_warning ".env file has overly permissive permissions: $perms"
            ((issues++))
        fi
    fi
    
    return 0
}

# Integration tests
test_sketchybar_integration() {
    if ! command -v sketchybar >/dev/null 2>&1; then
        test_failure "SketchyBar not installed"
        return 1
    fi
    
    # Check if SketchyBar can load our config
    test_info "Testing SketchyBar integration..."
    
    # Save current SketchyBar state
    local was_running=false
    if pgrep -x sketchybar >/dev/null; then
        was_running=true
        pkill -TERM sketchybar
        sleep 2
    fi
    
    # Try to start with our config
    local test_result=0
    if timeout 10s sketchybar --config "$CONFIG_DIR/sketchybarrc" >/dev/null 2>&1; then
        test_info "SketchyBar loaded configuration successfully"
    else
        test_failure "SketchyBar failed to load configuration"
        test_result=1
    fi
    
    # Clean up test instance
    pkill -TERM sketchybar 2>/dev/null || true
    sleep 1
    
    # Restore previous state
    if [ "$was_running" = true ]; then
        nohup sketchybar --config "$CONFIG_DIR/sketchybarrc" >/dev/null 2>&1 &
        sleep 2
    fi
    
    return $test_result
}

# Test report generation
generate_test_report() {
    local report_file="$CONFIG_DIR/logs/test-report-$(date +%Y%m%d-%H%M%S).html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>SketchyBar Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { color: #333; border-bottom: 2px solid #ddd; padding-bottom: 10px; }
        .summary { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .pass { color: #28a745; }
        .fail { color: #dc3545; }
        .warn { color: #ffc107; }
        .test-details { margin: 20px 0; }
        pre { background: #f8f9fa; padding: 10px; border-radius: 3px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>SketchyBar Configuration Test Report</h1>
        <p>Generated: $(date)</p>
        <p>Configuration: $CONFIG_DIR</p>
    </div>
    
    <div class="summary">
        <h2>Test Summary</h2>
        <p><strong>Total Tests:</strong> $TESTS_RUN</p>
        <p><strong class="pass">Passed:</strong> $TESTS_PASSED</p>
        <p><strong class="fail">Failed:</strong> $TESTS_FAILED</p>
        <p><strong>Success Rate:</strong> $(( TESTS_RUN > 0 ? (TESTS_PASSED * 100) / TESTS_RUN : 0 ))%</p>
    </div>
    
    <div class="test-details">
        <h2>Test Details</h2>
        <pre>$(cat "$TEST_LOG")</pre>
    </div>
</body>
</html>
EOF
    
    test_info "Test report generated: $report_file"
}

# Main test suites
run_basic_tests() {
    test_section "Basic Configuration Tests"
    run_test "Required Files" test_required_files
    run_test "Required Directories" test_required_directories
    run_test "File Permissions" test_file_permissions
}

run_syntax_tests() {
    test_section "Syntax Validation Tests"
    run_test "Shell Script Syntax" test_shell_script_syntax
    run_test "Lua Syntax" test_lua_syntax
}

run_config_tests() {
    test_section "Configuration Tests"
    run_test "Variables Loading" test_variables_loading
    run_test "Plugin Dependencies" test_plugin_dependencies
    run_test "SketchyBar Config Load" test_sketchybar_config_load
    run_test "Dry Run Config" test_dry_run_config
}

run_performance_tests() {
    test_section "Performance Tests"
    run_test "Plugin Performance" test_plugin_performance
}

run_security_tests() {
    test_section "Security Tests"
    run_test "Security Issues" test_security_issues
}

run_integration_tests() {
    test_section "Integration Tests"
    run_test "SketchyBar Integration" test_sketchybar_integration
}

# Test suite runner
run_test_suite() {
    local suite="$1"
    
    case "$suite" in
        basic)
            run_basic_tests
            ;;
        syntax)
            run_syntax_tests
            ;;
        config)
            run_config_tests
            ;;
        performance)
            run_performance_tests
            ;;
        security)
            run_security_tests
            ;;
        integration)
            run_integration_tests
            ;;
        all)
            run_basic_tests
            run_syntax_tests
            run_config_tests
            run_performance_tests
            run_security_tests
            run_integration_tests
            ;;
        *)
            echo "Unknown test suite: $suite"
            return 1
            ;;
    esac
}

# Cleanup function
cleanup_test_env() {
    rm -rf "$TEMP_TEST_DIR"
}

# Usage
usage() {
    cat << EOF
SketchyBar Configuration Testing Framework

Usage: $0 <suite> [options]

Test Suites:
    basic          Test file structure and permissions
    syntax         Test shell and Lua syntax
    config         Test configuration loading and dependencies
    performance    Test plugin performance
    security       Test for security issues
    integration    Test SketchyBar integration
    all            Run all test suites

Options:
    --report       Generate HTML test report
    --verbose      Enable verbose output
    --help         Show this help message

Examples:
    $0 all                    # Run all tests
    $0 basic --report         # Run basic tests and generate report
    $0 config --verbose       # Run config tests with verbose output

EOF
}

# Main function
main() {
    local suite="${1:-all}"
    local generate_report=false
    local verbose=false
    
    # Parse options
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --report)
                generate_report=true
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
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Initialize test environment
    init_test_env
    
    # Set verbose mode
    if [ "$verbose" = true ]; then
        set -x
    fi
    
    test_info "Starting SketchyBar test suite: $suite"
    
    # Run tests
    if run_test_suite "$suite"; then
        test_section "Test Summary"
        test_info "Tests completed: $TESTS_RUN run, $TESTS_PASSED passed, $TESTS_FAILED failed"
        
        if [ $TESTS_FAILED -eq 0 ]; then
            test_success "All tests passed!"
            exit_code=0
        else
            test_failure "Some tests failed!"
            exit_code=1
        fi
    else
        test_failure "Test suite execution failed"
        exit_code=1
    fi
    
    # Generate report if requested
    if [ "$generate_report" = true ]; then
        generate_test_report
    fi
    
    # Cleanup
    cleanup_test_env
    
    exit $exit_code
}

# Trap for cleanup
trap cleanup_test_env EXIT

# Run main function with all arguments
main "$@"