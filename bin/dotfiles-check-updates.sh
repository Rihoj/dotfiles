#!/bin/bash
set -euo pipefail
# Check for dotfiles updates and optionally auto-update or prompt
# Frequency controlled via ZSH_DOTFILES_UPDATE_FREQ (days)

# Dynamically determine the dotfiles directory from script location
# Resolve symlinks to get the actual script location
SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
while [ -L "$SCRIPT_PATH" ]; do
  SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
  [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
done
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
FREQ="${ZSH_DOTFILES_UPDATE_FREQ:-1}"       # default: check every day (FREQ=0 runs every time)
AUTOUPDATE="${ZSH_DOTFILES_AUTOUPDATE:-true}" # true to auto-update when behind

# Validate numeric inputs
if ! [[ "$FREQ" =~ ^[0-9]+$ ]]; then
  FREQ=1
fi

CURRENT_TIME=$(date +%s)

# Only run if this is a git repo
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
  return 0 2>/dev/null || exit 0
fi

# Atomic lock with stale lock detection
LOCK_DIR="$DOTFILES_DIR/.update.lock"
LOCK_TIMEOUT=300
if mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "$$ $CURRENT_TIME $SCRIPT_PATH" > "$LOCK_DIR/info"
else
  LOCK_INFO="$LOCK_DIR/info"
  if [[ -f "$LOCK_INFO" ]]; then
    read -r LOCK_PID LOCK_TIME LOCK_SCRIPT < "$LOCK_INFO" 2>/dev/null || { LOCK_PID=""; LOCK_TIME=0; LOCK_SCRIPT=""; }
    if ! [[ "$LOCK_TIME" =~ ^[0-9]+$ ]]; then LOCK_TIME=0; fi
    LOCK_AGE=$((CURRENT_TIME - LOCK_TIME))
    
    # Check if process is still running this script
    PROC_CMD="$(ps -o args= -p "$LOCK_PID" 2>/dev/null || echo "")"
    if [[ -n "$LOCK_SCRIPT" && "$PROC_CMD" == *"$LOCK_SCRIPT"* ]]; then
      # Process running, respect lock
      return 0 2>/dev/null || exit 0
    elif [[ $LOCK_AGE -ge $LOCK_TIMEOUT ]]; then
      # Stale lock (process gone or old), remove and retry
      rm -rf "$LOCK_DIR"
      mkdir "$LOCK_DIR" 2>/dev/null || { return 0 2>/dev/null || exit 0; }
      echo "$$ $CURRENT_TIME $SCRIPT_PATH" > "$LOCK_DIR/info"
    else
      # Recent lock but process gone, respect lock anyway
      return 0 2>/dev/null || exit 0
    fi
  else
    # No info file, treat as stale and remove the lock
    rm -rf "$LOCK_DIR"
    return 0 2>/dev/null || exit 0
  fi
fi
trap 'rm -rf "$LOCK_DIR"' EXIT

LAST_UPDATE_FILE="$DOTFILES_DIR/.last_update_check"

# Respect check frequency
if [[ -f "$LAST_UPDATE_FILE" ]]; then
  LAST_UPDATE=$(cat "$LAST_UPDATE_FILE" 2>/dev/null || echo "0")
  if ! [[ "$LAST_UPDATE" =~ ^[0-9]+$ ]]; then
    LAST_UPDATE=0
  fi
  DAYS_SINCE=$(( (CURRENT_TIME - LAST_UPDATE) / 86400 ))
  if [[ $DAYS_SINCE -lt $FREQ ]]; then
    return 0 2>/dev/null || exit 0
  fi
fi

cd "$DOTFILES_DIR" || { return 0 2>/dev/null || exit 0; }

# Check if upstream exists before fetching
if ! git rev-parse @{u} >/dev/null 2>&1; then
  # No upstream configured
  return 0 2>/dev/null || exit 0
fi

# Optionally rewrite SSH remotes to HTTPS for public repos
if [[ "${ZSH_DOTFILES_AUTOHTTPS:-false}" == "true" ]]; then
  upstream_ref="$(git rev-parse --abbrev-ref @{u} 2>/dev/null || true)"
  upstream_remote="${upstream_ref%%/*}"
  if [[ -n "$upstream_remote" ]]; then
    remote_url="$(git remote get-url "$upstream_remote" 2>/dev/null || true)"
    case "$remote_url" in
      git@github.com:*|ssh://git@github.com/*)
        path="${remote_url#git@github.com:}"
        path="${path#ssh://git@github.com/}"
        path="${path%.git}"
        git remote set-url "$upstream_remote" "https://github.com/${path}.git" 2>/dev/null || true
        ;;
      git@gitlab.com:*|ssh://git@gitlab.com/*)
        path="${remote_url#git@gitlab.com:}"
        path="${path#ssh://git@gitlab.com/}"
        path="${path%.git}"
        git remote set-url "$upstream_remote" "https://gitlab.com/${path}.git" 2>/dev/null || true
        ;;
    esac
  fi
fi

# Quietly fetch upstream without prompting for SSH passphrases
GIT_SSH_COMMAND="ssh -o BatchMode=yes" GIT_TERMINAL_PROMPT=0 \
  git fetch --quiet 2>/dev/null || { return 0 2>/dev/null || exit 0; }

# Update timestamp after successful fetch
echo "$CURRENT_TIME" > "$LAST_UPDATE_FILE" 2>/dev/null || true

# Determine commit deltas
BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)

if [[ "$BEHIND" -gt 0 ]]; then
  if [[ "$AUTOUPDATE" == "true" ]]; then
    # Auto-update in background, do not block shell startup
    GIT_SSH_COMMAND="ssh -o BatchMode=yes" GIT_TERMINAL_PROMPT=0 \
      "$DOTFILES_DIR/bin/dotfiles-pull-updates.sh" >/dev/null 2>&1 &
  elif [[ $- == *i* ]]; then
    # Offer to run the update for the user with a short timeout
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Dotfiles update available ($BEHIND commit(s) behind)"
    echo "Run update now? [y/N] (timeout in 8s)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    read -r -t 8 REPLY 2>/dev/null || REPLY=""
    if [[ "$REPLY" == [yY] ]]; then
      "$DOTFILES_DIR/bin/dotfiles-pull-updates.sh" || true
    else
      echo "(Skipped. You can run: dotfiles-pull-updates)"
    fi
  else
    # Non-interactive: show a short notice to stderr
    echo "" >&2
    echo "📦 Dotfiles update available ($BEHIND commit(s) behind)." >&2
    echo "Run later: dotfiles-pull-updates" >&2
  fi
fi
