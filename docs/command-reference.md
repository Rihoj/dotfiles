# Command Reference

Complete reference for all scripts and commands in the dotfiles system.

## Bootstrap Command

### `./bootstrap.sh`

Main entry point for dotfiles provisioning.

#### Synopsis
```bash
./bootstrap.sh [OPTIONS]
```

#### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--repo URL` | Clone dotfiles from remote repository | Use local repo |
| `--no-install-deps` | Skip system package installation | Install packages |
| `--no-chsh` | Don't change default shell to zsh | Change to zsh |
| `--dry-run` | Preview changes without applying | Apply changes |
| `-h, --help` | Show help message | - |

#### Examples

**Standard installation**:
```bash
./bootstrap.sh
```

**Install without package dependencies**:
```bash
./bootstrap.sh --no-install-deps
```

**Preview what would be done**:
```bash
./bootstrap.sh --dry-run
```

**Clone from remote and provision**:
```bash
./bootstrap.sh --repo https://github.com/username/dotfiles.git
```

**Skip shell change (keep bash)**:
```bash
./bootstrap.sh --no-chsh
```

**Combine multiple options**:
```bash
./bootstrap.sh --no-install-deps --no-chsh --dry-run
```

#### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error (missing dependency, invalid option) |

#### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DOTFILES_DIR` | Target directory for dotfiles | Auto-detected from script location, or `~/.dotfiles` |

---

## Update Scripts

> **Note:** All update scripts automatically detect the dotfiles repository location, so they work correctly regardless of where you've cloned the repository. You can override this by setting the `DOTFILES_DIR` environment variable.

### `dotfiles-check-updates.sh`

Checks for available updates from upstream repository.

#### Synopsis
```bash
dotfiles-check-updates.sh
```

#### Description

- Runs automatically on shell startup (configurable frequency)
- Fetches from origin without blocking shell startup
- Can notify or auto-update based on configuration
- Uses lock file to prevent concurrent runs

#### Configuration (in `~/.zshrc.local`)

```zsh
# Check frequency in days (default: 1)
export ZSH_DOTFILES_UPDATE_FREQ=1

# Auto-update when behind (default: true)
export ZSH_DOTFILES_AUTOUPDATE=true
```

#### Behavior

**When `AUTOUPDATE=false`**:
```
Shell starts → Check if 1+ days → Fetch → Notify if behind
```

**When `AUTOUPDATE=true`**:
```
Shell starts → Check if 1+ days → Fetch → Auto-pull if behind
```

#### Manual Run
```bash
# Check now regardless of frequency
~/.dotfiles/bin/dotfiles-check-updates.sh
```

#### Output

**When up to date**:
```
(No output - silent success)
```

**When behind**:
```
╭─────────────────────────────────────╮
│ Dotfiles Update Available           │
│ 3 commits behind upstream           │
│ Run: dotfiles-pull-updates.sh       │
╰─────────────────────────────────────╯
```

#### State Files

- `.last_update_check` - Timestamp of last check
- `.update.lock` - Lock file during update process

---

### `dotfiles-pull-updates.sh`

Manually pull and apply upstream changes.

#### Synopsis
```bash
dotfiles-pull-updates.sh [OPTIONS]
```

#### Options

| Option | Description |
|--------|-------------|
| `--no-provision` | Pull changes but don't run Ansible |
| `--dry-run` | Show what would be pulled |

#### Examples

**Standard update**:
```bash
dotfiles-pull-updates.sh
```

**Pull without re-provisioning**:
```bash
dotfiles-pull-updates.sh --no-provision
```

**Preview changes**:
```bash
dotfiles-pull-updates.sh --dry-run
```

#### Process Flow

```
1. Check for uncommitted changes
2. Stash local changes (if any)
3. Pull from origin
4. Pop stashed changes
5. Run Ansible playbook (unless --no-provision)
6. Reload shell
```

#### Output

```
Checking for updates...
Pulling latest changes...
From github.com:user/dotfiles
   abc1234..def5678  main -> origin/main
Updating abc1234..def5678
Fast-forward
 zsh/zshrc.d/10-aliases.zsh | 3 +++
 1 file changed, 3 insertions(+)

Running provisioning...
[Ansible output...]

✓ Dotfiles updated successfully
Run 'exec zsh' to reload shell
```

---

### `dotfiles-link-bin.sh`

Symlink utility scripts to a directory in your PATH.

#### Synopsis
```bash
dotfiles-link-bin.sh [TARGET_DIR]
```

#### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `TARGET_DIR` | Directory to create symlinks | `~/.local/bin` |

#### Examples

**Link to default location**:
```bash
dotfiles-link-bin.sh
```

**Link to custom location**:
```bash
dotfiles-link-bin.sh ~/bin
```

#### What Gets Linked

```
~/.local/bin/dotfiles-check-updates.sh → ~/.dotfiles/bin/dotfiles-check-updates.sh
~/.local/bin/dotfiles-pull-updates.sh  → ~/.dotfiles/bin/dotfiles-pull-updates.sh
~/.local/bin/dotfiles-link-bin.sh      → ~/.dotfiles/bin/dotfiles-link-bin.sh
```

#### Prerequisites

Target directory must be in your `$PATH`:
```bash
# Add to ~/.zshrc.local if not already there
export PATH="$HOME/.local/bin:$PATH"
```

---

## Ansible Commands

### Direct Ansible Usage

Run the playbook directly (requires Ansible installed):

```bash
ansible-playbook -i localhost, -c local ansible/playbook.yml
```

### With Extra Variables

```bash
ansible-playbook -i localhost, -c local \
  ansible/playbook.yml \
  -e "install_deps=false" \
  -e "set_default_shell=false"
```

### Using Tags

Run specific parts of the playbook:

#### Available Tags

| Tag | Description |
|-----|-------------|
| `packages` | Install system packages only |
| `repo` | Clone/update repository only |
| `omz` | Install/update Oh My Zsh only |
| `config` | Link configuration files only |
| `shell` | Change default shell only |

#### Examples

**Install packages only**:
```bash
ansible-playbook ansible/playbook.yml --tags packages
```

**Update Oh My Zsh and configs**:
```bash
ansible-playbook ansible/playbook.yml --tags omz,config
```

**Everything except package installation**:
```bash
ansible-playbook ansible/playbook.yml --skip-tags packages
```

### Dry-Run Mode

```bash
ansible-playbook ansible/playbook.yml --check
```

### Verbose Output

```bash
ansible-playbook ansible/playbook.yml -v    # Verbose
ansible-playbook ansible/playbook.yml -vv   # More verbose
ansible-playbook ansible/playbook.yml -vvv  # Debug
```

---

## Zsh Built-in Commands

### Reload Configuration

```bash
# Reload without restarting shell
source ~/.zshrc

# Restart shell (recommended)
exec zsh
```

### Check Syntax

```bash
# Check for syntax errors
zsh -n ~/.zshrc

# Check specific file
zsh -n ~/.dotfiles/zsh/zshrc.d/10-aliases.zsh
```

### Profile Startup Time

```bash
# Time shell startup
time zsh -i -c exit

# Detailed profiling (add to ~/.zshrc temporarily)
zmodload zsh/zprof
# ... your config ...
zprof
```

### Debug Mode

```bash
# Enable tracing
setopt XTRACE

# Your commands here

# Disable tracing
setopt NOXTRACE
```

---

## Git Commands (Dotfiles Management)

### Check Status

```bash
cd ~/.dotfiles
git status
```

### View Changes

```bash
# See what changed
git diff

# See what's staged
git diff --staged
```

### Commit Changes

```bash
git add zsh/zshrc.d/10-aliases.zsh
git commit -m "Add new git shortcuts"
```

### Push to Remote

```bash
git push origin main
```

### Pull Latest Changes

```bash
git pull origin main
```

### View History

```bash
# Short format
git log --oneline

# With graph
git log --oneline --graph --all

# Last 5 commits
git log -5
```

---

## Oh My Zsh Commands

### Update Oh My Zsh

```bash
omz update
```

### Reload Oh My Zsh

```bash
omz reload
```

### Plugin Management

```bash
# List enabled plugins
omz plugin list

# Enable a plugin (edit config file)
vim ~/.dotfiles/zsh/zshrc.d/00-omz.zsh
```

### Theme Configuration

```bash
# Powerlevel10k configuration wizard
p10k configure

# Reload Powerlevel10k
p10k reload
```

---

## Backup & Recovery Commands

### List Backups

```bash
ls -lth ~/.dotfiles-backups/
```

### Restore from Backup

```bash
# List available backups
ls ~/.dotfiles-backups/zshrc.*

# Restore specific backup
cp ~/.dotfiles-backups/zshrc.2025-12-25_10-30-45 ~/.zshrc

# Reload shell
exec zsh
```

### Manual Backup

```bash
# Backup before making changes
cp ~/.zshrc ~/.dotfiles-backups/zshrc.$(date +%Y-%m-%d_%H-%M-%S)
```

---

## Diagnostic Commands

### Check What's Loaded

```bash
# List loaded zsh modules
zmodload

# List loaded functions
functions | grep -E "^[a-z]"

# List aliases
alias

# Check specific alias
which gs

# Check function definition
which mkcd
```

### Check Environment

```bash
# All environment variables
env

# Specific variable
echo $EDITOR
echo $PATH
```

### Check Shell

```bash
# Current shell
echo $SHELL

# Available shells
cat /etc/shells

# Change shell
chsh -s $(which zsh)
```

---

## Integration Commands

### Docker Integration

If using the `phpunit-docker` function:
```bash
# Run PHPUnit in Docker container
phpunit-docker tests/Unit/ExampleTest.php
```

### Custom Functions

Check `~/.dotfiles/zsh/zshrc.d/15-functions.zsh` for available functions:
```bash
# View all custom functions
grep "^[a-z_]*() {" ~/.dotfiles/zsh/zshrc.d/15-functions.zsh
```

---

## Quick Reference Card

### Daily Use

```bash
exec zsh                        # Reload shell
source ~/.zshrc                 # Reload config (alternative)
dotfiles-pull-updates.sh        # Update dotfiles
git status                      # Check dotfiles status (in ~/.dotfiles)
```

### Configuration

```bash
vim ~/.zshrc.local              # Machine-specific config
vim ~/.dotfiles/zsh/zshrc.d/10-aliases.zsh  # Aliases
vim ~/.dotfiles/zsh/zshrc.d/15-functions.zsh # Functions
```

### Troubleshooting

```bash
zsh -n ~/.zshrc                 # Check syntax
time zsh -i -c exit             # Profile startup
ls ~/.dotfiles-backups/         # List backups
```

### Oh My Zsh

```bash
omz update                      # Update framework
p10k configure                  # Configure theme
```

---

## Environment Variables Reference

### Dotfiles System

| Variable | Purpose | Default |
|----------|---------|---------|
| `DOTFILES_DIR` | Dotfiles repository location | Auto-detected from script location, or `~/.dotfiles` |
| `ZSH_DOTFILES_UPDATE_FREQ` | Update check frequency (days) | `1` |
| `ZSH_DOTFILES_AUTOUPDATE` | Auto-pull updates | `true` |

### Oh My Zsh

| Variable | Purpose | Default |
|----------|---------|---------|
| `ZSH` | Oh My Zsh installation | `~/.oh-my-zsh` |
| `ZSH_THEME` | Active theme | `powerlevel10k/powerlevel10k` |
| `ZSH_CUSTOM` | Custom directory | `~/.dotfiles/zsh/omz-custom` |

### Standard Shell

| Variable | Purpose | Example |
|----------|---------|---------|
| `EDITOR` | Default text editor | `vim` |
| `VISUAL` | Visual editor | `vim` |
| `PAGER` | Default pager | `less` |
| `SHELL` | Current shell | `/usr/bin/zsh` |

---

## Exit Codes

All scripts follow standard exit code conventions:

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Misuse of command (invalid arguments) |
| 126 | Command found but not executable |
| 127 | Command not found |
| 130 | Terminated by Ctrl+C |

---

## See Also

- [Configuration Guide](configuration.md) - How to customize
- [Troubleshooting](troubleshooting.md) - Fix common issues
- [Architecture](architecture.md) - How it all works
- [FAQ](faq.md) - Common questions
