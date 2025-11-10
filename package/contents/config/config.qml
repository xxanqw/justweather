import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
         name: "General"
         icon: "preferences-system-windows"
         source: "config/ConfigGeneral.qml"
    }
    ConfigCategory {
         name: "Compact View"
         icon: "preferences-desktop-theme"
         source: "config/ConfigAppearance.qml"
    }
    ConfigCategory {
         name: "Desktop View"
         icon: "preferences-desktop-display"
         source: "config/ConfigFullView.qml"
    }
}
