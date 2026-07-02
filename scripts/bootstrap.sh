#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Install Xcode Command Line Tools first:"
  echo "  xcode-select --install"
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

echo "Installing Homebrew packages..."
brew bundle --file "$REPO_DIR/Brewfile"

if brew list ollama >/dev/null 2>&1; then
  echo "Starting Ollama service..."
  brew services start ollama || true
fi

echo "Applying macOS defaults..."
"$SCRIPT_DIR/macos-defaults.sh"

echo "Syncing git dotfiles..."
"$SCRIPT_DIR/sync-dotfiles.sh"

echo "Done. Some settings require logout or restart to fully apply."
