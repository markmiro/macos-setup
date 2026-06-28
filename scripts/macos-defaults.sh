#!/usr/bin/env bash
set -euo pipefail

# Applies personal macOS preferences captured from the source Mac.
# Lines marked "macOS default" are commented out — they match a fresh install
# and do not need to be written on a new machine.

###############################################################################
# Global UI
###############################################################################

# Force dark mode (default: unset / follow Light until chosen).
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
# Auto-switch appearance with sunrise/sunset (default: false).
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true
# Accent color 4 = purple (default: unset / multicolor-blue).
defaults write NSGlobalDomain AppleAccentColor -int 4
# Show all filename extensions in Finder and Open/Save panels (default: false).
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# macOS default: show scroll bars based on mouse/trackpad presence.
# defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"
# Disable two-finger swipe for back/forward in Safari, Finder, etc. (default: true).
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false
# macOS default: hide menu bar in full-screen apps.
# defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool false
# macOS default: double-click title bar zooms instead of minimizing.
# defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false
# Prefer tabs in full screen only, not always (default: manual).
defaults write NSGlobalDomain AppleWindowTabbingMode -string "fullscreen"
# Disable auto-capitalization (default: true).
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# macOS default: add a period after double-space.
# defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true
# Ask before closing documents with unsaved edits (default: false / auto-save).
defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -bool true
# Hide icons in contextual menus (default on recent macOS: false).
defaults write NSGlobalDomain NSMenuEnableActionImages -bool false
# macOS default: no sound on keyboard modifier keys.
# defaults write NSGlobalDomain "com.apple.sound.beep.feedback" -int 0
# macOS default: natural scroll direction (content follows finger).
# defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool true

# Pointer and keyboard speeds captured from this Mac.
# macOS default: middle tracking speed (4th notch).
# defaults write NSGlobalDomain "com.apple.mouse.scaling" -float 1
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

# Dock on the left (default: bottom).
defaults write com.apple.dock orientation -string "left"
# Auto-hide Dock (default: false).
defaults write com.apple.dock autohide -bool true
# No delay before Dock hides (default when autohide is on: 0).
defaults write com.apple.dock autohide-delay -float 0
# Instant show/hide animation (default: 0.5).
defaults write com.apple.dock autohide-time-modifier -float 0
# Large Dock icons (default: 48).
defaults write com.apple.dock tilesize -int 128
# Magnified icon size when magnification is on (default: 128; unused here).
defaults write com.apple.dock largesize -int 16
# macOS default: magnification off.
# defaults write com.apple.dock magnification -bool false
# Hide recent apps section (default: true).
defaults write com.apple.dock show-recents -bool false
# macOS default: genie minimize effect.
# defaults write com.apple.dock mineffect -string "genie"
# Disable app-launch bounce animation (default: true).
defaults write com.apple.dock launchanim -bool false
# Faster Mission Control animation (default: ~0.5).
defaults write com.apple.dock expose-animation-duration -float 0.1
# Bottom-right hot corner → Mission Control (default: disabled / 0).
defaults write com.apple.dock wvous-br-corner -int 14
# macOS default: no modifier key required for hot corners.
# defaults write com.apple.dock wvous-br-modifier -int 0

# Snappier window resize and close animations (defaults: 0.2s, animations on).
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
# macOS default: Reduce Motion off.
# defaults write com.apple.Accessibility ReduceMotionEnabled -bool false

###############################################################################
# Finder and Desktop
###############################################################################

# Hide all desktop icons/items (default: true / icons visible).
defaults write com.apple.finder CreateDesktop -bool false
# Hide external drives on desktop (default on recent macOS: false).
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
# macOS default: internal drives not shown on desktop.
# defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
# macOS default: removable media not shown on desktop.
# defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Redundant with NSGlobalDomain AppleShowAllExtensions above; kept for Finder domain.
defaults write com.apple.finder AppleShowAllExtensions -bool true
# Show folder path bar at bottom of Finder windows (default: false).
defaults write com.apple.finder ShowPathbar -bool true
# Show item count / free space bar (default: false).
defaults write com.apple.finder ShowStatusBar -bool true
# Hide recent tags in sidebar (default: true).
defaults write com.apple.finder ShowRecentTags -bool false
# Keep folders above files when sorting by name (default: false).
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
# Default new Finder windows to list view (default: icon view / icnv).
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Search current folder by default (default: this Mac / SCev).
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Skip warning when changing a file's default app (default: true).
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

###############################################################################
# Trackpad and mouse
###############################################################################

# Tap to click (default: false).
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# macOS default: drag without drag lock.
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool false
# macOS default: secondary click enabled.
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
# macOS default: three-finger drag off.
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false
# macOS default: three-finger horizontal swipe for Mission Control / App Exposé.
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 2
# macOS default: three-finger vertical swipe for Mission Control / App Exposé.
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
# macOS default: one-button mouse mode for Magic Mouse / trackpad.
# defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string "OneButton"
# macOS default: scroll axes and momentum enabled.
# defaults write com.apple.AppleMultitouchMouse MouseHorizontalScroll -bool true
# defaults write com.apple.AppleMultitouchMouse MouseMomentumScroll -bool true
# defaults write com.apple.AppleMultitouchMouse MouseVerticalScroll -bool true

###############################################################################
# Screenshots and screen recording defaults
###############################################################################

# Capture selection only instead of whole window (default: window).
defaults write com.apple.screencapture style -string "selection"
# Show click ripples in screen recordings (default: false).
defaults write com.apple.screencapture showsClicks -bool true
# Include cursor in screenshots/recordings (default: false).
defaults write com.apple.screencapture showsCursor -bool true
# Record screen captures as video (QuickTime-style) instead of stills only.
defaults write com.apple.screencapture video -bool true

###############################################################################
# Window Manager / Stage Manager
# (Most values below are macOS defaults while Stage Manager is off.)
###############################################################################

# macOS default: standard window grouping.
# defaults write com.apple.WindowManager AppWindowGroupingBehavior -int 0
# macOS default: Stage Manager strip stays visible.
# defaults write com.apple.WindowManager AutoHide -bool false
# macOS default.
# defaults write com.apple.WindowManager AutoHideDelay -float 0
# macOS default: tiled window margins off.
# defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
# macOS default: Stage Manager off.
# defaults write com.apple.WindowManager GloballyEnabled -bool false
# macOS default: desktop visible when Stage Manager is off.
# defaults write com.apple.WindowManager HideDesktop -bool false
# Hide widgets when Stage Manager is active (default when SM off: true).
defaults write com.apple.WindowManager StageManagerHideWidgets -bool true
# macOS default: desktop icons visible in standard mode.
# defaults write com.apple.WindowManager StandardHideDesktopIcons -bool false
# Hide widgets in standard desktop mode (personal preference).
defaults write com.apple.WindowManager StandardHideWidgets -bool true

###############################################################################
# Menu bar and Control Center
###############################################################################

# macOS default: digital clock.
# defaults write com.apple.menuextra.clock IsAnalog -bool false
# 24-hour-style clock without AM/PM (US default: 12-hour with AM/PM).
defaults write com.apple.menuextra.clock ShowAMPM -bool false
# Always show date in menu bar (default: often "when space allows").
defaults write com.apple.menuextra.clock ShowDate -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
# macOS default: hide seconds.
# defaults write com.apple.menuextra.clock ShowSeconds -bool false

# macOS default: these modules stay in Control Center, not the menu bar.
# defaults write com.apple.controlcenter "NSStatusItem Visible AccessibilityShortcuts" -bool false
# defaults write com.apple.controlcenter "NSStatusItem Visible AirDrop" -bool false
# defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool false
# defaults write com.apple.controlcenter "NSStatusItem Visible FocusModes" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Shortcuts" -bool true
# defaults write com.apple.controlcenter "NSStatusItem Visible StageManager" -bool false
# defaults write com.apple.controlcenter "NSStatusItem Visible Timer" -bool false
# defaults write com.apple.controlcenter "NSStatusItem Visible UserSwitcher" -bool false
# Pin these Control Center modules to the menu bar (default: hidden there).
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
