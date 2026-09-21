#!/usr/bin/with-contenv bashio

# Set log level from configuration
LOG_LEVEL=$(bashio::config 'log_level')
bashio::log.level "${LOG_LEVEL}"

bashio::log.info "Starting TLP Power Savings..."

# TLP writes almost exclusively to sysfs, which Docker mounts read-only.
# CAP_SYS_ADMIN (privileged: SYS_ADMIN) lets us remount it read-write.
if ! mount -o remount,rw /sys 2>/dev/null; then
    bashio::log.error "Could not remount /sys read-write; TLP cannot apply any settings."
    bashio::log.error "Ensure 'apparmor: false' is set - the default AppArmor profile denies mount."
    exit 1
fi
bashio::log.info "Remounted /sys read-write"

# Generate TLP config from user options
CONFIG_FILE="/etc/tlp.conf"

bashio::log.info "Generating TLP configuration from user options..."

# Start with a minimal config header
cat > "$CONFIG_FILE" << 'EOF'
# TLP Configuration - Generated from Home Assistant Add-on Options
# Manual edits to this file will be lost on container restart
# Use the add-on configuration options instead

EOF

# Read and apply profile setting.
# TLP's own vocabulary is PRF/BAL/SAV (see id2pp in /usr/share/tlp/tlp-func-base);
# the friendly names below are translated to it.
PROFILE=$(bashio::config 'profile')
case "${PROFILE}" in
    performance) TLP_PROFILE="PRF" ;;
    balanced)    TLP_PROFILE="BAL" ;;
    power-saver) TLP_PROFILE="SAV" ;;
    *)
        bashio::log.error "Unknown profile '${PROFILE}'; expected performance, balanced or power-saver"
        exit 1
        ;;
esac
bashio::log.info "Setting TLP profile: ${PROFILE} (${TLP_PROFILE})"
# A Home Assistant host usually has no battery, so there are no AC<->BAT
# transitions to follow. Pin the chosen profile instead of auto-switching.
echo "TLP_AUTO_SWITCH=0" >> "$CONFIG_FILE"
echo "TLP_PROFILE_DEFAULT=${TLP_PROFILE}" >> "$CONFIG_FILE"

# Read and apply custom configuration from the add-on options
if bashio::config.has_value 'tlp_config'; then
    bashio::log.info "Applying custom TLP configuration line(s)..."
    echo "" >> "$CONFIG_FILE"
    echo "# Custom configuration from add-on options" >> "$CONFIG_FILE"
    while read -r line; do
        echo "$line" >> "$CONFIG_FILE"
        bashio::log.info "  $line"
    done <<< "$(bashio::config 'tlp_config')"
else
    bashio::log.info "No custom configuration lines, using TLP defaults"
fi

# Start TLP
bashio::log.info "Starting TLP service..."
TLP_OUTPUT=$(tlp start 2>&1)
bashio::log.info "${TLP_OUTPUT}"

# 'tlp start' exits 0 even when it applies nothing, so confirm the profile it
# reports actually matches the one we asked for.
ACTIVE=$(tlp-stat -s 2>/dev/null | awk -F'= *' '/^TLP profile/{print $2}')
if [ -z "${ACTIVE}" ]; then
    bashio::log.error "TLP reported no active profile - settings were not applied"
    exit 1
fi
case "${ACTIVE}" in
    "${PROFILE}"*)
        bashio::log.info "TLP active profile: ${ACTIVE}"
        ;;
    *)
        bashio::log.error "TLP applied '${ACTIVE}' but '${PROFILE}' was requested"
        exit 1
        ;;
esac

# Periodically re-apply settings. Sysfs values can be reset outside our control
# (device hotplug, driver reloads, devices appearing after startup). TLP normally
# reacts to udev events, which cannot reach us inside an add-on container.
INTERVAL=$(bashio::config 'reapply_interval')
bashio::log.info "Re-applying TLP settings every ${INTERVAL}s"

while true; do
    sleep "${INTERVAL}"
    if ! tlp start > /dev/null 2>&1; then
        bashio::log.warning "Periodic TLP re-apply failed"
    fi
done
