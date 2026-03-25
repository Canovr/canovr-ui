#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA_PATH="$(mktemp -d "${TMPDIR:-/tmp}/canovr-ui-derived-XXXXXX")"
APP_BUNDLE="${DERIVED_DATA_PATH}/Build/Products/Release-iphoneos/canovr-ios-app.app"
INFO_PLIST="${APP_BUNDLE}/Info.plist"
APP_CONFIG_PLIST="${APP_BUNDLE}/AppConfig.Release.plist"
ENTITLEMENTS_FILE="${PROJECT_ROOT}/canovr-ios-app.entitlements"
EXPECTED_ASSOCIATED_DOMAIN="applinks:canovr-354203175068.europe-west3.run.app"

cleanup() {
  rm -rf "${DERIVED_DATA_PATH}"
}
trap cleanup EXIT

echo "[canovr-ui] Release Build gestartet"

BUILD_SETTINGS="$(
  xcodebuild \
    -project "${PROJECT_ROOT}/canovr-ios-app.xcodeproj" \
    -scheme canovr-ios-app \
    -configuration Release \
    -showBuildSettings
)"

if ! grep -q "CODE_SIGN_ENTITLEMENTS = canovr-ios-app.entitlements" <<<"${BUILD_SETTINGS}"; then
  echo "[canovr-ui] Fehler: CODE_SIGN_ENTITLEMENTS ist nicht auf canovr-ios-app.entitlements gesetzt."
  exit 1
fi

xcodebuild \
  -project "${PROJECT_ROOT}/canovr-ios-app.xcodeproj" \
  -scheme canovr-ios-app \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  CODE_SIGNING_ALLOWED=NO \
  build

echo "[canovr-ui] Bundle-Audit gestartet"

if [ ! -d "${APP_BUNDLE}" ]; then
  echo "[canovr-ui] Fehler: App-Bundle nicht gefunden."
  exit 1
fi

for forbidden in ".claude" "patches" ".gitignore" "settings.local.json"; do
  if [ -e "${APP_BUNDLE}/${forbidden}" ]; then
    echo "[canovr-ui] Fehler: Unerlaubte Datei/Ordner im Bundle: ${forbidden}"
    exit 1
  fi
done

if find "${APP_BUNDLE}" -type f -name "*.patch" | grep -q .; then
  echo "[canovr-ui] Fehler: Patch-Dateien im Bundle gefunden."
  exit 1
fi

MIN_OS_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :MinimumOSVersion' "${INFO_PLIST}")"
if [ "${MIN_OS_VERSION}" != "18.0" ]; then
  echo "[canovr-ui] Fehler: Mindestversion unerwartet (${MIN_OS_VERSION}). Erwartet 18.0."
  exit 1
fi

if [ ! -f "${APP_CONFIG_PLIST}" ]; then
  echo "[canovr-ui] Fehler: AppConfig.Release.plist fehlt im Bundle."
  exit 1
fi

if ! /usr/libexec/PlistBuddy -c 'Print :api_base_url' "${APP_CONFIG_PLIST}" >/dev/null 2>&1; then
  echo "[canovr-ui] Fehler: api_base_url fehlt in AppConfig.Release.plist."
  exit 1
fi

if ! /usr/libexec/PlistBuddy -c 'Print :strava_callback_domain' "${APP_CONFIG_PLIST}" >/dev/null 2>&1; then
  echo "[canovr-ui] Fehler: strava_callback_domain fehlt in AppConfig.Release.plist."
  exit 1
fi

if [ ! -f "${ENTITLEMENTS_FILE}" ]; then
  echo "[canovr-ui] Fehler: Entitlements-Datei fehlt."
  exit 1
fi

if ! /usr/libexec/PlistBuddy -c 'Print :com.apple.developer.associated-domains' "${ENTITLEMENTS_FILE}" | grep -q "${EXPECTED_ASSOCIATED_DOMAIN}"; then
  echo "[canovr-ui] Fehler: Expected Associated Domain fehlt in Entitlements."
  exit 1
fi

echo "[canovr-ui] Release Gate erfolgreich"
