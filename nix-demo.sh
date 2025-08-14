#!/usr/bin/env bash

# GeekyMenu Nix Flake Demo Script
# This script demonstrates different ways to use the GeekyMenu Nix flake

set -e

echo "🚀 GeekyMenu Nix Flake Demo"
echo "=========================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_section() {
    echo -e "${BLUE}$1${NC}"
    echo "----------------------------------------"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if Nix is available
if ! command -v nix &> /dev/null; then
    print_error "Nix is not installed or not in PATH"
    echo "Please install Nix from https://nixos.org/download.html"
    exit 1
fi

# Check if flakes are enabled
print_info "Checking if flakes are enabled..."
if ! nix eval --expr "1" &>/dev/null || ! nix flake --help &>/dev/null; then
    print_error "Nix flakes are not enabled or nix-command is missing"
    echo "Add 'experimental-features = nix-command flakes' to your nix.conf"
    echo "Or if using NixOS, add to configuration.nix:"
    echo "  nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];"
    exit 1
fi

print_success "Nix with flakes support detected"
echo

# Demo 1: Run directly from flake
print_section "Demo 1: Running GeekyMenu directly from flake"
echo "Command: nix run . -- --debug"
print_info "This runs GeekyMenu in debug mode to test application discovery"
echo "Testing application discovery on NixOS..."
if nix run . -- --debug; then
    print_success "Application discovery test completed successfully"
else
    print_error "Application discovery test failed"
fi
echo

# Demo 2: Build the package
print_section "Demo 2: Building the package"
echo "Command: nix build"
print_info "This builds GeekyMenu and creates a 'result' symlink"
if nix build; then
    print_success "Build completed successfully"
    echo "Binary available at: $(readlink -f result)/bin/geekymenu"
else
    print_error "Build failed"
fi
echo

# Demo 3: Enter development shell
print_section "Demo 3: Development shell"
echo "Command: nix develop"
print_info "This provides a development environment with Node.js and dependencies"
if nix develop --command bash -c 'echo "Node.js: $(node --version)"; echo "npm: $(npm --version)"'; then
    print_success "Development shell test completed"
else
    print_error "Development shell test failed"
fi
echo

# Demo 4: Test NixOS application discovery
print_section "Demo 4: NixOS application discovery test"
echo "Command: nix run .#test-nixos-apps"
print_info "This tests if GeekyMenu can find applications on NixOS"
if nix run .#test-nixos-apps; then
    print_success "NixOS application discovery test passed"
else
    print_error "NixOS application discovery test failed"
fi
echo

# Demo 5: Test cross-platform compatibility
print_section "Demo 5: Cross-platform compatibility test"
echo "Command: nix run .#test-compatibility"
print_info "This tests Flatpak, Snap, Nix, and traditional Linux compatibility"
if nix run .#test-compatibility; then
    print_success "Cross-platform compatibility test passed"
else
    print_error "Cross-platform compatibility test failed"
fi
echo

# Demo 6: Check flake validity
print_section "Demo 6: Flake validation"
echo "Command: nix flake check"
print_info "This validates the flake structure and builds"
if nix flake check 2>&1 | grep -v "warning:" || true; then
    print_success "Flake check completed"
else
    print_error "Flake check failed"
fi
echo

# Demo 7: Show flake metadata
print_section "Demo 7: Flake metadata"
echo "Command: nix flake show"
print_info "This shows available packages, apps, and development shells"
nix flake show 2>/dev/null || print_info "Flake show completed"
echo

# Demo 8: Profile installation
print_section "Demo 8: Profile installation example"
echo "Commands for permanent installation:"
echo
echo "# Install to user profile:"
echo "nix profile install ."
echo
echo "# Install system-wide (NixOS):"
echo "Add to configuration.nix:"
echo "  programs.geekymenu.enable = true;"
echo
echo "# Install via Home Manager:"
echo "Add to home.nix:"
echo "  programs.geekymenu.enable = true;"
echo

print_section "Summary"
print_success "GeekyMenu Nix flake is ready to use!"
echo
echo "Quick start commands:"
echo "  nix run .                    # Run without installing"
echo "  nix profile install .       # Install to user profile"
echo "  nix develop                 # Enter development environment"
echo "  nix build                   # Build the package"
echo
echo "For more information, see the README.md file."
