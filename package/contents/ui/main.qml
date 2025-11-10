import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Properties for weather data
    property string temperature: "..."
    property string weatherCondition: "..."
    property string location: plasmoid.configuration.location
    property string iconName: "not-available"
    property bool loading: false
    property string lastUpdate: ""
    
    // Helper to get icon path
    function getIconPath(iconName) {
        var style = plasmoid.configuration.iconStyle === 0 ? "fill" : "line"
        return Qt.resolvedUrl("../icons/" + style + "/all/" + iconName + ".svg")
    }
    
    // Widget size preferences
    preferredRepresentation: plasmoid.configuration.compactMode ? compactRepresentation : fullRepresentation
    
    Plasmoid.backgroundHints: plasmoid.configuration.showBackground ? 
        PlasmaCore.Types.DefaultBackground : PlasmaCore.Types.NoBackground

    // Timer for auto-refresh
    Timer {
        id: refreshTimer
        interval: plasmoid.configuration.updateInterval * 60000 // Convert minutes to milliseconds
        running: true
        repeat: true
        onTriggered: fetchWeather()
    }

    // Detect form factor changes (panel vs desktop)
    Connections {
        target: plasmoid
        function onFormFactorChanged() {
            // Automatically use full representation on desktop, compact on panel
            if (plasmoid.formFactor === PlasmaCore.Types.Planar) {
                // Desktop widget - use full representation
                plasmoid.configuration.compactMode = false
            } else if (plasmoid.formFactor === PlasmaCore.Types.Horizontal || 
                       plasmoid.formFactor === PlasmaCore.Types.Vertical) {
                // Panel widget - use compact representation
                plasmoid.configuration.compactMode = true
            }
        }
    }

    // Fetch weather on load
    Component.onCompleted: {
        fetchWeather()
        
        // Set initial mode based on form factor
        if (plasmoid.formFactor === PlasmaCore.Types.Planar) {
            // Desktop widget
            plasmoid.configuration.compactMode = false
        } else if (plasmoid.formFactor === PlasmaCore.Types.Horizontal || 
                   plasmoid.formFactor === PlasmaCore.Types.Vertical) {
            // Panel widget
            plasmoid.configuration.compactMode = true
        }
    }

    // Watch for location changes
    onLocationChanged: {
        if (location) {
            fetchWeather()
        }
    }

    // Compact representation (for panel)
    compactRepresentation: Item {
        Layout.minimumWidth: compactLayout.implicitWidth
        Layout.minimumHeight: compactLayout.implicitHeight
        Layout.preferredWidth: compactLayout.implicitWidth
        Layout.preferredHeight: compactLayout.implicitHeight

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }

        RowLayout {
            id: compactLayout
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                id: compactIcon
                source: root.getIconPath(root.iconName)
                Layout.preferredWidth: plasmoid.configuration.iconSize
                Layout.preferredHeight: plasmoid.configuration.iconSize
                visible: plasmoid.configuration.showIcon
            }

            PlasmaComponents.Label {
                text: root.temperature + (plasmoid.configuration.temperatureUnit === 0 ? "°C" : "°F")
                font.pixelSize: plasmoid.configuration.fontSize
                font.bold: plasmoid.configuration.boldFont
                visible: plasmoid.configuration.showTemperature
            }
        }
    }

    // Full representation (expanded/desktop widget)
    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 10
        Layout.minimumHeight: Kirigami.Units.gridUnit * 14
        Layout.preferredWidth: Kirigami.Units.gridUnit * 12
        Layout.preferredHeight: Kirigami.Units.gridUnit * 16

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            // Location header
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: "find-location"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                }

                PlasmaComponents.Label {
                    text: root.location || "No location set"
                    font.bold: true
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
                    Layout.fillWidth: true
                }

                PlasmaComponents.ToolButton {
                    icon.name: "view-refresh"
                    onClicked: fetchWeather()
                    enabled: !root.loading
                    
                    PlasmaComponents.ToolTip {
                        text: "Refresh weather"
                    }
                }
            }

            // Main weather display
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0

                    // Icon and temperature in single container
                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: Math.max(weatherIcon.width, tempLabel.width)
                        implicitHeight: weatherIcon.height + tempLabel.height

                        Kirigami.Icon {
                            id: weatherIcon
                            source: root.getIconPath(root.iconName)
                            width: plasmoid.configuration.fullIconSize
                            height: plasmoid.configuration.fullIconSize
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            visible: plasmoid.configuration.showFullIcon
                        }

                        PlasmaComponents.Label {
                            id: tempLabel
                            text: root.temperature + (plasmoid.configuration.temperatureUnit === 0 ? "°C" : "°F")
                            font.pixelSize: plasmoid.configuration.fullTempSize
                            font.bold: plasmoid.configuration.fullBoldTemp
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: weatherIcon.bottom
                            anchors.topMargin: 0
                            visible: plasmoid.configuration.showFullTemp
                        }
                    }

                    PlasmaComponents.Label {
                        text: root.weatherCondition
                        font.pixelSize: plasmoid.configuration.fullConditionSize
                        opacity: 0.8
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: Kirigami.Units.largeSpacing
                        visible: plasmoid.configuration.showCondition
                    }
                }
            }

            // Last update info
            PlasmaComponents.Label {
                text: root.loading ? "Updating..." : "Last update: " + root.lastUpdate
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                opacity: 0.6
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Function to fetch weather from wttr.in
    function fetchWeather() {
        if (!location) {
            console.log("No location set")
            return
        }

        loading = true
        
        var xhr = new XMLHttpRequest()
        var url = "https://wttr.in/" + encodeURIComponent(location) + "?format=j1"
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loading = false
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText)
                        parseWeatherData(data)
                    } catch (e) {
                        console.error("Error parsing weather data:", e)
                        weatherCondition = "Error parsing data"
                    }
                } else {
                    console.error("Error fetching weather:", xhr.status)
                    weatherCondition = "Error fetching data"
                }
            }
        }
        
        xhr.open("GET", url)
        xhr.send()
    }

    // Parse weather data from wttr.in
    function parseWeatherData(data) {
        if (!data || !data.current_condition || data.current_condition.length === 0) {
            console.error("Invalid weather data structure")
            return
        }

        var current = data.current_condition[0]
        
        // Get temperature based on user preference (0 = Celsius, 1 = Fahrenheit)
        if (plasmoid.configuration.temperatureUnit === 0) {
            temperature = current.temp_C
        } else {
            temperature = current.temp_F
        }
        
        weatherCondition = current.weatherDesc[0].value
        
        // Map weather condition to icon
        iconName = mapWeatherToIcon(current.weatherCode, isNightTime())
        
        // Update last refresh time
        var now = new Date()
        lastUpdate = now.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        
        console.log("Weather updated:", temperature, weatherCondition, iconName)
    }

    // Check if it's night time
    function isNightTime() {
        var hour = new Date().getHours()
        return hour < 6 || hour >= 20
    }

    // Map wttr.in weather codes to icon names
    function mapWeatherToIcon(code, isNight) {
        var codeInt = parseInt(code)
        var daySuffix = isNight ? "-night" : "-day"
        
        var iconPath = ""
        
        // Clear
        if (codeInt === 113) {
            iconPath = isNight ? "clear-night" : "clear-day"
        }
        // Partly cloudy
        else if (codeInt === 116) {
            iconPath = "partly-cloudy" + daySuffix
        }
        // Cloudy
        else if (codeInt === 119 || codeInt === 122) {
            iconPath = "cloudy"
        }
        // Overcast
        else if (codeInt === 143 || codeInt === 248 || codeInt === 260) {
            iconPath = "overcast" + daySuffix
        }
        // Fog/Mist
        else if (codeInt === 248 || codeInt === 260 || codeInt === 143) {
            iconPath = "fog" + daySuffix
        }
        // Rain
        else if ([176, 263, 266, 293, 296, 299, 302, 305, 308, 353, 356, 359].includes(codeInt)) {
            iconPath = "rain"
        }
        // Snow
        else if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371, 374, 377].includes(codeInt)) {
            iconPath = "snow"
        }
        // Sleet
        else if ([182, 185, 281, 284, 311, 314, 317, 350, 362, 365, 374].includes(codeInt)) {
            iconPath = "sleet"
        }
        // Thunderstorm
        else if ([200, 386, 389, 392, 395].includes(codeInt)) {
            iconPath = "thunderstorms" + daySuffix
        }
        // Default
        else {
            iconPath = "not-available"
        }
        
        console.log("Weather code:", code, "-> Icon:", iconPath)
        return iconPath
    }
}
