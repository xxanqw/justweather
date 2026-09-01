import QtQuick
import "Translations.js" as Translations

QtObject {
    id: localization

    property int language: 0
    readonly property int effectiveLanguage: language === 0
                                             ? Translations.languageForLocale(Qt.locale().name)
                                             : language
    readonly property string localeName: Translations.effectiveLocaleName(
                                             language, Qt.locale().name)
    readonly property string languageCode: effectiveLanguage === 0
                                            ? ""
                                            : Translations.languageCode(effectiveLanguage)
    readonly property bool rightToLeft: Translations.isRightToLeft(
                                            language, Qt.locale().name)

    function text(message, arg1, arg2, arg3) {
        if (language === 0 && effectiveLanguage === 0) {
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

        return Translations.translate(effectiveLanguage, message,
                                      [arg1, arg2, arg3])
    }

    function plural(singular, plural, count) {
        if (language === 0 && effectiveLanguage === 0) {
            return i18ndp("plasma_applet_pp.ua.xxanqw.justweather",
                          singular, plural, count)
        }

        return Translations.translatePlural(effectiveLanguage,
                                            singular, plural, count)
    }
}
