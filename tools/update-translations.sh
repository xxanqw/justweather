#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DOMAIN="plasma_applet_pp.ua.xxanqw.justweather"
POT_FILE="$ROOT_DIR/package/translate/$DOMAIN.pot"
LOCALES=(uk zh_CN ar fr es)

cd "$ROOT_DIR/package/contents"
mapfile -t QML_FILES < <(rg --files config ui -g '*.qml' | sort)
xgettext \
    --language=JavaScript \
    --from-code=UTF-8 \
    --keyword=i18n \
    --keyword=i18np:1,2 \
    --package-name=JustWeather \
    --msgid-bugs-address=https://github.com/xxanqw/justweather/issues \
    --output="$POT_FILE" \
    "${QML_FILES[@]}"

for locale in "${LOCALES[@]}"; do
    po_file="$ROOT_DIR/package/translate/$locale/LC_MESSAGES/$DOMAIN.po"
    mo_dir="$ROOT_DIR/package/contents/locale/$locale/LC_MESSAGES"

    msgmerge --update --backup=none "$po_file" "$POT_FILE"
    mkdir -p "$mo_dir"
    msgfmt --check --output-file="$mo_dir/$DOMAIN.mo" "$po_file"
done

node "$SCRIPT_DIR/generate-runtime-translations.mjs"
