#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"

backup_if_exists() {
  local target="$1"
  if [[ -f "$target" ]]; then
    cp "$target" "${target}.bak.$(date +%Y%m%d%H%M%S)"
  fi
}

install_file() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"
  backup_if_exists "$target"
  cp "$source" "$target"
  echo "Installed $(basename "$target") -> $target"
}

if ! command -v git >/dev/null 2>&1; then
  echo "git not found. Install Xcode Command Line Tools first:"
  echo "  xcode-select --install"
  exit 1
fi

echo "Syncing dotfiles from $DOTFILES_DIR..."

install_file "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
install_file "$DOTFILES_DIR/gitignore_global" "$HOME/.gitignore_global"

echo "Done."
echo "Commit signing needs 1Password and your SSH signing key in 1Password."
echo "GitHub push/pull to private repos needs: gh auth login"
