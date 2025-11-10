import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    property alias cfg_iconStyle: iconStyleCombo.currentIndex
    property alias cfg_iconSize: iconSizeSpinBox.value
    property alias cfg_showIcon: showIconCheck.checked
    property alias cfg_showTemperature: showTempCheck.checked
    property alias cfg_fontSize: fontSizeSpinBox.value
    property alias cfg_boldFont: boldFontCheck.checked

    Kirigami.FormLayout {
        Layout.fillWidth: true

        // Icon settings
        QQC2.ComboBox {
            id: iconStyleCombo
            Kirigami.FormData.label: "Icon style:"
            model: ["fill", "line"]
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Choose between filled or line icons"
        }

        QQC2.SpinBox {
            id: iconSizeSpinBox
            Kirigami.FormData.label: "Icon size (compact):"
            from: 16
            to: 64
            stepSize: 2
            
            textFromValue: function(value) {
                return value + " px"
            }
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Icon size in compact/panel mode"
        }

        QQC2.CheckBox {
            id: showIconCheck
            text: "Show icon in compact mode"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Display weather icon when widget is in panel"
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Text settings
        QQC2.SpinBox {
            id: fontSizeSpinBox
            Kirigami.FormData.label: "Font size (compact):"
            from: 8
            to: 32
            stepSize: 1
            
            textFromValue: function(value) {
                return value + " pt"
            }
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Temperature text size in compact/panel mode"
        }

        QQC2.CheckBox {
            id: showTempCheck
            text: "Show temperature in compact mode"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Display temperature when widget is in panel"
        }

        QQC2.CheckBox {
            id: boldFontCheck
            text: "Use bold font"
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Make temperature text bold"
        }

        Item {
            Kirigami.FormData.isSection: true
            height: Kirigami.Units.largeSpacing
        }

        // Preview section
        Kirigami.Separator {
            Layout.fillWidth: true
        }

        QQC2.Label {
            Kirigami.FormData.label: "Preview:"
            text: "Compact mode preview:"
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "weather-clear"
                Layout.preferredWidth: iconSizeSpinBox.value
                Layout.preferredHeight: iconSizeSpinBox.value
                visible: showIconCheck.checked
            }

            QQC2.Label {
                text: "23°C"
                font.pixelSize: fontSizeSpinBox.value
                font.bold: boldFontCheck.checked
                visible: showTempCheck.checked
            }
        }
    }
}
