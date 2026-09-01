import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property int language: plasmoid.configuration.language
    property bool initialized: false

    // Properties for weather data
    property string temperatureC: "..."
    property string temperatureF: "..."
    property string feelsLikeC: "..."
    property string feelsLikeF: "..."
    property string todayMinC: "..."
    property string todayMinF: "..."
    property string todayMaxC: "..."
    property string todayMaxF: "..."
    property string weatherCondition: "..."
    property string precipitationLabel: ""
    property int precipitationChance: 0
    property string location: plasmoid.configuration.location
    property bool autoLocation: plasmoid.configuration.autoLocation
    property string displayLocation: location
    property string iconName: "not-available"
    property bool loading: false
    property bool updateFailed: false
    property string lastUpdate: ""
    property bool forecastEnabled: plasmoid.configuration.showHourlyForecast
                                   || plasmoid.configuration.showDailyForecast
    property bool forecastLoading: false
    property bool forecastFailed: false
    property int forecastRequestId: 0
    property real forecastLatitude: 0
    property real forecastLongitude: 0
    property bool hasForecastCoordinates: false
    property var hourlyForecast: []
    property var dailyForecast: []

    function i18n(message, arg1, arg2, arg3) {
        return localization.text(message, arg1, arg2, arg3)
    }

    function i18np(singular, plural, count) {
        return localization.plural(singular, plural, count)
    }

    function currentLocale() {
        return Qt.locale(localization.localeName)
    }

    LayoutMirroring.enabled: localization.rightToLeft
    LayoutMirroring.childrenInherit: true

    Localization {
        id: localization
        language: root.language
    }

    // Helper to get icon path
    function getIconPath(iconName) {
        var style = plasmoid.configuration.iconStyle === 0 ? "fill" : "line"
        return Qt.resolvedUrl("../icons/" + style + "/all/" + iconName + ".svg")
    }

    function currentTemperature() {
        return plasmoid.configuration.temperatureUnit === 0 ? temperatureC : temperatureF
    }

    function currentFeelsLike() {
        return plasmoid.configuration.temperatureUnit === 0 ? feelsLikeC : feelsLikeF
    }

    function currentCompactTemperature() {
        if (plasmoid.configuration.compactTemperatureMode === 1 && currentFeelsLike() !== "...") {
            return currentFeelsLike()
        }
        return currentTemperature()
    }

    function currentTodayMin() {
        return plasmoid.configuration.temperatureUnit === 0 ? todayMinC : todayMinF
    }

    function currentTodayMax() {
        return plasmoid.configuration.temperatureUnit === 0 ? todayMaxC : todayMaxF
    }

    function temperatureSuffix() {
        return plasmoid.configuration.temperatureUnit === 0 ? "°C" : "°F"
    }

    function precipitationText() {
        if (precipitationChance < 30 || !precipitationLabel) {
            return ""
        }
        return i18n("%1 · %2%", precipitationLabel, precipitationChance)
    }

    function weatherDetailsText() {
        if (temperatureC === "...") {
            return loading ? i18n("Updating...") : weatherCondition
        }

        var suffix = temperatureSuffix()
        var details = weatherCondition

        if (currentFeelsLike() !== "...") {
            details += "\n" + i18n("Feels like %1", currentFeelsLike() + suffix)
        }

        if (currentTodayMax() !== "..." && currentTodayMin() !== "...") {
            details += "\n" + i18n("H %1 / L %2", currentTodayMax() + suffix, currentTodayMin() + suffix)
        }

        var precipitation = precipitationText()
        if (precipitation) {
            details += "\n" + precipitation
        }

        if (updateFailed) {
            details += "\n" + (lastUpdate
                ? i18n("Update failed · Last update: %1", lastUpdate)
                : i18n("Update failed"))
        }

        return details
    }

    function updateStatusText() {
        if (loading) {
            return i18n("Updating...")
        }
        if (updateFailed) {
            return lastUpdate
                ? i18n("Update failed · Last update: %1", lastUpdate)
                : i18n("Update failed")
        }
        return i18n("Last update: %1", lastUpdate)
    }

    Plasmoid.toolTipMainText: displayLocation || i18n("Weather")
    Plasmoid.toolTipSubText: weatherDetailsText()

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
        initialized = true
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
        if (!autoLocation && location) {
            displayLocation = location
            fetchWeather()
        }
    }

    onAutoLocationChanged: {
        displayLocation = autoLocation ? i18n("Current location") : location
        fetchWeather()
    }

    onLanguageChanged: {
        if (initialized) {
            fetchWeather()
        }
    }

    onForecastEnabledChanged: {
        if (forecastEnabled && hasForecastCoordinates) {
            fetchForecast()
        } else if (!forecastEnabled) {
            forecastRequestId++
            forecastLoading = false
            forecastFailed = false
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
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.MiddleButton) {
                    fetchWeather()
                } else {
                    root.expanded = !root.expanded
                }
            }
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
                text: root.currentCompactTemperature() + root.temperatureSuffix()
                font.pixelSize: plasmoid.configuration.fontSize
                font.bold: plasmoid.configuration.boldFont
                visible: plasmoid.configuration.showTemperature
            }
        }
    }

    // Full representation (expanded/desktop widget)
    fullRepresentation: Item {
        implicitWidth: root.fullViewMinimumWidth()
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 14,
                                 fullContentLayout.implicitHeight
                                 + Kirigami.Units.largeSpacing * 2)

        Layout.minimumWidth: implicitWidth
        Layout.minimumHeight: implicitHeight
        Layout.preferredWidth: root.forecastEnabled
                               ? implicitWidth
                               : Kirigami.Units.gridUnit * 12
        Layout.preferredHeight: root.forecastEnabled
                                ? implicitHeight
                                : Math.max(implicitHeight, Kirigami.Units.gridUnit * 16)

        ColumnLayout {
            id: fullContentLayout
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
                    text: root.displayLocation || i18n("No location set")
                    font.bold: true
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
                    Layout.fillWidth: true
                }

                PlasmaComponents.ToolButton {
                    icon.name: "view-refresh"
                    onClicked: fetchWeather()
                    enabled: !root.loading

                    PlasmaComponents.ToolTip {
                        text: i18n("Refresh weather")
                    }
                }
            }

            // Main weather display
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: currentWeatherLayout.implicitHeight
                Layout.preferredHeight: currentWeatherLayout.implicitHeight

                ColumnLayout {
                    id: currentWeatherLayout
                    anchors.centerIn: parent
                    spacing: 0

                    // Icon and temperature in single container
                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: Math.max(weatherIcon.visible ? weatherIcon.width : 0,
                                                tempLabel.visible ? tempLabel.width : 0)
                        implicitHeight: (weatherIcon.visible ? weatherIcon.height : 0)
                                        + (tempLabel.visible ? tempLabel.height : 0)

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
                            text: root.currentTemperature() + root.temperatureSuffix()
                            font.pixelSize: plasmoid.configuration.fullTempSize
                            font.bold: plasmoid.configuration.fullBoldTemp
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: weatherIcon.visible ? weatherIcon.bottom : parent.top
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

                    PlasmaComponents.Label {
                        text: i18n("H %1 / L %2",
                                   root.currentTodayMax() + root.temperatureSuffix(),
                                   root.currentTodayMin() + root.temperatureSuffix())
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        opacity: 0.6
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: Kirigami.Units.smallSpacing
                        visible: root.currentTodayMax() !== "..." && root.currentTodayMin() !== "..."
                    }

                    PlasmaComponents.Label {
                        text: root.precipitationText()
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        opacity: 0.7
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: Kirigami.Units.smallSpacing
                        visible: text !== ""
                    }
                }
            }

            // Optional hourly weather changes
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: plasmoid.configuration.showHourlyForecast

                RowLayout {
                    Layout.fillWidth: true

                    PlasmaComponents.Label {
                        text: i18np("Next %1 hour", "Next %1 hours",
                                    plasmoid.configuration.hourlyForecastHours)
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    PlasmaComponents.Label {
                        text: root.forecastStatusText()
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        opacity: 0.6
                        visible: text !== ""
                    }
                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                    Layout.minimumHeight: root.forecastStripHeight(
                                              plasmoid.configuration.showHourlyIcons,
                                              plasmoid.configuration.showHourlyPrecipitation)
                    Layout.preferredHeight: Layout.minimumHeight
                    clip: true

                    Flickable {
                        anchors.fill: parent
                        contentWidth: hourlyForecastLayout.implicitWidth
                        contentHeight: height
                        flickableDirection: Flickable.HorizontalFlick
                        boundsBehavior: Flickable.StopAtBounds

                        RowLayout {
                            id: hourlyForecastLayout
                            height: parent.height
                            spacing: Kirigami.Units.largeSpacing

                            Repeater {
                                model: root.visibleHourlyForecast()

                                delegate: ColumnLayout {
                                    required property var modelData

                                    Layout.minimumWidth: root.forecastColumnWidth()
                                    Layout.alignment: Qt.AlignTop
                                    spacing: Kirigami.Units.smallSpacing

                                    PlasmaComponents.Label {
                                        text: root.formatForecastTime(modelData.time)
                                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                        opacity: 0.7
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Kirigami.Icon {
                                        source: root.getIconPath(modelData.iconName)
                                        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                                        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                                        Layout.alignment: Qt.AlignHCenter
                                        visible: plasmoid.configuration.showHourlyIcons
                                    }

                                    PlasmaComponents.Label {
                                        text: root.forecastTemperature(
                                                  plasmoid.configuration.hourlyTemperatureMode === 1
                                                  ? modelData.apparentTemperatureC
                                                  : modelData.temperatureC) + "°"
                                        font.bold: true
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    PlasmaComponents.Label {
                                        text: i18n("%1%", Math.round(modelData.precipitation))
                                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                        opacity: 0.6
                                        Layout.alignment: Qt.AlignHCenter
                                        visible: plasmoid.configuration.showHourlyPrecipitation
                                                 && modelData.precipitation !== null
                                    }
                                }
                            }
                        }
                    }

                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: root.forecastFailed
                              ? i18n("Forecast unavailable")
                              : i18n("Loading forecast...")
                        opacity: 0.6
                        visible: root.hourlyForecast.length === 0
                    }
                }
            }

            // Optional multi-day forecast
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: plasmoid.configuration.showDailyForecast

                RowLayout {
                    Layout.fillWidth: true

                    PlasmaComponents.Label {
                        text: i18n("%1-day forecast", plasmoid.configuration.forecastDays)
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    PlasmaComponents.Label {
                        text: root.forecastStatusText()
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        opacity: 0.6
                        visible: text !== ""
                    }
                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                    Layout.minimumHeight: root.forecastStripHeight(
                                              plasmoid.configuration.showDailyIcons,
                                              plasmoid.configuration.showDailyPrecipitation)
                    Layout.preferredHeight: Layout.minimumHeight
                    clip: true

                    Flickable {
                        anchors.fill: parent
                        contentWidth: dailyForecastLayout.implicitWidth
                        contentHeight: height
                        flickableDirection: Flickable.HorizontalFlick
                        boundsBehavior: Flickable.StopAtBounds

                        RowLayout {
                            id: dailyForecastLayout
                            height: parent.height
                            spacing: Kirigami.Units.largeSpacing

                            Repeater {
                                model: root.visibleDailyForecast()

                                delegate: ColumnLayout {
                                    required property var modelData
                                    required property int index

                                    Layout.minimumWidth: root.forecastColumnWidth()
                                    Layout.alignment: Qt.AlignTop
                                    spacing: Kirigami.Units.smallSpacing

                                    PlasmaComponents.Label {
                                        text: root.formatForecastDay(modelData.date, index)
                                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                        opacity: 0.7
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Kirigami.Icon {
                                        source: root.getIconPath(modelData.iconName)
                                        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                                        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                                        Layout.alignment: Qt.AlignHCenter
                                        visible: plasmoid.configuration.showDailyIcons
                                    }

                                    PlasmaComponents.Label {
                                        property real maximum: plasmoid.configuration.dailyTemperatureMode === 1
                                                               ? modelData.apparentMaxC
                                                               : modelData.maxC
                                        property real minimum: plasmoid.configuration.dailyTemperatureMode === 1
                                                               ? modelData.apparentMinC
                                                               : modelData.minC

                                        text: i18n("%1° / %2°",
                                                   root.forecastTemperature(maximum),
                                                   root.forecastTemperature(minimum))
                                        font.bold: true
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    PlasmaComponents.Label {
                                        text: i18n("%1%", Math.round(modelData.precipitation))
                                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                        opacity: 0.6
                                        Layout.alignment: Qt.AlignHCenter
                                        visible: plasmoid.configuration.showDailyPrecipitation
                                                 && modelData.precipitation !== null
                                    }
                                }
                            }
                        }
                    }

                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: root.forecastFailed
                              ? i18n("Forecast unavailable")
                              : i18n("Loading forecast...")
                        opacity: 0.6
                        visible: root.dailyForecast.length === 0
                    }
                }
            }

            // Last update info
            PlasmaComponents.Label {
                text: root.updateStatusText()
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                opacity: root.updateFailed ? 0.8 : 0.6
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Map Qt system locale to wttr.in language code
    function getWttrLang() {
        if (language !== 0) {
            return localization.languageCode
        }

        var locale = Qt.locale().name  // e.g., "zh_CN"
        var lang = locale.toLowerCase().replace("_", "-")  // "zh-cn"

        if (lang === "ru" || lang.indexOf("ru-") === 0) {
            return "uk"
        }

        var supportedLangs = [
            "af","am","ar","az","ba","be","bg","bn","bs","by","ca","crk","cs","cy",
            "da","de","el","en","eo","es","et","eu","fa","fi","fr","fy","ga","gl",
            "he","hi","hr","hy","hu","ia","id","is","it","ja","jv","ka","kk","ko",
            "ky","lt","lv","mg","mk","ml","mr","nb","nl","nn","oc","pa","pl","pt",
            "pt-br","ro","ru","sk","sl","sr","sr-lat","sv","sw","ta","te","th","tr",
            "ts","uk","vi","zh","zh-cn","zh-tw","zu"
        ]

        if (supportedLangs.indexOf(lang) !== -1) {
            return lang
        }
        // Fall back to just the language code (e.g., "en_US" -> "en")
        var fallback = locale.substring(0, 2).toLowerCase()
        if (supportedLangs.indexOf(fallback) !== -1) {
            return fallback
        }
        return "en"
    }

    // Read localized weather description from the lang-specific field
    function getLocalizedWeatherDesc(current) {
        var lang = getWttrLang()
        var langField = "lang_" + lang  // e.g., "lang_zh-cn"

        if (current[langField] && current[langField][0] && current[langField][0].value) {
            var localized = current[langField][0].value
            if (localized !== "") {
                return localized
            }
        }
        // Fall back to default English description
        return current.weatherDesc[0].value
    }

    function normalizeWeatherData(data) {
        return data && data.data ? data.data : data
    }

    function resolveLocationName(data) {
        if (!autoLocation || !data || !data.nearest_area || data.nearest_area.length === 0) {
            return location
        }

        var area = data.nearest_area[0]
        if (area.areaName && area.areaName.length > 0 && area.areaName[0].value) {
            return area.areaName[0].value
        }

        return i18n("Current location")
    }

    function resolveForecastCoordinates(data) {
        if (!data || !data.nearest_area || data.nearest_area.length === 0) {
            return null
        }

        var area = data.nearest_area[0]
        var latitude = parseFloat(area.latitude)
        var longitude = parseFloat(area.longitude)

        if (isNaN(latitude) || isNaN(longitude)) {
            return null
        }

        return {
            "latitude": latitude,
            "longitude": longitude
        }
    }

    function celsiusToFahrenheit(value) {
        return value * 9 / 5 + 32
    }

    function forecastTemperature(value) {
        if (value === undefined || value === null || isNaN(value)) {
            return "..."
        }

        var converted = plasmoid.configuration.temperatureUnit === 0
            ? value
            : celsiusToFahrenheit(value)
        return Math.round(converted).toString()
    }

    function forecastDate(value) {
        if (!value) {
            return null
        }

        var dateAndTime = value.split("T")
        var dateParts = dateAndTime[0].split("-")
        var timeParts = dateAndTime.length > 1 ? dateAndTime[1].split(":") : ["12", "0"]

        if (dateParts.length !== 3) {
            return null
        }

        return new Date(parseInt(dateParts[0]),
                        parseInt(dateParts[1]) - 1,
                        parseInt(dateParts[2]),
                        parseInt(timeParts[0]),
                        parseInt(timeParts[1]))
    }

    function formatForecastTime(value) {
        var date = forecastDate(value)
        return date ? date.toLocaleTimeString(currentLocale(), Locale.ShortFormat) : value
    }

    function formatForecastDay(value, index) {
        if (index === 0 && plasmoid.configuration.forecastIncludesToday) {
            return i18n("Today")
        }

        var date = forecastDate(value)
        return date ? date.toLocaleDateString(currentLocale(), "ddd") : value
    }

    function visibleHourlyForecast() {
        var result = []
        var horizon = Math.min(plasmoid.configuration.hourlyForecastHours, hourlyForecast.length)
        var step = Math.max(1, plasmoid.configuration.hourlyForecastStep)

        for (var i = 0; i < horizon; i += step) {
            result.push(hourlyForecast[i])
        }
        return result
    }

    function visibleDailyForecast() {
        var start = plasmoid.configuration.forecastIncludesToday ? 0 : 1
        return dailyForecast.slice(start, start + plasmoid.configuration.forecastDays)
    }

    function forecastStatusText() {
        if (forecastLoading) {
            return i18n("Updating...")
        }
        if (forecastFailed) {
            return i18n("Update failed")
        }
        return ""
    }

    function forecastColumnCount() {
        var columns = 0

        if (plasmoid.configuration.showHourlyForecast) {
            var step = Math.max(1, plasmoid.configuration.hourlyForecastStep)
            columns = Math.max(columns,
                               Math.ceil(plasmoid.configuration.hourlyForecastHours / step))
        }

        if (plasmoid.configuration.showDailyForecast) {
            columns = Math.max(columns, plasmoid.configuration.forecastDays)
        }

        // Keep very large forecasts scrollable instead of growing beyond seven columns.
        return Math.min(7, Math.max(4, columns))
    }

    function fullViewMinimumWidth() {
        var gridUnit = Kirigami.Units.gridUnit

        if (!forecastEnabled) {
            return gridUnit * 10
        }

        var columns = forecastColumnCount()
        var forecastWidth = columns * forecastColumnWidth()
            + (columns - 1) * Kirigami.Units.largeSpacing
            + Kirigami.Units.largeSpacing * 2
        return Math.max(gridUnit * 16, forecastWidth)
    }

    function forecastColumnWidth() {
        return Kirigami.Units.gridUnit * 3.25
    }

    function forecastStripHeight(showIcons, showPrecipitation) {
        var gridUnits = 2.3
            + (showIcons ? 1.8 : 0)
            + (showPrecipitation ? 0.9 : 0)
        return Kirigami.Units.gridUnit * gridUnits
    }

    // Function to fetch weather from wttr.in
    function fetchWeather() {
        if (!autoLocation && !location) {
            console.log("No location set")
            return
        }

        loading = true

        var xhr = new XMLHttpRequest()
        var requestLocation = autoLocation ? "" : encodeURIComponent(location)
        var url = "https://wttr.in/" + requestLocation + "?format=j1&lang=" + getWttrLang()

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loading = false
                if (xhr.status === 200) {
                    try {
                        var data = normalizeWeatherData(JSON.parse(xhr.responseText))
                        updateFailed = !parseWeatherData(data)
                    } catch (e) {
                        console.error("Error parsing weather data:", e)
                        updateFailed = true
                    }
                } else {
                    console.error("Error fetching weather:", xhr.status)
                    updateFailed = true
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
            return false
        }

        var current = data.current_condition[0]
        var today = data.weather && data.weather.length > 0 ? data.weather[0] : null
        var coordinates = resolveForecastCoordinates(data)

        displayLocation = resolveLocationName(data)
        temperatureC = current.temp_C
        temperatureF = current.temp_F
        feelsLikeC = current.FeelsLikeC || "..."
        feelsLikeF = current.FeelsLikeF || "..."

        if (today) {
            todayMinC = today.mintempC || "..."
            todayMinF = today.mintempF || "..."
            todayMaxC = today.maxtempC || "..."
            todayMaxF = today.maxtempF || "..."
        }

        updatePrecipitationForecast(current, today)
        weatherCondition = getLocalizedWeatherDesc(current)

        // Map weather condition to icon using the selected location's local time.
        iconName = mapWeatherToIcon(current.weatherCode, isNightTime(current, today))

        if (coordinates) {
            forecastLatitude = coordinates.latitude
            forecastLongitude = coordinates.longitude
            hasForecastCoordinates = true

            if (forecastEnabled) {
                fetchForecast()
            }
        } else {
            hasForecastCoordinates = false
            forecastFailed = forecastEnabled
        }

        // Update last refresh time
        var now = new Date()
        lastUpdate = now.toLocaleTimeString(currentLocale(), Locale.ShortFormat)

        console.log("Weather updated:", currentTemperature(), weatherCondition, iconName)
        return true
    }

    function fetchForecast() {
        if (!forecastEnabled || !hasForecastCoordinates) {
            return
        }

        forecastLoading = true
        var requestId = ++forecastRequestId

        var xhr = new XMLHttpRequest()
        var hourlyFields = "temperature_2m,apparent_temperature,precipitation_probability,weather_code,is_day"
        var dailyFields = "weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,precipitation_probability_max"
        var url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + encodeURIComponent(forecastLatitude)
            + "&longitude=" + encodeURIComponent(forecastLongitude)
            + "&hourly=" + hourlyFields
            + "&daily=" + dailyFields
            + "&current=temperature_2m"
            + "&timezone=auto"
            + "&forecast_days=8"

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return
            }

            if (requestId !== forecastRequestId) {
                return
            }

            forecastLoading = false
            if (xhr.status === 200) {
                try {
                    forecastFailed = !parseForecastData(JSON.parse(xhr.responseText))
                } catch (e) {
                    console.error("Error parsing forecast data:", e)
                    forecastFailed = true
                }
            } else {
                console.error("Error fetching forecast:", xhr.status)
                forecastFailed = true
            }
        }

        xhr.open("GET", url)
        xhr.send()
    }

    function parseForecastData(data) {
        if (!data || !data.hourly || !data.daily
                || !data.hourly.time || !data.daily.time) {
            console.error("Invalid forecast data structure")
            return false
        }

        var hours = []
        var currentTime = data.current && data.current.time ? data.current.time : ""
        var firstHour = 0

        while (firstHour < data.hourly.time.length
                && currentTime
                && data.hourly.time[firstHour] < currentTime) {
            firstHour++
        }

        var lastHour = Math.min(firstHour + 24, data.hourly.time.length)
        for (var i = firstHour; i < lastHour; i++) {
            hours.push({
                "time": data.hourly.time[i],
                "temperatureC": data.hourly.temperature_2m[i],
                "apparentTemperatureC": data.hourly.apparent_temperature[i],
                "precipitation": data.hourly.precipitation_probability[i],
                "iconName": mapWmoToIcon(data.hourly.weather_code[i], data.hourly.is_day[i] === 0)
            })
        }

        var days = []
        for (var day = 0; day < data.daily.time.length; day++) {
            days.push({
                "date": data.daily.time[day],
                "maxC": data.daily.temperature_2m_max[day],
                "minC": data.daily.temperature_2m_min[day],
                "apparentMaxC": data.daily.apparent_temperature_max[day],
                "apparentMinC": data.daily.apparent_temperature_min[day],
                "precipitation": data.daily.precipitation_probability_max[day],
                "iconName": mapWmoToIcon(data.daily.weather_code[day], false)
            })
        }

        hourlyForecast = hours
        dailyForecast = days
        console.log("Forecast updated:", hours.length, "hours,", days.length, "days")
        return true
    }

    function parseClockMinutes(value) {
        if (!value) {
            return -1
        }

        var match = value.match(/(\d{1,2}):(\d{2})\s*(AM|PM)/i)
        if (!match) {
            return -1
        }

        var hour = parseInt(match[1])
        var minute = parseInt(match[2])
        var period = match[3].toUpperCase()

        if (period === "AM" && hour === 12) {
            hour = 0
        } else if (period === "PM" && hour !== 12) {
            hour += 12
        }

        return hour * 60 + minute
    }

    function forecastSlotMinutes(value) {
        var time = parseInt(value)
        if (isNaN(time)) {
            return -1
        }
        return Math.floor(time / 100) * 60 + (time % 100)
    }

    function updatePrecipitationForecast(current, today) {
        precipitationLabel = ""
        precipitationChance = 0

        if (!today || !today.hourly || today.hourly.length === 0) {
            return
        }

        var localMinutes = current ? parseClockMinutes(current.localObsDateTime) : -1
        var checked = 0

        for (var i = 0; i < today.hourly.length && checked < 3; i++) {
            var hour = today.hourly[i]
            var slotMinutes = forecastSlotMinutes(hour.time)

            if (localMinutes >= 0 && slotMinutes >= 0 && slotMinutes < localMinutes) {
                continue
            }

            var rain = parseInt(hour.chanceofrain || 0)
            var snow = parseInt(hour.chanceofsnow || 0)
            var thunder = parseInt(hour.chanceofthunder || 0)
            var chance = Math.max(rain, snow, thunder)
            var label = rain >= snow && rain >= thunder
                ? i18n("Rain")
                : (snow >= thunder ? i18n("Snow") : i18n("Thunder"))

            if (chance > precipitationChance) {
                precipitationChance = chance
                precipitationLabel = label
            }
            checked++
        }
    }

    // Check day/night against sunrise and sunset at the selected location.
    function isNightTime(current, today) {
        var astronomy = today && today.astronomy && today.astronomy.length > 0
            ? today.astronomy[0]
            : null
        var localMinutes = current ? parseClockMinutes(current.localObsDateTime) : -1
        var sunriseMinutes = astronomy ? parseClockMinutes(astronomy.sunrise) : -1
        var sunsetMinutes = astronomy ? parseClockMinutes(astronomy.sunset) : -1

        if (localMinutes >= 0 && sunriseMinutes >= 0 && sunsetMinutes >= 0) {
            return localMinutes < sunriseMinutes || localMinutes >= sunsetMinutes
        }

        // Fall back to system time when astronomy data is unavailable.
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
        else if (codeInt === 119) {
            iconPath = "cloudy"
        }
        // Overcast
        else if (codeInt === 122) {
            iconPath = "overcast" + daySuffix
        }
        // Fog/Mist
        else if ([143, 248, 260].includes(codeInt)) {
            iconPath = "fog" + daySuffix
        }
        // Rain
        else if ([176, 263, 266, 293, 296, 299, 302, 305, 308, 353, 356, 359].includes(codeInt)) {
            iconPath = "rain"
        }
        // Snow
        else if ([179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(codeInt)) {
            iconPath = "snow"
        }
        // Sleet/Ice pellets
        else if ([182, 185, 281, 284, 311, 314, 317, 350, 362, 365, 374, 377].includes(codeInt)) {
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

    // Map Open-Meteo WMO weather codes to the bundled icon set.
    function mapWmoToIcon(code, isNight) {
        var codeInt = parseInt(code)
        var daySuffix = isNight ? "-night" : "-day"

        if (codeInt === 0) {
            return isNight ? "clear-night" : "clear-day"
        }
        if (codeInt === 1 || codeInt === 2) {
            return "partly-cloudy" + daySuffix
        }
        if (codeInt === 3) {
            return "overcast" + daySuffix
        }
        if (codeInt === 45 || codeInt === 48) {
            return "fog" + daySuffix
        }
        if ([51, 53, 55, 56, 57].includes(codeInt)) {
            return "drizzle"
        }
        if ([61, 63, 65, 80, 81, 82].includes(codeInt)) {
            return "rain"
        }
        if ([66, 67].includes(codeInt)) {
            return "sleet"
        }
        if ([71, 73, 75, 77, 85, 86].includes(codeInt)) {
            return "snow"
        }
        if ([95, 96, 99].includes(codeInt)) {
            return "thunderstorms" + daySuffix
        }
        return "not-available"
    }
}
