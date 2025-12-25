# Dotfiles auto-update check (similar to OMZ)
# Checks for updates every N days (default: 7)
# Customize with: export ZSH_DOTFILES_UPDATE_FREQ=14

if [[ -f "$DOTFILES_DIR/bin/dotfiles-check-updates.sh" ]]; then
  source "$DOTFILES_DIR/bin/dotfiles-check-updates.sh"
fi
