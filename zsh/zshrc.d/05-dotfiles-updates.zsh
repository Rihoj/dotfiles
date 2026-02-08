# Dotfiles auto-update check (similar to OMZ)
# Checks for updates every N days (default: 1)
# Customize with: export ZSH_DOTFILES_UPDATE_FREQ=7
# Set DOTFILES_DIR if not already set
# This is typically ~/.dotfiles when properly installed
if [[ -z "$DOTFILES_DIR" ]]; then
  # Prefer detecting from this file's location (works even when ~/.zshrc is copied)
  this_file="${(%):-%x}"
  if [[ -n "$this_file" ]]; then
    DOTFILES_DIR="$(cd "$(dirname "${this_file:A}")/../.." 2>/dev/null && pwd)"
  fi

  # Fallback: detect from the zshrc symlink location
  if [[ -z "$DOTFILES_DIR" && -L "$HOME/.zshrc" ]]; then
    zshrc_target="$(readlink "$HOME/.zshrc")"
    if [[ -n "$zshrc_target" ]]; then
      # If readlink returns a relative path, resolve it relative to $HOME
      [[ "$zshrc_target" != /* ]] && zshrc_target="$HOME/$zshrc_target"
      DOTFILES_DIR="$(cd "$(dirname "$(dirname "$zshrc_target")")" 2>/dev/null && pwd)"
    fi
  fi

  # Fallback to standard location if detection failed
  [[ -z "$DOTFILES_DIR" ]] && DOTFILES_DIR="$HOME/.dotfiles"
fi

if [[ -f "$DOTFILES_DIR/bin/dotfiles-check-updates.sh" ]]; then
  if [[ -o interactive ]]; then
    if [[ "${ZSH_DOTFILES_AUTOUPDATE:-true}" == "true" ]]; then
      # Run quietly and disown to avoid job-complete notifications in prompt
      command bash "$DOTFILES_DIR/bin/dotfiles-check-updates.sh" >/dev/null 2>&1 &!
    else
      # Allow non-interactive notice output when autoupdate is disabled.
      command bash "$DOTFILES_DIR/bin/dotfiles-check-updates.sh"
    fi
  fi
fi
