#!/bin/bash
# Check for dotfiles updates and optionally auto-update or prompt
# Frequency controlled via ZSH_DOTFILES_UPDATE_FREQ (days)

# Dynamically determine the dotfiles directory from script location
# Resolve symlinks to get the actual script location
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
  SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
  [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
FREQ="${ZSH_DOTFILES_UPDATE_FREQ:-7}"       # default: check every 7 days
AUTOUPDATE="${ZSH_DOTFILES_AUTOUPDATE:-false}" # true to auto-update when behind

# Only run if this is a git repo
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
  return 0 2>/dev/null || exit 0
fi

# Avoid concurrent runs
LOCK_FILE="$DOTFILES_DIR/.update.lock"
if [[ -f "$LOCK_FILE" ]]; then
  return 0 2>/dev/null || exit 0
fi

LAST_UPDATE_FILE="$DOTFILES_DIR/.last_update_check"
CURRENT_TIME=$(date +%s)

# Respect check frequency
if [[ -f "$LAST_UPDATE_FILE" ]]; then
  LAST_UPDATE=$(cat "$LAST_UPDATE_FILE" 2>/dev/null)
  [[ -n "$LAST_UPDATE" ]] || LAST_UPDATE=0
  DAYS_SINCE=$(( (CURRENT_TIME - LAST_UPDATE) / 86400 ))
  if [[ $DAYS_SINCE -lt $FREQ ]]; then
    return 0 2>/dev/null || exit 0
  fi
fi

# Update the timestamp and create a light lock
echo "$CURRENT_TIME" > "$LAST_UPDATE_FILE" 2>/dev/null || true
echo $$ > "$LOCK_FILE" 2>/dev/null || true

trap 'rm -f "$LOCK_FILE"' EXIT
cd "$DOTFILES_DIR" || { rm -f "$LOCK_FILE"; return 0 2>/dev/null || exit 0; }

# Quietly fetch upstream
git fetch --quiet 2>/dev/null || { rm -f "$LOCK_FILE"; return 0 2>/dev/null || exit 0; }

# Determine commit deltas
BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)

if [[ "$BEHIND" -gt 0 ]]; then
  # Interactive shell? ($- contains 'i')
  if [[ "$AUTOUPDATE" == "true" ]]; then
    # Auto-update in background, do not block shell startup
    ( "$DOTFILES_DIR/bin/dotfiles-pull-updates.sh" >/dev/null 2>&1 & )
  elif [[ $- == *i* ]]; then
    # Offer to run the update for the user with a short timeout
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Dotfiles update available ($BEHIND commit(s) behind)"
    echo "Run update now? [y/N] (auto in ${FREQ}d)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    read -r -t 8 REPLY 2>/dev/null || REPLY=""
    if [[ "$REPLY" == [yY] ]]; then
      "$DOTFILES_DIR/bin/dotfiles-pull-updates.sh" || true
    else
      echo "(Skipped. You can run: dotfiles-pull-updates)"
    fi
  else
    # Non-interactive: show a short notice only
    echo ""
    echo "📦 Dotfiles update available ($BEHIND commit(s) behind)."
    echo "Run later: dotfiles-pull-updates"
  fi
fi

# Clean up lock
rm -f "$LOCK_FILE" 2>/dev/null || true
