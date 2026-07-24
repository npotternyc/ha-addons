# Changelog

All notable changes to this addon will be documented in this file.

## [0.2.0] - 2026-07-15

### Changed

- Updated Genmon to version 2.0.01
- Relaxed Genmon's `X-Frame-Options` and CSP `frame-ancestors` headers to `SAMEORIGIN`/`'self'` so the web UI loads in the Home Assistant ingress panel
- Made the web UI's AJAX base URL and config-restore upload endpoint relative so they resolve against the ingress path prefix
- Documented in the README that Genmon's own auth/MFA/passkey/certificate features are unused behind ingress
- Guarded all Dockerfile `sed` patches to fail the build if a pattern no longer matches upstream
- Removed unused OpenContainer image labels from the Dockerfile; documented the Genmon upstream source in a comment instead

## [0.1.2] - 2026-03-01

### Changed

- Updated Genmon to version 1.19.08
- Improved README with installation instructions, configuration table, and automated build documentation

### Added

- GitHub Actions CI: multi-arch Docker builds (aarch64, amd64, armv7) pushed to GitHub Container Registry
- Automated daily update checks for new Genmon releases and base image changes

## [0.1.1] - 2025-11-29

### Changed

- Updated Genmon to version 1.19.07 (latest release as of November 2025)
- Updated from previous Genmon version 1.19.02

### Added

- Added README.md with quick start guide
- Genmon Logos

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
