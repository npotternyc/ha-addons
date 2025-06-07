#!/usr/bin/env bashio

# Read configuration
AUTO_TUNE=$(bashio::config 'auto_tune')
REPORT_INTERVAL=$(bashio::config 'report_interval')
WEB_PORT=$(bashio::config 'web_port')

bashio::log.info "Starting PowerTop Plus addon..."
bashio::log.info "Auto-tune: ${AUTO_TUNE}"
bashio::log.info "Report interval: ${REPORT_INTERVAL} seconds"
bashio::log.info "Web port: ${WEB_PORT}"

# Start web interface in background
bashio::log.info "Starting web interface on port ${WEB_PORT}..."
cd /app && python3 app.py --port="${WEB_PORT}" &
WEB_PID=$!

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
        if powertop --auto-tune; then
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

# Initial report generation and auto-tune
generate_report
run_autotune

# Main loop - generate reports at specified intervals
while true; do
    sleep "${REPORT_INTERVAL}"
    generate_report
    run_autotune
done