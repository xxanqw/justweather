import QtQuick
import "GeneratedTranslations.js" as Catalogs

QtObject {
    id: localization

    property int language: 0
    readonly property string systemLocaleName: Qt.locale().name
    readonly property string systemLanguageCode: localeLanguage(systemLocaleName)
    readonly property int effectiveLanguage: language === 0
                                             ? languageForLocale(systemLocaleName)
                                             : language
    readonly property string catalogLocale: catalogLocaleForLanguage(effectiveLanguage)
    readonly property string localeName: effectiveLocaleName(language, systemLocaleName)
    readonly property string languageCode: weatherLanguageCode(effectiveLanguage)
    readonly property bool rightToLeft: language === 0
                                            ? systemLanguageCode !== "ru"
                                                && Qt.application.layoutDirection
                                                    === Qt.RightToLeft
                                            : effectiveLanguage === 4

    function localeLanguage(localeName) {
        return (localeName || "").toLowerCase().replace("_", "-").split("-")[0]
    }

    function languageForLocale(localeName) {
        var code = localeLanguage(localeName)
        if (code === "en") return 1
        if (code === "uk" || code === "ru") return 2
        if (code === "zh") return 3
        if (code === "ar") return 4
        if (code === "fr") return 5
        if (code === "es") return 6
        return 0
    }

    function catalogLocaleForLanguage(value) {
        return ["", "en", "uk", "zh_CN", "ar", "fr", "es"][value] || ""
    }

    function weatherLanguageCode(value) {
        return ["", "en", "uk", "zh-cn", "ar", "fr", "es"][value] || ""
    }

    function localeNameForLanguage(value) {
        return ["", "en_US", "uk_UA", "zh_CN", "ar", "fr_FR", "es_ES"][value]
                || "en_US"
    }

    function effectiveLocaleName(value, currentSystemLocale) {
        if (value !== 0) {
            return localeNameForLanguage(value)
        }
        return localeLanguage(currentSystemLocale) === "ru"
            ? localeNameForLanguage(2)
            : currentSystemLocale
    }

    function text(message, arg1, arg2, arg3) {
        if (language === 0 && systemLanguageCode !== "ru") {
            if (arg3 !== undefined) {
                return i18nd("plasma_applet_pp.ua.xxanqw.justweather",
                             message, arg1, arg2, arg3)
            }
            if (arg2 !== undefined) {
                return i18nd("plasma_applet_pp.ua.xxanqw.justweather",
                             message, arg1, arg2)
            }
            if (arg1 !== undefined) {
                return i18nd("plasma_applet_pp.ua.xxanqw.justweather",
                             message, arg1)
            }
            return i18nd("plasma_applet_pp.ua.xxanqw.justweather", message)
        }

        return Catalogs.translate(catalogLocale, message, [arg1, arg2, arg3])
    }

    function plural(singular, plural, count) {
        if (language === 0 && systemLanguageCode !== "ru") {
            return i18ndp("plasma_applet_pp.ua.xxanqw.justweather",
                          singular, plural, count)
        }

        return Catalogs.translatePlural(catalogLocale, singular, plural, count)
    }
}
