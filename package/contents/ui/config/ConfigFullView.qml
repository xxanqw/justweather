import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import ".." as JustWeather

KCM.SimpleKCM {
    id: root

    property alias cfg_fullIconSize: fullIconSizeSpinBox.value
    property alias cfg_fullTempSize: fullTempSizeSpinBox.value
    property alias cfg_fullConditionSize: fullConditionSizeSpinBox.value
    property alias cfg_showFullIcon: showFullIconCheck.checked
    property alias cfg_showFullTemp: showFullTempCheck.checked
    property alias cfg_showCondition: showConditionCheck.checked
    property alias cfg_fullBoldTemp: fullBoldTempCheck.checked

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

        QQC2.Label {
            Kirigami.FormData.label: i18n("Desktop Widget View:")
            text: i18n("Configure the appearance when widget is on desktop")
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
            Kirigami.FormData.label: i18n("Icon size:")
            from: 48
            to: 256
            stepSize: 8
            
            textFromValue: function(value) {
                return i18n("%1 px", value)
            }
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Weather icon size in desktop mode")
        }

        QQC2.CheckBox {
            id: showFullIconCheck
            text: i18n("Show weather icon")
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Display weather icon in desktop widget")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Temperature settings
        QQC2.SpinBox {
            id: fullTempSizeSpinBox
            Kirigami.FormData.label: i18n("Temperature size:")
            from: 16
            to: 128
            stepSize: 4
            
            textFromValue: function(value) {
                return i18n("%1 px", value)
            }
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Temperature text size in desktop mode")
        }

        QQC2.CheckBox {
            id: showFullTempCheck
            text: i18n("Show temperature")
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Display temperature in desktop widget")
        }

        QQC2.CheckBox {
            id: fullBoldTempCheck
            text: i18n("Bold temperature text")
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Make temperature text bold")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // Condition settings
        QQC2.SpinBox {
            id: fullConditionSizeSpinBox
            Kirigami.FormData.label: i18n("Weather condition size:")
            from: 10
            to: 32
            stepSize: 1
            
            textFromValue: function(value) {
                return i18n("%1 px", value)
            }
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Weather condition text size (e.g., 'Partly cloudy')")
        }

        QQC2.CheckBox {
            id: showConditionCheck
            text: i18n("Show weather condition")
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Display weather condition description")
        }

        Item {
            Kirigami.FormData.isSection: true
            height: Kirigami.Units.largeSpacing
        }

        // Info label
        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("These settings apply to the desktop widget view only. For panel/compact view, use the 'Compact View' tab.")
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
            wrapMode: Text.WordWrap
        }
    }
}
