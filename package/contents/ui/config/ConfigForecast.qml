import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import ".." as JustWeather

KCM.SimpleKCM {
    id: root

    property alias cfg_showHourlyForecast: showHourlyForecastCheck.checked
    property alias cfg_hourlyForecastHours: hourlyForecastHoursSpinBox.value
    property alias cfg_hourlyForecastStep: hourlyForecastStepSpinBox.value
    property alias cfg_hourlyTemperatureMode: hourlyTemperatureModeCombo.currentIndex
    property alias cfg_showHourlyIcons: showHourlyIconsCheck.checked
    property alias cfg_showHourlyPrecipitation: showHourlyPrecipitationCheck.checked
    property alias cfg_showDailyForecast: showDailyForecastCheck.checked
    property alias cfg_forecastDays: forecastDaysSpinBox.value
    property alias cfg_forecastIncludesToday: forecastIncludesTodayCheck.checked
    property alias cfg_dailyTemperatureMode: dailyTemperatureModeCombo.currentIndex
    property alias cfg_showDailyIcons: showDailyIconsCheck.checked
    property alias cfg_showDailyPrecipitation: showDailyPrecipitationCheck.checked

    function i18n(message, arg1, arg2, arg3) {
        return localization.text(message, arg1, arg2, arg3)
    }

    function i18np(singular, plural, count) {
        return localization.plural(singular, plural, count)
    }

    LayoutMirroring.enabled: localization.rightToLeft
    LayoutMirroring.childrenInherit: true

    JustWeather.Localization {
        id: localization
        language: plasmoid.configuration.language
    }

    Kirigami.FormLayout {
        Layout.fillWidth: true

        QQC2.CheckBox {
            id: showHourlyForecastCheck
            Kirigami.FormData.label: i18n("Hourly forecast:")
            text: i18n("Show weather changes during the day")
        }

        QQC2.SpinBox {
            id: hourlyForecastHoursSpinBox
            Kirigami.FormData.label: i18n("Forecast horizon:")
            from: 3
            to: 24
            enabled: showHourlyForecastCheck.checked

            textFromValue: function(value) {
                return i18np("%1 hour", "%1 hours", value)
            }
        }

        QQC2.SpinBox {
            id: hourlyForecastStepSpinBox
            Kirigami.FormData.label: i18n("Display interval:")
            from: 1
            to: 6
            enabled: showHourlyForecastCheck.checked

            textFromValue: function(value) {
                return i18np("Every %1 hour", "Every %1 hours", value)
            }
        }

        QQC2.ComboBox {
            id: hourlyTemperatureModeCombo
            Kirigami.FormData.label: i18n("Temperature:")
            model: [i18n("Actual"), i18n("Feels like")]
            enabled: showHourlyForecastCheck.checked
        }

        QQC2.CheckBox {
            id: showHourlyIconsCheck
            text: i18n("Show condition icons")
            enabled: showHourlyForecastCheck.checked
        }

        QQC2.CheckBox {
            id: showHourlyPrecipitationCheck
            text: i18n("Show precipitation probability")
            enabled: showHourlyForecastCheck.checked
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: showDailyForecastCheck
            Kirigami.FormData.label: i18n("Daily forecast:")
            text: i18n("Show multi-day forecast")
        }

        QQC2.SpinBox {
            id: forecastDaysSpinBox
            Kirigami.FormData.label: i18n("Number of days:")
            from: 3
            to: 7
            enabled: showDailyForecastCheck.checked
        }

        QQC2.CheckBox {
            id: forecastIncludesTodayCheck
            text: i18n("Include today")
            enabled: showDailyForecastCheck.checked
        }

        QQC2.ComboBox {
            id: dailyTemperatureModeCombo
            Kirigami.FormData.label: i18n("Temperature range:")
            model: [i18n("Actual"), i18n("Feels like")]
            enabled: showDailyForecastCheck.checked
        }

        QQC2.CheckBox {
            id: showDailyIconsCheck
            text: i18n("Show condition icons")
            enabled: showDailyForecastCheck.checked
        }

        QQC2.CheckBox {
            id: showDailyPrecipitationCheck
            text: i18n("Show precipitation probability")
            enabled: showDailyForecastCheck.checked
        }

        Item {
            Kirigami.FormData.isSection: true
            height: Kirigami.Units.largeSpacing
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Forecast sections appear only in the expanded and desktop views. They are disabled by default to preserve the minimal layout. Forecast data provided by Open-Meteo.")
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
            wrapMode: Text.WordWrap
        }
    }
}
