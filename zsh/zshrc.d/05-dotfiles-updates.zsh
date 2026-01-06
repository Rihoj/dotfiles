# Dotfiles auto-update check (similar to OMZ)
# Checks for updates every N days (default: 7)
# Customize with: export ZSH_DOTFILES_UPDATE_FREQ=14

# Set DOTFILES_DIR if not already set
# This is typically ~/.dotfiles when properly installed
if [[ -z "$DOTFILES_DIR" ]]; then
  # Try to detect from the zshrc location
  if [[ -L "$HOME/.zshrc" ]]; then
    DOTFILES_DIR="$(dirname "$(dirname "$(readlink "$HOME/.zshrc")")")"
  else
    DOTFILES_DIR="$HOME/.dotfiles"
  fi
fi

if [[ -f "$DOTFILES_DIR/bin/dotfiles-check-updates.sh" ]]; then
  source "$DOTFILES_DIR/bin/dotfiles-check-updates.sh"
fi
