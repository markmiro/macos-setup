# Remote work readiness

## Prerequisites

`remote-ready` targets macOS. The core operating-system commands it uses
(`bash`, `curl`, `launchctl`, `caffeinate`, `ifconfig`, `open`, `security`, and
`xcrun`) are supplied by macOS or Xcode.

Install the required command-line tools:

```sh
brew install gh jq fnm tmux
fnm install 24.18.0
fnm exec --using=24.18.0 npm install --global eas-cli
```

You also need:

- Codex CLI, signed in with `codex login`.
- GitHub CLI, signed in with `gh auth login`.
- Expo/EAS CLI, signed in with `eas login`.
- The Tailscale macOS app, signed in and connected. The script supports either
  an installed `tailscale` command or the CLI executable inside the App Store
  app bundle.
- An Expo project with dependencies installed. The default is
  `~/Documents/gift-cardy`; change it with `REMOTE_READY_EXPO_PROJECT`.
- Node.js `24.18.0` available through `fnm`, unless
  `REMOTE_READY_NODE_VERSION` selects another installed version.
- An `OPEN_ROUTER_KEY` entry in the Expo project's `.env`, unless the
  OpenRouter check is disabled with `REMOTE_READY_CHECK_OPENROUTER=0`.

Workflow-specific prerequisites:

- For iPhone native-build checks: Xcode, Xcode Command Line Tools, a paired and
  trusted iPhone, and a valid Apple code-signing identity.
- For Android native-build checks: Android SDK Platform Tools (`adb`) and an
  authorized USB or wireless-debugging connection.
- For faster and more reliable Metro file watching: Watchman. This is
  recommended but not required.
- For local model startup: Ollama. This is optional; its absence is reported as
  a warning.

If a phone is not part of the morning workflow, set its corresponding
`REMOTE_READY_REQUIRE_IOS_DEVICE` or `REMOTE_READY_REQUIRE_ANDROID_DEVICE`
variable to `0` so absence is a warning rather than a blocker.

## Install

From the repository root:

```sh
mkdir -p "$HOME/.local/bin"
ln -sfn "$PWD/scripts/remote-ready.sh" "$HOME/.local/bin/remote-ready"
```

Ensure `~/.local/bin` is on `PATH`. The script stores runtime logs and state
outside the repository and never writes credential values to the checkout.

Run this from any terminal before leaving home:

```sh
remote-ready
```

The command performs live, value-free credential checks, starts the services
used by the current remote-development workflow, and reports a single
`READY`/`NOT READY` result. It never prints tokens.

## What it checks

| Surface | Credential/lifetime | Morning behavior |
| --- | --- | --- |
| GitHub CLI | OAuth token in macOS Keychain; normally long-lived but revocable | Calls GitHub's API, classifies the token, and enforces the expiration safety window; only reauthenticates when invalid or too close to expiry |
| Expo/EAS | Expo session secret; renewable/revocable | Calls `eas whoami`; opens `eas login` only when EAS reports an authentication failure |
| Codex | Short-lived access token plus renewable ChatGPT refresh token | Performs a tiny live Codex request, which proves that refresh still works |
| Tailscale | Device/node key; commonly long-lived and optionally non-expiring | Starts the app, checks the VPN, and checks key expiry when CLI Integration is installed |
| OpenRouter | API key in `gift-cardy/.env`; no scheduled daily expiry | Calls the key metadata endpoint without printing or putting the key in process arguments |
| Apple/Xcode | Device trust record plus signing certificate/profile | Checks that the iPhone is visible; separately warns if local iOS signing is unavailable |
| Android | ADB USB/wireless-debugging trust | Checks for `device`, `unauthorized`, and `offline` states |

A provider can still revoke a credential or have an outage after the check, so
no script can make a literal availability guarantee. `READY` means every
checkable credential is accepted now, expiring credentials have at least 36
hours left or a tested refresh path, the VPN is up, and the development server
is responding.

“Accepted” and “refreshed” are deliberately reported as different states. In
particular, `gh auth status` only tests the existing GitHub credential. The
workflow additionally reads GitHub's authenticated expiration response and the
credential type. A long-lived `gho_` OAuth token has no scheduled daily expiry,
so rotating it every morning would add risk without adding useful runway. If a
future GitHub token has an expiration timestamp, the command requires at least
`REMOTE_READY_MIN_HOURS` remaining and initiates reauthentication when below
that window.

## What it starts

- Tailscale
- `caffeinate`, so the Mac does not sleep
- Ollama (when installed)
- Expo Metro for `~/Documents/gift-cardy` on port 8081

Metro runs in a detached `tmux` session named `remote-ready-metro`, while
`caffeinate` is a per-user `launchd` job. They therefore survive the
Terminal/Codex shell that launched them; both stop at reboot and are recreated
by the next morning run.

Runtime state and logs are under:

```text
~/Library/Application Support/remote-ready/
```

Stop Metro and the keep-awake process started by the command with:

```sh
remote-ready --stop
```

## Phone testing

There are two independent kinds of “pairing”:

1. Xcode/ADB pairing is required to install or launch native development
   builds from the Mac.
2. Expo Go only needs Metro network reachability. Away from home, connect
   Tailscale on the Mac and phone, then open the printed
   `exp://100.x.y.z:8081` URL in Expo Go.

The morning check verifies both physical development-device states. Tailscale
CLI Integration additionally lets it verify node-key expiry and whether other
tailnet devices are online. Enable it in **Tailscale → Settings → CLI
Integration** once while the Mac is unlocked.

## Options and configuration

Useful options:

```sh
remote-ready --check-only
remote-ready --non-interactive
remote-ready --skip-codex-probe
remote-ready --stop
```

Defaults can be changed in the shell environment:

```sh
export REMOTE_READY_EXPO_PROJECT="$HOME/Documents/gift-cardy"
export REMOTE_READY_EXPO_PORT=8081
export REMOTE_READY_NODE_VERSION=24.18.0
export REMOTE_READY_MIN_HOURS=36
export REMOTE_READY_REQUIRE_IOS_DEVICE=1
export REMOTE_READY_REQUIRE_ANDROID_DEVICE=1
export REMOTE_READY_EXPO_CLEAR=0
```

Set either phone requirement to `0` to turn an absent development device from
a blocker into a warning. Do not export token values for this command; it reads
credentials from their normal Keychain/config locations.
