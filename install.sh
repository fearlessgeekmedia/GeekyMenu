#!/bin/bash

# GeekyMenu Installation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing GeekyMenu...${NC}"

# Check if binary exists
if [ ! -f "dist/geekymenu" ]; then
    echo -e "${RED}Error: Binary not found. Please run 'npm run build-linux' first.${NC}"
    exit 1
fi

# Determine installation directory
if [ "$EUID" -eq 0 ]; then
    # Root user - install system-wide
    INSTALL_DIR="/usr/local/bin"
else
    # Regular user - install to user's bin directory
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

# Copy binary
echo -e "${YELLOW}Copying binary to $INSTALL_DIR...${NC}"
cp dist/geekymenu "$INSTALL_DIR/"

# Make executable
chmod +x "$INSTALL_DIR/geekymenu"

echo -e "${GREEN}✓ GeekyMenu installed successfully!${NC}"
echo -e "${YELLOW}You can now run 'geekymenu' from anywhere.${NC}"

# Add to PATH if not already there (for user installations)
if [ "$EUID" -ne 0 ] && [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}Note: You may need to add $INSTALL_DIR to your PATH.${NC}"
    echo -e "${YELLOW}Add this line to your shell profile (.bashrc, .zshrc, etc.):${NC}"
    echo -e "${GREEN}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
fi 