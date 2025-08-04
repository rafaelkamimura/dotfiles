#!/bin/bash

# SketchyBar Monitoring and Health Check System
# Continuous monitoring, alerting, and health diagnostics

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$SCRIPT_DIR"
readonly LOGS_DIR="$CONFIG_DIR/logs"
readonly MONITOR_DIR="$CONFIG_DIR/monitoring"
readonly HEALTH_LOG="$LOGS_DIR/health-$(date +%Y%m%d).log"
readonly METRICS_FILE="$MONITOR_DIR/metrics.json"
readonly ALERTS_FILE="$MONITOR_DIR/alerts.json"
readonly PID_FILE="$MONITOR_DIR/monitor.pid"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# Monitoring configuration
readonly MONITOR_INTERVAL=30              # Check every 30 seconds
readonly ALERT_COOLDOWN=300              # 5 minutes between same alerts
readonly MAX_LOG_SIZE=10485760           # 10MB
readonly MAX_MEMORY_USAGE=100000000      # 100MB
readonly MAX_CPU_USAGE=50                # 50%
readonly MAX_PLUGIN_RUNTIME=5            # 5 seconds

# Initialize directories and files
init_monitoring() {
    mkdir -p "$MONITOR_DIR" "$LOGS_DIR"
    
    # Initialize metrics file
    if [ ! -f "$METRICS_FILE" ]; then
        cat > "$METRICS_FILE" << 'EOF'
{
  "start_time": "",
  "last_check": "",
  "uptime": 0,
  "checks_performed": 0,
  "alerts_sent": 0,
  "performance": {
    "memory_usage": [],
    "cpu_usage": [],
    "plugin_performance": {}
  },
  "health_status": "unknown"
}
EOF
    fi
    
    # Initialize alerts file
    if [ ! -f "$ALERTS_FILE" ]; then
        echo "[]" > "$ALERTS_FILE"
    fi
}

# Logging functions
log_health() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$HEALTH_LOG"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log_health "INFO: $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log_health "SUCCESS: $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log_health "WARNING: $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log_health "ERROR: $1"
}

log_section() {
    echo -e "${PURPLE}=== $1 ===${NC}"
    log_health "SECTION: $1"
}

# Utility functions
is_sketchybar_running() {
    pgrep -x sketchybar >/dev/null 2>&1
}

get_sketchybar_pid() {
    pgrep -x sketchybar 2>/dev/null || echo ""
}

get_uptime_seconds() {
    if is_sketchybar_running; then
        local pid
        pid=$(get_sketchybar_pid)
        if [ -n "$pid" ]; then
            local start_time
            start_time=$(ps -o lstart= -p "$pid" 2>/dev/null | xargs -I {} date -j -f "%a %b %d %T %Y" "{}" "+%s" 2>/dev/null || echo "0")
            local current_time
            current_time=$(date +%s)
            echo $((current_time - start_time))
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# Performance monitoring
monitor_memory_usage() {
    if is_sketchybar_running; then
        local pid
        pid=$(get_sketchybar_pid)
        if [ -n "$pid" ]; then
            # Get memory usage in bytes
            local memory_usage
            memory_usage=$(ps -o rss= -p "$pid" 2>/dev/null | awk '{print $1 * 1024}' || echo "0")
            echo "$memory_usage"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

monitor_cpu_usage() {
    if is_sketchybar_running; then
        local pid
        pid=$(get_sketchybar_pid)
        if [ -n "$pid" ]; then
            # Get CPU usage percentage
            local cpu_usage
            cpu_usage=$(ps -o pcpu= -p "$pid" 2>/dev/null | awk '{print $1}' || echo "0")
            echo "$cpu_usage"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# Plugin performance monitoring
monitor_plugin_performance() {
    local plugin_metrics="{}"
    
    # Test each plugin's execution time
    while IFS= read -r -d '' plugin; do
        local plugin_name
        plugin_name=$(basename "$plugin" .sh)
        
        local start_time
        start_time=$(date +%s.%N)
        
        local exit_code=0
        if timeout "$MAX_PLUGIN_RUNTIME" bash "$plugin" >/dev/null 2>&1; then
            local end_time
            end_time=$(date +%s.%N)
            local duration
            duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
            
            # Update plugin metrics
            plugin_metrics=$(echo "$plugin_metrics" | jq --arg plugin "$plugin_name" --arg duration "$duration" \
                '.[$plugin] = {duration: ($duration | tonumber), status: "ok", last_check: now}' 2>/dev/null || echo "{}")
        else
            exit_code=$?
            plugin_metrics=$(echo "$plugin_metrics" | jq --arg plugin "$plugin_name" --arg code "$exit_code" \
                '.[$plugin] = {duration: 0, status: "error", exit_code: ($code | tonumber), last_check: now}' 2>/dev/null || echo "{}")
        fi
    done < <(find "$CONFIG_DIR/plugins" -name "*.sh" -type f -print0 2>/dev/null)
    
    echo "$plugin_metrics"
}

# Health checks
check_sketchybar_status() {
    local status="healthy"
    local issues=()
    
    if ! is_sketchybar_running; then
        status="critical"
        issues+=("SketchyBar is not running")
    else
        local pid
        pid=$(get_sketchybar_pid)
        
        # Check if process is responsive
        if ! kill -0 "$pid" 2>/dev/null; then
            status="critical"
            issues+=("SketchyBar process is not responsive")
        fi
        
        # Check memory usage
        local memory_usage
        memory_usage=$(monitor_memory_usage)
        if [ "$memory_usage" -gt "$MAX_MEMORY_USAGE" ]; then
            status="warning"
            issues+=("High memory usage: $(echo "scale=2; $memory_usage / 1048576" | bc)MB")
        fi
        
        # Check CPU usage
        local cpu_usage
        cpu_usage=$(monitor_cpu_usage)
        if (( $(echo "$cpu_usage > $MAX_CPU_USAGE" | bc -l) )); then
            status="warning"
            issues+=("High CPU usage: ${cpu_usage}%")
        fi
    fi
    
    echo "{\"status\": \"$status\", \"issues\": $(printf '%s\n' "${issues[@]}" | jq -R . | jq -s .)}"
}

check_configuration_integrity() {
    local status="healthy"
    local issues=()
    
    # Check required files
    local required_files=(
        "sketchybarrc"
        "variables.sh"
        "init.lua"
        "settings.lua"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$CONFIG_DIR/$file" ]; then
            status="critical"
            issues+=("Required file missing: $file")
        fi
    done
    
    # Check script syntax
    while IFS= read -r -d '' script; do
        if ! bash -n "$script" 2>/dev/null; then
            status="critical"
            issues+=("Syntax error in: $(basename "$script")")
        fi
    done < <(find "$CONFIG_DIR" -name "*.sh" -type f -print0)
    
    echo "{\"status\": \"$status\", \"issues\": $(printf '%s\n' "${issues[@]}" | jq -R . | jq -s .)}"
}

check_dependencies() {
    local status="healthy"
    local issues=()
    
    # Check critical dependencies
    local critical_deps=("sketchybar")
    for dep in "${critical_deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            status="critical"
            issues+=("Critical dependency missing: $dep")
        fi
    done
    
    # Check optional dependencies
    local optional_deps=("yabai" "jq" "curl")
    local missing_optional=()
    for dep in "${optional_deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_optional+=("$dep")
        fi
    done
    
    if [ ${#missing_optional[@]} -gt 0 ]; then
        if [ "$status" = "healthy" ]; then
            status="warning"
        fi
        issues+=("Optional dependencies missing: ${missing_optional[*]}")
    fi
    
    echo "{\"status\": \"$status\", \"issues\": $(printf '%s\n' "${issues[@]}" | jq -R . | jq -s .)}"
}

check_disk_space() {
    local status="healthy"
    local issues=()
    
    # Check available space in config directory
    local available_kb
    available_kb=$(df "$CONFIG_DIR" | awk 'NR==2 {print $4}')
    local available_mb=$((available_kb / 1024))
    
    if [ "$available_mb" -lt 100 ]; then
        status="critical"
        issues+=("Very low disk space: ${available_mb}MB available")
    elif [ "$available_mb" -lt 500 ]; then
        status="warning"
        issues+=("Low disk space: ${available_mb}MB available")
    fi
    
    # Check log file sizes
    local total_log_size=0
    while IFS= read -r -d '' log_file; do
        local file_size
        file_size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file" 2>/dev/null || echo "0")
        total_log_size=$((total_log_size + file_size))
    done < <(find "$LOGS_DIR" -name "*.log" -type f -print0 2>/dev/null)
    
    if [ "$total_log_size" -gt "$((MAX_LOG_SIZE * 10))" ]; then
        status="warning"
        issues+=("Large log files: $(echo "scale=2; $total_log_size / 1048576" | bc)MB total")
    fi
    
    echo "{\"status\": \"$status\", \"issues\": $(printf '%s\n' "${issues[@]}" | jq -R . | jq -s .)}"
}

# Comprehensive health check
perform_health_check() {
    log_info "Performing comprehensive health check..."
    
    local overall_status="healthy"
    local health_report="{}"
    
    # SketchyBar status check
    local sketchybar_check
    sketchybar_check=$(check_sketchybar_status)
    health_report=$(echo "$health_report" | jq --argjson check "$sketchybar_check" '.sketchybar = $check')
    
    local check_status
    check_status=$(echo "$sketchybar_check" | jq -r '.status')
    if [ "$check_status" = "critical" ]; then
        overall_status="critical"
    elif [ "$check_status" = "warning" ] && [ "$overall_status" = "healthy" ]; then
        overall_status="warning"
    fi
    
    # Configuration integrity check
    local config_check
    config_check=$(check_configuration_integrity)
    health_report=$(echo "$health_report" | jq --argjson check "$config_check" '.configuration = $check')
    
    check_status=$(echo "$config_check" | jq -r '.status')
    if [ "$check_status" = "critical" ]; then
        overall_status="critical"
    elif [ "$check_status" = "warning" ] && [ "$overall_status" = "healthy" ]; then
        overall_status="warning"
    fi
    
    # Dependencies check
    local deps_check
    deps_check=$(check_dependencies)
    health_report=$(echo "$health_report" | jq --argjson check "$deps_check" '.dependencies = $check')
    
    check_status=$(echo "$deps_check" | jq -r '.status')
    if [ "$check_status" = "critical" ]; then
        overall_status="critical"
    elif [ "$check_status" = "warning" ] && [ "$overall_status" = "healthy" ]; then
        overall_status="warning"
    fi
    
    # Disk space check
    local disk_check
    disk_check=$(check_disk_space)
    health_report=$(echo "$health_report" | jq --argjson check "$disk_check" '.disk_space = $check')
    
    check_status=$(echo "$disk_check" | jq -r '.status')
    if [ "$check_status" = "critical" ]; then
        overall_status="critical"
    elif [ "$check_status" = "warning" ] && [ "$overall_status" = "healthy" ]; then
        overall_status="warning"
    fi
    
    # Plugin performance check
    local plugin_metrics
    plugin_metrics=$(monitor_plugin_performance)
    health_report=$(echo "$health_report" | jq --argjson plugins "$plugin_metrics" '.plugins = $plugins')
    
    # Add overall status and timestamp
    health_report=$(echo "$health_report" | jq --arg status "$overall_status" --arg timestamp "$(date -Iseconds)" \
        '.overall_status = $status | .timestamp = $timestamp')
    
    echo "$health_report"
}

# Update metrics
update_metrics() {
    local health_status="$1"
    
    # Get current metrics
    local current_time
    current_time=$(date -Iseconds)
    local memory_usage
    memory_usage=$(monitor_memory_usage)
    local cpu_usage
    cpu_usage=$(monitor_cpu_usage)
    local uptime
    uptime=$(get_uptime_seconds)
    
    # Update metrics file
    local updated_metrics
    updated_metrics=$(jq --arg time "$current_time" \
                        --arg memory "$memory_usage" \
                        --arg cpu "$cpu_usage" \
                        --arg uptime "$uptime" \
                        --arg status "$health_status" \
                        '
    .last_check = $time |
    .uptime = ($uptime | tonumber) |
    .checks_performed += 1 |
    .health_status = $status |
    .performance.memory_usage += [{"timestamp": $time, "value": ($memory | tonumber)}] |
    .performance.cpu_usage += [{"timestamp": $time, "value": ($cpu | tonumber)}] |
    .performance.memory_usage = (.performance.memory_usage | if length > 100 then .[1:] else . end) |
    .performance.cpu_usage = (.performance.cpu_usage | if length > 100 then .[1:] else . end)
    ' "$METRICS_FILE" 2>/dev/null || echo '{}')
    
    echo "$updated_metrics" > "$METRICS_FILE"
}

# Alert system
send_alert() {
    local alert_type="$1"
    local message="$2"
    local severity="${3:-warning}"
    
    local current_time
    current_time=$(date -Iseconds)
    
    # Check alert cooldown
    local last_alert_time
    last_alert_time=$(jq -r --arg type "$alert_type" \
        'map(select(.type == $type)) | if length > 0 then .[0].timestamp else "1970-01-01T00:00:00Z" end' \
        "$ALERTS_FILE" 2>/dev/null || echo "1970-01-01T00:00:00Z")
    
    local last_alert_epoch
    last_alert_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_alert_time" "+%s" 2>/dev/null || echo "0")
    local current_epoch
    current_epoch=$(date +%s)
    
    if [ $((current_epoch - last_alert_epoch)) -lt $ALERT_COOLDOWN ]; then
        return 0  # Skip alert due to cooldown
    fi
    
    # Create alert record
    local alert_record
    alert_record=$(jq -n --arg type "$alert_type" \
                        --arg message "$message" \
                        --arg severity "$severity" \
                        --arg timestamp "$current_time" \
                        '{type: $type, message: $message, severity: $severity, timestamp: $timestamp}')
    
    # Add to alerts file
    local updated_alerts
    updated_alerts=$(jq --argjson alert "$alert_record" '. += [$alert] | if length > 50 then .[1:] else . end' "$ALERTS_FILE")
    echo "$updated_alerts" > "$ALERTS_FILE"
    
    # Send notification (macOS)
    osascript -e "display notification \"$message\" with title \"SketchyBar Monitor\" subtitle \"$severity\""
    
    # Log alert
    log_warning "ALERT [$severity]: $message"
    
    # Update metrics
    jq '.alerts_sent += 1' "$METRICS_FILE" > "$METRICS_FILE.tmp" && mv "$METRICS_FILE.tmp" "$METRICS_FILE"
}

# Process health check results
process_health_results() {
    local health_report="$1"
    
    local overall_status
    overall_status=$(echo "$health_report" | jq -r '.overall_status')
    
    case "$overall_status" in
        critical)
            # Check each component for critical issues
            echo "$health_report" | jq -r '.[] | select(type == "object" and .status == "critical") | .issues[]' | while read -r issue; do
                send_alert "critical" "$issue" "critical"
            done
            ;;
        warning)
            # Check for warning issues
            echo "$health_report" | jq -r '.[] | select(type == "object" and .status == "warning") | .issues[]' | while read -r issue; do
                send_alert "warning" "$issue" "warning"
            done
            ;;
        healthy)
            log_success "All health checks passed"
            ;;
    esac
    
    # Check for slow plugins
    echo "$health_report" | jq -r '.plugins | to_entries[] | select(.value.duration > 2) | "Plugin \(.key) is slow: \(.value.duration)s"' | while read -r issue; do
        send_alert "performance" "$issue" "warning"
    done
}

# Auto-recovery actions
attempt_recovery() {
    local issue_type="$1"
    
    log_info "Attempting automatic recovery for: $issue_type"
    
    case "$issue_type" in
        "sketchybar_not_running")
            log_info "Attempting to restart SketchyBar..."
            if "$CONFIG_DIR/deploy.sh" start; then
                log_success "SketchyBar restarted successfully"
                send_alert "recovery" "SketchyBar automatically restarted" "info"
            else
                log_error "Failed to restart SketchyBar"
                send_alert "recovery_failed" "Failed to automatically restart SketchyBar" "critical"
            fi
            ;;
        "high_memory_usage")
            log_info "Attempting to restart SketchyBar due to high memory usage..."
            if "$CONFIG_DIR/deploy.sh" restart; then
                log_success "SketchyBar restarted to free memory"
                send_alert "recovery" "SketchyBar restarted due to high memory usage" "info"
            fi
            ;;
        "disk_space_low")
            log_info "Cleaning up logs due to low disk space..."
            "$CONFIG_DIR/deploy.sh" cleanup
            log_success "Log cleanup completed"
            ;;
    esac
}

# Continuous monitoring daemon
run_monitor_daemon() {
    log_info "Starting SketchyBar monitoring daemon (PID: $$)"
    echo $$ > "$PID_FILE"
    
    # Initialize metrics
    jq --arg start_time "$(date -Iseconds)" '.start_time = $start_time' "$METRICS_FILE" > "$METRICS_FILE.tmp" && mv "$METRICS_FILE.tmp" "$METRICS_FILE"
    
    while true; do
        local health_report
        health_report=$(perform_health_check)
        
        local overall_status
        overall_status=$(echo "$health_report" | jq -r '.overall_status')
        
        # Update metrics
        update_metrics "$overall_status"
        
        # Process results and send alerts
        process_health_results "$health_report"
        
        # Attempt recovery for critical issues
        if [ "$overall_status" = "critical" ]; then
            if ! is_sketchybar_running; then
                attempt_recovery "sketchybar_not_running"
            fi
        fi
        
        # Sleep until next check
        sleep "$MONITOR_INTERVAL"
    done
}

# Stop monitoring daemon
stop_monitor_daemon() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            log_info "Stopping monitoring daemon (PID: $pid)"
            kill "$pid"
            rm -f "$PID_FILE"
            log_success "Monitoring daemon stopped"
        else
            log_warning "Monitoring daemon not running (stale PID file)"
            rm -f "$PID_FILE"
        fi
    else
        log_warning "Monitoring daemon not running"
    fi
}

# Show monitoring status
show_status() {
    log_section "SketchyBar Monitoring Status"
    
    # Check daemon status
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Monitoring Daemon: Running (PID: $pid)"
        else
            echo "Monitoring Daemon: Not running (stale PID file)"
        fi
    else
        echo "Monitoring Daemon: Not running"
    fi
    
    # Show current metrics
    if [ -f "$METRICS_FILE" ]; then
        echo ""
        echo "Current Metrics:"
        echo "---------------"
        local metrics
        metrics=$(cat "$METRICS_FILE")
        
        echo "Health Status: $(echo "$metrics" | jq -r '.health_status')"
        echo "Uptime: $(echo "$metrics" | jq -r '.uptime') seconds"
        echo "Checks Performed: $(echo "$metrics" | jq -r '.checks_performed')"
        echo "Alerts Sent: $(echo "$metrics" | jq -r '.alerts_sent')"
        echo "Last Check: $(echo "$metrics" | jq -r '.last_check')"
        
        if is_sketchybar_running; then
            local memory_usage
            memory_usage=$(monitor_memory_usage)
            local cpu_usage
            cpu_usage=$(monitor_cpu_usage)
            echo "Current Memory Usage: $(echo "scale=2; $memory_usage / 1048576" | bc)MB"
            echo "Current CPU Usage: ${cpu_usage}%"
        fi
    fi
    
    # Show recent alerts
    if [ -f "$ALERTS_FILE" ]; then
        local alert_count
        alert_count=$(jq length "$ALERTS_FILE")
        if [ "$alert_count" -gt 0 ]; then
            echo ""
            echo "Recent Alerts (last 5):"
            echo "----------------------"
            jq -r '.[-5:] | .[] | "\(.timestamp) [\(.severity)] \(.message)"' "$ALERTS_FILE"
        fi
    fi
}

# Generate monitoring report
generate_report() {
    local report_file="$LOGS_DIR/monitor-report-$(date +%Y%m%d-%H%M%S).html"
    
    log_info "Generating monitoring report: $report_file"
    
    local metrics=""
    if [ -f "$METRICS_FILE" ]; then
        metrics=$(cat "$METRICS_FILE")
    else
        metrics="{}"
    fi
    
    local alerts=""
    if [ -f "$ALERTS_FILE" ]; then
        alerts=$(cat "$ALERTS_FILE")
    else
        alerts="[]"
    fi
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>SketchyBar Monitoring Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .header { color: #333; border-bottom: 2px solid #ddd; padding-bottom: 10px; }
        .section { margin: 20px 0; padding: 15px; background: white; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric { display: inline-block; margin: 10px; padding: 10px; background: #f8f9fa; border-radius: 3px; }
        .healthy { color: #28a745; }
        .warning { color: #ffc107; }
        .critical { color: #dc3545; }
        .chart { width: 100%; height: 200px; background: #f8f9fa; border-radius: 3px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="header">
        <h1>SketchyBar Monitoring Report</h1>
        <p>Generated: $(date)</p>
        <p>System: $(uname -s) $(uname -r)</p>
    </div>
    
    <div class="section">
        <h2>Current Status</h2>
        <div class="metric">
            <strong>Health Status:</strong> 
            <span class="$(echo "$metrics" | jq -r '.health_status')">$(echo "$metrics" | jq -r '.health_status')</span>
        </div>
        <div class="metric">
            <strong>Uptime:</strong> $(echo "$metrics" | jq -r '.uptime') seconds
        </div>
        <div class="metric">
            <strong>Checks Performed:</strong> $(echo "$metrics" | jq -r '.checks_performed')
        </div>
        <div class="metric">
            <strong>Alerts Sent:</strong> $(echo "$metrics" | jq -r '.alerts_sent')
        </div>
    </div>
    
    <div class="section">
        <h2>Performance Metrics</h2>
        <canvas id="memoryChart" class="chart"></canvas>
        <canvas id="cpuChart" class="chart"></canvas>
    </div>
    
    <div class="section">
        <h2>Recent Alerts</h2>
        <table>
            <thead>
                <tr>
                    <th>Timestamp</th>
                    <th>Severity</th>
                    <th>Type</th>
                    <th>Message</th>
                </tr>
            </thead>
            <tbody>
$(echo "$alerts" | jq -r '.[-10:] | .[] | "<tr><td>\(.timestamp)</td><td class=\"\(.severity)\">\(.severity)</td><td>\(.type)</td><td>\(.message)</td></tr>"')
            </tbody>
        </table>
    </div>
    
    <script>
        // Memory usage chart
        const memoryData = $(echo "$metrics" | jq '.performance.memory_usage // []');
        const memoryCtx = document.getElementById('memoryChart').getContext('2d');
        new Chart(memoryCtx, {
            type: 'line',
            data: {
                labels: memoryData.map(d => new Date(d.timestamp).toLocaleTimeString()),
                datasets: [{
                    label: 'Memory Usage (MB)',
                    data: memoryData.map(d => d.value / 1048576),
                    borderColor: 'rgb(75, 192, 192)',
                    tension: 0.1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: 'Memory Usage Over Time'
                    }
                }
            }
        });
        
        // CPU usage chart
        const cpuData = $(echo "$metrics" | jq '.performance.cpu_usage // []');
        const cpuCtx = document.getElementById('cpuChart').getContext('2d');
        new Chart(cpuCtx, {
            type: 'line',
            data: {
                labels: cpuData.map(d => new Date(d.timestamp).toLocaleTimeString()),
                datasets: [{
                    label: 'CPU Usage (%)',
                    data: cpuData.map(d => d.value),
                    borderColor: 'rgb(255, 99, 132)',
                    tension: 0.1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: 'CPU Usage Over Time'
                    }
                }
            }
        });
    </script>
</body>
</html>
EOF
    
    log_success "Monitoring report generated: $report_file"
}

# Usage function
usage() {
    cat << EOF
SketchyBar Monitoring and Health Check System

Usage: $0 <command> [options]

Commands:
    start              Start monitoring daemon
    stop               Stop monitoring daemon
    status             Show monitoring status
    check              Perform one-time health check
    report             Generate monitoring report
    alerts             Show recent alerts
    metrics            Show current metrics
    help               Show this help message

Examples:
    $0 start           # Start continuous monitoring
    $0 check           # Perform health check once
    $0 status          # Show current status
    $0 report          # Generate HTML report

EOF
}

# Main function
main() {
    local command="${1:-status}"
    
    # Initialize monitoring
    init_monitoring
    
    case "$command" in
        start)
            if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
                log_error "Monitoring daemon already running"
                exit 1
            fi
            run_monitor_daemon &
            disown
            log_success "Monitoring daemon started"
            ;;
        stop)
            stop_monitor_daemon
            ;;
        status)
            show_status
            ;;
        check)
            local health_report
            health_report=$(perform_health_check)
            echo "$health_report" | jq .
            process_health_results "$health_report"
            ;;
        report)
            generate_report
            ;;
        alerts)
            if [ -f "$ALERTS_FILE" ]; then
                log_section "Recent Alerts"
                jq -r '.[] | "\(.timestamp) [\(.severity)] \(.type): \(.message)"' "$ALERTS_FILE"
            else
                log_info "No alerts recorded"
            fi
            ;;
        metrics)
            if [ -f "$METRICS_FILE" ]; then
                log_section "Current Metrics"
                cat "$METRICS_FILE" | jq .
            else
                log_info "No metrics available"
            fi
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
trap 'rm -f "$MONITOR_DIR"/.tmp.*' EXIT

# Run main function with all arguments
main "$@"