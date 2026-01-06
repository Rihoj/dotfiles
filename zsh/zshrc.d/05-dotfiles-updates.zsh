# Dotfiles auto-update check (similar to OMZ)
# Checks for updates every N days (default: 7)
# Customize with: export ZSH_DOTFILES_UPDATE_FREQ=14

# Set DOTFILES_DIR if not already set
# This is typically ~/.dotfiles when properly installed
if [[ -z "$DOTFILES_DIR" ]]; then
  # Try to detect from the zshrc location
  if [[ -L "$HOME/.zshrc" ]]; then
    local zshrc_target="$(readlink "$HOME/.zshrc")"
    if [[ -n "$zshrc_target" ]]; then
      DOTFILES_DIR="$(cd "$(dirname "$(dirname "$zshrc_target")")" 2>/dev/null && pwd)"
    fi
  fi
  # Fallback to standard location if detection failed
  [[ -z "$DOTFILES_DIR" ]] && DOTFILES_DIR="$HOME/.dotfiles"
fi

if [[ -f "$DOTFILES_DIR/bin/dotfiles-check-updates.sh" ]]; then
  source "$DOTFILES_DIR/bin/dotfiles-check-updates.sh"
fi
