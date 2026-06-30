#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CURSOR_DIR="$REPO_DIR/cursor"

CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
CURSOR_HOME_DIR="$HOME/.cursor"

cursor_bin() {
  if command -v cursor >/dev/null 2>&1; then
    command cursor
    return
  fi

  if [[ -x "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" ]]; then
    "/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
    return
  fi

  echo "Cursor CLI not found. Install Cursor and ensure the 'cursor' command is on PATH."
  exit 1
}

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

merge_cli_config() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [[ ! -f "$target" ]]; then
    cp "$source" "$target"
    echo "Installed cli-config.json -> $target"
    return
  fi

  if command -v jq >/dev/null 2>&1; then
    local merged
    merged="$(mktemp)"
    jq -s '.[0] * .[1]' "$target" "$source" > "$merged"
    backup_if_exists "$target"
    mv "$merged" "$target"
    echo "Merged cli-config.json preferences into $target (kept existing auth/session fields)"
  else
    echo "jq not found; skipping cli-config.json merge to avoid overwriting auth state."
    echo "Install jq or copy $source manually."
  fi
}

echo "Syncing Cursor settings from $CURSOR_DIR..."

install_file "$CURSOR_DIR/user/settings.json" "$CURSOR_USER_DIR/settings.json"
install_file "$CURSOR_DIR/user/keybindings.json" "$CURSOR_USER_DIR/keybindings.json"
install_file "$CURSOR_DIR/mcp.json" "$CURSOR_HOME_DIR/mcp.json"
merge_cli_config "$CURSOR_DIR/cli-config.json" "$CURSOR_HOME_DIR/cli-config.json"

if [[ -f "$CURSOR_DIR/extensions.txt" ]]; then
  echo "Installing Cursor extensions..."
  while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" || "$extension" =~ ^# ]] && continue
    cursor_bin --install-extension "$extension" --force
  done < "$CURSOR_DIR/extensions.txt"
fi

echo "Done. Restart Cursor if it is already open."
