import QtQuick
import org.kde.plasma.configuration

ConfigModel {
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
