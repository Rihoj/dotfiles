#!/bin/bash
set -euo pipefail
# Update dotfiles repo from remote and reload shell config
# Usage: dotfiles-pull-updates [--check-only]

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

# Ensure it's a git repo
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
  echo "❌ Error: $DOTFILES_DIR is not a git repository"
  exit 1
fi

cd "$DOTFILES_DIR"

# Check for changes only
if [[ "${1-}" == "--check-only" ]]; then
  echo "Checking for updates..."
  if ! git rev-parse @{u} >/dev/null 2>&1; then
    echo "No upstream configured for this repository."
    exit 0
  fi
  # Avoid SSH passphrase prompts in check mode
  GIT_SSH_COMMAND="ssh -o BatchMode=yes" GIT_TERMINAL_PROMPT=0 \
    git fetch --quiet
  
  # Calculate behind/ahead relative to upstream
  BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
  AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
  if [[ "$BEHIND" -eq 0 ]]; then
    echo "✅ You're up to date!"
  else
    echo "📦 $BEHIND commit(s) available to pull"
    echo "Run: dotfiles-pull-updates"
  fi
  exit 0
fi

# Require upstream for pull updates
if ! git rev-parse @{u} >/dev/null 2>&1; then
  echo "❌ Error: No upstream configured for this repository." >&2
  exit 1
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

# Refuse to pull with local changes
if [[ -n "$(git status --porcelain)" ]]; then
  echo "❌ Error: Working tree has local changes. Commit or stash before updating." >&2
  exit 1
fi

# Refuse to pull when local commits exist
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
if [[ "$AHEAD" -gt 0 ]]; then
  echo "❌ Error: Local commits detected ($AHEAD ahead). Push or reset before updating." >&2
  exit 1
fi

# Pull updates
echo "🔄 Pulling dotfiles updates..."
git fetch --quiet || true
git pull --ff-only

echo "✅ Dotfiles updated successfully!"
echo "💡 Reload your shell to apply changes: exec zsh"
