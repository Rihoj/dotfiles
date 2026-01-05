# Dotfiles

Personal dotfiles managed with Ansible for consistency across machines.

## 📚 Documentation

**Complete documentation** is available in the [`docs/`](docs/) directory:

- **[Quick Start Guide](docs/getting-started.md)** - Get running in 5 minutes
- **[Full Documentation Index](docs/README.md)** - All available docs
- **[Troubleshooting](docs/troubleshooting.md)** - Fix common issues
- **[FAQ](docs/faq.md)** - Frequently asked questions

## The One True Way

```bash
# Clone this repo
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# Run the bootstrap (installs Ansible if needed, then provisions)
./bootstrap.sh

# Configure your git identity (name, email, GPG key)
./bin/setup-git-config.sh
```

That's it. Everything else is optional flags.

## Optional Flags

```bash
./bootstrap.sh --repo <url>        # Clone from remote instead of using local repo
./bootstrap.sh --no-install-deps   # Skip package installation
./bootstrap.sh --no-chsh           # Don't change default shell to zsh
./bootstrap.sh --dry-run           # See what would be done without making changes
```

## What Gets Managed

- **Repo files**: All files in this repo are the canonical source of truth
- **~/.zshrc**: Symlinked to repo. Overwritten on every run.
- **~/.zshrc.local**: Created once from template. NEVER touched again. This is YOUR file.
- **~/.gitconfig**: Symlinked to repo. Contains global git settings.
- **~/.gitconfig.local**: Created by setup script. NEVER touched again. Contains your git identity.

## Platform Support

Tested on:
- Linux (Debian, Ubuntu, RHEL, Fedora, Arch)
- macOS (with some limitations on shell detection)

Requirements:
- Bash 4.0+
- Python 3.6+
- Git

## Ownership Contract

- **Repo owns**: .zshrc, all zsh modules, aliases, environment setup, .gitconfig (global git settings)
- **You own**: ~/.zshrc.local for machine-specific config, secrets, local paths
- **You own**: ~/.gitconfig.local for your git identity (name, email, GPG key)

## Safety Features

- **Backups**: Existing files backed up to `~/.dotfiles-backups/` before replacement
- **Dry-run**: Use `--dry-run` to see changes without applying them
- **Idempotent**: Safe to re-run any time
- **Tags**: Run specific parts with `ansible-playbook ... --tags config,omz`

## Direct Ansible Usage

If you already have Ansible installed:

```bash
ansible-playbook -i localhost, -c local ansible/playbook.yml
```

Use extra vars as needed:
```bash
ansible-playbook ... -e dotfiles_repo=<url> -e install_deps=false
```

Available tags: `packages`, `repo`, `config`, `omz`, `shell`

## Rollback

Backups are timestamped in `~/.dotfiles-backups/`. To restore:

```bash
cp ~/.dotfiles-backups/zshrc.<timestamp> ~/.zshrc
```

## Learn More

### Key Documentation

- **[Configuration Guide](docs/configuration.md)** - Customize your setup
- **[Architecture Overview](docs/architecture.md)** - How it all works
- **[Command Reference](docs/command-reference.md)** - All available commands
- **[Update Management](docs/updates.md)** - Keep dotfiles synchronized
- **[Zsh Configuration](docs/zsh-configuration.md)** - Deep dive into Zsh

### Common Tasks

- **Add aliases**: Edit `zsh/zshrc.d/10-aliases.zsh` (see [Configuration Guide](docs/configuration.md#adding-an-alias))
- **Machine-specific config**: Use `~/.zshrc.local` (see [Ownership Model](docs/ownership-model.md))
- **Update dotfiles**: Run `dotfiles-pull-updates.sh` (see [Update Management](docs/updates.md))
- **Troubleshooting**: Check [Troubleshooting Guide](docs/troubleshooting.md)
- [ ] Split config into zsh/zshrc.d/ modules
- [ ] Move machine-specific config to ~/.zshrc.local
- [ ] Migrate additional configs (git, vim, npm, etc.)
- [ ] Add custom scripts to bin/
- [ ] Test with `./bootstrap.sh --dry-run`
- [ ] Verify modules load: `zsh -c 'echo $DOTFILES_DIR'`
- [ ] Commit: `git add zsh/ git/ bin/ && git commit -m "Migrate dotfiles"`
- [ ] Push to remote: `git push -u origin main`

## Legacy Scripts

- `setup-dotfiles.sh`: Old bash-only bootstrap. **Deprecated.** Use `bootstrap.sh` instead.

## Update Utilities

These scripts help keep your dotfiles up to date across machines and make commands available globally.

- **[bin/dotfiles-check-updates.sh](bin/dotfiles-check-updates.sh):** Auto-checks for repo updates on shell startup, every N days.
    - Env: `ZSH_DOTFILES_UPDATE_FREQ` (default: 7)
    - Loaded by [zsh/zshrc.d/05-dotfiles-updates.zsh](zsh/zshrc.d/05-dotfiles-updates.zsh)

- **[bin/dotfiles-pull-updates.sh](bin/dotfiles-pull-updates.sh):** Manual updater.
    - Check only: `dotfiles-pull-updates --check-only`
    - Pull and notify reload: `dotfiles-pull-updates`
    - Uses your upstream tracking branch (`@{u}`), not hardcoded origin/main

- **[bin/dotfiles-link-bin.sh](bin/dotfiles-link-bin.sh):** Symlinks scripts in `bin/` to `~/.local/bin`.
    - Run once: `~/.dotfiles/bin/dotfiles-link-bin.sh`
    - Ensure PATH includes `~/.local/bin`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Behavior
- Non-blocking: update checks run in the background during shell startup.
- Safe defaults: does nothing if the repo isn’t a git clone.
- Clear prompts: shows a short notice when updates are available.

### Migration Mode (Optional)
By default, provisioning will NOT copy existing home dotfiles into the repo.
To explicitly migrate legacy dotfiles from `~` into this repo during provisioning, set:

```bash
MIGRATE_EXISTING_DOTFILES=true ./bootstrap.sh
```

Or pass via Ansible extra vars:

```bash
ansible-playbook -i localhost, -c local ansible/playbook.yml -e migrate_existing_dotfiles=true
```

This gates home→repo copy/backup/removal to avoid mutating a curated repo on subsequent runs.
