#!/bin/bash

# JustWeather Plasmoid Packaging Script
# Creates a .plasmoid file for distribution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/package"
BUILD_DIR="$SCRIPT_DIR/build"
WIDGET_NAME="justweather"

echo "========================================"
echo "  JustWeather Plasmoid Packager"
echo "========================================"
echo ""

# Check if package directory exists
if [ ! -d "$PACKAGE_DIR" ]; then
    echo "Error: Package directory not found at $PACKAGE_DIR"
    exit 1
fi

# Read version from metadata.json
VERSION=$(grep -oP '"Version":\s*"\K[^"]+' "$PACKAGE_DIR/metadata.json" || echo "1.0")
echo "📦 Packaging version: $VERSION"
echo ""

# Create build directory
echo "Creating build directory..."
mkdir -p "$BUILD_DIR"

# Clean old builds
echo "Cleaning old builds..."
rm -f "$BUILD_DIR"/*.plasmoid

# Create the plasmoid file
PLASMOID_FILE="$BUILD_DIR/${WIDGET_NAME}-${VERSION}.plasmoid"

echo "Creating plasmoid archive..."
cd "$PACKAGE_DIR"
zip -r "$PLASMOID_FILE" . -x "*.git*" -x "*~" -x "*.swp"

echo ""
echo "✓ Success!"
echo ""
echo "Package created: $PLASMOID_FILE"
echo "Size: $(du -h "$PLASMOID_FILE" | cut -f1)"
echo ""
echo "To install:"
echo "  kpackagetool6 -t Plasma/Applet -i $PLASMOID_FILE"
echo ""
echo "Or double-click the .plasmoid file in Dolphin!"
echo ""
