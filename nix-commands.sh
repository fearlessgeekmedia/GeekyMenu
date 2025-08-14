#!/usr/bin/env bash

# GeekyMenu Nix Commands Quick Reference
# Run this script to see all available Nix commands for GeekyMenu

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 GeekyMenu Nix Commands Quick Reference${NC}"
echo "============================================="
echo

echo -e "${GREEN}Basic Usage:${NC}"
echo -e "${CYAN}nix run .${NC}                          # Run GeekyMenu without installing"
echo -e "${CYAN}nix run . -- --debug${NC}              # Run in debug mode (shows app discovery)"
echo -e "${CYAN}nix run github:fearlessgeek/geekymenu${NC} # Run from GitHub directly"
echo -e "${CYAN}nix build${NC}                         # Build the package locally"
echo -e "${CYAN}nix develop${NC}                       # Enter development shell"
echo

echo -e "${GREEN}Installation:${NC}"
echo -e "${CYAN}nix profile install .${NC}             # Install to user profile"
echo -e "${CYAN}nix profile install github:fearlessgeek/geekymenu${NC} # Install from GitHub"
echo -e "${CYAN}nix profile list${NC}                  # List installed packages"
echo -e "${CYAN}nix profile remove geekymenu${NC}      # Remove from profile"
echo

echo -e "${GREEN}Development:${NC}"
echo -e "${CYAN}nix develop${NC}                       # Enter dev shell with Node.js"
echo -e "${CYAN}nix develop -c npm install${NC}        # Install deps in dev shell"
echo -e "${CYAN}nix develop -c npm start${NC}          # Run application in dev shell"
echo -e "${CYAN}nix develop -c bash${NC}               # Custom shell in dev environment"
echo

echo -e "${GREEN}Testing & Debugging:${NC}"
echo -e "${CYAN}nix run .#test-nixos-apps${NC}         # Test NixOS application discovery"
echo -e "${CYAN}nix run .#test-compatibility${NC}      # Test cross-platform compatibility"
echo -e "${CYAN}geekymenu --debug${NC}                 # Run with debug output"
echo -e "${CYAN}GEEKYMENU_DEBUG=1 geekymenu${NC}       # Debug via environment variable"
echo -e "${CYAN}node test-nixos-apps.js${NC}           # Local NixOS test script"
echo -e "${CYAN}node test-compatibility.js${NC}        # Local cross-platform test script"
echo

echo -e "${GREEN}Validation & Info:${NC}"
echo -e "${CYAN}nix flake check${NC}                   # Validate flake structure"
echo -e "${CYAN}nix flake show${NC}                    # Show flake outputs"
echo -e "${CYAN}nix flake metadata${NC}                # Show flake metadata"
echo -e "${CYAN}nix eval .#packages.x86_64-linux.default.meta${NC} # Show package info"
echo

echo -e "${GREEN}Advanced:${NC}"
echo -e "${CYAN}nix build --json${NC}                  # Build and output JSON info"
echo -e "${CYAN}nix build --print-build-logs${NC}      # Build with verbose output"
echo -e "${CYAN}nix path-info ./result${NC}            # Show store path info"
echo -e "${CYAN}nix-store --query --tree ./result${NC} # Show dependency tree"
echo

echo -e "${GREEN}Cross-platform:${NC}"
echo -e "${CYAN}nix build .#packages.aarch64-linux.default${NC} # Build for ARM64 Linux"
echo -e "${CYAN}nix flake show --all-systems${NC}      # Show all system outputs"
echo

echo -e "${GREEN}Cleanup:${NC}"
echo -e "${CYAN}nix-collect-garbage${NC}               # Clean up old builds"
echo -e "${CYAN}nix-collect-garbage -d${NC}            # Deep cleanup"
echo -e "${CYAN}rm -f result${NC}                      # Remove local build symlink"
echo

echo -e "${GREEN}NixOS Integration:${NC}"
echo "Add to configuration.nix:"
echo -e "${YELLOW}  inputs.geekymenu.url = \"github:fearlessgeek/geekymenu\";${NC}"
echo -e "${YELLOW}  imports = [ inputs.geekymenu.nixosModules.default ];${NC}"
echo -e "${YELLOW}  programs.geekymenu.enable = true;${NC}"
echo

echo -e "${GREEN}Home Manager Integration:${NC}"
echo "Add to home.nix:"
echo -e "${YELLOW}  inputs.geekymenu.url = \"github:fearlessgeek/geekymenu\";${NC}"
echo -e "${YELLOW}  imports = [ inputs.geekymenu.homeManagerModules.default ];${NC}"
echo -e "${YELLOW}  programs.geekymenu = {${NC}"
echo -e "${YELLOW}    enable = true;${NC}"
echo -e "${YELLOW}    keybinding = \"Super+space\";${NC}"
echo -e "${YELLOW}  };${NC}"
echo

echo -e "${GREEN}Troubleshooting:${NC}"
echo -e "${CYAN}nix doctor${NC}                        # Check Nix installation"
echo -e "${CYAN}nix-shell -p nodejs_22 npm${NC}        # Quick Node.js environment"
echo -e "${CYAN}nix develop --ignore-environment${NC}   # Clean development environment"
echo

echo -e "${GREEN}Platform-specific:${NC}"
echo -e "${CYAN}nix run .#test-nixos-apps${NC}         # Test app discovery on NixOS"
echo -e "${CYAN}nix run .#test-compatibility${NC}      # Test all platforms (Flatpak/Snap/Nix)"
echo -e "${CYAN}ls /run/current-system/sw/share/applications${NC} # Check NixOS system apps"
echo -e "${CYAN}ls /var/lib/flatpak/exports/share/applications${NC} # Check Flatpak apps"
echo -e "${CYAN}ls ~/.nix-profile/share/applications${NC} # Check user profile apps"
echo -e "${CYAN}nix-env -iA nixpkgs.firefox${NC}       # Install test application"
echo -e "${CYAN}flatpak install org.mozilla.firefox${NC} # Install Flatpak application"
echo

echo -e "${BLUE}For more details, see:${NC}"
echo "  📖 README.md - General usage and installation"
echo "  📚 NIX.md - Comprehensive Nix guide"
echo "  🧪 ./nix-demo.sh - Interactive demonstration"
echo "  🔧 ./test-compatibility.js - Cross-platform compatibility test"
echo "  📋 examples/flake-template.nix - Integration examples"
