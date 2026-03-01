# Genmon Home Assistant Addon

Monitor your backup generator with Home Assistant using this Genmon addon.

## Adding to Home Assistant

1. Navigate to **Settings → Add-ons → Add-on Store**
2. Click the **⋮ menu** (top right) and select **Repositories**
3. Add the following URL and click **Add**:
   ```
   https://github.com/npotternyc/ha-addons
   ```
4. Refresh the page — the **Genmon** addon will appear in the store
5. Click **Install**

## About

This addon packages [Genmon](https://github.com/jgyates/genmon) for easy installation in Home Assistant. Genmon is a comprehensive monitoring solution for backup generators. Tested with the Generac Evolution V2 — should work with all Genmon-supported generators, but requires a working Serial-to-WiFi bridge.

## Requirements

- Home Assistant OS or Supervised installation
- Physical connection to your generator's controller (RS-232/RS-485)
- Serial-to-WiFi bridge (e.g., ESP32 with ser2net) or USB serial adapter. I use the discontinued [pintsize.me](https://pintsize.me/store/ols/products/opengenset) product, but you can also [make your own](https://github.com/gregmac/Genmon-ESP32-Serial-Bridge).
- MQTT broker (optional, for Home Assistant integration)

## Quick Start

1. Install the addon from the Home Assistant addon store
2. Start the addon
3. Click **Open Web UI** to access the Genmon interface
4. Follow the setup wizard to configure your generator
5. Enable MQTT integration for Home Assistant automation

## Default Configuration

The addon comes pre-configured for common setups:

| Setting | Value |
|---------|-------|
| Serial TCP Mode | Enabled (for ESP32/WiFi serial bridges) |
| TCP Port | 6638 |
| Logs | `/data/genmon/log/` |
| MQTT JSON format | Enabled |
| MQTT flush interval | 60 seconds |
| Web Interface | Ingress on port 8000 |

## Automated Builds

This addon is automatically rebuilt via GitHub Actions whenever:

- A new **Genmon release** is published on GitHub
- The **Home Assistant Debian base image** is updated

Builds are produced for `aarch64`, `amd64`, and `armv7` architectures and pushed to the GitHub Container Registry.

## Version

- **Addon Version**: 0.1.2
- **Genmon Version**: 1.19.08

## Support and Resources

- [Genmon Official GitHub](https://github.com/jgyates/genmon)
- [Genmon Wiki](https://github.com/jgyates/genmon/wiki)
- [Report Issues](https://github.com/npotternyc/ha-addons/issues)

## License

This addon packaging is released under the GPL-2.0 license, matching the Genmon project license.

Genmon is developed and maintained by [jgyates](https://github.com/jgyates).

## Credits

Docker image derived from image maintained by [m0ngr31](https://github.com/m0ngr31/genmon).
