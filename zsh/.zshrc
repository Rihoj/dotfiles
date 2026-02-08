# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load modular configuration files
if [[ -f "$HOME/.zshenv.local" && -z "${ZSHRC_LOCAL_ENV_LOADED:-}" ]]; then
  export ZSHRC_LOCAL_ENV_LOADED=1
  source "$HOME/.zshenv.local"
fi
this_file="${(%):-%N}"
this_real="${this_file:A}"
if [[ "$this_real" == */zsh/.zshrc ]]; then
  DOTFILES_DIR="${DOTFILES_DIR:-${this_real:h:h}}"
elif [[ -z "$DOTFILES_DIR" && -d "$HOME/.dotfiles/zsh/zshrc.d" ]]; then
  DOTFILES_DIR="$HOME/.dotfiles"
fi
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
for f in "${DOTFILES_DIR}/zsh/zshrc.d"/*.zsh(N); do
  [[ -r "$f" ]] && source "$f"
done

# Local per-machine overrides (not committed)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
