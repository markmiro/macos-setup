#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Global UI
###############################################################################

defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true
defaults write NSGlobalDomain AppleAccentColor -int 4
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool false
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false
defaults write NSGlobalDomain AppleWindowTabbingMode -string "fullscreen"
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true
defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -bool true
defaults write NSGlobalDomain NSMenuEnableActionImages -bool false
defaults write NSGlobalDomain "com.apple.sound.beep.feedback" -int 0
defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool true

# Pointer and keyboard speeds captured from this Mac.
defaults write NSGlobalDomain "com.apple.mouse.scaling" -float 1
defaults write NSGlobalDomain "com.apple.trackpad.scaling" -float 2
defaults write NSGlobalDomain "com.apple.scrollwheel.scaling" -float 0.5
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write com.apple.Accessibility KeyRepeatEnabled -bool true
defaults write com.apple.Accessibility KeyRepeatDelay -float 0.5
defaults write com.apple.Accessibility KeyRepeatInterval -float 0.083333333

###############################################################################
# Dock, Mission Control, and animations
###############################################################################

defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock tilesize -int 128
defaults write com.apple.dock largesize -int 16
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mineffect -string "genie"
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock wvous-br-corner -int 14
defaults write com.apple.dock wvous-br-modifier -int 0

# General animation reductions. Keep Reduce Motion off to match the source Mac.
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write com.apple.Accessibility ReduceMotionEnabled -bool false

###############################################################################
# Finder and Desktop
###############################################################################

# Hide desktop icons/items.
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowRecentTags -bool false
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

###############################################################################
# Trackpad and mouse
###############################################################################

defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string "OneButton"
defaults write com.apple.AppleMultitouchMouse MouseHorizontalScroll -bool true
defaults write com.apple.AppleMultitouchMouse MouseMomentumScroll -bool true
defaults write com.apple.AppleMultitouchMouse MouseVerticalScroll -bool true

###############################################################################
# Screenshots and screen recording defaults
###############################################################################

defaults write com.apple.screencapture style -string "selection"
defaults write com.apple.screencapture showsClicks -bool true
defaults write com.apple.screencapture showsCursor -bool true
defaults write com.apple.screencapture video -bool true

###############################################################################
# Window Manager / Stage Manager
###############################################################################

defaults write com.apple.WindowManager AppWindowGroupingBehavior -int 0
defaults write com.apple.WindowManager AutoHide -bool false
defaults write com.apple.WindowManager AutoHideDelay -float 0
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
defaults write com.apple.WindowManager GloballyEnabled -bool false
defaults write com.apple.WindowManager HideDesktop -bool false
defaults write com.apple.WindowManager StageManagerHideWidgets -bool true
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool false
defaults write com.apple.WindowManager StandardHideWidgets -bool true

###############################################################################
# Menu bar and Control Center
###############################################################################

defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock ShowAMPM -bool false
defaults write com.apple.menuextra.clock ShowDate -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowSeconds -bool false

defaults write com.apple.controlcenter "NSStatusItem Visible AccessibilityShortcuts" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible AirDrop" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible FocusModes" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Shortcuts" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible StageManager" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Timer" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible UserSwitcher" -bool false
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Battery" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Clock" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Sound" -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC WiFi" -bool true

###############################################################################
# File handlers
###############################################################################

if command -v duti >/dev/null 2>&1; then
  duti -s com.openai.atlas http all
  duti -s com.openai.atlas https all
  duti -s com.openai.atlas public.html all
  duti -s com.google.chrome mailto all
  duti -s com.readdle.pdfexpert-mac com.adobe.pdf all
  duti -s com.microsoft.vscode public.plain-text all
  duti -s com.microsoft.vscode public.source-code all
  duti -s com.microsoft.vscode public.json all
  duti -s com.microsoft.vscode public.yaml all
  duti -s com.microsoft.vscode net.daringfireball.markdown all
fi

###############################################################################
# Wallpaper
###############################################################################

if [[ -n "${WALLPAPER_PATH:-}" ]]; then
  if [[ ! -f "$WALLPAPER_PATH" ]]; then
    echo "WALLPAPER_PATH does not exist: $WALLPAPER_PATH" >&2
    exit 1
  fi

  osascript <<APPLESCRIPT
tell application "System Events"
  set picture of every desktop to POSIX file "$WALLPAPER_PATH"
end tell
APPLESCRIPT
else
  echo "Skipping wallpaper. Set WALLPAPER_PATH to apply an image wallpaper."
fi

###############################################################################
# Restart affected services
###############################################################################

killall Dock >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true

echo "macOS defaults applied."
