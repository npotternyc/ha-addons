#!/usr/bin/env bashio

# Read configuration with defaults
AUTO_TUNE=$(bashio::config 'auto_tune' || echo 'true')
REPORT_INTERVAL=$(bashio::config 'report_interval' || echo '300')
WEB_PORT=$(bashio::config 'web_port' || echo '8080')

# Ensure variables are not empty
AUTO_TUNE=${AUTO_TUNE:-true}
REPORT_INTERVAL=${REPORT_INTERVAL:-300}
WEB_PORT=${WEB_PORT:-8080}

bashio::log.info "Starting PowerTop Plus addon..."
bashio::log.info "Auto-tune: ${AUTO_TUNE}"
bashio::log.info "Report interval: ${REPORT_INTERVAL} seconds"
bashio::log.info "Web port: ${WEB_PORT}"

# Function to mount debugfs for PowerTop
mount_debugfs() {
    bashio::log.info "Checking debugfs for PowerTop kernel access..."

    # Check if debugfs is already mounted
    if mountpoint -q /sys/kernel/debug 2>/dev/null; then
        bashio::log.info "debugfs already mounted"
        return 0
    fi

    # Check if /sys/kernel/debug exists
    if [[ ! -d /sys/kernel/debug ]]; then
        bashio::log.info "Creating /sys/kernel/debug directory..."
        mkdir -p /sys/kernel/debug 2>/dev/null || {
            bashio::log.warning "Cannot create /sys/kernel/debug - may already exist or lack permissions"
        }
    fi

    # Try to mount debugfs
    bashio::log.info "Attempting to mount debugfs..."
    if mount -t debugfs none /sys/kernel/debug 2>/dev/null; then
        bashio::log.info "debugfs mounted successfully"
        return 0
    else
        bashio::log.warning "Failed to mount debugfs - it may already be mounted on the host"
        bashio::log.info "PowerTop will use existing host debugfs if available"
        return 0
    fi
}

# Start web interface in background
bashio::log.info "Starting web interface on port ${WEB_PORT}..."
cd /app && python3 app.py --port="${WEB_PORT}" &
WEB_PID=$!

# Function to calibrate PowerTop
calibrate_powertop() {
    bashio::log.info "Starting PowerTop calibration..."
    bashio::log.info "This will take several minutes to complete various system measurements"
    
    # Run PowerTop calibration which measures system behavior
    if powertop --calibrate --time=60; then
        bashio::log.info "PowerTop calibration completed successfully"
        return 0
    else
        bashio::log.warning "PowerTop calibration failed or had issues"
        return 0
    fi
}

# Function to generate PowerTop report
generate_report() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_file="/data/reports/powertop_report_${timestamp}.html"
    
    bashio::log.info "Generating PowerTop report: ${report_file}"
    
    # Run PowerTop to generate HTML report
    if powertop --html="${report_file}" --time=60; then
        bashio::log.info "Report generated successfully: ${report_file}"
        
        # Create/update symlink to latest report
        ln -sf "${report_file}" "/data/reports/latest.html"
        
        # Cleanup old reports (keep last 10)
        cd /data/reports
        ls -t powertop_report_*.html | tail -n +11 | xargs rm -f 2>/dev/null || true
    else
        bashio::log.error "Failed to generate PowerTop report"
    fi
}

# Function to run auto-tune
run_autotune() {
    if [[ "${AUTO_TUNE}" == "true" ]]; then
        bashio::log.info "Running PowerTop auto-tune..."
        if powertop --quiet --auto-tune; then
            bashio::log.info "Auto-tune completed successfully"
        else
            bashio::log.warning "Auto-tune failed or had issues"
        fi
    else
        bashio::log.info "Auto-tune disabled"
    fi
}

# Function to cleanup on exit
cleanup() {
    bashio::log.info "Shutting down PowerTop Plus addon..."
    if [[ -n "${WEB_PID}" ]]; then
        kill "${WEB_PID}" 2>/dev/null || true
    fi
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Create reports directory if it doesn't exist
mkdir -p /data/reports

# Mount debugfs for kernel access
mount_debugfs

# Run initial calibration on first startup
bashio::log.info "Performing initial PowerTop calibration for accurate measurements..."
calibrate_powertop

# Initial report generation and auto-tune
generate_report
run_autotune

# Main loop - generate reports at specified intervals
while true; do
    sleep "${REPORT_INTERVAL}"
    generate_report
    run_autotune
done