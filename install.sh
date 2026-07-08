#!/bin/bash

# JustWeather Plasma Widget Installer
# This script installs the JustWeather widget for KDE Plasma 6

set -e

WIDGET_NAME="com.github.justweather"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/package"

echo "========================================"
echo "  JustWeather Widget Installer"
echo "========================================"
echo ""

# Check if running Plasma 6
    if ! plasmashell --version | grep -q "plasmashell 6"; then
        echo "Warning: This widget is designed for KDE Plasma 6"
        echo "Current version:"
        plasmashell --version
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
fi

# Check if package directory exists
if [ ! -d "$PACKAGE_DIR" ]; then
    echo "Error: Package directory not found at $PACKAGE_DIR"
    exit 1
fi

# Remove old installation if exists
echo "Removing old installation (if exists)..."
rm -rf "$HOME/.local/share/plasma/plasmoids/pp.ua.xxanqw.justweather"
kpackagetool6 -t Plasma/Applet -r $WIDGET_NAME 2>/dev/null || true

# Install translations (pre-compiled .mo files)
TRANSLATE_DIR="$PACKAGE_DIR/translate"
if [ -d "$TRANSLATE_DIR" ]; then
    echo "Installing translations..."
    for mo_file in "$TRANSLATE_DIR"/*/LC_MESSAGES/*.mo; do
        if [ -f "$mo_file" ]; then
            locale_dir=$(basename "$(dirname "$(dirname "$mo_file")")")
            target_dir="$HOME/.local/share/locale/$locale_dir/LC_MESSAGES"
            mkdir -p "$target_dir"
            cp "$mo_file" "$target_dir/plasma_applet_pp.ua.xxanqw.justweather.mo"
            echo "  Installed $locale_dir translation"
        fi
    done
fi

# Install the widget
echo "Installing JustWeather widget..."
if kpackagetool6 -t Plasma/Applet -i "$PACKAGE_DIR"; then
    echo ""
    echo "✓ Installation successful!"
    echo ""
    echo "To use the widget:"
    echo "1. Right-click on your panel or desktop"
    echo "2. Select 'Add Widgets'"
    echo "3. Search for 'JustWeather'"
    echo "4. Click to add it to your panel or desktop"
    echo ""
    echo "Don't forget to configure your location in widget settings!"
    echo ""
else
    echo ""
    echo "✗ Installation failed!"
    echo ""
    echo "Try manually with:"
    echo "kpackagetool6 -t Plasma/Applet -i $PACKAGE_DIR"
    exit 1
fi
