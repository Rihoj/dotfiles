# Zsh Configuration In-Depth

Comprehensive guide to Zsh configuration in this dotfiles system.

## Zsh Configuration Architecture

### Overview

```
~/.zshrc (or sourcing mechanism)
    │
    ├─ Source: zsh/zshrc.d/00-omz.zsh
    │   └─ Initialize Oh My Zsh framework
    │
    ├─ Source: zsh/zshrc.d/05-dotfiles-updates.zsh
    │   └─ Trigger update checks
    │
    ├─ Source: zsh/zshrc.d/10-aliases.zsh
    │   └─ Load command aliases
    │
    ├─ Source: zsh/zshrc.d/15-functions.zsh
    │   └─ Load custom functions
    │
    ├─ Source: zsh/zshrc.d/20-keybindings.zsh
    │   └─ Configure key bindings
    │
    ├─ Source: zsh/zshrc.d/30-env.zsh
    │   └─ Set environment variables
    │
    ├─ Source: zsh/zshrc.d/99-p10k.zsh
    │   └─ Configure Powerlevel10k theme
    │
    └─ Source: ~/.zshrc.local (if exists)
        └─ User's machine-specific config
```

### Module Loading

Modules are loaded in numeric order (00 → 99):

```zsh
# Typical loading loop in main .zshrc
for config_file in ~/.dotfiles/zsh/zshrc.d/*.zsh; do
    source "$config_file"
done

# Load user overrides last
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

---

## Module Reference

### 00-omz.zsh - Oh My Zsh Initialization

**Purpose**: Bootstrap Oh My Zsh framework

**Typical Content**:
```zsh
# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme selection
ZSH_THEME="powerlevel10k/powerlevel10k"

# Custom directory for plugins/themes
ZSH_CUSTOM="$HOME/.dotfiles/zsh/omz-custom"

# Plugins to load
plugins=(
    git                    # Git aliases and functions
    docker                 # Docker completion
    docker-compose         # Docker Compose completion
    kubectl                # Kubernetes completion
    sudo                   # Press ESC twice to add sudo
    z                      # Jump to frequent directories
    history-substring-search  # Better history search
    colored-man-pages      # Colorful man pages
)

# Oh My Zsh options
HIST_STAMPS="yyyy-mm-dd"
DISABLE_AUTO_UPDATE="true"  # Managed by dotfiles system
COMPLETION_WAITING_DOTS="true"

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh
```

**Key Variables**:
- `ZSH`: Oh My Zsh installation directory
- `ZSH_THEME`: Active theme
- `ZSH_CUSTOM`: Custom plugins/themes directory
- `plugins`: Array of plugins to load

**Customization**:
```zsh
# Disable plugin
plugins=(
    git
    # docker  # Commented out = disabled
    kubectl
)

# Change theme
ZSH_THEME="robbyrussell"  # Or any other theme
```

---

### 05-dotfiles-updates.zsh - Update Management

**Purpose**: Enable automatic update checks

**Typical Content**:
```zsh
# Source the update checker
if [[ -f "$HOME/.dotfiles/bin/dotfiles-check-updates.sh" ]]; then
    source "$HOME/.dotfiles/bin/dotfiles-check-updates.sh"
fi
```

**Why Separate Module?**
- Loads after Oh My Zsh (which needs to be ready first)
- Runs in background (non-blocking)
- Easy to disable if needed

**Disable Updates**:
```zsh
# Comment out in this file, or set in ~/.zshrc.local:
export ZSH_DOTFILES_UPDATE_FREQ=999999  # Never check
```

---

### 10-aliases.zsh - Command Aliases

**Purpose**: Define short command abbreviations

**Examples**:
```zsh
# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate'

# Docker shortcuts
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'

# System shortcuts
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Utility aliases
alias h='history'
alias c='clear'
alias x='exit'
alias reload='exec zsh'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
```

**Alias Guidelines**:
- Keep short (1-3 characters ideal)
- Group by category (Git, Docker, System)
- Add comments for non-obvious aliases
- Don't override important commands without `='`

**Anti-Patterns**:
```zsh
# Bad: Overrides important command
alias ls='ls -la'  # Now you can't use plain ls

# Good: Use different name
alias ll='ls -la'  # ls still works normally
```

---

### 15-functions.zsh - Custom Functions

**Purpose**: Complex commands and logic

**Examples**:
```zsh
# Create directory and enter it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick git commit with message
gcm() {
    git commit -m "$*"
}

# Extract any archive format
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find in files
findin() {
    grep -rnw . -e "$1"
}

# Git clone and cd
gclone() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Docker compose wrapper with path fixing
phpunit-docker() {
    docker compose exec app vendor/bin/phpunit "$@" 2>&1 | \
        sed "s|/var/www/html/|$(pwd)/|g"
}

# Quick backup
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Weather in terminal
weather() {
    curl "wttr.in/${1:-}"
}

# Show file tree
tree() {
    find "${1:-.}" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
}
```

**Function Guidelines**:
- Use descriptive names (not single letters)
- Add parameter validation
- Include error handling
- Document complex logic with comments
- Consider edge cases

**Function vs Alias**:

Use **Alias** when:
- Simple one-liner
- No parameters needed
- Direct command substitution

Use **Function** when:
- Multiple lines of logic
- Parameters or arguments
- Conditional behavior
- Error handling needed

---

### 20-keybindings.zsh - Keyboard Shortcuts

**Purpose**: Map keys to commands or widgets

**Examples**:
```zsh
# Ctrl+F to accept autosuggestion
bindkey '^F' autosuggest-accept

# Ctrl+Z to undo
bindkey '^Z' undo

# Ctrl+R for history search (with fzf if available)
if command -v fzf &> /dev/null; then
    bindkey '^R' fzf-history-widget
fi

# Alt+. to insert last argument
bindkey '\e.' insert-last-word

# Ctrl+Left/Right for word navigation
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Home/End keys
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Delete key
bindkey '^[[3~' delete-char

# Page Up/Down for history
bindkey '^[[5~' history-search-backward
bindkey '^[[6~' history-search-forward
```

**Vim Mode** (if preferred):
```zsh
# Enable vim mode
bindkey -v

# Faster mode switching
export KEYTIMEOUT=1

# Vi mode indicator in prompt
function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
```

**Find Key Codes**:
```zsh
# Press Ctrl+V then the key combination
# Example: Ctrl+V then Ctrl+F shows ^F

# Or use:
cat > /dev/null
# Then press keys and see their codes
```

---

### 30-env.zsh - Environment Variables

**Purpose**: Configure environment and PATH

**Examples**:
```zsh
# Default editors
export EDITOR='vim'
export VISUAL='vim'

# Pager configuration
export PAGER='less'
export LESS='-R -F -X -i -M -w'

# History configuration
export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# PATH modifications
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Language and locale
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Go development
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Rust development
export PATH="$HOME/.cargo/bin:$PATH"

# Node.js (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Python virtual environments
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_PYTHON='/usr/bin/python3'

# FZF configuration
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Colors for ls
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# GPG TTY (for git signing)
export GPG_TTY=$(tty)
```

**PATH Management Best Practices**:
```zsh
# Add to beginning (higher priority)
export PATH="/new/path:$PATH"

# Add to end (lower priority)
export PATH="$PATH:/new/path"

# Remove duplicates
typeset -U path  # Zsh-specific

# Check PATH
echo $PATH | tr ':' '\n'
```

---

### 99-p10k.zsh - Powerlevel10k Configuration

**Purpose**: Configure the Powerlevel10k theme

**Generated by**: `p10k configure`

**Key Sections**:
```zsh
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Prompt elements
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                  # Current directory
    vcs                  # Git status
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status               # Exit code
    command_execution_time
    background_jobs
    time                 # Current time
)

# Customization
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=50
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
```

**Why Load Last?**
- Needs all environment variables set
- Depends on other configurations
- Instant prompt feature benefits from being last

**Re-configure**:
```bash
p10k configure  # Run configuration wizard
```

---

## Oh My Zsh Deep Dive

### Plugin System

**Built-in Plugins** location: `~/.oh-my-zsh/plugins/`

**Custom Plugins** location: `~/.dotfiles/zsh/omz-custom/plugins/`

**Popular Plugins**:

| Plugin | Purpose |
|--------|---------|
| `git` | Git aliases and functions |
| `docker` | Docker CLI completion |
| `kubectl` | Kubernetes completion |
| `sudo` | Press ESC twice to add sudo |
| `z` | Quick directory jumping |
| `history-substring-search` | Better history search |
| `colored-man-pages` | Colorful man pages |
| `command-not-found` | Suggests packages |
| `extract` | Universal archive extraction |
| `web-search` | Web search from terminal |

**Installing Third-Party Plugins**:
```bash
# Clone to custom directory
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.dotfiles/zsh/omz-custom/plugins/zsh-autosuggestions

# Enable in 00-omz.zsh
plugins=(
    ...
    zsh-autosuggestions
)

# Reload
exec zsh
```

**Recommended Plugin Set**:
```zsh
plugins=(
    # Version control
    git

    # Docker
    docker
    docker-compose

    # Cloud
    kubectl
    terraform
    aws

    # Utilities
    sudo
    z
    extract
    colored-man-pages
    history-substring-search

    # Third-party
    zsh-autosuggestions
    zsh-syntax-highlighting
)
```

### Theme System

**Location**: `~/.oh-my-zsh/themes/` or `~/.oh-my-zsh/custom/themes/`

**Popular Themes**:
- `powerlevel10k` - Feature-rich, fast
- `robbyrussell` - Simple, default
- `agnoster` - Git-aware, requires powerline fonts
- `pure` - Minimal, clean

**Change Theme**:
```zsh
# In 00-omz.zsh
ZSH_THEME="theme-name"

# Reload
exec zsh
```

---

## Advanced Zsh Features

### History Management

```zsh
# Ignore commands starting with space
setopt HIST_IGNORE_SPACE

# Remove older duplicate entries
setopt HIST_IGNORE_ALL_DUPS

# Share history between terminals
setopt SHARE_HISTORY

# Append instead of overwrite
setopt APPEND_HISTORY

# Add timestamp to history
setopt EXTENDED_HISTORY

# Don't execute, just add to history
setopt HIST_VERIFY
```

### Completion System

```zsh
# Enable completion system
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Use menu selection
zstyle ':completion:*' menu select

# Color completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Verbose completion
zstyle ':completion:*' verbose yes

# Group completions by type
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
```

### Globbing (Pattern Matching)

```zsh
# Enable extended globbing
setopt EXTENDED_GLOB

# Examples:
ls **/*.txt          # All .txt files recursively
ls *.txt~README.txt  # All .txt except README.txt
ls *.(txt|md)        # All .txt or .md files
ls file<1-100>.txt   # file1.txt through file100.txt
```

### Directory Stack

```zsh
# Auto-push directories
setopt AUTO_PUSHD

# Don't push duplicates
setopt PUSHD_IGNORE_DUPS

# Use directory stack
cd /path/to/dir1
cd /path/to/dir2
cd /path/to/dir3
dirs -v              # Show stack
cd -2                # Jump to 2nd entry
```

---

## Performance Optimization

### Profile Startup Time

```zsh
# Add to top of ~/.zshrc
zmodload zsh/zprof

# ... your configuration ...

# Add to bottom
zprof
```

### Lazy Loading

**NVM Example**:
```zsh
# Instead of loading immediately:
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Lazy load:
nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
}

node() {
    unset -f node
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    node "$@"
}
```

### Reduce Plugin Count

```zsh
# Before: 20 plugins
plugins=(git docker kubectl aws terraform ... lots more)

# After: Only what you actually use
plugins=(git docker kubectl)
```

### Use Powerlevel10k Instant Prompt

Enabled by default in `99-p10k.zsh`:
```zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
```

---

## Debugging Zsh Configuration

### Enable Tracing

```zsh
# Add to ~/.zshrc temporarily
set -x  # Enable
# ... configuration to debug ...
set +x  # Disable
```

### Check What's Loaded

```zsh
# List all functions
functions | grep "^[a-z]"

# List all aliases
alias

# List all variables
env

# Check specific module
source ~/.dotfiles/zsh/zshrc.d/10-aliases.zsh
```

### Find Slow Parts

```zsh
# Time each module load
for module in ~/.dotfiles/zsh/zshrc.d/*.zsh; do
    time source "$module"
done
```

---

## Related Documentation

- [Configuration Guide](configuration.md) - Customization basics
- [Command Reference](command-reference.md) - Available commands
- [Performance](troubleshooting.md#slow-shell-startup) - Speed optimization
