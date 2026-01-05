# Troubleshooting Guide

Solutions to common issues and diagnostic techniques.

## Quick Diagnostics

Run these commands to gather information about your setup:

```bash
# Check zsh version
zsh --version

# Check if dotfiles repo exists
ls -la ~/.dotfiles

# Check if .zshrc is a symlink (if using symlink approach)
ls -la ~/.zshrc

# Check Oh My Zsh installation
ls -la ~/.oh-my-zsh

# Check shell configuration loads
zsh -n ~/.zshrc

# Profile startup time
time zsh -i -c exit
```

---

## Installation Issues

### Bootstrap Script Fails to Run

**Symptom**: `Permission denied` when running `./bootstrap.sh`

**Solution**:
```bash
chmod +x ~/.dotfiles/bootstrap.sh
./bootstrap.sh
```

---

### "Command not found: ansible-playbook"

**Symptom**: Bootstrap fails with Ansible not found

**Solution**: Bootstrap should install Ansible. If it fails:

```bash
# Manual Ansible installation
# Debian/Ubuntu (preferred - uses pipx to avoid PEP 668 issues)
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv pipx
pipx install --include-deps ansible

# Debian/Ubuntu (fallback - if pipx unavailable)
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv
python3 -m pip install --user --break-system-packages ansible

# Fedora (preferred - uses pipx)
sudo dnf install -y python3 python3-pip pipx
pipx install --include-deps ansible

# Fedora (fallback)
sudo dnf install -y python3 python3-pip
python3 -m pip install --user --break-system-packages ansible

# macOS
brew install ansible
```

Then re-run bootstrap:
```bash
./bootstrap.sh
```

---

### Python "externally-managed-environment" Error

**Symptom**: `pip install` fails with error about externally-managed environment (PEP 668)

```
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.
```

**Cause**: Modern Python installations (Python 3.12+) on Debian/Ubuntu prevent `pip install --user` to protect system packages.

**Solution 1**: Use `pipx` (recommended - automatically handled by bootstrap)
```bash
# Install pipx
sudo apt-get install -y pipx

# Then bootstrap will use pipx automatically
./bootstrap.sh
```

**Solution 2**: Bootstrap already handles this
The `bootstrap.sh` script automatically:
1. Tries to install and use `pipx` if available
2. Falls back to `pip install --user --break-system-packages` if pipx is unavailable

Simply re-run bootstrap:
```bash
./bootstrap.sh
```

**Solution 3**: Manual installation with pipx
```bash
sudo apt-get install -y pipx
pipx install --include-deps ansible
```

---

### Package Installation Fails

**Symptom**: `Failed to install packages`

**Cause**: Missing sudo/doas or permission denied

**Solution 1**: Install packages manually
```bash
# Debian/Ubuntu
sudo apt-get install -y git curl zsh vim

# Fedora
sudo dnf install -y git curl zsh vim

# Arch
sudo pacman -S git curl zsh vim
```

**Solution 2**: Skip package installation
```bash
./bootstrap.sh --no-install-deps
```

---

### Can't Clone Repository

**Symptom**: `fatal: could not read Username` or `Permission denied (publickey)`

**Solution**: Use HTTPS instead of SSH or set up SSH keys

```bash
# Clone with HTTPS
git clone https://github.com/username/dotfiles.git ~/.dotfiles

# Or set up SSH keys
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub  # Add to GitHub
```

---

## Shell Issues

### Zsh Not Activating After Installation

**Symptom**: Still using bash after running bootstrap

**Solution 1**: Manually start zsh
```bash
exec zsh
```

**Solution 2**: Check default shell
```bash
# Check current shell
echo $SHELL

# Change to zsh
chsh -s $(which zsh)

# Log out and back in
```

**Solution 3**: Bootstrap with shell change
```bash
./bootstrap.sh  # Without --no-chsh flag
```

---

### "zsh: command not found" for Custom Functions

**Symptom**: Functions defined in dotfiles don't work

**Diagnostics**:
```bash
# Check if file is being sourced
grep "15-functions.zsh" ~/.zshrc

# Check function exists in file
cat ~/.dotfiles/zsh/zshrc.d/15-functions.zsh

# Test sourcing directly
source ~/.dotfiles/zsh/zshrc.d/15-functions.zsh
```

**Solution**: Reload shell
```bash
exec zsh
```

---

### Configuration Changes Not Taking Effect

**Symptom**: Modified aliases/functions don't work

**Cause**: Shell configuration not reloaded

**Solution**:
```bash
# Quick reload (current shell)
source ~/.zshrc

# Full reload (recommended)
exec zsh
```

---

### Slow Shell Startup

**Symptom**: Shell takes 3+ seconds to start

**Diagnosis**:
```bash
# Time startup
time zsh -i -c exit

# Profile startup
zmodload zsh/zprof
# Add to top of ~/.zshrc, then source it
source ~/.zshrc
zprof  # Shows what's slow
```

**Common Causes & Solutions**:

1. **Too many Oh My Zsh plugins**
   ```bash
   # Edit plugins list
   vim ~/.dotfiles/zsh/zshrc.d/00-omz.zsh
   # Remove unused plugins
   ```

2. **NVM loading synchronously**
   ```bash
   # Lazy load NVM
   export NVM_DIR="$HOME/.nvm"
   # Remove: [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
   # Add lazy loader instead
   nvm() {
     unset -f nvm
     [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
     nvm "$@"
   }
   ```

3. **Complex command substitutions in prompt**
   ```bash
   # Use Powerlevel10k instant prompt
   # Should be at top of ~/.zshrc or 99-p10k.zsh
   ```

---

## Oh My Zsh Issues

### Oh My Zsh Not Installed

**Symptom**: `~/.oh-my-zsh` directory doesn't exist

**Solution**:
```bash
# Automatic via bootstrap
./bootstrap.sh --tags omz

# Manual installation
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

---

### Plugin Not Working

**Symptom**: Enabled plugin has no effect

**Diagnostics**:
```bash
# Check if plugin is in the list
cat ~/.dotfiles/zsh/zshrc.d/00-omz.zsh | grep plugins

# Check if plugin exists
ls ~/.oh-my-zsh/plugins/ | grep plugin-name
```

**Solution 1**: Verify plugin name
```bash
vim ~/.dotfiles/zsh/zshrc.d/00-omz.zsh
# Ensure correct plugin name in plugins array
```

**Solution 2**: Install custom plugin
```bash
git clone https://github.com/author/plugin-name \
  ~/.dotfiles/zsh/omz-custom/plugins/plugin-name
```

**Solution 3**: Reload shell
```bash
exec zsh
```

---

### Powerlevel10k Theme Not Working

**Symptom**: Prompt looks broken or uses default theme

**Diagnostics**:
```bash
# Check theme setting
grep ZSH_THEME ~/.dotfiles/zsh/zshrc.d/00-omz.zsh

# Check if p10k is installed
ls ~/.oh-my-zsh/custom/themes/ | grep powerlevel10k
```

**Solution 1**: Install Powerlevel10k
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ~/.oh-my-zsh/custom/themes/powerlevel10k
```

**Solution 2**: Configure theme
```bash
p10k configure
```

**Solution 3**: Install required fonts
```bash
# Debian/Ubuntu
sudo apt-get install -y fonts-powerline

# Fedora
sudo dnf install -y powerline-fonts

# macOS
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```

---

## Update Issues

### "Already up to date" But Changes Are Missing

**Symptom**: `git pull` says up to date but config is old

**Cause**: Local modifications or detached HEAD

**Diagnostics**:
```bash
cd ~/.dotfiles
git status
git log --oneline -5
git log --oneline origin/main -5
```

**Solution 1**: Stash local changes and pull
```bash
cd ~/.dotfiles
git stash
git pull origin main
git stash pop
```

**Solution 2**: Reset to origin
```bash
cd ~/.dotfiles
# CAUTION: This discards local changes
git fetch origin
git reset --hard origin/main
```

**Solution 3**: Re-run provisioning
```bash
./bootstrap.sh
```

---

### Update Check Not Running

**Symptom**: No update notifications despite being behind

**Diagnostics**:
```bash
# Check last update time
cat ~/.dotfiles/.last_update_check

# Calculate days since last check
echo $(( ($(date +%s) - $(cat ~/.dotfiles/.last_update_check)) / 86400 ))

# Check frequency setting
echo $ZSH_DOTFILES_UPDATE_FREQ
```

**Solution 1**: Manual check
```bash
~/.dotfiles/bin/dotfiles-check-updates.sh
```

**Solution 2**: Reset check timer
```bash
rm ~/.dotfiles/.last_update_check
exec zsh
```

**Solution 3**: Verify script is sourced
```bash
grep "dotfiles-check-updates" ~/.dotfiles/zsh/zshrc.d/05-dotfiles-updates.zsh
```

---

### Auto-Update Not Working

**Symptom**: `AUTOUPDATE=true` but updates don't apply automatically

**Diagnostics**:
```bash
# Check setting
echo $ZSH_DOTFILES_AUTOUPDATE
```

**Solution**: Set in `~/.zshrc.local`
```bash
vim ~/.zshrc.local
# Add:
export ZSH_DOTFILES_AUTOUPDATE=true

# Reload
exec zsh
```

---

## Configuration Issues

### Changes in `~/.zshrc.local` Not Working

**Symptom**: Variables or aliases in `~/.zshrc.local` don't work

**Diagnostics**:
```bash
# Check file exists
ls -la ~/.zshrc.local

# Check syntax
zsh -n ~/.zshrc.local

# Check if sourced
grep "zshrc.local" ~/.zshrc
```

**Solution 1**: Create file if missing
```bash
touch ~/.zshrc.local
chmod 600 ~/.zshrc.local
```

**Solution 2**: Verify sourcing in ~/.zshrc
```bash
# Should contain:
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

**Solution 3**: Check for syntax errors
```bash
cat ~/.zshrc.local  # Look for typos
```

---

### Aliases Not Working

**Symptom**: Defined aliases don't execute

**Diagnostics**:
```bash
# Check if alias exists
alias | grep alias-name

# Check alias file
cat ~/.dotfiles/zsh/zshrc.d/10-aliases.zsh
```

**Solution 1**: Verify alias syntax
```bash
# Correct
alias gs='git status'

# Wrong
alias gs=git status  # Missing quotes
```

**Solution 2**: Check for conflicts
```bash
# Check if it's a function
type alias-name

# Check if it's a command
which alias-name
```

**Solution 3**: Reload shell
```bash
exec zsh
```

---

### Environment Variables Not Set

**Symptom**: `echo $VARIABLE` returns empty

**Diagnostics**:
```bash
# Check where it's defined
grep -r "VARIABLE" ~/.dotfiles/zsh/zshrc.d/
grep "VARIABLE" ~/.zshrc.local

# Check export keyword
grep "export VARIABLE" ~/.dotfiles/zsh/zshrc.d/30-env.zsh
```

**Solution 1**: Use `export`
```bash
# Wrong
EDITOR=vim

# Correct
export EDITOR=vim
```

**Solution 2**: Check load order
```bash
# Variables should be in 30-env.zsh or earlier
# If in 99-p10k.zsh, they load too late
```

---

## Git Integration Issues

### Git Aliases Not Working

**Symptom**: `gs` (git status alias) doesn't work

**Cause**: Often `gs` conflicts with Ghostscript

**Solution 1**: Use different alias
```bash
vim ~/.dotfiles/zsh/zshrc.d/10-aliases.zsh
# Change to:
alias gst='git status'
```

**Solution 2**: Unalias conflicting command
```bash
# In ~/.zshrc.local
unalias gs 2>/dev/null
alias gs='git status'
```

---

### Gitconfig Not Applied

**Symptom**: Git still uses old name/email

**Diagnostics**:
```bash
# Check what Git sees
git config --global user.name
git config --global user.email

# Check symlink
ls -la ~/.gitconfig
```

**Solution 1**: Verify symlink
```bash
# Should point to dotfiles repo
ls -la ~/.gitconfig
# Should show: .gitconfig -> /home/user/.dotfiles/git/.gitconfig
```

**Solution 2**: Re-provision
```bash
cd ~/.dotfiles
./bootstrap.sh --tags config
```

**Solution 3**: Manual link
```bash
ln -sf ~/.dotfiles/git/.gitconfig ~/.gitconfig
```

---

## Backup and Recovery Issues

### Backup Directory Full

**Symptom**: `~/.dotfiles-backups/` is large

**Solution**: Clean old backups
```bash
# See disk usage
du -sh ~/.dotfiles-backups/

# List backups by age
ls -lt ~/.dotfiles-backups/

# Delete backups older than 30 days
find ~/.dotfiles-backups/ -type f -mtime +30 -delete
```

---

### Need to Restore Previous Configuration

**Symptom**: Recent changes broke something

**Solution 1**: Restore from backup
```bash
# List backups
ls -lt ~/.dotfiles-backups/

# Restore specific file
cp ~/.dotfiles-backups/zshrc.2025-12-24_15-30-00 ~/.zshrc

# Reload
exec zsh
```

**Solution 2**: Revert git changes
```bash
cd ~/.dotfiles

# See recent commits
git log --oneline -10

# Revert to specific commit
git checkout abc1234 -- zsh/zshrc.d/10-aliases.zsh

# Or reset entire repo
git reset --hard HEAD~1  # Go back 1 commit
```

**Solution 3**: Re-run clean provision
```bash
cd ~/.dotfiles
git pull origin main
./bootstrap.sh
```

---

## Permission Issues

### "Permission denied" on Script Execution

**Symptom**: Can't run dotfiles scripts

**Solution**:
```bash
# Make scripts executable
chmod +x ~/.dotfiles/bin/*.sh
chmod +x ~/.dotfiles/bootstrap.sh
```

---

### "Permission denied" on File Creation

**Symptom**: Can't create/modify dotfiles

**Solution 1**: Check ownership
```bash
ls -la ~/.dotfiles/
# Should be owned by your user

# Fix ownership if needed
sudo chown -R $USER:$USER ~/.dotfiles/
```

**Solution 2**: Check directory permissions
```bash
chmod 755 ~/.dotfiles/
chmod 755 ~/.dotfiles/bin/
chmod 755 ~/.dotfiles/zsh/
```

---

## Platform-Specific Issues

### macOS: "Operation not permitted"

**Symptom**: macOS blocks file operations

**Solution**: Grant Full Disk Access to Terminal
1. Open System Preferences → Security & Privacy
2. Go to Privacy tab → Full Disk Access
3. Add Terminal.app (or your terminal emulator)
4. Restart terminal

---

### WSL: Symlinks Not Working

**Symptom**: Symlinks show as regular files in Windows

**Solution**: Enable developer mode in Windows
1. Open Settings → Update & Security → For Developers
2. Enable Developer Mode
3. Restart WSL

---

### macOS: Shell Change Requires Password

**Symptom**: `chsh` keeps asking for password

**Solution**:
```bash
# Check available shells
cat /etc/shells

# If zsh not listed, add it
echo $(which zsh) | sudo tee -a /etc/shells

# Try again
chsh -s $(which zsh)
```

---

## Advanced Diagnostics

### Enable Verbose Debugging

```bash
# Add to top of ~/.zshrc temporarily
set -x  # Enable execution tracing

# Your problematic configuration here

# Reload and watch output
exec zsh
```

### Trace Configuration Loading

```bash
# Add to ~/.zshrc
echo "Loading ~/.zshrc"
# ... your config ...
echo "Loaded successfully"

# In each module file
echo "Loading $(basename ${(%):-%N})"
```

### Check for Conflicts

```bash
# Find duplicate definitions
alias | sort | uniq -d  # Duplicate aliases
functions | grep "^[a-z]" | sort | uniq -d  # Duplicate functions
```

### Verify File Sourcing Order

```bash
# List what's being sourced
grep -E "^source|^\." ~/.zshrc

# Check zshrc.d loading
ls -1 ~/.dotfiles/zsh/zshrc.d/*.zsh
```

---

## Still Having Issues?

### Gathering Debug Information

Create a debug report:

```bash
{
  echo "=== System Info ==="
  uname -a
  
  echo -e "\n=== Zsh Version ==="
  zsh --version
  
  echo -e "\n=== Current Shell ==="
  echo $SHELL
  
  echo -e "\n=== Dotfiles Status ==="
  cd ~/.dotfiles && git status
  
  echo -e "\n=== Dotfiles Remote ==="
  cd ~/.dotfiles && git remote -v
  
  echo -e "\n=== File Linkage ==="
  ls -la ~/.zshrc ~/.gitconfig ~/.vimrc
  
  echo -e "\n=== Oh My Zsh ==="
  ls -la ~/.oh-my-zsh/
  
  echo -e "\n=== Environment ==="
  env | grep -E "ZSH|DOTFILES|EDITOR"
  
  echo -e "\n=== Recent Errors ==="
  zsh -n ~/.zshrc 2>&1
  
} > ~/dotfiles-debug.txt

cat ~/dotfiles-debug.txt
```

### Clean Reinstall

Last resort - start fresh:

```bash
# Backup your local config
cp ~/.zshrc.local ~/zshrc.local.backup

# Remove everything
rm -rf ~/.dotfiles
rm -rf ~/.oh-my-zsh
rm ~/.zshrc

# Clone and reinstall
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh

# Restore local config
cp ~/zshrc.local.backup ~/.zshrc.local

# Reload
exec zsh
```

---

## Getting Help

If these solutions don't work:

1. Check the [FAQ](faq.md)
2. Review [Architecture](architecture.md) to understand the system
3. Check [Configuration Guide](configuration.md) for proper syntax
4. Open an issue with your debug information

---

**Pro Tip**: Before major changes, create a backup:
```bash
tar czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/.dotfiles ~/.zshrc.local
```
