#!/bin/bash

# JustWeather Plasma Widget Uninstaller

set -e

WIDGET_NAME="com.github.justweather"

echo "========================================"
echo "  JustWeather Widget Uninstaller"
echo "========================================"
echo ""

read -p "Are you sure you want to uninstall JustWeather? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstalling JustWeather widget..."
    if kpackagetool6 -t Plasma/Applet -r $WIDGET_NAME; then
        echo ""
        echo "✓ Uninstallation successful!"
        echo ""
        echo "Note: Widget instances may still appear on your panel/desktop"
        echo "until you restart plasmashell or log out/in."
        echo ""
        echo "To restart plasmashell now, run:"
        echo "killall plasmashell && plasmashell &"
        echo ""
    else
        echo ""
        echo "✗ Uninstallation failed or widget was not installed"
        exit 1
    fi
else
    echo "Uninstallation cancelled."
    exit 0
fi
