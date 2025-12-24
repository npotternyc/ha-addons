# Genmon Home Assistant Addon

Monitor your backup generator with Home Assistant using this Genmon addon.

## About

This addon packages [Genmon](https://github.com/jgyates/genmon) for easy installation in Home Assistant. Genmon is a comprehensive monitoring solution for backup generators. I have tested this with the Generac Evolution V2. It should work with all the genmon supported generators, but you need to have a working Serial-to-WiFi bridge.

## Requirements

- Home Assistant OS or Supervised installation
- Physical connection to your generator's controller (RS-232/RS-485)
- Serial-to-WiFi bridge (e.g., ESP32 with ser2net) or USB serial adapter. I use the discontinued [pintsize.me](https://pintsize.me/store/ols/products/opengenset) product, but you can also [make your own](https://github.com/gregmac/Genmon-ESP32-Serial-Bridge).
- MQTT broker (optional, for Home Assistant integration)

## Quick Start

1. Install the addon from the Home Assistant addon store
2. Start the addon
3. Click "Open Web UI" to access the Genmon interface
4. Follow the setup wizard to configure your generator
5. Enable MQTT integration for Home Assistant automation

## Default Configuration

The addon comes pre-configured for common setups:

- **Serial TCP Mode**: Enabled (for ESP32/WiFi serial bridges)
- **TCP Port**: 6638
- **Logs**: Stored in `/data/genmon/log/`
- **MQTT**: Auto-discovery enabled
- **Web Interface**: Available via Ingress (port 8000)

## Version

- **Addon Version**: 0.1.1
- **Genmon Version**: 1.19.07 (October 2024)

## Support and Resources

- [Detailed Documentation](DOCS.md)
- [Genmon Official GitHub](https://github.com/jgyates/genmon)
- [Genmon Wiki](https://github.com/jgyates/genmon/wiki)
- [Report Issues](../../issues)

## License

This addon packaging is released under GPL-2.0 license, matching the Genmon project license.

Genmon is developed and maintained by [jgyates](https://github.com/jgyates).

## Credits
Docket image derived from image maintained by [m0ngr31](https://github.com/m0ngr31/genmon)
