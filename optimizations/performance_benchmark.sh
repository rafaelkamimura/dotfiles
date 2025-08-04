#!/bin/bash

# SketchyBar Performance Benchmark Script
# Measures execution time of plugins and provides optimization recommendations

BENCHMARK_DIR="/tmp/sketchybar_benchmark"
PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
OPTIMIZED_DIR="$HOME/.config/sketchybar/optimizations"

mkdir -p "$BENCHMARK_DIR"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== SketchyBar Performance Benchmark ===${NC}"
echo "Timestamp: $(date)"
echo "System: $(uname -a)"
echo ""

# Function to measure execution time
measure_plugin() {
    local plugin_name="$1"
    local plugin_path="$2"
    local iterations="${3:-5}"
    
    if [ ! -f "$plugin_path" ]; then
        echo -e "${RED}Plugin not found: $plugin_path${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Testing: $plugin_name${NC}"
    
    local total_time=0
    local times=()
    
    for ((i=1; i<=iterations; i++)); do
        local start_time=$(date +%s.%N)
        
        # Run plugin with minimal environment
        NAME="benchmark_test" timeout 10s bash "$plugin_path" >/dev/null 2>&1
        local exit_code=$?
        
        local end_time=$(date +%s.%N)
        local execution_time=$(echo "$end_time - $start_time" | bc -l)
        
        if [ $exit_code -eq 0 ]; then
            times+=("$execution_time")
            total_time=$(echo "$total_time + $execution_time" | bc -l)
        else
            echo -e "  ${RED}Run $i failed (exit code: $exit_code)${NC}"
        fi
    done
    
    if [ ${#times[@]} -gt 0 ]; then
        local avg_time=$(echo "scale=4; $total_time / ${#times[@]}" | bc -l)
        local min_time=$(printf '%s\n' "${times[@]}" | sort -n | head -1)
        local max_time=$(printf '%s\n' "${times[@]}" | sort -n | tail -1)
        
        printf "  Average: %8.4fs | Min: %8.4fs | Max: %8.4fs | Runs: %d/%d\n" \
               "$avg_time" "$min_time" "$max_time" "${#times[@]}" "$iterations"
        
        # Store results for comparison
        echo "$plugin_name|$avg_time|$min_time|$max_time|${#times[@]}" >> "$BENCHMARK_DIR/results.csv"
        
        return 0
    else
        echo -e "  ${RED}All runs failed${NC}"
        return 1
    fi
}

# Function to benchmark system commands
benchmark_system_commands() {
    echo -e "\n${BLUE}=== System Command Performance ===${NC}"
    
    local commands=(
        "top -l 1|CPU usage via top"
        "iostat -c 1|CPU usage via iostat"
        "vm_stat|Memory stats"
        "pmset -g batt|Battery status"
        "system_profiler SPAirPortDataType|WiFi info"
        "networksetup -listallhardwareports|Network interfaces"
        "yabai -m query --windows|Yabai windows"
    )
    
    for cmd_info in "${commands[@]}"; do
        IFS='|' read -r cmd desc <<< "$cmd_info"
        
        echo -e "${YELLOW}$desc${NC}"
        
        local total_time=0
        local successful_runs=0
        
        for ((i=1; i<=3; i++)); do
            local start_time=$(date +%s.%N)
            timeout 5s bash -c "$cmd" >/dev/null 2>&1
            local exit_code=$?
            local end_time=$(date +%s.%N)
            
            if [ $exit_code -eq 0 ]; then
                local execution_time=$(echo "$end_time - $start_time" | bc -l)
                total_time=$(echo "$total_time + $execution_time" | bc -l)
                ((successful_runs++))
            fi
        done
        
        if [ $successful_runs -gt 0 ]; then
            local avg_time=$(echo "scale=4; $total_time / $successful_runs" | bc -l)
            printf "  Average: %8.4fs | Success: %d/3\n" "$avg_time" "$successful_runs"
        else
            echo -e "  ${RED}All runs failed${NC}"
        fi
    done
}

# Function to compare original vs optimized plugins
compare_plugins() {
    echo -e "\n${BLUE}=== Original vs Optimized Comparison ===${NC}"
    
    local plugins=(
        "cpu.sh"
        "weather.sh"
        "network.sh"
        "space.sh"
    )
    
    echo "Plugin,Original(s),Optimized(s),Improvement(%)" > "$BENCHMARK_DIR/comparison.csv"
    
    for plugin in "${plugins[@]}"; do
        local original_path="$PLUGIN_DIR/$plugin"
        local optimized_path="$OPTIMIZED_DIR/optimized_$plugin"
        
        if [ -f "$original_path" ] && [ -f "$optimized_path" ]; then
            echo -e "\n${YELLOW}Comparing: $plugin${NC}"
            
            # Benchmark original
            echo -n "  Original:  "
            local original_result=$(measure_plugin "original_$plugin" "$original_path" 3 2>/dev/null | grep Average | awk '{print $2}' | sed 's/s//')
            
            # Benchmark optimized
            echo -n "  Optimized: "
            local optimized_result=$(measure_plugin "optimized_$plugin" "$optimized_path" 3 2>/dev/null | grep Average | awk '{print $2}' | sed 's/s//')
            
            if [ -n "$original_result" ] && [ -n "$optimized_result" ]; then
                local improvement=$(echo "scale=2; (($original_result - $optimized_result) / $original_result) * 100" | bc -l)
                
                if (( $(echo "$improvement > 0" | bc -l) )); then
                    echo -e "  ${GREEN}Improvement: ${improvement}%${NC}"
                else
                    echo -e "  ${RED}Regression: ${improvement}%${NC}"
                fi
                
                echo "$plugin,$original_result,$optimized_result,$improvement" >> "$BENCHMARK_DIR/comparison.csv"
            fi
        fi
    done
}

# Function to analyze memory usage
analyze_memory() {
    echo -e "\n${BLUE}=== Memory Usage Analysis ===${NC}"
    
    # Get SketchyBar process info
    local sketchybar_pid=$(pgrep sketchybar | head -1)
    
    if [ -n "$sketchybar_pid" ]; then
        local memory_info=$(ps -o pid,rss,vsz,pcpu,comm -p "$sketchybar_pid" 2>/dev/null)
        echo "SketchyBar Process Info:"
        echo "$memory_info"
        
        # Get detailed memory breakdown
        echo -e "\nDetailed Memory Usage:"
        top -pid "$sketchybar_pid" -l 1 | grep sketchybar || echo "No detailed info available"
    else
        echo "SketchyBar process not found"
    fi
    
    # Count running plugin processes
    local plugin_processes=$(ps aux | grep -E "\.config/sketchybar/plugins" | grep -v grep | wc -l)
    echo -e "\nActive plugin processes: $plugin_processes"
}

# Function to generate recommendations
generate_recommendations() {
    echo -e "\n${BLUE}=== Performance Recommendations ===${NC}"
    
    local recommendations=()
    
    # Analyze results file
    if [ -f "$BENCHMARK_DIR/results.csv" ]; then
        # Find slowest plugins
        local slow_plugins=$(awk -F'|' '$2 > 0.5 {print $1, $2}' "$BENCHMARK_DIR/results.csv" | sort -k2 -nr)
        
        if [ -n "$slow_plugins" ]; then
            recommendations+=("🐌 Slow plugins detected (>0.5s execution time):")
            while IFS= read -r line; do
                recommendations+=("   - $line")
            done <<< "$slow_plugins"
        fi
    fi
    
    # Check for common performance issues
    if pgrep -f "system_profiler" >/dev/null; then
        recommendations+=("⚠️  system_profiler processes detected - consider caching WiFi data")
    fi
    
    if pgrep -f "curl.*wttr.in" >/dev/null; then
        recommendations+=("🌐 Active weather API calls - implement caching for weather data")
    fi
    
    if [ "$(pgrep -f "yabai.*query" | wc -l)" -gt 3 ]; then
        recommendations+=("🪟 Multiple yabai queries detected - batch window operations")
    fi
    
    # General recommendations
    recommendations+=(
        ""
        "📈 Performance Optimization Checklist:"
        "   ✓ Use optimized plugins from the optimizations/ directory"
        "   ✓ Enable caching for expensive operations (location, WiFi interface)"
        "   ✓ Reduce update frequencies for stable data (weather, network signal)"
        "   ✓ Use native event providers instead of shell scripts where possible"
        "   ✓ Implement adaptive update frequencies based on system state"
    )
    
    for rec in "${recommendations[@]}"; do
        echo -e "$rec"
    done
}

# Main execution
echo -e "Starting benchmark...\n"

# Clear previous results
rm -f "$BENCHMARK_DIR/results.csv"

# Initialize results CSV
echo "Plugin|Average|Min|Max|Successful_Runs" > "$BENCHMARK_DIR/results.csv"

# Benchmark individual plugins
echo -e "${BLUE}=== Plugin Performance ===${NC}"
local plugins=(
    "cpu.sh"
    "ram.sh"
    "battery.sh"
    "weather.sh"
    "network.sh"
    "space.sh"
    "front_app.sh"
    "media.sh"
)

for plugin in "${plugins[@]}"; do
    measure_plugin "$plugin" "$PLUGIN_DIR/$plugin"
done

# Run additional benchmarks
benchmark_system_commands
compare_plugins
analyze_memory
generate_recommendations

echo -e "\n${GREEN}Benchmark completed!${NC}"
echo "Results saved to: $BENCHMARK_DIR/"
echo ""
echo "Files created:"
echo "  - $BENCHMARK_DIR/results.csv (plugin performance data)"
echo "  - $BENCHMARK_DIR/comparison.csv (original vs optimized comparison)"
echo ""
echo -e "${BLUE}To apply optimizations:${NC}"
echo "1. Review the optimized plugins in: $OPTIMIZED_DIR/"
echo "2. Backup your current plugins: cp -r $PLUGIN_DIR $PLUGIN_DIR.backup"
echo "3. Replace plugins with optimized versions as needed"
echo "4. Restart SketchyBar: brew services restart sketchybar"