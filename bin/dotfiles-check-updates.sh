#!/bin/bash
# Check if dotfiles repo has updates available (similar to OMZ update check)
# Runs periodically (configured via ZSH_DOTFILES_UPDATE_FREQ days)

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
FREQ="${ZSH_DOTFILES_UPDATE_FREQ:-7}"  # Check every 7 days by default

# Exit early if not a git repo
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
  return 0
fi

# Get last update check timestamp file
LAST_UPDATE_FILE="$DOTFILES_DIR/.last_update_check"

# Check if we should run the update check
if [[ -f "$LAST_UPDATE_FILE" ]]; then
  LAST_UPDATE=$(cat "$LAST_UPDATE_FILE")
  CURRENT_TIME=$(date +%s)
  DAYS_SINCE=$((($CURRENT_TIME - $LAST_UPDATE) / 86400))
  
  if [[ $DAYS_SINCE -lt $FREQ ]]; then
    # Not yet time to check
    return 0
  fi
fi

# Update the timestamp
date +%s > "$LAST_UPDATE_FILE" 2>/dev/null || return 0

# Check for updates (non-blocking, quiet)
(
  cd "$DOTFILES_DIR" || return 0
  
  # Fetch without blocking
  git fetch origin main --quiet 2>/dev/null || return 0
  
  # Check if there are commits behind
  if git diff --quiet @{u}..HEAD 2>/dev/null; then
    # We're ahead or even
    return 0
  else
    # We're behind, show a message
    BEHIND=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    if [[ $BEHIND -gt 0 ]]; then
      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "📦 Dotfiles update available ($BEHIND commits behind)"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "Run: cd ~/.dotfiles && git pull"
      echo ""
    fi
  fi
) &
