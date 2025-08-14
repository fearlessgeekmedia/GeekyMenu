# GeekyMenu Nix Usage Guide

This document provides comprehensive information about using GeekyMenu with Nix and NixOS.

## Quick Start

```bash
# Run directly without installing
nix run github:fearlessgeek/geekymenu

# Install to your profile
nix profile install github:fearlessgeek/geekymenu

# Enter development environment
nix develop github:fearlessgeek/geekymenu
```

## Installation Methods

### 1. Direct Run (No Installation)

Perfect for trying out GeekyMenu without permanent installation:

```bash
nix run github:fearlessgeek/geekymenu
```

### 2. User Profile Installation

Install GeekyMenu to your user profile:

```bash
# From GitHub
nix profile install github:fearlessgeek/geekymenu

# From local clone
git clone https://github.com/fearlessgeek/geekymenu
cd geekymenu
nix profile install .

# List installed packages
nix profile list

# Remove if needed
nix profile remove geekymenu
```

### 3. NixOS System Configuration

Add GeekyMenu system-wide on NixOS:

```nix
# configuration.nix
{ config, pkgs, ... }:

{
  # Option 1: Direct package installation
  environment.systemPackages = [
    (pkgs.callPackage (builtins.fetchGit {
      url = "https://github.com/fearlessgeek/geekymenu";
      rev = "main";  # or specific commit
    }) {})
  ];

  # Option 2: Using the flake input (recommended)
  # Add to your flake.nix inputs:
  # inputs.geekymenu.url = "github:fearlessgeek/geekymenu";
  # Then in your configuration:
  # imports = [ inputs.geekymenu.nixosModules.default ];
  # programs.geekymenu.enable = true;
}
```

### 4. Home Manager Configuration

Install GeekyMenu per-user with Home Manager:

```nix
# home.nix
{ config, pkgs, ... }:

{
  # Option 1: Direct package installation
  home.packages = [
    (pkgs.callPackage (builtins.fetchGit {
      url = "https://github.com/fearlessgeek/geekymenu";
      rev = "main";
    }) {})
  ];

  # Option 2: Using the flake module (recommended)
  # Add to your flake.nix inputs:
  # inputs.geekymenu.url = "github:fearlessgeek/geekymenu";
  # Then in your home configuration:
  # imports = [ inputs.geekymenu.homeManagerModules.default ];
  # programs.geekymenu = {
  #   enable = true;
  #   keybinding = "Super+space";
  # };
}
```

## Flake Structure

The GeekyMenu flake provides the following outputs:

### Packages

- `packages.default` - The GeekyMenu package
- `packages.geekymenu` - Alias for the default package

### Apps

- `apps.default` - Run GeekyMenu directly
- `apps.geekymenu` - Alias for the default app

### Development Shells

- `devShells.default` - Development environment with Node.js 22 and tools

### Modules

- `nixosModules.default` - NixOS system module
- `homeManagerModules.default` - Home Manager user module

## Development

### Setting Up Development Environment

```bash
# Clone the repository
git clone https://github.com/fearlessgeek/geekymenu
cd geekymenu

# Enter development shell
nix develop

# The shell provides:
# - Node.js 22
# - npm package manager
# - npm-check-updates for dependency management
```

### Development Commands

Inside the development shell:

```bash
# Install project dependencies
npm install

# Run the application
npm start
# or
node geekymenu.js

# Check for dependency updates
ncu

# Test the Nix build
nix build

# Run Nix checks
nix flake check
```

### Building Locally

```bash
# Build the package
nix build

# The binary will be available at:
./result/bin/geekymenu

# You can also run it with:
nix run .
```

## Window Manager Integration

### i3wm

Add to `~/.config/i3/config`:

```
# Launch GeekyMenu with Super+Space
bindsym $mod+space exec --no-startup-id geekymenu

# Or if installed via Nix profile:
bindsym $mod+space exec --no-startup-id ~/.nix-profile/bin/geekymenu

# Or using the result directly:
bindsym $mod+space exec --no-startup-id /path/to/geekymenu/result/bin/geekymenu
```

### sway

Add to `~/.config/sway/config`:

```
# Launch GeekyMenu with Super+Space
bindsym $mod+space exec geekymenu

# Or with full path:
bindsym $mod+space exec ~/.nix-profile/bin/geekymenu
```

### Other Window Managers

For window managers that support custom keybindings, use:

```bash
# Command to bind:
geekymenu

# Or full path if not in PATH:
~/.nix-profile/bin/geekymenu
```

## Advanced Nix Usage

### Pinning to Specific Version

```nix
# Pin to specific commit
inputs.geekymenu.url = "github:fearlessgeek/geekymenu/abc123def456";

# Pin to specific tag
inputs.geekymenu.url = "github:fearlessgeek/geekymenu/v1.0.0";
```

### Using in Nix Shells

Create a `shell.nix` for temporary environments:

```nix
# shell.nix
let
  pkgs = import <nixpkgs> {};
  geekymenu = pkgs.callPackage (builtins.fetchGit {
    url = "https://github.com/fearlessgeek/geekymenu";
  }) {};
in
pkgs.mkShell {
  buildInputs = [ geekymenu ];
}
```

### Overriding Package Attributes

```nix
# Override version or other attributes
let
  geekymenu = inputs.geekymenu.packages.${system}.default.overrideAttrs (old: {
    version = "custom-1.0.0";
    # other overrides...
  });
in
{
  environment.systemPackages = [ geekymenu ];
}
```

## Troubleshooting

### Common Issues

1. **"experimental-features" error**
   - Enable flakes: `echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf`

2. **"Git tree is dirty" warning**
   - This is harmless but means you have uncommitted changes
   - Commit your changes or use `--impure` flag

3. **Build fails with hash mismatch**
   - This usually means dependencies have changed
   - Update the `npmDepsHash` in `flake.nix` with the suggested value

4. **Package not found in PATH after profile install**
   - Make sure `~/.nix-profile/bin` is in your PATH
   - Add to your shell config: `export PATH="$HOME/.nix-profile/bin:$PATH"`

5. **No applications found on NixOS**
   - This is fixed in GeekyMenu v1.1.0+ which includes NixOS compatibility
   - Test application discovery: `node test-nixos-apps.js`
   - Install some applications if none exist: `nix-env -iA nixpkgs.firefox nixpkgs.chromium`
   - Check system applications: `ls /run/current-system/sw/share/applications/`
   - Check user applications: `ls ~/.nix-profile/share/applications/`

### Debug Building

```bash
# Build with verbose output
nix build --print-build-logs

# Check what's in the built package
nix-store --query --tree ./result

# Get detailed build information
nix show-derivation
```

### Testing the Package

```bash
# Quick test that binary exists and is executable
nix build && test -x result/bin/geekymenu && echo "Binary is executable"

# Test in a minimal environment
nix run --ignore-environment . 

# Test NixOS application discovery (multiple options)
node test-nixos-apps.js                    # Local test script
nix run .#test-nixos-apps                  # Nix flake test
geekymenu --debug                          # Built-in debug mode
GEEKYMENU_DEBUG=1 geekymenu               # Environment variable debug
```

### NixOS-specific Testing

GeekyMenu v1.1.0+ includes NixOS compatibility fixes. Use these commands to test and debug:

```bash
# Test application discovery with debug mode
nix run . -- --debug

# Test with dedicated test script
nix run .#test-nixos-apps

# Check what applications are available in NixOS paths
ls /run/current-system/sw/share/applications/ | wc -l          # System apps
ls ~/.nix-profile/share/applications/ | wc -l                  # User profile apps
ls /etc/profiles/per-user/$USER/share/applications/ | wc -l    # Per-user apps

# Install test applications if needed
nix-env -iA nixpkgs.firefox nixpkgs.chromium nixpkgs.thunderbird

# System-wide installation (add to configuration.nix)
# environment.systemPackages = [ pkgs.firefox pkgs.chromium ];

# Verify the fix works
nix run . # Should now show applications on NixOS
```

### NixOS Application Discovery Paths

GeekyMenu scans these NixOS-specific directories:

```bash
# System-wide applications (NixOS)
/run/current-system/sw/share/applications/

# Per-user profile applications
/etc/profiles/per-user/$USER/share/applications/

# User Nix profile applications
~/.nix-profile/share/applications/
~/.local/state/nix/profiles/profile/share/applications/

# Traditional paths (for compatibility)
/usr/share/applications/
/usr/local/share/applications/
~/.local/share/applications/
```

### Common NixOS Issues and Solutions

```bash
# Issue: "No matches" on NixOS
# Solution: Install GUI applications
nix-env -iA nixpkgs.firefox nixpkgs.thunderbird nixpkgs.libreoffice

# Issue: Applications installed but not showing
# Solution: Check if .desktop files exist
find /run/current-system/sw/share/applications/ -name "firefox*"

# Issue: Using old version without NixOS support
# Solution: Ensure you're using v1.1.0+
geekymenu --debug | head -5  # Should show debug output

# Issue: Applications in non-standard locations
# Solution: Check all Nix profile paths
find ~/.nix-profile ~/.local/state/nix /run/current-system -name "*.desktop" 2>/dev/null | head -10
```

## Contributing to the Nix Flake

If you want to improve the Nix flake:

1. **Update dependencies**: Modify `package.json`, run `npm install`, then update `npmDepsHash`
2. **Add new features**: Update the package derivation in `flake.nix`
3. **Improve modules**: Enhance the NixOS or Home Manager modules
4. **Test thoroughly**: Run `nix flake check` and the demo script

### Updating npmDepsHash

When dependencies change:

```bash
# 1. Update package.json
# 2. Run npm install to update package-lock.json
npm install

# 3. Try building with dummy hash to get real hash
sed -i 's/npmDepsHash = .*/npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";/' flake.nix

# 4. Build and copy the suggested hash
nix build 2>&1 | grep "got:" | awk '{print $2}'

# 5. Update flake.nix with the real hash
```

## Related Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - In-depth Nix tutorial
- [buildNpmPackage documentation](https://nixos.org/manual/nixpkgs/stable/#javascript-nodejs)

## License

This Nix flake is released under the same MIT license as GeekyMenu itself.