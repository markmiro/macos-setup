#!/usr/bin/env bash

# Prepare this Mac for a day of unattended development through ChatGPT Remote.
# The script never prints credential values. Configuration is via the
# REMOTE_READY_* environment variables documented in docs/remote-work-readiness.md.

set -uo pipefail

PROJECT_DIR="${REMOTE_READY_EXPO_PROJECT:-$HOME/Documents/gift-cardy}"
EXPO_PORT="${REMOTE_READY_EXPO_PORT:-8081}"
NODE_VERSION="${REMOTE_READY_NODE_VERSION:-24.18.0}"
STATE_DIR="${REMOTE_READY_STATE_DIR:-$HOME/Library/Application Support/remote-ready}"
MIN_HOURS="${REMOTE_READY_MIN_HOURS:-36}"
START_SERVICES="${REMOTE_READY_START_SERVICES:-1}"
CODEX_PROBE="${REMOTE_READY_CODEX_PROBE:-1}"
CHECK_OPENROUTER="${REMOTE_READY_CHECK_OPENROUTER:-1}"
REQUIRE_IOS="${REMOTE_READY_REQUIRE_IOS_DEVICE:-1}"
REQUIRE_ANDROID="${REMOTE_READY_REQUIRE_ANDROID_DEVICE:-1}"
EXPO_CLEAR="${REMOTE_READY_EXPO_CLEAR:-0}"

INTERACTIVE=0
[[ -t 0 && -t 1 ]] && INTERACTIVE=1
BLOCKERS=0
WARNINGS=0
TAILSCALE_IP=""
TAILSCALE_CLI=""
CAFFEINATE_LABEL="com.markmiro.remote-ready.caffeinate"
METRO_LABEL="com.markmiro.remote-ready.metro"
TMUX_SESSION="remote-ready-metro"

usage() {
  cat <<'EOF'
Usage: remote-ready [options]

Checks credentials, starts Tailscale/Ollama/Metro, keeps the Mac awake, and
verifies iOS and Android development-device availability.

Options:
  --check-only       Check readiness without starting services.
  --non-interactive  Never open a login flow; report failures instead.
  --skip-codex-probe Skip the small live Codex API probe.
  --stop             Stop Metro/caffeinate processes started by this command.
  -h, --help         Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-only) START_SERVICES=0 ;;
    --non-interactive) INTERACTIVE=0 ;;
    --skip-codex-probe) CODEX_PROBE=0 ;;
    --stop)
      mkdir -p "$STATE_DIR"
      uid="$(id -u)"
      for label in "$METRO_LABEL" "$CAFFEINATE_LABEL"; do
        launchctl bootout "gui/$uid/$label" >/dev/null 2>&1 || true
      done
      if command -v tmux >/dev/null 2>&1; then
        tmux kill-session -t "$TMUX_SESSION" >/dev/null 2>&1 || true
      fi
      # Clean up PID-file jobs created by versions prior to launchd support.
      for name in metro caffeinate; do
        pid_file="$STATE_DIR/$name.pid"
        if [[ -f "$pid_file" ]]; then
          pid="$(sed -n '1p' "$pid_file")"
          if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
            echo "Stopped $name (PID $pid)."
          fi
          rm -f "$pid_file"
        fi
      done
      echo "Stopped remote-ready launchd jobs."
      exit 0
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if ! mkdir -p "$STATE_DIR"; then
  echo "Could not create runtime state directory: $STATE_DIR" >&2
  exit 1
fi

if [[ -t 1 ]]; then
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  RED=$'\033[31m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  GREEN="" YELLOW="" RED="" BOLD="" RESET=""
fi

section() { printf '\n%s%s%s\n' "$BOLD" "$1" "$RESET"; }
pass() { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$RESET" "$1"; WARNINGS=$((WARNINGS + 1)); }
fail() { printf '%s✗%s %s\n' "$RED" "$RESET" "$1"; BLOCKERS=$((BLOCKERS + 1)); }

timebox() {
  local seconds="$1"
  shift
  /usr/bin/perl -e '$seconds = shift; $SIG{ALRM} = sub { exit 124 }; alarm $seconds; exec @ARGV' "$seconds" "$@"
}

command_path() {
  command -v "$1" 2>/dev/null || true
}

repair_login() {
  local service="$1"
  shift
  if [[ "$INTERACTIVE" -eq 1 ]]; then
    echo "  $service needs attention; opening its login flow now."
    "$@"
  else
    return 1
  fi
}

check_internet() {
  curl -fsS --connect-timeout 5 --max-time 15 -o /dev/null https://api.github.com/
}

github_expiration_header() {
  local gh="$1" headers
  headers="$(env GH_HTTP_TIMEOUT=20 "$gh" api --include --silent user 2>/dev/null)" || return 1
  awk 'BEGIN { IGNORECASE=1 }
       /^github-authentication-token-expiration:/ {
         sub(/^[^:]+:[[:space:]]*/, "")
         sub(/\r$/, "")
         print
         exit
       }' <<< "$headers"
}

github_expiration_epoch() {
  local value="$1" epoch format
  for format in \
    '%Y-%m-%d %H:%M:%S %z' \
    '%Y-%m-%d %H:%M:%S UTC' \
    '%Y-%m-%dT%H:%M:%SZ'; do
    epoch="$(date -j -f "$format" "$value" '+%s' 2>/dev/null || true)"
    if [[ "$epoch" =~ ^[0-9]+$ ]]; then
      printf '%s\n' "$epoch"
      return
    fi
  done
  return 1
}

check_github() {
  local gh token_prefix expiry expiry_epoch now remaining_hours
  gh="$(command_path gh)"
  if [[ -z "$gh" ]]; then
    fail "GitHub CLI is not installed."
    return
  fi

  if ! check_internet; then
    fail "Internet/API access is unavailable; credential checks would be misleading."
    return
  fi

  if ! env GH_PROMPT_DISABLED=1 GH_HTTP_TIMEOUT=20 "$gh" auth status -h github.com >/dev/null 2>&1; then
    if ! repair_login "GitHub" "$gh" auth login -h github.com -p https -w || \
       ! env GH_PROMPT_DISABLED=1 GH_HTTP_TIMEOUT=20 "$gh" auth status -h github.com >/dev/null 2>&1; then
      fail "GitHub OAuth failed. Run: gh auth login -h github.com -p https -w"
      return
    fi
  fi

  # Retain only the non-secret credential prefix.
  token_prefix="$("$gh" auth token -h github.com 2>/dev/null | cut -c1-4)"
  expiry="$(github_expiration_header "$gh")"
  if [[ $? -ne 0 ]]; then
    fail "GitHub accepted auth status, but the live expiration check failed."
    return
  fi

  if [[ -n "$expiry" ]]; then
    expiry_epoch="$(github_expiration_epoch "$expiry" || true)"
    if [[ ! "$expiry_epoch" =~ ^[0-9]+$ ]]; then
      fail "GitHub reports an expiration, but its timestamp could not be parsed."
      return
    fi
    now="$(date +%s)"
    remaining_hours=$(( (expiry_epoch - now) / 3600 ))
    if [[ "$remaining_hours" -ge "$MIN_HOURS" ]]; then
      pass "GitHub token is accepted and has ${remaining_hours}h until scheduled expiration (checked, not refreshed)."
      return
    fi

    if repair_login "GitHub" "$gh" auth refresh -h github.com; then
      expiry="$(github_expiration_header "$gh")"
      if [[ -z "$expiry" ]]; then
        pass "GitHub reauthentication produced a token with no scheduled expiration."
        return
      fi
      expiry_epoch="$(github_expiration_epoch "$expiry" || true)"
      now="$(date +%s)"
      if [[ "$expiry_epoch" =~ ^[0-9]+$ ]] && (( (expiry_epoch - now) / 3600 >= MIN_HOURS )); then
        pass "GitHub token was reauthenticated and now exceeds the ${MIN_HOURS}h safety window."
        return
      fi
    fi
    fail "GitHub token has only ${remaining_hours}h left; reauthenticate before leaving."
    return
  fi

  case "$token_prefix" in
    gho_)
      pass "GitHub uses a long-lived OAuth token with no scheduled expiration (accepted now; no refresh needed)."
      ;;
    ghp_|gith)
      pass "GitHub API reports no scheduled expiration for the active personal access token."
      ;;
    ghu_)
      fail "GitHub uses a normally short-lived GitHub App token, but no expiration was reported; reauthenticate before leaving."
      ;;
    *)
      fail "GitHub accepted the token, but its type and expiration horizon could not be proven."
      ;;
  esac
}

check_expo() {
  local eas output
  eas="$(command_path eas)"
  if [[ -z "$eas" ]]; then
    fail "EAS CLI is not installed."
    return
  fi

  output="$(timebox 30 env CI=1 EAS_NO_VCS=1 "$eas" whoami 2>&1)"
  if [[ $? -eq 0 ]]; then
    pass "Expo/EAS session is accepted by api.expo.dev."
    return
  fi

  # Only launch login when EAS itself says this is an authentication problem.
  # Network outages must not be mislabeled as expired tokens.
  if grep -Eqi 'not logged|log in|login|unauthorized|authentication' <<< "$output" && \
     repair_login "Expo/EAS" "$eas" login && \
     timebox 30 env CI=1 EAS_NO_VCS=1 "$eas" whoami >/dev/null 2>&1; then
    pass "Expo/EAS login was repaired and rechecked."
  elif grep -Eqi 'ENOTFOUND|timed out|network|GraphQL request failed|connect' <<< "$output"; then
    fail "Expo API is unreachable; the stored session could not be judged."
  else
    fail "Expo/EAS session failed. Run: eas login"
  fi
}

codex_access_expiry() {
  local auth_file="$HOME/.codex/auth.json"
  [[ -r "$auth_file" ]] || return 1
  jq -r '.tokens.access_token // empty' "$auth_file" 2>/dev/null |
    cut -d. -f2 |
    tr '_-' '/+' |
    awk '{ remainder=length($0)%4; if (remainder==2) $0=$0"=="; else if (remainder==3) $0=$0"="; print }' |
    base64 -d 2>/dev/null |
    jq -r '.exp // empty' 2>/dev/null
}

run_codex_probe() {
  local codex="$1"
  printf '%s\n' 'Reply with exactly READY. Do not use tools.' |
    timebox 120 "$codex" exec \
      --ephemeral \
      --ignore-user-config \
      --ignore-rules \
      --skip-git-repo-check \
      --sandbox read-only \
      --color never \
      - >"$STATE_DIR/codex-probe.log" 2>&1
}

check_codex() {
  local codex status expiry now remaining_hours
  codex="$(command_path codex)"
  if [[ -z "$codex" ]]; then
    fail "Codex CLI is not installed."
    return
  fi

  # Capture before matching: with pipefail, grep -q can close the pipe early and
  # make an otherwise successful Codex command look like a failure.
  status="$("$codex" login status 2>&1)"
  if ! grep -q 'Logged in' <<< "$status"; then
    if ! repair_login "Codex" "$codex" login; then
      fail "Codex is not logged in. Run: codex login"
      return
    fi
  fi

  if [[ "$CODEX_PROBE" -eq 1 ]]; then
    if run_codex_probe "$codex"; then
      pass "Codex ChatGPT session completed a live API probe (refresh works)."
    elif repair_login "Codex" "$codex" login && run_codex_probe "$codex"; then
      pass "Codex login was repaired and completed a live API probe."
    else
      fail "Codex is locally logged in but its live API probe failed; see $STATE_DIR/codex-probe.log"
      return
    fi
  else
    warn "Codex reports logged in locally; the live refresh-token probe was skipped."
  fi

  expiry="$(codex_access_expiry || true)"
  if [[ "$expiry" =~ ^[0-9]+$ ]]; then
    now="$(date +%s)"
    remaining_hours=$(( (expiry - now) / 3600 ))
    if [[ "$remaining_hours" -ge "$MIN_HOURS" ]]; then
      pass "Current Codex access token has ${remaining_hours}h left (and is renewable)."
    elif [[ "$CODEX_PROBE" -eq 1 ]]; then
      warn "Codex access token has ${remaining_hours}h left, but the refresh path works."
    else
      fail "Codex access token has only ${remaining_hours}h left and refresh was not tested."
    fi
  fi
}

check_openrouter() {
  local env_file="$PROJECT_DIR/.env" key http_code
  [[ "$CHECK_OPENROUTER" -eq 1 ]] || return
  if [[ ! -r "$env_file" ]]; then
    warn "OpenRouter check skipped: $env_file is missing."
    return
  fi

  key="$(sed -n 's/^[[:space:]]*OPEN_ROUTER_KEY[[:space:]]*=[[:space:]]*//p' "$env_file" | tail -1)"
  key="${key%\"}"; key="${key#\"}"; key="${key%\'}"; key="${key#\'}"
  if [[ -z "$key" ]]; then
    fail "OPEN_ROUTER_KEY is not configured in $env_file."
    return
  fi

  # curl imports the secret from the environment and expands it internally, so
  # the token is not exposed in the process argument list or output.
  http_code="$(OPEN_ROUTER_KEY="$key" curl -sS \
    --connect-timeout 5 --max-time 20 \
    --variable '%OPEN_ROUTER_KEY' \
    --expand-header 'Authorization: Bearer {{OPEN_ROUTER_KEY}}' \
    -o /dev/null -w '%{http_code}' \
    https://openrouter.ai/api/v1/auth/key 2>/dev/null)"
  unset key
  if [[ "$http_code" == "200" ]]; then
    pass "OpenRouter API key is accepted (API keys do not have a scheduled daily expiry)."
  elif [[ "$http_code" == "401" || "$http_code" == "403" ]]; then
    fail "OpenRouter rejected the configured API key; replace OPEN_ROUTER_KEY before leaving."
  else
    fail "OpenRouter could not be verified (HTTP ${http_code:-unreachable})."
  fi
}

find_tailscale_cli() {
  local candidate
  # The App Store build commonly exposes its CLI through a zsh alias rather
  # than an installed PATH entry. Aliases are not inherited by this Bash
  # script, so include the app executable explicitly.
  for candidate in \
    "$(command_path tailscale)" \
    /usr/local/bin/tailscale \
    /opt/homebrew/bin/tailscale \
    "$HOME/.local/bin/tailscale" \
    /Applications/Tailscale.app/Contents/MacOS/Tailscale; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done
}

tailscale_interface_ip() {
  ifconfig 2>/dev/null | awk '/^[a-z0-9]+:/{iface=$1; sub(":$","",iface)} /inet 100\./{print $2; exit}'
}

check_tailscale() {
  local status_json expiry expiry_epoch now remaining_hours peer_count
  if [[ "$START_SERVICES" -eq 1 ]]; then
    open -gja Tailscale >/dev/null 2>&1 || true
  fi

  TAILSCALE_CLI="$(find_tailscale_cli || true)"
  if [[ -n "$TAILSCALE_CLI" ]]; then
    status_json="$(timebox 15 "$TAILSCALE_CLI" status --json 2>/dev/null)"
    if [[ $? -ne 0 || -z "$status_json" ]]; then
      fail "Tailscale CLI is installed, but the VPN backend is unavailable."
      return
    fi
    TAILSCALE_IP="$(jq -r '.TailscaleIPs[0] // empty' <<< "$status_json")"
    if [[ "$(jq -r '.BackendState // empty' <<< "$status_json")" == "Running" && -n "$TAILSCALE_IP" ]]; then
      pass "Tailscale is running at $TAILSCALE_IP."
    else
      fail "Tailscale is not connected. Open the Tailscale app and sign in."
      return
    fi

    expiry="$(jq -r '.Self.KeyExpiry // empty' <<< "$status_json")"
    if [[ -n "$expiry" && "$expiry" != "0001-01-01T00:00:00Z" ]]; then
      expiry_epoch="$(date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$expiry" '+%s' 2>/dev/null || true)"
      if [[ "$expiry_epoch" =~ ^[0-9]+$ ]]; then
        now="$(date +%s)"
        remaining_hours=$(( (expiry_epoch - now) / 3600 ))
        if [[ "$remaining_hours" -ge "$MIN_HOURS" ]]; then
          pass "Tailscale node key has ${remaining_hours}h left."
        else
          fail "Tailscale node key has only ${remaining_hours}h left; reauthenticate it now."
        fi
      fi
    else
      pass "Tailscale node-key expiry is disabled for this device."
    fi

    peer_count="$(jq '[.Peer[]? | select(.Online == true)] | length' <<< "$status_json")"
    if [[ "$peer_count" -gt 0 ]]; then
      pass "Tailscale reports $peer_count other online device(s)."
    else
      warn "No other Tailscale device is online; open Tailscale on each phone before leaving."
    fi
  else
    for _ in {1..15}; do
      TAILSCALE_IP="$(tailscale_interface_ip)"
      [[ -n "$TAILSCALE_IP" ]] && break
      [[ "$START_SERVICES" -eq 1 ]] || break
      sleep 1
    done
    if [[ -n "$TAILSCALE_IP" ]]; then
      pass "Tailscale interface is connected at $TAILSCALE_IP."
      warn "Tailscale CLI integration is absent, so node-key expiry and phone peers cannot be checked. Enable Tailscale Settings → CLI Integration."
    else
      fail "No active Tailscale interface was found."
    fi
  fi
}

start_keep_awake() {
  local uid job_state
  [[ "$START_SERVICES" -eq 1 ]] || return
  uid="$(id -u)"
  job_state="$(launchctl print "gui/$uid/$CAFFEINATE_LABEL" 2>/dev/null || true)"
  if grep -q 'state = running' <<< "$job_state"; then
    pass "Mac sleep prevention is already owned by launchd."
    return
  fi
  launchctl bootout "gui/$uid/$CAFFEINATE_LABEL" >/dev/null 2>&1 || true
  if ! launchctl submit \
      -l "$CAFFEINATE_LABEL" \
      -o "$STATE_DIR/caffeinate.log" \
      -e "$STATE_DIR/caffeinate.log" \
      -- /usr/bin/caffeinate -dimsu >/dev/null 2>&1; then
    fail "Could not start caffeinate; the Mac may sleep while you are away."
    return
  fi
  for _ in {1..20}; do
    job_state="$(launchctl print "gui/$uid/$CAFFEINATE_LABEL" 2>/dev/null || true)"
    if grep -q 'state = running' <<< "$job_state"; then
      pass "Mac will stay awake; launchd owns caffeinate independently of this shell."
      return
    fi
    sleep 0.1
  done
  fail "Could not confirm caffeinate; the Mac may sleep while you are away."
}

start_ollama() {
  [[ "$START_SERVICES" -eq 1 ]] || return
  if ! command -v ollama >/dev/null 2>&1; then
    warn "Ollama is not installed; skipping its service."
    return
  fi
  if curl -fsS --max-time 2 -o /dev/null http://127.0.0.1:11434/api/tags; then
    pass "Ollama is already responding on localhost:11434."
    return
  fi
  if command -v brew >/dev/null 2>&1; then
    HOMEBREW_NO_AUTO_UPDATE=1 brew services start ollama >/dev/null 2>&1 || true
  else
    nohup ollama serve >"$STATE_DIR/ollama.log" 2>&1 &
  fi
  for _ in {1..20}; do
    if curl -fsS --max-time 2 -o /dev/null http://127.0.0.1:11434/api/tags; then
      pass "Ollama is responding on localhost:11434."
      return
    fi
    sleep 1
  done
  warn "Ollama did not become ready; see $STATE_DIR/ollama.log"
}

metro_healthy() {
  [[ "$(curl -fsS --max-time 2 "http://127.0.0.1:$EXPO_PORT/status" 2>/dev/null)" == "packager-status:running" ]]
}

start_metro() {
  local expo_bin="$PROJECT_DIR/node_modules/.bin/expo"
  local fnm tmux metro_command
  if metro_healthy; then
    pass "Metro is already responding on port $EXPO_PORT."
    return
  fi
  if [[ "$START_SERVICES" -eq 0 ]]; then
    fail "Metro is not running on port $EXPO_PORT."
    return
  fi
  if [[ ! -d "$PROJECT_DIR" || ! -x "$expo_bin" ]]; then
    fail "Expo project or local Expo binary is missing at $PROJECT_DIR."
    return
  fi
  fnm="$(command_path fnm)"
  if [[ -z "$fnm" ]]; then
    fail "fnm is not installed; cannot start Metro with Node $NODE_VERSION."
    return
  fi
  tmux="$(command_path tmux)"
  if [[ -z "$tmux" ]]; then
    fail "tmux is not installed; Metro cannot outlive the launching shell."
    return
  fi
  "$tmux" kill-session -t "$TMUX_SESSION" >/dev/null 2>&1 || true
  : > "$STATE_DIR/metro.log"
  if [[ "$EXPO_CLEAR" -eq 1 ]]; then
    printf -v metro_command 'exec %q exec --using=%q %q start --go --lan --port %q --clear >> %q 2>&1' \
      "$fnm" "$NODE_VERSION" "$expo_bin" "$EXPO_PORT" "$STATE_DIR/metro.log"
  else
    printf -v metro_command 'exec %q exec --using=%q %q start --go --lan --port %q >> %q 2>&1' \
      "$fnm" "$NODE_VERSION" "$expo_bin" "$EXPO_PORT" "$STATE_DIR/metro.log"
  fi
  if ! "$tmux" new-session -d -s "$TMUX_SESSION" -c "$PROJECT_DIR" "$metro_command"; then
    fail "tmux could not start the Metro session."
    return
  fi
  for _ in {1..60}; do
    if metro_healthy; then
      pass "Metro is responding on port $EXPO_PORT in persistent tmux session '$TMUX_SESSION'."
      return
    fi
    if ! "$tmux" has-session -t "$TMUX_SESSION" 2>/dev/null; then
      break
    fi
    sleep 1
  done
  fail "Metro did not become ready; see $STATE_DIR/metro.log"
}

check_ios_device() {
  local output json available paired
  if ! command -v xcrun >/dev/null 2>&1; then
    warn "Xcode tools are absent; iPhone pairing cannot be checked."
    return
  fi
  output="$(timebox 12 xcrun xcdevice list --timeout 6 2>/dev/null)"
  json="$(sed -n '/^[[:space:]]*\[/,$p' <<< "$output")"
  if ! jq -e . >/dev/null 2>&1 <<< "$json"; then
    if [[ "$REQUIRE_IOS" -eq 1 ]]; then fail "Xcode could not enumerate the iPhone."; else warn "Xcode could not enumerate the iPhone."; fi
    return
  fi
  available="$(jq '[.[] | select(.simulator == false and .platform == "com.apple.platform.iphoneos" and .available == true)] | length' <<< "$json")"
  paired="$(jq '[.[] | select(.simulator == false and .platform == "com.apple.platform.iphoneos")] | length' <<< "$json")"
  if [[ "$available" -gt 0 ]]; then
    pass "iPhone is paired and available to Xcode."
  elif [[ "$paired" -gt 0 ]]; then
    if [[ "$REQUIRE_IOS" -eq 1 ]]; then fail "iPhone is paired but unavailable; unlock/reconnect it before leaving."; else warn "iPhone is paired but unavailable."; fi
  else
    if [[ "$REQUIRE_IOS" -eq 1 ]]; then fail "No physical iPhone is visible to Xcode; connect, unlock, and trust this Mac."; else warn "No physical iPhone is visible to Xcode."; fi
  fi
}

find_adb() {
  local adb
  adb="$(command_path adb)"
  if [[ -n "$adb" ]]; then printf '%s\n' "$adb"; return; fi
  [[ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]] && printf '%s\n' "$HOME/Library/Android/sdk/platform-tools/adb"
}

check_android_device() {
  local adb output connected unauthorized offline
  adb="$(find_adb)"
  if [[ -z "$adb" ]]; then
    if [[ "$REQUIRE_ANDROID" -eq 1 ]]; then fail "ADB is not installed."; else warn "ADB is not installed."; fi
    return
  fi
  output="$(timebox 12 "$adb" devices -l 2>&1)"
  connected="$(awk '$2 == "device" {n++} END {print n+0}' <<< "$output")"
  unauthorized="$(awk '$2 == "unauthorized" {n++} END {print n+0}' <<< "$output")"
  offline="$(awk '$2 == "offline" {n++} END {print n+0}' <<< "$output")"
  if [[ "$connected" -gt 0 ]]; then
    pass "Android device is paired and available to ADB."
  elif [[ "$unauthorized" -gt 0 ]]; then
    fail "Android is connected but unauthorized; unlock it and accept the USB-debugging prompt."
  elif [[ "$offline" -gt 0 ]]; then
    fail "Android is paired but offline; reconnect USB or wireless debugging."
  else
    if [[ "$REQUIRE_ANDROID" -eq 1 ]]; then fail "No Android device is visible to ADB; connect it or reconnect wireless debugging."; else warn "No Android device is visible to ADB."; fi
  fi
}

check_signing() {
  local count
  count="$(security find-identity -v -p codesigning 2>/dev/null | awk '/valid identities found/ {print $1}')"
  if [[ "${count:-0}" -gt 0 ]]; then
    pass "A valid local Apple code-signing identity is installed."
  else
    warn "No local Apple code-signing identity is installed; Expo Go works, but local native iOS rebuilds will not."
  fi
}

echo "Remote work readiness — $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Project: $PROJECT_DIR"

section "Credentials"
check_github
check_expo
check_codex
check_openrouter

section "Remote access"
check_tailscale
start_keep_awake

section "Development services"
start_ollama
start_metro

section "Phones"
check_ios_device
check_android_device
check_signing

section "Handoff"
if [[ -n "$TAILSCALE_IP" ]] && metro_healthy; then
  echo "Expo URL: exp://$TAILSCALE_IP:$EXPO_PORT"
  echo "Open that URL in Expo Go while each phone's Tailscale app is connected."
fi
echo "Logs: $STATE_DIR"

if [[ "$BLOCKERS" -eq 0 ]]; then
  printf '%sREADY%s — %d warning(s), no known blocker for the next %sh.\n' "$GREEN" "$RESET" "$WARNINGS" "$MIN_HOURS"
  exit 0
fi

printf '%sNOT READY%s — %d blocker(s), %d warning(s). Fix the ✗ items before leaving.\n' "$RED" "$RESET" "$BLOCKERS" "$WARNINGS"
exit 1
