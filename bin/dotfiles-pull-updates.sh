#!/bin/bash
# Update dotfiles repo from remote and reload shell config
# Usage: dotfiles-pull-updates [--check-only]

set -e

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
if [[ "$1" == "--check-only" ]]; then
  echo "Checking for updates..."
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

# Pull updates
echo "🔄 Pulling dotfiles updates..."
git fetch --quiet || true
git pull --ff-only

echo "✅ Dotfiles updated successfully!"
echo "💡 Reload your shell to apply changes: exec zsh"
