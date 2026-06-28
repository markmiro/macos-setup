#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AUDIT_DIR="$REPO_DIR/audit"

mkdir -p "$AUDIT_DIR"

sw_vers > "$AUDIT_DIR/sw_vers.txt"
pmset -g custom > "$AUDIT_DIR/pmset-custom.txt" || true
find /Applications -maxdepth 1 -name "*.app" -print | sort > "$AUDIT_DIR/applications.txt"

if command -v brew >/dev/null 2>&1; then
  HOMEBREW_NO_AUTO_UPDATE=1 brew tap > "$AUDIT_DIR/brew-taps.txt" || true
  HOMEBREW_NO_AUTO_UPDATE=1 brew leaves > "$AUDIT_DIR/brew-formulae.txt" || true
  HOMEBREW_NO_AUTO_UPDATE=1 brew list --cask > "$AUDIT_DIR/brew-casks.txt" || true
  HOMEBREW_NO_AUTO_UPDATE=1 brew services list > "$AUDIT_DIR/brew-services.txt" || true
fi

for domain in \
  NSGlobalDomain \
  com.apple.Accessibility \
  com.apple.AppleMultitouchMouse \
  com.apple.ActivityMonitor \
  com.apple.WindowManager \
  com.apple.controlcenter \
  com.apple.dock \
  com.apple.driver.AppleBluetoothMultitouch.trackpad \
  com.apple.finder \
  com.apple.menuextra.clock \
  com.apple.screencapture
do
  defaults read "$domain" > "$AUDIT_DIR/$domain.plist.txt" 2>/dev/null || true
done

WALLPAPER_INDEX="$HOME/Library/Application Support/com.apple.wallpaper/Store/Index.plist"
if [[ -f "$WALLPAPER_INDEX" ]]; then
  plutil -p "$WALLPAPER_INDEX" > "$AUDIT_DIR/wallpaper-index.txt" || true
fi

echo "Wrote audit files to $AUDIT_DIR"
