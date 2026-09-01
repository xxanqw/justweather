import QtQuick
import org.kde.plasma.configuration
import "../ui" as JustWeather

ConfigModel {
    id: root

    property QtObject localization: JustWeather.Localization {
        language: plasmoid.configuration.language
    }

    function i18n(message, arg1, arg2, arg3) {
        return localization.text(message, arg1, arg2, arg3)
    }

    ConfigCategory {
         name: i18n("General")
         icon: "preferences-system-windows"
         source: "config/ConfigGeneral.qml"
    }
    ConfigCategory {
         name: i18n("Compact View")
         icon: "preferences-desktop-theme"
         source: "config/ConfigAppearance.qml"
    }
    ConfigCategory {
         name: i18n("Desktop View")
         icon: "preferences-desktop-display"
         source: "config/ConfigFullView.qml"
    }
    ConfigCategory {
         name: i18n("Forecast")
         icon: "view-calendar-week"
         source: "config/ConfigForecast.qml"
    }
}
