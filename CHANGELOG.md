# Changelog

All notable changes to GeekyMenu will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2024-08-14

### Added
- **Flatpak support**: GeekyMenu now discovers Flatpak applications
  - System-wide Flatpaks: `/var/lib/flatpak/exports/share/applications/`
  - User-specific Flatpaks: `~/.local/share/flatpak/exports/share/applications/`
- **Snap support**: Added support for Snap packages
  - System-wide Snaps: `/var/lib/snapd/desktop/applications/`
  - User-specific Snaps: `~/.local/share/applications/snap/`
- **Universal compatibility**: Works across all Linux package managers
- **Enhanced testing**: Test scripts now verify Flatpak and Snap discovery

### Fixed
- **Flatpak applications not showing**: Zen Browser and other Flatpaks now discovered
- **Cross-distribution compatibility**: Maintains support for traditional Linux while adding NixOS

### Changed
- Expanded application directory scanning to cover all major package managers
- Improved debug output to show all scanned directories
- Enhanced test coverage for different application sources

## [1.1.0] - 2024-08-14

### Added
- **NixOS compatibility**: GeekyMenu now discovers applications on NixOS systems
- Added scanning of NixOS-specific application directories:
  - `/run/current-system/sw/share/applications/` (system packages)
  - `/etc/profiles/per-user/<username>/share/applications/` (per-user profiles)
  - `~/.nix-profile/share/applications/` (user profile packages)
  - `~/.local/state/nix/profiles/profile/share/applications/` (new-style profiles)
- **Debug mode**: Added `--debug` flag and `GEEKYMENU_DEBUG` environment variable
- **Nix flake**: Complete Nix flake with packages, apps, dev shells, and modules
- **NixOS module**: System-wide installation support for NixOS
- **Home Manager module**: Per-user installation with optional keybinding configuration
- **Testing utilities**: Built-in application discovery testing
- **Comprehensive documentation**: Added NIX.md and extensive README updates
- **Development tools**: Nix development shell with Node.js 22 and tools
- **CI/CD**: GitHub Actions workflow for testing Nix builds

### Fixed
- **NixOS application discovery**: Applications are now properly found on NixOS systems
- **Dependency conflicts**: Removed conflicting `react-devtools-core` dependency

### Changed
- Updated Node.js requirement from 18+ to 22+ for better compatibility
- Improved code formatting and structure
- Enhanced error handling in directory scanning

### Documentation
- Added comprehensive Nix installation and usage instructions
- Added NixOS-specific troubleshooting guide
- Added integration examples for window managers
- Added development and contribution guidelines for Nix users

## [1.0.0] - 2024-08-13

### Added
- Initial release of GeekyMenu
- Terminal-based application launcher using React and Ink
- Fuzzy search functionality for application names
- Split-pane interface with application list and description preview
- Support for traditional Linux application directories:
  - `/usr/share/applications/`
  - `/usr/local/share/applications/`
  - `~/.local/share/applications/`
- Keyboard navigation with arrow keys, Page Up/Down
- Application launching with Enter key
- Desktop file parsing for Name, Comment, and Exec fields
- Terminal handling for applications that require terminal execution

### Features
- Fast fuzzy search algorithm
- Responsive terminal UI that adapts to terminal size
- Cross-platform desktop file discovery
- Clean, minimal interface design
- No external runtime dependencies (when installed via npm)

---

## Migration Notes

### From 1.1.0 to 1.2.0

**For all users**: v1.2.0 adds universal package manager support. If you use Flatpak or Snap applications, they will now be discovered automatically.

**For Flatpak users**: Zen Browser and other Flatpak applications will now appear in GeekyMenu.

**For Snap users**: Snap applications will now be discovered on Ubuntu and other Snap-enabled distributions.

### From 1.0.0 to 1.2.0

**For NixOS users**: If you were experiencing "No matches" or empty application lists, upgrade to v1.2.0 to get full NixOS, Flatpak, and Snap compatibility. No configuration changes are needed - the fix is automatic.

**For Nix users**: The flake is now available with comprehensive installation options:
- `nix run github:fearlessgeek/geekymenu` - Direct run
- `nix profile install github:fearlessgeek/geekymenu` - Profile installation
- NixOS and Home Manager modules for declarative configuration

**For developers**: The development environment now uses Node.js 22 instead of 18. Use `nix develop` for a consistent development environment.

**For all Linux distributions**: GeekyMenu now works universally across:
- Traditional package managers (apt, dnf, pacman, etc.)
- Flatpak (system and user installations)
- Snap packages
- NixOS/Nix packages
- Locally installed applications

## Support

- **General issues**: [GitHub Issues](https://github.com/fearlessgeek/geekymenu/issues)
- **NixOS-specific issues**: Use `geekymenu --debug` or `nix run .#test-nixos-apps` for diagnostics
- **Flatpak issues**: Verify Flatpak is installed and applications are in `/var/lib/flatpak/exports/share/applications/`
- **Snap issues**: Check that Snap is enabled and applications are in `/var/lib/snapd/desktop/applications/`
- **Development questions**: Check NIX.md for comprehensive Nix usage guide