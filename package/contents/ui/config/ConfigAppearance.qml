import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import ".." as JustWeather

KCM.SimpleKCM {
    id: root

    property alias cfg_iconStyle: iconStyleCombo.currentIndex
    property alias cfg_iconSize: iconSizeSpinBox.value
    property alias cfg_showIcon: showIconCheck.checked
    property alias cfg_showTemperature: showTempCheck.checked
    property alias cfg_compactTemperatureMode: compactTemperatureModeCombo.currentIndex
    property alias cfg_fontSize: fontSizeSpinBox.value
    property alias cfg_boldFont: boldFontCheck.checked

    function i18n(message, arg1, arg2, arg3) {
        return localization.text(message, arg1, arg2, arg3)
    }

    LayoutMirroring.enabled: localization.rightToLeft
    LayoutMirroring.childrenInherit: true

    JustWeather.Localization {
        id: localization
        language: plasmoid.configuration.language
    }

    Kirigami.FormLayout {
        Layout.fillWidth: true

        // Icon settings
        QQC2.ComboBox {
            id: iconStyleCombo
            Kirigami.FormData.label: i18n("Icon style:")
            model: [i18n("Fill"), i18n("Line")]

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Choose between filled or line icons")
        }

        QQC2.SpinBox {
            id: iconSizeSpinBox
            Kirigami.FormData.label: i18n("Icon size (compact):")
            from: 16
            to: 64
            stepSize: 2

            textFromValue: function(value) {
                return i18n("%1 px", value)
            }

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Icon size in compact/panel mode")
        }

        QQC2.CheckBox {
            id: showIconCheck
            text: i18n("Show icon in compact mode")

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Display weather icon when widget is in panel")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Text settings
        QQC2.ComboBox {
            id: compactTemperatureModeCombo
            Kirigami.FormData.label: i18n("Temperature value:")
            model: [i18n("Actual"), i18n("Feels like")]

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Choose which temperature is shown in compact mode")
        }

        QQC2.SpinBox {
            id: fontSizeSpinBox
            Kirigami.FormData.label: i18n("Font size (compact):")
            from: 8
            to: 32
            stepSize: 1

            textFromValue: function(value) {
                return i18n("%1 pt", value)
            }

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Temperature text size in compact/panel mode")
        }

        QQC2.CheckBox {
            id: showTempCheck
            text: i18n("Show temperature in compact mode")

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Display temperature when widget is in panel")
        }

        QQC2.CheckBox {
            id: boldFontCheck
            text: i18n("Use bold font")

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Make temperature text bold")
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
            Kirigami.FormData.label: i18n("Preview:")
            text: i18n("Compact mode preview:")
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
                text: compactTemperatureModeCombo.currentIndex === 1 ? "21°C" : "23°C"
                font.pixelSize: fontSizeSpinBox.value
                font.bold: boldFontCheck.checked
                visible: showTempCheck.checked
            }
        }
    }
}
