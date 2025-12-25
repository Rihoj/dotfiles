# Directory Structure

This document provides a complete reference for the dotfiles repository structure.

## Overview

```
~/.dotfiles/
├── ansible/               # Automation and provisioning
├── bin/                   # Utility scripts
├── docs/                  # Documentation (you are here)
├── git/                   # Git configuration
├── npm/                   # NPM configuration
├── shell/                 # Generic shell configuration
├── vim/                   # Vim configuration
├── zsh/                   # Zsh configuration
├── bootstrap.sh           # Main entry point
└── README.md              # Quick reference
```

## Directory Reference

### `/ansible/` - Automation Layer

```
ansible/
├── playbook.yml           # Main Ansible playbook
├── requirements.yml       # Ansible Galaxy dependencies
└── roles/
    └── dotfiles/          # Primary configuration role
        ├── tasks/
        │   ├── main.yml           # Main task list
        │   └── dotfile_tasks.yml  # Specific dotfile operations
        └── templates/
            └── zshrc.local.j2     # Template for user-specific config
```

#### Key Files

**`playbook.yml`**
- Purpose: Orchestrates the entire provisioning process
- Variables: `dotfiles_dir`, `install_deps`, `set_default_shell`, `backup_dir`
- Structure: Pre-tasks → Roles → Post-tasks

**`requirements.yml`**
- Purpose: Declares required Ansible Galaxy collections
- Currently empty but prepared for future dependencies

**`roles/dotfiles/tasks/main.yml`**
- Purpose: Complete provisioning logic
- Tags: `packages`, `repo`, `omz`, `config`, `shell`
- Length: ~490 lines covering all configuration aspects

**`roles/dotfiles/templates/zshrc.local.j2`**
- Purpose: Generate user's local configuration file
- Generated once, never overwritten
- Location: `~/.zshrc.local` after provisioning

### `/bin/` - Utility Scripts

```
bin/
├── dotfiles-check-updates.sh   # Auto-update checker
├── dotfiles-link-bin.sh        # Symlink utility scripts to PATH
└── dotfiles-pull-updates.sh    # Manual update trigger
```

#### Script Details

**`dotfiles-check-updates.sh`**
- Purpose: Check for upstream updates periodically
- Triggered: On shell startup (via `05-dotfiles-updates.zsh`)
- Frequency: Configurable via `ZSH_DOTFILES_UPDATE_FREQ` (default: 7 days)
- Behavior: Can notify or auto-update based on `ZSH_DOTFILES_AUTOUPDATE`
- Lock file: `.update.lock` prevents concurrent runs

**`dotfiles-link-bin.sh`**
- Purpose: Create symlinks for bin scripts in user's PATH
- Typical target: `~/.local/bin/` or `~/bin/`

**`dotfiles-pull-updates.sh`**
- Purpose: Manually update dotfiles from upstream
- Usage: Run when you want latest changes immediately
- Safer than auto-update for critical systems

### `/git/` - Git Configuration

```
git/
└── .gitconfig             # Git global configuration
```

**Contents**:
- User configuration (name, email)
- Alias definitions
- Core settings (editor, pager)
- Color schemes
- Merge/diff tools

**Linking**: Symlinked to `~/.gitconfig` during provisioning

### `/npm/` - NPM Configuration

```
npm/
└── .npmrc                 # NPM user configuration
```

**Contents**:
- Registry settings
- Authentication tokens (use environment variables!)
- Package defaults
- Cache configuration

**Linking**: Symlinked to `~/.npmrc` during provisioning

### `/shell/` - Generic Shell Configuration

```
shell/
└── (common shell utilities and functions)
```

**Purpose**: Configuration shared across shell types (bash, zsh)

**Contents** (typical):
- POSIX-compatible functions
- Environment variables needed by all shells
- Cross-shell compatibility helpers

### `/vim/` - Vim Configuration

```
vim/
└── .vimrc                 # Vim configuration
```

**Contents**:
- Plugin management (if using vim-plug, Vundle, etc.)
- Key mappings
- Editor settings (tabs, spaces, colors)
- File type settings
- Custom commands

**Linking**: Symlinked to `~/.vimrc` during provisioning

### `/zsh/` - Zsh Configuration

```
zsh/
├── omz-custom/            # Oh My Zsh customizations
│   ├── plugins/           # Custom OMZ plugins
│   └── themes/            # Custom OMZ themes
└── zshrc.d/               # Modular zsh configuration
    ├── 00-omz.zsh         # Oh My Zsh initialization
    ├── 05-dotfiles-updates.zsh  # Update checking
    ├── 10-aliases.zsh     # Command aliases
    ├── 15-functions.zsh   # Custom shell functions
    ├── 20-keybindings.zsh # Keyboard shortcuts
    ├── 30-env.zsh         # Environment variables
    └── 99-p10k.zsh        # Powerlevel10k configuration
```

#### Zsh Module Loading Order

Modules are loaded numerically. Lower numbers load first:

1. **00-omz.zsh** (Priority: Highest)
   - Initialize Oh My Zsh framework
   - Load OMZ plugins
   - Set theme (Powerlevel10k)

2. **05-dotfiles-updates.zsh**
   - Source update checking script
   - Runs non-blocking update checks

3. **10-aliases.zsh**
   - Command aliases (e.g., `docker-compose` → `docker compose`)
   - Shorthand commands

4. **15-functions.zsh**
   - Custom shell functions
   - Complex command wrappers

5. **20-keybindings.zsh**
   - Custom key bindings
   - Readline shortcuts

6. **30-env.zsh**
   - Environment variables
   - PATH modifications
   - Tool configuration (e.g., `EDITOR`, `PAGER`)

7. **99-p10k.zsh** (Priority: Lowest)
   - Powerlevel10k instant prompt
   - Theme configuration
   - Loads last to ensure all setup is complete

#### Module Details

**`00-omz.zsh`**
```zsh
# Purpose: Initialize Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git docker docker-compose kubectl)
source $ZSH/oh-my-zsh.sh
```

**`05-dotfiles-updates.zsh`**
```zsh
# Purpose: Check for dotfiles updates
# Non-blocking: won't slow shell startup
source "$HOME/.dotfiles/bin/dotfiles-check-updates.sh"
```

**`10-aliases.zsh`**
- Simple command aliases
- One-line definitions
- Quick shortcuts

**`15-functions.zsh`**
- Multi-line functions
- Complex logic
- Command wrappers (e.g., `phpunit-docker`)

**`20-keybindings.zsh`**
- Ctrl/Alt/Shift key combinations
- Vi/Emacs mode settings
- Widget definitions

**`30-env.zsh`**
- `export` statements
- `PATH` modifications
- Tool configurations

**`99-p10k.zsh`**
- Powerlevel10k instant prompt setup
- Generated by `p10k configure`
- Should be last to avoid conflicts

#### Oh My Zsh Custom Directory

**`omz-custom/plugins/`**
- Custom plugins not in main OMZ repository
- Cloned from third-party sources
- Activated in `00-omz.zsh` plugins array

**`omz-custom/themes/`**
- Custom themes not in main OMZ repository
- Currently using Powerlevel10k (external)

### Root Level Files

```
bootstrap.sh               # Main entry point
README.md                  # Quick reference documentation
.gitignore                 # Git ignore patterns
.last_update_check         # Update check timestamp (generated)
```

**`bootstrap.sh`**
- Purpose: Prerequisite setup and Ansible invocation
- Permissions: Executable (`chmod +x`)
- Arguments: `--repo`, `--no-install-deps`, `--no-chsh`, `--dry-run`

**`README.md`**
- Quick start instructions
- Common use cases
- Basic troubleshooting

**`.gitignore`**
- Prevents tracking of generated files
- Excludes `.last_update_check`
- Excludes `.update.lock`
- Excludes local Ansible retry files

**`.last_update_check`**
- Generated by `dotfiles-check-updates.sh`
- Unix timestamp of last update check
- Used to enforce update frequency

## File Linking Map

Files from the repository are symlinked to standard locations:

```
Repository → Home Directory

~/.dotfiles/git/.gitconfig              → ~/.gitconfig
~/.dotfiles/vim/.vimrc                  → ~/.vimrc
~/.dotfiles/npm/.npmrc                  → ~/.npmrc
~/.dotfiles/zsh/zshrc                   → ~/.zshrc (if exists)
~/.dotfiles/bin/dotfiles-*.sh           → ~/.local/bin/ (optional)

Generated Files (not symlinked):
~/.dotfiles/roles/dotfiles/templates/zshrc.local.j2 → ~/.zshrc.local
```

## State Files

Files generated during runtime (not in git):

```
~/.dotfiles/.last_update_check          # Update timestamp
~/.dotfiles/.update.lock                # Update lock file
~/.dotfiles-backups/                    # Backup directory
    ├── zshrc.2025-12-25_10-30-45      # Timestamped backups
    ├── gitconfig.2025-12-25_10-30-45
    └── vimrc.2025-12-25_10-30-45
```

## User's Home Directory Structure

After provisioning, your home directory includes:

```
~/
├── .oh-my-zsh/                    # Oh My Zsh framework
├── .zshrc                         # Symlink → ~/.dotfiles/zsh/zshrc (if exists)
├── .zshrc.local                   # Your custom config (NOT a symlink)
├── .gitconfig                     # Symlink → ~/.dotfiles/git/.gitconfig
├── .vimrc                         # Symlink → ~/.dotfiles/vim/.vimrc
├── .npmrc                         # Symlink → ~/.dotfiles/npm/.npmrc
├── .dotfiles/                     # This repository
└── .dotfiles-backups/             # Backup directory
```

## Adding New Directories

When adding new tool configurations:

1. Create directory: `mkdir ~/.dotfiles/newtool`
2. Add config file: `touch ~/.dotfiles/newtool/.newtoolrc`
3. Update Ansible tasks to link it
4. Document in this file

Example:
```bash
# Adding tmux configuration
mkdir ~/.dotfiles/tmux
vim ~/.dotfiles/tmux/.tmux.conf

# Update ansible/roles/dotfiles/tasks/main.yml
# Add linking task
```

## Naming Conventions

### Zsh Modules
- Format: `NN-name.zsh`
- `NN`: Two-digit load order (00-99)
- Lower numbers load first
- Gaps allowed (e.g., 00, 05, 10, 15)

### Scripts in `/bin/`
- Format: `dotfiles-action.sh`
- Prefix: `dotfiles-` for easy identification
- Suffix: `.sh` for shell scripts
- Descriptive action names

### Configuration Files
- Start with `.` (dotfiles convention)
- Use standard names (`.gitconfig`, `.vimrc`)
- Match expected paths for each tool

## Directory Permissions

```
~/.dotfiles/                  # 755 (standard directory)
~/.dotfiles/bin/*.sh          # 755 (executable)
~/.dotfiles-backups/          # 700 (secure, user-only)
~/.zshrc.local                # 600 (secure, user-only)
```

## Platform-Specific Considerations

### Linux
- All directories supported
- Full package installation via apt/dnf/pacman

### macOS
- Most directories supported
- Some package names differ
- Shell detection may require additional steps

### WSL (Windows Subsystem for Linux)
- Same as Linux
- Consider Windows-Linux path integration
- Symlinks work but may need special handling

---

**Pro Tip**: Use `tree ~/.dotfiles` to visualize the structure. Install with:
```bash
# Debian/Ubuntu
sudo apt-get install tree

# macOS
brew install tree
```

Then run:
```bash
tree -L 3 ~/.dotfiles -I '.git'
```
