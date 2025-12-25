# ~/.zshrc (managed by ~/.dotfiles)
export DOTFILES_DIR="$HOME/.dotfiles"

# Oh My Zsh location (installed by install script)
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$DOTFILES_DIR/zsh/omz-custom"

# Prefer minimal, predictable behavior
setopt AUTO_CD
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$HOME/.zsh_history"

# Load modular config
for f in $DOTFILES_DIR/zsh/zshrc.d/*.zsh(N); do
  [[ -r "$f" ]] && source "$f"
done

# Local per-machine overrides (not committed)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Load Oh My Zsh last (so it sees plugins/theme vars)
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi
