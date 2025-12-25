#!/bin/bash
# Update dotfiles repo from remote and reload shell config
# Usage: dotfiles-pull-updates [--check-only]

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Ensure it's a git repo
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
  echo "❌ Error: $DOTFILES_DIR is not a git repository"
  exit 1
fi

cd "$DOTFILES_DIR"

# Check for changes only
if [[ "$1" == "--check-only" ]]; then
  echo "Checking for updates..."
  git fetch origin main --quiet
  
  if git diff --quiet @{u}..HEAD 2>/dev/null; then
    echo "✅ You're up to date!"
  else
    BEHIND=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    echo "📦 $BEHIND commit(s) available to pull"
    echo "Run: dotfiles-pull-updates"
  fi
  exit 0
fi

# Pull updates
echo "🔄 Pulling dotfiles updates..."
git fetch origin main
git pull origin main

echo "✅ Dotfiles updated successfully!"
echo "💡 Reload your shell to apply changes: exec zsh"
