# Mac Bootstrap

This repo captures the current Mac setup in a form that can be re-run on a new machine.

The repo is **public** so you can clone it on a fresh Mac without signing in to GitHub first.

## Fresh Mac Flow

1. Sign in to iCloud and the App Store manually.
2. Install Xcode Command Line Tools:

   ```sh
   xcode-select --install
   ```

3. Clone this repo on the new Mac (no GitHub login required):

   ```sh
   git clone https://github.com/markmiro/macos-setup.git
   cd macos-setup
   ```

4. Run:

   ```sh
   ./scripts/bootstrap.sh
   ```

The bootstrap installs Homebrew if needed, runs `brew bundle`, applies macOS settings from `scripts/macos-defaults.sh`, and syncs git config from `dotfiles/`.

5. After installing Cursor, sync editor settings and extensions:

   ```sh
   ./scripts/sync-cursor.sh
   ```

## What Is Automated

- Homebrew taps, formulae, and casks from this machine.
- Dock location, size, autohide, recent apps, hot corner, and animation speed.
- Finder desktop icon hiding and default view preferences.
- Global UI preferences such as dark mode, file extensions, scroll behavior, keyboard repeat, mouse speed, and trackpad speed.
- Screenshot defaults.
- Stage Manager/window tiling preferences.
- Menu bar clock and selected Control Center visibility.
- Cursor user settings, keybindings, MCP config, CLI agent preferences, and extensions from `cursor/`.
- Git config and global gitignore from `dotfiles/` (`~/.gitconfig`, `~/.gitignore_global`).

## Manual Follow-Up

Some macOS settings are intentionally not scripted because they are tied to accounts, hardware security, app approvals, or private databases:

- iCloud account, Apple Pay, Find My, Messages, FaceTime.
- Touch ID, FileVault recovery, Lockdown Mode, privacy permissions, Screen Recording, Accessibility, Full Disk Access.
- Login Items and background item approvals for GUI apps.
- App Store purchases where no `mas` receipt is installed locally.
- Browser profiles, extensions, and logged-in app state.

See `manual-apps.md` for installed applications that were not present in the local Homebrew cask list.

See `manual-files.md` for project directories (`~/proj`, `~/github`), dotfiles, SSH keys, and other local data to migrate.

Dotfiles and secrets (`~/.zshrc`, `~/.npmrc`, `~/.ssh/`, etc.) are documented in `manual-files.md`. Git config is synced from `dotfiles/`; everything else must be copied manually on migration.

## Re-Audit This Mac

Run this when you make meaningful setup changes and want a snapshot:

```sh
./scripts/audit-current-mac.sh
```

It writes files under `audit/` with local preference and package information. That directory is gitignored.
