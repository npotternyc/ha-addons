# TLP Power Savings - Home Assistant Add-on

This add-on runs TLP (The Linux Power Management Tool) to apply advanced power saving settings to your Home Assistant installation.

## About

TLP is a feature-rich command line utility for Linux, saving laptop battery power without the need to delve deeper into technical details.

Note that TLP was designed for laptops. Many of its settings (battery charge
thresholds, AC/battery switching) have no effect on a mains-powered Home
Assistant host, and the settings that do apply (CPU governor, SATA link power,
USB autosuspend) affect the **host** kernel, because sysfs is shared.

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "TLP Power Savings" add-on
3. Configure the add-on (optional)
4. Start the add-on

## Configuration

### Basic Configuration

The add-on works out of the box with TLP's default settings. TLP will automatically detect your power source and apply appropriate power saving settings.

### Configuration Options

#### `tlp_config`
An array of TLP configuration lines to customize TLP behavior.

**Example:**

```yaml
tlp_config:
  - "CPU_SCALING_GOVERNOR_ON_BAT=powersave"
  - "CPU_SCALING_GOVERNOR_ON_AC=performance"
  - "WIFI_PWR_ON_BAT=on"
  - "WIFI_PWR_ON_AC=off"
  - "USB_AUTOSUSPEND=1"
```

#### `log_level`
Controls the verbosity of add-on logs. Available levels: `trace`, `debug`, `info`, `warning`, `error`. Default is `info`.

**Example:**
```yaml
log_level: debug
```

#### `profile`
Select the power profile TLP applies. Available profiles:
- `performance` - Maximum performance, higher power consumption
- `balanced` - Balance between performance and power saving (default)
- `power-saver` - Maximum power savings, reduced performance

These are translated to TLP's own profile codes (`PRF`/`BAL`/`SAV`) and written
as `TLP_PROFILE_DEFAULT`. The add-on also sets `TLP_AUTO_SWITCH=0`, which pins
the selected profile instead of following the power source - a Home Assistant
host usually has no battery and therefore no AC/battery transitions to follow.

**Example:**
```yaml
profile: power-saver
```

#### `reapply_interval`
How often, in seconds, TLP re-applies its settings. Default is `300` (5 minutes),
minimum `60`, maximum `86400`. Sysfs values can be reset by events outside the
add-on's control (device hotplug, driver reloads); re-applying periodically
restores them. TLP normally reacts to udev events instead, but those cannot reach
a process inside an add-on container.

**Example:**
```yaml
reapply_interval: 600
```

### Common TLP Settings

Here are some commonly used TLP configuration options:

#### CPU Settings
```yaml
tlp_config:
  - "CPU_SCALING_GOVERNOR_ON_AC=performance"
  - "CPU_SCALING_GOVERNOR_ON_BAT=powersave"
  - "CPU_ENERGY_PERF_POLICY_ON_AC=performance"
  - "CPU_ENERGY_PERF_POLICY_ON_BAT=power"
  - "CPU_MIN_PERF_ON_AC=0"
  - "CPU_MAX_PERF_ON_AC=100"
  - "CPU_MIN_PERF_ON_BAT=0"
  - "CPU_MAX_PERF_ON_BAT=50"
```

#### Disk Settings
```yaml
tlp_config:
  - "DISK_DEVICES=\"nvme0n1 sda\""
  - "DISK_APM_LEVEL_ON_AC=\"254 254\""
  - "DISK_APM_LEVEL_ON_BAT=\"128 128\""
  - "SATA_LINKPWR_ON_AC=\"med_power_with_dipm max_performance\""
  - "SATA_LINKPWR_ON_BAT=\"med_power_with_dipm min_power\""
```

#### Network Settings
```yaml
tlp_config:
  - "WIFI_PWR_ON_AC=off"
  - "WIFI_PWR_ON_BAT=on"
  - "WOL_DISABLE=Y"
```

#### USB Settings
```yaml
tlp_config:
  - "USB_AUTOSUSPEND=1"
  - "USB_EXCLUDE_BTUSB=0"
  - "USB_EXCLUDE_PHONE=0"
  - "USB_EXCLUDE_PRINTER=1"
  - "USB_EXCLUDE_WWAN=0"
```

## Example Configuration

Full add-on configuration example:

```yaml
tlp_config:
  - "# CPU settings"
  - "CPU_SCALING_GOVERNOR_ON_BAT=powersave"
  - "CPU_ENERGY_PERF_POLICY_ON_BAT=power"
  - "# Disk settings"
  - "SATA_LINKPWR_ON_BAT=min_power"
  - "# Network settings"
  - "WIFI_PWR_ON_BAT=on"
  - "# USB settings"
  - "USB_AUTOSUSPEND=1"
```

## How It Works

1. The add-on remounts `/sys` read-write, which TLP needs to apply any setting
   at all (Docker mounts it read-only by default)
2. It reads your configuration and writes `/etc/tlp.conf`
3. TLP starts and applies the selected profile
4. The add-on verifies that TLP actually activated the profile you asked for,
   and stops with an error if it did not
5. Settings are re-applied every `reapply_interval` seconds

## Troubleshooting

### Check if TLP is running

View the add-on logs to see TLP status messages. You should see:
- "Remounted /sys read-write"
- "Starting TLP service..."
- "TLP started using profile ..."
- "TLP active profile: ..." matching the profile you selected

### TLP not starting

- **"Could not remount /sys read-write"** - TLP cannot change anything without a
  writable sysfs. This needs `SYS_ADMIN` in `privileged:` and `apparmor: false`,
  because the default AppArmor profile denies `mount`.
- **"TLP applied 'X' but 'Y' was requested"** - a setting in `tlp_config` is
  overriding the `profile` option. Check for `TLP_AUTO_SWITCH` or
  `TLP_PROFILE_*` lines in your custom configuration.

### Custom settings not working

- Ensure your configuration uses valid TLP parameter names. TLP renames
  parameters between releases (for example `USB_BLACKLIST_*` became
  `USB_EXCLUDE_*`); run `tlp-stat -c` to see which file each value came from.
- Use double quotes for values containing spaces. TLP silently ignores
  single-quoted values and falls back to its built-in default.
- Check TLP documentation for correct syntax
- View add-on logs for any error messages

## Support

For issues and feature requests, please visit the GitHub repository.

## Resources

- [TLP Official Documentation](https://linrunner.de/tlp/)
- [TLP Configuration Reference](https://linrunner.de/tlp/settings/)
- [Home Assistant Add-on Documentation](https://www.home-assistant.io/addons/)

## Notes

- This add-on needs the `SYS_ADMIN` capability and runs with AppArmor disabled,
  so that it can remount `/sys` read-write
- Changes to TLP configuration require restarting the add-on
- The selected profile is pinned; the add-on does not switch between AC and
  battery profiles. Set `TLP_AUTO_SWITCH=2` via `tlp_config` to restore TLP's
  automatic switching on a host that does have a battery.
- The add-on is built for `aarch64` and `amd64`
