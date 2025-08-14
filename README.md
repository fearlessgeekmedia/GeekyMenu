# GeekyMenu

A fast, fuzzy-search application launcher for Linux with a terminal-based UI. Quickly find and launch applications from your system's `.desktop` files, including native packages, Flatpaks, Snaps, and Nix packages. Works universally across traditional Linux distributions and NixOS. Perfect for window managers that need a lightweight application launcher.

## Features

- 🔍 **Fuzzy Search**: Type to instantly filter applications
- ⚡ **Fast Navigation**: Use arrow keys to browse results
- 📱 **Terminal UI**: Beautiful blessed-based interface
- 🚀 **Quick Launch**: Press Enter to launch applications
- 📂 **Universal discovery**: Finds apps from all sources (native, Flatpak, Snap, Nix)
- 🐧 **Cross-platform**: Works on traditional Linux, NixOS, with Flatpak/Snap support
- 🔍 **Debug mode**: Built-in diagnostics for troubleshooting application discovery

## Screenshots

The launcher provides a split-pane interface:
- **Top**: Search input field
- **Left**: Filtered application list
- **Right**: Application description preview

![Geekydmenu animation](./geekymenu.gif)
![GeekyMenu screenshot](./screenshot.png)

## Installation

### Prerequisites

- Node.js 18+ 
- npm or yarn

**Cross-platform compatibility**: GeekyMenu v1.2.0+ includes universal support for:
- **Traditional Linux**: FHS paths (`/usr/share/applications`, etc.)
- **NixOS**: Nix store paths (`/run/current-system/sw/share/applications`, etc.)
- **Flatpak**: System and user Flatpak applications (`/var/lib/flatpak/exports/...`)
- **Snap**: Snap packages on Ubuntu and other distributions
- **Debug mode**: `geekymenu --debug` for troubleshooting

### Installation Options

#### Option 1: Nix Flake (Recommended)

If you have Nix with flakes enabled, you can install and run GeekyMenu directly:

```bash
# Run directly without installing
nix run github:fearlessgeek/geekymenu

# Or install to your profile
nix profile install github:fearlessgeek/geekymenu

# For local development
git clone <your-repo-url>
cd geekymenu
nix develop  # Enter development shell
```

#### Option 2: Global Installation (npm)

Install GeekyMenu globally to use it as a command from anywhere:

```bash
# Clone the repository
git clone <your-repo-url>
cd geekymenu

# Install globally
npm install -g .

# Now you can run it from anywhere
geekymenu
```

### Local Development

For development or testing:

```bash
# Clone the repository
git clone <your-repo-url>
cd geekymenu

# Install dependencies
npm install

# Run locally
npm start
# or
node geekymenu.js
```

## Usage

### Running the Launcher

```bash
# If installed globally
geekymenu

# If running locally
node geekymenu.js

# For window managers, use with terminal emulator
terminal -e geekymenu
```

### Controls

- **Type**: Start typing to filter applications
- **↑/↓**: Navigate through results
- **Page Up/Page Down**: Jump by 10 items
- **Enter**: Launch selected application
- **Escape**: Exit the launcher
- **Ctrl+C**: Force quit

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `↑` | Move up in list |
| `↓` | Move down in list |
| `Page Up` | Jump up 10 items |
| `Page Down` | Jump down 10 items |
| `Enter` | Launch application |
| `Escape` | Exit launcher |
| `Ctrl+C` | Force quit |

## Development

### Project Structure

```
geekymenu/
├── geekymenu.js      # Main application code
├── package.json      # Dependencies and scripts
├── README.md         # This file
└── .gitignore        # Git ignore rules
```

### Dependencies

- **ink**: React-based terminal UI library
- **react**: React framework for building user interfaces

### Adding Features

The launcher is modular and easy to extend:

1. **Add new search directories**: Modify the `appDirs` array in `geekymenu.js`
2. **Customize UI**: Modify the blessed widget configurations
3. **Add keyboard shortcuts**: Extend the keypress handlers

## NixOS and Home Manager Integration

### NixOS System-wide Installation

Add GeekyMenu to your NixOS configuration:

```nix
# In your configuration.nix or flake.nix
{
  inputs.geekymenu.url = "github:fearlessgeek/geekymenu";
  
  # In your system configuration
  imports = [ inputs.geekymenu.nixosModules.default ];
  
  programs.geekymenu.enable = true;
}
```

### Home Manager Installation

Add GeekyMenu to your Home Manager configuration:

```nix
# In your home.nix or flake.nix
{
  inputs.geekymenu.url = "github:fearlessgeek/geekymenu";
  
  # In your home configuration
  imports = [ inputs.geekymenu.homeManagerModules.default ];
  
  programs.geekymenu = {
    enable = true;
    keybinding = "Super+space";  # Optional global keybinding
  };
}
```

### Nix Profile Installation

For users without NixOS or Home Manager:

```bash
# Install from GitHub
nix profile install github:fearlessgeek/geekymenu

# Or install from local clone
git clone <your-repo-url>
cd geekymenu
nix profile install .
```

### Development with Nix

```bash
# Clone and enter development environment
git clone <your-repo-url>
cd geekymenu
nix develop

# The development shell provides:
# - Node.js and npm
# - npm-check-updates for dependency management
# - All necessary development tools
```

## Troubleshooting

### Common Issues

1. **"Cannot find module 'blessed'"**
   - Run `npm install` to install dependencies

2. **"geekymenu: command not found"**
   - Ensure you installed globally with `npm install -g .`
   - Check that npm's global bin directory is in your PATH

3. **No applications found**
   - **On traditional Linux**: Check that your system has `.desktop` files in `/usr/share/applications`
   - **On NixOS**: Ensure you have applications installed via Nix (system packages or user profile)
   - **Flatpak apps**: Check `/var/lib/flatpak/exports/share/applications/` and `~/.local/share/flatpak/exports/share/applications/`
   - **Snap apps**: Check `/var/lib/snapd/desktop/applications/`
   - Use the test script: `node test-nixos-apps.js` to debug application discovery
   - Verify GeekyMenu v1.2.0+ is being used for full compatibility

4. **No applications found on specific systems**
   - **NixOS**: Install applications with `nix-env -iA nixpkgs.firefox nixpkgs.chromium`
   - **NixOS**: Or add to configuration: `environment.systemPackages = [ pkgs.firefox ];`
   - **Flatpak**: Install with `flatpak install firefox` or `flatpak install zen-browser`
   - **Snap**: Install with `snap install firefox` or similar
   - Check system applications: `ls /run/current-system/sw/share/applications/`
   - Check Flatpak apps: `ls /var/lib/flatpak/exports/share/applications/`

5. **Permission errors during global install**
   - Use `sudo npm install -g .` (not recommended)
   - Or configure npm to use a different global directory

### Debug Mode

To run with additional logging:

```bash
# Enable debug output
geekymenu --debug

# Or with environment variable
GEEKYMENU_DEBUG=1 geekymenu

# Check what apps are discovered
geekymenu --debug | grep "Sample applications" -A10

# Test cross-platform compatibility
node test-compatibility.js
```

### Platform-specific Debugging

GeekyMenu v1.2.0+ includes universal compatibility (NixOS, Flatpak, Snap). If you're still having issues:

```bash
# Test application discovery with built-in debug mode
geekymenu --debug

# Run the dedicated test scripts
node test-nixos-apps.js              # NixOS-specific test
node test-compatibility.js           # Cross-platform test

# Or use the Nix flake test
nix run .#test-nixos-apps

# Check what's in NixOS application directories
ls /run/current-system/sw/share/applications/ | wc -l
ls ~/.nix-profile/share/applications/ | wc -l

# Install test applications if none are found
nix-env -iA nixpkgs.firefox nixpkgs.chromium

# For system-wide applications, add to configuration.nix:
# environment.systemPackages = [ pkgs.firefox pkgs.chromium ];
```

#### Application Discovery Paths

GeekyMenu scans all standard Linux application directories:

**Traditional Linux (FHS)**:
- `/usr/share/applications/` (system packages)
- `/usr/local/share/applications/` (locally installed)
- `~/.local/share/applications/` (user-installed)

**Flatpak**:
- `/var/lib/flatpak/exports/share/applications/` (system-wide)
- `~/.local/share/flatpak/exports/share/applications/` (user-specific)

**Snap**:
- `/var/lib/snapd/desktop/applications/` (system-wide)
- `~/.local/share/applications/snap/` (user-specific)

**NixOS/Nix**:
- `/run/current-system/sw/share/applications/` (system packages)
- `/etc/profiles/per-user/<username>/share/applications/` (per-user profiles)
- `~/.nix-profile/share/applications/` (user profile packages)
- `~/.local/state/nix/profiles/profile/share/applications/` (new-style profiles)

#### Common Issues by Platform

1. **"No matches" on fresh systems**
   - **NixOS**: `nix-env -iA nixpkgs.firefox nixpkgs.thunderbird`
   - **Flatpak**: `flatpak install org.mozilla.firefox`
   - **Snap**: `snap install firefox`
   - **Traditional**: `apt install firefox` / `dnf install firefox` / etc.

2. **Applications not appearing after install**
   - Run `geekymenu --debug` to see what directories are being scanned
   - Check if the application created a .desktop file in the expected locations
   - For Flatpaks: Check `/var/lib/flatpak/exports/share/applications/`
   - For Snaps: Check `/var/lib/snapd/desktop/applications/`

3. **Old version of GeekyMenu**
   - Ensure you're using v1.2.0+ which includes universal compatibility
   - Update with: `nix profile upgrade geekymenu` or reinstall

4. **Missing Flatpak applications**
   - Verify Flatpak is installed: `flatpak --version`
   - Check Flatpak apps are installed: `flatpak list`
   - Check desktop files exist: `ls /var/lib/flatpak/exports/share/applications/`
   - Example: Zen Browser should appear if installed via Flatpak

5. **Missing Snap applications**
   - Verify Snap is installed: `snap version`
   - Check Snap apps are installed: `snap list`
   - Check desktop files exist: `ls /var/lib/snapd/desktop/applications/`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source. Feel free to modify and distribute as needed.

## Acknowledgments

- Built with [blessed](https://github.com/chjj/blessed) for the terminal UI
- Inspired by modern application launchers like dmenu and rofi 
