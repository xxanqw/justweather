import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    property alias cfg_location: locationField.text
    property alias cfg_autoLocation: autoLocationCheck.checked
    property alias cfg_temperatureUnit: tempUnitCombo.currentIndex
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_showBackground: showBackgroundCheck.checked
    property alias cfg_compactMode: compactModeCheck.checked

    Kirigami.FormLayout {
        Layout.fillWidth: true

        QQC2.CheckBox {
            id: autoLocationCheck
            Kirigami.FormData.label: i18n("Location:")
            text: i18n("Detect automatically")

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Use wttr.in IP-based location detection")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Manual location:")
            Layout.fillWidth: true

            QQC2.TextField {
                id: locationField
                Layout.fillWidth: true
                enabled: !autoLocationCheck.checked
                placeholderText: i18n("City name, ZIP code, or coordinates")

                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: i18n("Enter city name (e.g., 'London'), ZIP code (e.g., '10001'), or coordinates (e.g., '51.5074,-0.1278')")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Temperature unit
        QQC2.ComboBox {
            id: tempUnitCombo
            Kirigami.FormData.label: i18n("Temperature unit:")
            model: ["°C", "°F"]

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Choose between Celsius and Fahrenheit")
        }

        // Update interval
        QQC2.SpinBox {
            id: updateIntervalSpinBox
            Kirigami.FormData.label: i18n("Update interval (minutes):")
            from: 5
            to: 120
            stepSize: 5

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("How often to refresh weather data (5-120 minutes)")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Display options
        QQC2.CheckBox {
            id: showBackgroundCheck
            Kirigami.FormData.label: i18n("Display:")
            text: i18n("Show widget background")

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Show/hide the widget background panel")
        }

        QQC2.CheckBox {
            id: compactModeCheck
            text: i18n("Use compact mode")

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Use compact view as default (recommended for panel)")
        }

        Item {
            Kirigami.FormData.isSection: true
            height: Kirigami.Units.largeSpacing
        }

        // Info label
        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Weather data provided by wttr.in")
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
            wrapMode: Text.WordWrap
        }
    }
}
