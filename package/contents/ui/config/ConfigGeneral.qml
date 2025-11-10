import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    property alias cfg_location: locationField.text
    property alias cfg_temperatureUnit: tempUnitCombo.currentIndex
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_showBackground: showBackgroundCheck.checked
    property alias cfg_compactMode: compactModeCheck.checked

    Kirigami.FormLayout {
        Layout.fillWidth: true

        // Location settings
        RowLayout {
            Kirigami.FormData.label: "Location:"
            Layout.fillWidth: true

            QQC2.TextField {
                id: locationField
                Layout.fillWidth: true
                placeholderText: "City name, ZIP code, or coordinates"
                
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: "Enter city name (e.g., 'London'), ZIP code (e.g., '10001'), or coordinates (e.g., '51.5074,-0.1278')"
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Temperature unit
        QQC2.ComboBox {
            id: tempUnitCombo
            Kirigami.FormData.label: "Temperature unit:"
            model: ["°C", "°F"]
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Choose between Celsius and Fahrenheit"
        }

        // Update interval
        QQC2.SpinBox {
            id: updateIntervalSpinBox
            Kirigami.FormData.label: "Update interval (minutes):"
            from: 5
            to: 120
            stepSize: 5
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "How often to refresh weather data (5-120 minutes)"
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Display options
        QQC2.CheckBox {
            id: showBackgroundCheck
            Kirigami.FormData.label: "Display:"
            text: "Show widget background"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Show/hide the widget background panel"
        }

        QQC2.CheckBox {
            id: compactModeCheck
            text: "Use compact mode"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Use compact view as default (recommended for panel)"
        }

        Item {
            Kirigami.FormData.isSection: true
            height: Kirigami.Units.largeSpacing
        }

        // Info label
        QQC2.Label {
            Layout.fillWidth: true
            text: "Weather data provided by wttr.in"
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
            wrapMode: Text.WordWrap
        }
    }
}
