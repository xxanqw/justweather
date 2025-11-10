import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    property alias cfg_fullIconSize: fullIconSizeSpinBox.value
    property alias cfg_fullTempSize: fullTempSizeSpinBox.value
    property alias cfg_fullConditionSize: fullConditionSizeSpinBox.value
    property alias cfg_showFullIcon: showFullIconCheck.checked
    property alias cfg_showFullTemp: showFullTempCheck.checked
    property alias cfg_showCondition: showConditionCheck.checked
    property alias cfg_fullBoldTemp: fullBoldTempCheck.checked

    Kirigami.FormLayout {
        Layout.fillWidth: true

        QQC2.Label {
            Kirigami.FormData.label: "Desktop Widget View:"
            text: "Configure the appearance when widget is on desktop"
            font.bold: true
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Icon settings
        QQC2.SpinBox {
            id: fullIconSizeSpinBox
            Kirigami.FormData.label: "Icon size:"
            from: 48
            to: 256
            stepSize: 8
            
            textFromValue: function(value) {
                return value + " px"
            }
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Weather icon size in desktop mode"
        }

        QQC2.CheckBox {
            id: showFullIconCheck
            text: "Show weather icon"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Display weather icon in desktop widget"
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Temperature settings
        QQC2.SpinBox {
            id: fullTempSizeSpinBox
            Kirigami.FormData.label: "Temperature size:"
            from: 16
            to: 128
            stepSize: 4
            
            textFromValue: function(value) {
                return value + " px"
            }
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Temperature text size in desktop mode"
        }

        QQC2.CheckBox {
            id: showFullTempCheck
            text: "Show temperature"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Display temperature in desktop widget"
        }

        QQC2.CheckBox {
            id: fullBoldTempCheck
            text: "Bold temperature text"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Make temperature text bold"
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Condition settings
        QQC2.SpinBox {
            id: fullConditionSizeSpinBox
            Kirigami.FormData.label: "Weather condition size:"
            from: 10
            to: 32
            stepSize: 1
            
            textFromValue: function(value) {
                return value + " px"
            }
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Weather condition text size (e.g., 'Partly cloudy')"
        }

        QQC2.CheckBox {
            id: showConditionCheck
            text: "Show weather condition"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Display weather condition description"
        }

        Item {
            Kirigami.FormData.isSection: true
            height: Kirigami.Units.largeSpacing
        }

        // Info label
        QQC2.Label {
            Layout.fillWidth: true
            text: "These settings apply to the desktop widget view only. For panel/compact view, use the 'Compact View' tab."
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
            wrapMode: Text.WordWrap
        }
    }
}
