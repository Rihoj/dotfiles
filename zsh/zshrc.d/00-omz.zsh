# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# OMZ Plugins
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting 
	aws
)

# Source Oh My Zsh
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"
