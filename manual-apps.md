# Manual Apps

Installed apps seen in `/Applications` but not in the local Homebrew cask list.
Many may still have casks, but they were not installed by Homebrew on this Mac.

## Account, Security, and Device Management

- 1Password
- Apple Configurator
- iMazing
- Ledger Live
- Trezor Suite

## Browsers and Web

- AdGuard for Safari
- ChatGPT Atlas
- Comet
- Firefox
- Google Chrome

## Communication and Meetings

- Signal
<!-- - Tella -->
- Toggl Track

## Creative, Media, and Design

- Blackmagic Disk Speed Test
- Figma
- Gifski
- iMovie
- Kap
<!-- - OBS -->
- Opal
- ProPresenter
- SF Symbols beta
- Shottr
<!-- - Speechify -->
<!-- - superwhisper -->

## Developer Tools

- Cursor
<!-- - DB Browser for SQLite -->
<!-- - GitHub Desktop -->
<!-- - GitKraken -->
<!-- - Modern CSV -->
<!-- - MySQLWorkbench -->
<!-- - Postgres -->
- Postico
- Postman
- Postman Agent
<!-- - Sublime Text -->
<!-- - Visual Studio Code -->
<!-- - Xcode -->
- Zed
- cmux

## Documents, Notes, and Writing

<!-- - BearWitness -->
- Obsidian
- Pages
<!-- - PDF Expert -->
<!-- - PDFgear -->
<!-- - Zotero -->

## Hardware, Network, and Utilities

<!-- - AmorphousDiskMark -->
<!-- - Angry IP Scanner -->
- BalenaEtcher
<!-- - Betaflight Configurator -->
- DaisyDisk
<!-- - Display Menu -->
<!-- - EasyRes -->
<!-- - Font Smoothing Adjuster -->
<!-- - IPFS Desktop -->
- LanScan
<!-- - NextDNS -->
- Raspberry Pi Imager
- Tailscale — install manually from the Apple App Store, not Homebrew
<!-- - Tapo -->
<!-- - Vivid -->

Tailscale is intentionally manual. The Apple App Store app provides the menu bar
app, uses macOS' normal VPN/network-extension approval flow, and receives app
updates through Apple's system. The Homebrew formula only installs the
`tailscale`/`tailscaled` command-line tools; running the daemon for normal
networking requires a root launchd service and still does not create the menu
bar app. Keeping this out of Homebrew makes fresh setup match the actual macOS
UX: install the app, approve the system prompts, and sign in.

## Menu Bar, Windowing, and Productivity

- Flux
<!-- - Hidden Bar -->
<!-- - iStat Menus -->
<!-- - KeyCastr -->
<!-- - MacGPT -->
<!-- - MacWhisper -->
<!-- - Magnet -->
<!-- - Next Meeting -->
- Pandan
- Raycast
<!-- - Rectangle Pro -->
<!-- - Soonie -->
<!-- - Umbra -->
- Up Next

## Games and Entertainment

- OpenRCT2
- Steam

## Remote, Virtualization, and Platform Apps

- Conductor
- Windows App

## Chat and AI Apps

- ChatGPT
- legcord
