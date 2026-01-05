# Quick Start Guide

Get your dotfiles up and running in just a few minutes.

## The Fast Track

```bash
# 1. Clone the repository
git clone <your-repo-url> ~/.dotfiles

# 2. Run bootstrap
cd ~/.dotfiles
./bootstrap.sh

# 3. Start using zsh
exec zsh
```

That's it! You're done. Everything is configured and ready to use.

## What Just Happened?

The bootstrap script:
1. ✅ Installed system dependencies (git, zsh, curl, vim)
2. ✅ Installed Oh My Zsh framework
3. ✅ Linked configuration files to your home directory
4. ✅ Created `~/.zshrc.local` for your custom settings
5. ✅ Backed up any existing files to `~/.dotfiles-backups/`
6. ✅ Set zsh as your default shell

## Next Steps

### Add Your Custom Configuration

**For machine-specific settings** (not tracked in git):
```bash
# Edit your local overrides
vim ~/.zshrc.local
```

Examples of what goes in `~/.zshrc.local`:
- API keys and secrets
- Machine-specific paths
- Work vs personal environment differences
- Local development tools

**For portable settings** (tracked in git):
```bash
# Edit aliases
vim ~/.dotfiles/zsh/zshrc.d/10-aliases.zsh

# Edit functions
vim ~/.dotfiles/zsh/zshrc.d/15-functions.zsh

# Edit environment variables
vim ~/.dotfiles/zsh/zshrc.d/30-env.zsh
```

### Verify Everything Works

```bash
# Check zsh is running
echo $SHELL

# Verify dotfiles updates work
dotfiles-check-updates.sh

# Test an alias
docker-compose --version  # Should resolve to 'docker compose'
```

## Optional Customization

### Skip Package Installation

If you already have the required packages:
```bash
./bootstrap.sh --no-install-deps
```

### Don't Change Default Shell

To keep your current shell:
```bash
./bootstrap.sh --no-chsh
```

### Preview Changes First

To see what would be done without applying:
```bash
./bootstrap.sh --dry-run
```

## Common First-Time Issues

### Permission Denied
If you see "Permission denied" errors:
```bash
chmod +x ~/.dotfiles/bootstrap.sh
```

### Sudo Password Required
The bootstrap needs sudo both to install packages and to change your default shell. You'll be prompted to enter your sudo password when Ansible needs elevated privileges (typically during package installation or when running `chsh`). If you don't want to install packages or change your default shell, you can skip these steps with:
```bash
./bootstrap.sh --no-install-deps --no-chsh
```

### Zsh Not Activating
After installation, run:
```bash
exec zsh
```

Or log out and back in.

## What's Next?

- Read the [Configuration Guide](configuration.md) to customize your setup
- Check [Zsh Configuration](zsh-configuration.md) for Oh My Zsh customization
- Set up [automatic updates](updates.md)
- Learn about the [ownership model](ownership-model.md)

## Getting Help

- See [Troubleshooting Guide](troubleshooting.md)
- Review [FAQ](faq.md)
- Check existing issues in the repository

---

**Pro Tip**: Run `./bootstrap.sh` anytime to re-sync your configuration. It's idempotent and safe to run repeatedly.
