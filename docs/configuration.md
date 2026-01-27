# Configuration Guide

Learn how to customize your dotfiles to match your workflow.

## Quick Reference

| What You Want | Where to Put It | Tracked in Git? |
|---------------|----------------|-----------------|
| Custom aliases | `zsh/zshrc.d/10-aliases.zsh` | ✅ Yes |
| Custom functions | `zsh/zshrc.d/15-functions.zsh` | ✅ Yes |
| Environment variables | `zsh/zshrc.d/30-env.zsh` | ✅ Yes |
| Key bindings | `zsh/zshrc.d/20-keybindings.zsh` | ✅ Yes |
| Git global config | `git/.gitconfig` | ✅ Yes |
| Git user identity | `~/.gitconfig.local` | ❌ No |
| Early env overrides | `~/.zshenv.local` | ❌ No |
| Machine-specific config | `~/.zshrc.local` | ❌ No |
| API keys / secrets | `~/.zshrc.local` | ❌ No |
| Work vs personal differences | `~/.zshrc.local` | ❌ No |

## Understanding Configuration Layers

Your shell configuration is loaded in layers:

```
1. Oh My Zsh (framework)
   ↓
2. Early local env (~/.zshenv.local)
   ↓
3. Repository modules (zsh/zshrc.d/*.zsh)
   ↓
4. Your local overrides (~/.zshrc.local)
```

### Layer 1: Oh My Zsh Framework

Managed in `zsh/zshrc.d/00-omz.zsh`:

```zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable plugins
plugins=(
  git
  docker
  docker-compose
  kubectl
  # Add more here
)

source $ZSH/oh-my-zsh.sh
```

### Layer 2: Early Local Env

`~/.zshenv.local` is sourced before modules for variables that must be set
before initialization (like update settings).

### Layer 3: Repository Modules

Files in `zsh/zshrc.d/` are sourced automatically in numeric order.

### Layer 4: Local Overrides

`~/.zshrc.local` is sourced last and never tracked in git. Perfect for:
- Machine-specific paths
- Work vs personal environment splits
- API keys and tokens
- Local development tool configurations

## Common Configuration Tasks

### Adding an Alias

**For portable aliases** (same across all machines):

```bash
# Edit the aliases file
vim ~/.dotfiles/zsh/zshrc.d/10-aliases.zsh
```

Add your alias:
```zsh
# Git shortcuts
alias gs='git status'
alias gp='git pull'
alias gc='git commit'

# Docker shortcuts
alias dps='docker ps'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
```

**For machine-specific aliases**:

```bash
# Edit your local file
vim ~/.zshrc.local
```

Add machine-specific aliases:
```zsh
# Work laptop only
alias vpn='sudo openvpn /etc/openvpn/work.conf'

# Home desktop only
alias nas='ssh admin@192.168.1.100'
```

Then reload:
```bash
source ~/.zshrc
# or
exec zsh
```

### Adding a Function

**For portable functions**:

```bash
vim ~/.dotfiles/zsh/zshrc.d/15-functions.zsh
```

Example function:
```zsh
# Create and enter a directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick git commit with message
gcm() {
    git commit -m "$*"
}

# Extract any archive type
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
```

### Setting Environment Variables

**For portable environment variables**:

```bash
vim ~/.dotfiles/zsh/zshrc.d/30-env.zsh
```

Examples:
```zsh
# Default editor
export EDITOR='vim'
export VISUAL='vim'

# Go development
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Python virtual environment
export WORKON_HOME="$HOME/.virtualenvs"
```

**For machine-specific environment variables**:

```bash
vim ~/.zshrc.local
```

Examples:
```zsh
# API keys (NEVER commit to git!)
export GITHUB_TOKEN='ghp_xxxxxxxxxxxx'
export AWS_ACCESS_KEY_ID='AKIA...'
export AWS_SECRET_ACCESS_KEY='...'

# Machine-specific paths
export JAVA_HOME='/usr/lib/jvm/java-17-openjdk-amd64'
export PROJECT_DIR='/mnt/projects'
```

### Adding Oh My Zsh Plugins

Edit the plugin list:
```bash
vim ~/.dotfiles/zsh/zshrc.d/00-omz.zsh
```

Add plugins to the array:
```zsh
plugins=(
  git              # Git aliases and functions
  docker           # Docker completion
  docker-compose   # Docker Compose completion
  kubectl          # Kubernetes completion
  sudo             # Press ESC twice to add sudo
  z                # Jump to frequent directories
  history          # History aliases
  colored-man-pages # Colorful man pages
  # Add more here
)
```

Available plugins: https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins

### Installing Custom Oh My Zsh Plugins

For plugins not in the main repository:

```bash
# Clone the plugin
git clone https://github.com/author/plugin-name \
  ~/.dotfiles/zsh/omz-custom/plugins/plugin-name

# Enable it in 00-omz.zsh
vim ~/.dotfiles/zsh/zshrc.d/00-omz.zsh
```

Add to plugins array:
```zsh
plugins=(
  ...
  plugin-name
)
```

Popular custom plugins:
- `zsh-autosuggestions` - Fish-like autosuggestions
- `zsh-syntax-highlighting` - Syntax highlighting as you type
- `zsh-completions` - Additional completion definitions

### Customizing Key Bindings

```bash
vim ~/.dotfiles/zsh/zshrc.d/20-keybindings.zsh
```

Examples:
```zsh
# Ctrl+F to accept autosuggestion
bindkey '^F' autosuggest-accept

# Ctrl+R for history search (fzf if installed)
bindkey '^R' history-incremental-search-backward

# Alt+. to insert last argument
bindkey '\e.' insert-last-word

# Vim mode
bindkey -v  # Enable vim mode
export KEYTIMEOUT=1  # Faster mode switching
```

### Configuring Powerlevel10k Theme

Run the configuration wizard:
```bash
p10k configure
```

Or edit directly:
```bash
vim ~/.dotfiles/zsh/zshrc.d/99-p10k.zsh
```

Common customizations:
```zsh
# Show fewer segments
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir                  # Current directory
  vcs                  # Git status
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status               # Exit code
  command_execution_time
  time                 # Current time
)

# Customize directory display
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=30
```

## Git Configuration

### User-Specific Configuration (Name, Email, GPG Key)

User-specific git settings are **not stored in the repository** to keep sensitive information private. Instead, they're configured locally on each machine using `~/.gitconfig.local`.

**Automatic setup during bootstrap:**

The bootstrap script prompts for your git identity at the beginning:
- Name
- Email address
- GPG signing key (if you have GPG installed)

The `.gitconfig.local` file is created automatically with your settings.

**Reconfiguration or manual setup:**

If you need to update your git identity or configure it manually:
```bash
# Run the interactive setup script
~/.dotfiles/bin/setup-git-config.sh
```

This script will:
1. Prompt for your name and email
2. List available GPG keys or offer to generate a new ed25519 key
3. Create or update `~/.gitconfig.local` with your settings

**Manual configuration** (if you prefer):
```bash
vim ~/.gitconfig.local
```

Example:
```ini
# ~/.gitconfig.local
[user]
    name = Your Name
    email = your.email@example.com
    signingkey = YOUR_GPG_KEY_ID  # Optional, for signed commits
```

### Repository Git Configuration

Global git settings are stored in `~/.dotfiles/git/.gitconfig`:

```bash
vim ~/.dotfiles/git/.gitconfig
```

Common settings:
```ini
[core]
    editor = vim
    pager = less -FRX
    excludesfile = ~/.gitignore_global

[alias]
    st = status
    co = checkout
    br = branch
    cm = commit
    lg = log --oneline --graph --decorate
    unstage = reset HEAD --

[color]
    ui = auto

[pull]
    rebase = false

[init]
    defaultBranch = main
```

**Note**: The repository `.gitconfig` includes your `~/.gitconfig.local` automatically via the `[include]` directive, so both files work together.

## Vim Configuration

```bash
vim ~/.dotfiles/vim/.vimrc
```

Basic settings:
```vim
" General settings
set number              " Line numbers
set relativenumber      " Relative line numbers
set tabstop=4           " Tab width
set shiftwidth=4        " Indent width
set expandtab           " Use spaces instead of tabs
set autoindent          " Auto indent
set smartindent         " Smart indent

" Search settings
set ignorecase          " Case insensitive search
set smartcase           " Case sensitive if uppercase used
set hlsearch            " Highlight search results
set incsearch           " Incremental search

" UI settings
set cursorline          " Highlight current line
set showcmd             " Show command in status line
set wildmenu            " Command-line completion
syntax on               " Enable syntax highlighting

" Key mappings
let mapleader = " "     " Set leader key to space
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
```

## NPM Configuration

```bash
vim ~/.dotfiles/npm/.npmrc
```

Common settings:
```ini
# Default settings
save-exact=true
fund=false
audit=false

# Registry (for private packages)
# registry=https://registry.npmjs.org/

# Authentication (use env vars!)
# //registry.npmjs.org/:_authToken=${NPM_TOKEN}
```

**Security Note**: Never hardcode tokens. Use environment variables:
```bash
# In ~/.zshrc.local
export NPM_TOKEN='npm_xxxxxxxxxxxx'
```

## Machine-Specific Configuration

The `~/.zshrc.local` file is your personal space:

```bash
vim ~/.zshrc.local
```

Example structure:
```zsh
# ~/.zshrc.local - Machine-specific configuration
# This file is NEVER tracked in git

# ============================================
# Environment Detection
# ============================================
export MACHINE_TYPE='work'  # or 'personal', 'server'

# ============================================
# Secrets and API Keys
# ============================================
export GITHUB_TOKEN='ghp_xxxx'
export AWS_ACCESS_KEY_ID='AKIA...'
export AWS_SECRET_ACCESS_KEY='...'

# ============================================
# Machine-Specific Paths
# ============================================
export PROJECT_DIR='/mnt/work/projects'
export NOTES_DIR='/home/user/Dropbox/notes'

# ============================================
# Machine-Specific Aliases
# ============================================
if [[ "$MACHINE_TYPE" == "work" ]]; then
    alias vpn-connect='sudo openvpn /etc/openvpn/work.conf'
    alias ssh-jump='ssh -J jumphost internal-server'
fi

# ============================================
# Local Development Tools
# ============================================
export JAVA_HOME='/usr/lib/jvm/java-17-openjdk-amd64'
export ANDROID_HOME='/home/user/Android/Sdk'

# ============================================
# Custom Functions
# ============================================
work-project() {
    cd "$PROJECT_DIR/$1"
}
```

## Testing Your Changes

### Quick Test (Current Shell)
```bash
source ~/.zshrc
```

### Full Test (New Shell)
```bash
exec zsh
```

### Verify a Specific Module
```bash
# Test if alias works
which gs

# Test if function exists
type mkcd

# Test if variable is set
echo $EDITOR
```

### Dry-Run Before Applying
```bash
cd ~/.dotfiles
./bootstrap.sh --dry-run
```

## Committing Your Changes

When you've modified repository files:

```bash
cd ~/.dotfiles

# Check what changed
git status
git diff

# Commit changes
git add zsh/zshrc.d/10-aliases.zsh
git commit -m "Add new git aliases"

# Push to remote
git push origin main
```

**Remember**: Never commit `~/.zshrc.local` to git!

## Syncing to Another Machine

On your second machine:

```bash
# Pull latest changes
cd ~/.dotfiles
git pull

# Re-run provisioning
./bootstrap.sh

# Reload shell
exec zsh
```

## Advanced Configuration Patterns

### Conditional Configuration

```zsh
# In ~/.zshrc.local
if [[ "$(hostname)" == "work-laptop" ]]; then
    export ENVIRONMENT='work'
    source ~/work-specific-config.sh
elif [[ "$(hostname)" == "personal-desktop" ]]; then
    export ENVIRONMENT='personal'
    # Personal settings
fi
```

### OS-Specific Configuration

```zsh
# In zsh/zshrc.d/30-env.zsh
case "$(uname)" in
    Linux)
        export CLIPBOARD='xclip -selection clipboard'
        ;;
    Darwin)
        export CLIPBOARD='pbcopy'
        ;;
esac
```

### Plugin Manager Integration

```zsh
# In zsh/zshrc.d/00-omz.zsh or separate file
# Example: zinit plugin manager
if [[ ! -d ~/.zinit ]]; then
    git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit
fi
source ~/.zinit/zinit.zsh

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
```

## Troubleshooting Configuration

### Changes Not Taking Effect

1. Reload the shell: `exec zsh`
2. Check for syntax errors: `zsh -n ~/.zshrc`
3. Check specific file: `source ~/.dotfiles/zsh/zshrc.d/10-aliases.zsh`

### Conflicting Settings

Settings loaded later override earlier ones. Check load order:
```bash
# In ~/.zshrc, add debugging
setopt XTRACE  # Enable debug mode
source ~/.zshrc
setopt NOXTRACE  # Disable debug mode
```

### Performance Issues

Profile startup time:
```bash
time zsh -i -c exit
```

Identify slow plugins/modules:
```bash
# Add to top of ~/.zshrc
zmodload zsh/zprof

# Add to bottom of ~/.zshrc
zprof
```

## Best Practices

1. ✅ **Keep portable config in repo**: Aliases, functions that work everywhere
2. ✅ **Keep secrets in ~/.zshrc.local**: Never commit API keys
3. ✅ **Document complex functions**: Add comments explaining what they do
4. ✅ **Test changes locally**: Before pushing to other machines
5. ✅ **Use meaningful names**: `git-cleanup` not `gc` for functions
6. ✅ **Group related config**: Keep git aliases together
7. ❌ **Don't hardcode paths**: Use `$HOME` not `/home/username`
8. ❌ **Don't mix concerns**: Keep aliases separate from functions
9. ❌ **Don't duplicate Oh My Zsh**: Use plugins instead of reimplementing

## Next Steps

- Learn about [Update Management](updates.md)
- Explore [Zsh Configuration](zsh-configuration.md) in depth
- Check [Command Reference](command-reference.md) for available scripts
- Review [Troubleshooting](troubleshooting.md) for common issues

---

**Remember**: Configuration is personal. Start simple, add complexity only as needed.
