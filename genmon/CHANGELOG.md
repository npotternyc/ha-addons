# Changelog

All notable changes to this addon will be documented in this file.

## [0.1.1] - 2025-11-29

### Changed
- Updated Genmon to version 1.19.07 (latest release as of November 2025)
- Updated from previous Genmon version 1.19.02

### Added
- Added comprehensive documentation (DOCS.md)
- Added README.md with quick start guide
- Added this CHANGELOG.md

## [0.1.0] - Initial Release

### Added
- Initial Home Assistant addon release
- Genmon 1.19.02 integration
- Web interface via Ingress (port 8000)
- MQTT discovery support
- Pre-configured for serial TCP connections (ESP32 compatibility)
- Default TCP port set to 6638
- Persistent data storage in `/data/genmon/`
- Log files stored in `/data/genmon/log/`
- Python 3.11 runtime environment

### Configuration Defaults
- Serial TCP mode enabled by default
- MQTT JSON format enabled for Home Assistant
- MQTT flush interval set to 60 seconds
- Update checks disabled (managed by addon versioning)
- Filtered MQTT topics to reduce noise

### Supported Architectures
- armhf
- armv7
- aarch64
- amd64
- i386
