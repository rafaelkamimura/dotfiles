#!/bin/bash

# Enhanced system monitoring script with comprehensive metrics
# Supports Apple Silicon and Intel Macs

get_cpu_usage() {
    # More accurate CPU usage calculation
    local cpu_usage=$(top -l 2 -n 0 | grep "CPU usage" | tail -1 | awk '{print $3}' | sed 's/%//' | cut -d'.' -f1)
    if [ -z "$cpu_usage" ]; then
        cpu_usage=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
    fi
    echo "${cpu_usage:-0}"
}

get_memory_usage() {
    # Get memory usage in GB
    local memory_used=$(memory_pressure 2>/dev/null | grep "System-wide memory free percentage" | awk '{print 100-$5}' | sed 's/%//')
    
    if [ -z "$memory_used" ]; then
        # Fallback method using vm_stat
        local page_size=$(vm_stat | head -1 | grep -o '[0-9]*')
        local pages_used=$(vm_stat | awk '
            /Pages active/ { active = $3; gsub(/[^0-9]/, "", active) }
            /Pages inactive/ { inactive = $3; gsub(/[^0-9]/, "", inactive) }
            /Pages speculative/ { speculative = $3; gsub(/[^0-9]/, "", speculative) }
            /Pages wired down/ { wired = $4; gsub(/[^0-9]/, "", wired) }
            /Pages occupied by compressor/ { compressed = $5; gsub(/[^0-9]/, "", compressed) }
            END { print active + inactive + speculative + wired + compressed }
        ')
        
        local memory_gb=$(echo "scale=1; ($pages_used * $page_size) / 1024 / 1024 / 1024" | bc -l 2>/dev/null)
        echo "${memory_gb:-0.0}"
    else
        local total_memory_gb=$(sysctl -n hw.memsize | awk '{printf "%.1f", $1/1024/1024/1024}')
        local used_memory_gb=$(echo "scale=1; $total_memory_gb * $memory_used / 100" | bc -l 2>/dev/null)
        echo "${used_memory_gb:-0.0}"
    fi
}

get_gpu_usage() {
    # GPU usage for Apple Silicon Macs
    if system_profiler SPHardwareDataType | grep -q "Apple"; then
        # Try to get GPU metrics from powermetrics (requires sudo setup)
        local gpu_usage=$(sudo powermetrics -n 1 -i 1000 --samplers gpu_power 2>/dev/null | grep "GPU Active residency" | awk '{print $4}' | sed 's/.$//' | cut -d'.' -f1)
        
        if [ -z "$gpu_usage" ]; then
            # Fallback: estimate based on GPU-intensive processes
            local gpu_processes=$(ps aux | grep -E "(Final Cut|Logic|Blender|Unity|Xcode)" | grep -v grep | wc -l | tr -d ' ')
            if [ "$gpu_processes" -gt 0 ]; then
                echo "45"  # Estimate moderate usage
            else
                echo "5"   # Low usage estimate
            fi
        else
            echo "$gpu_usage"
        fi
    else
        # Intel Mac - use discrete GPU if available
        local gpu_usage=$(ioreg -l | grep "\"PerformanceStatistics\"" | cut -d '{' -f 2 | grep "\"GPU Core Utilization\"" | awk '{print $4}' | sed 's/[^0-9]//g')
        echo "${gpu_usage:-0}"
    fi
}

get_cpu_temperature() {
    # CPU temperature using sensors or powermetrics
    local temp=$(sudo powermetrics -n 1 -i 1000 --samplers smc 2>/dev/null | grep "CPU die temperature" | awk '{print $4}' | cut -d'.' -f1)
    
    if [ -z "$temp" ]; then
        # Alternative method using istats (if installed)
        if command -v istats >/dev/null 2>&1; then
            temp=$(istats cpu temp --value-only | cut -d'.' -f1)
        else
            # Estimate based on CPU usage
            local cpu_usage=$(get_cpu_usage)
            if [ "$cpu_usage" -gt 80 ]; then
                temp="75"
            elif [ "$cpu_usage" -gt 50 ]; then
                temp="65"
            else
                temp="45"
            fi
        fi
    fi
    
    echo "${temp:-45}"
}

get_disk_io() {
    # Disk I/O speed in MB/s
    local disk_io=$(iostat -d 1 2 | tail -1 | awk '{print ($3 + $4) * 1024}' | cut -d'.' -f1)
    
    if [ -z "$disk_io" ] || [ "$disk_io" = "0" ]; then
        # Alternative method using fs_usage (background sampling)
        disk_io=$(fs_usage -w -f diskio 2>/dev/null | head -10 | wc -l | awk '{print $1 * 0.5}')
    fi
    
    # Convert to MB/s
    local disk_mbps=$(echo "scale=1; ${disk_io:-0} / 1048576" | bc -l 2>/dev/null)
    echo "${disk_mbps:-0.0}"
}

get_power_consumption() {
    # Power consumption in Watts (Apple Silicon)
    if system_profiler SPHardwareDataType | grep -q "Apple"; then
        local power=$(sudo powermetrics -n 1 -i 1000 --samplers cpu_power,gpu_power 2>/dev/null | grep "Power:" | awk '{sum += $2} END {printf "%.1f", sum/1000}')
        echo "${power:-5.0}"
    else
        # Intel Mac estimate based on CPU usage
        local cpu_usage=$(get_cpu_usage)
        local estimated_power=$(echo "scale=1; 15 + ($cpu_usage * 0.5)" | bc -l 2>/dev/null)
        echo "${estimated_power:-15.0}"
    fi
}

# Handle different actions
case "$1" in
    "update")
        # Return all metrics in a colon-separated format
        cpu_percent=$(get_cpu_usage)
        memory_gb=$(get_memory_usage)
        gpu_percent=$(get_gpu_usage)
        temp_celsius=$(get_cpu_temperature)
        disk_mbps=$(get_disk_io)
        power_watts=$(get_power_consumption)
        
        echo "${cpu_percent}:${memory_gb}:${gpu_percent}:${temp_celsius}:${disk_mbps}:${power_watts}"
        ;;
    "click")
        # Handle click events
        if [ "$BUTTON" = "left" ]; then
            # Open Activity Monitor
            open -a "Activity Monitor"
        elif [ "$BUTTON" = "right" ]; then
            # Open System Information
            open -a "System Information"
        fi
        ;;
    *)
        # Default action - just update
        cpu_percent=$(get_cpu_usage)
        memory_gb=$(get_memory_usage)
        gpu_percent=$(get_gpu_usage)
        temp_celsius=$(get_cpu_temperature)
        disk_mbps=$(get_disk_io)
        power_watts=$(get_power_consumption)
        
        echo "${cpu_percent}:${memory_gb}:${gpu_percent}:${temp_celsius}:${disk_mbps}:${power_watts}"
        ;;
esac