# Ownership Model

Understanding what the repository owns and what you own.

## The Fundamental Contract

This dotfiles system operates on a clear ownership contract:

```
┌─────────────────────────────────────┐
│          Repository Owns            │
│  - All files in ~/.dotfiles/        │
│  - Configuration structure          │
│  - Framework setup                  │
│  - Default settings                 │
└─────────────────────────────────────┘
                 │
                 ▼
         Provisions & Links
                 │
                 ▼
┌─────────────────────────────────────┐
│            You Own                  │
│  - ~/.zshrc.local                   │
│  - Machine-specific overrides       │
│  - Secrets and credentials          │
└─────────────────────────────────────┘
```

## Repository Ownership

### What the Repo Controls

The repository has **complete ownership** over:

#### 1. Configuration Structure
```
~/.dotfiles/
├── zsh/zshrc.d/         # Module organization
├── git/.gitconfig       # Git settings
├── vim/.vimrc          # Vim settings
└── ansible/            # Automation logic
```

**Implication**: Don't manually edit these files in place. Edit them in the repo, commit, and re-provision.

#### 2. Symlinked Files

These files are **symlinks** to the repo:
```bash
~/.gitconfig  →  ~/.dotfiles/git/.gitconfig
~/.vimrc      →  ~/.dotfiles/vim/.vimrc
```

**Implication**: Changes to `~/.gitconfig` actually modify the repo file. Commit them to git.

#### 3. Generated Configuration

The main `.zshrc` (if the repo contains one) or the sourcing logic that loads modules from `zsh/zshrc.d/`.

**Implication**: The repo controls how configuration is loaded and structured.

#### 4. Framework Setup

- Oh My Zsh installation
- Oh My Zsh plugin list
- Oh My Zsh theme configuration
- Directory structure

**Implication**: Framework changes require updating the repo and re-provisioning.

### What the Repo Will Overwrite

During provisioning (`./bootstrap.sh`), the repo will **overwrite**:

- Symlinked configuration files (after backing up)
- Oh My Zsh installation (if outdated)
- Zsh module structure
- Utility scripts in `bin/`

**Safety**: Original files are backed up to `~/.dotfiles-backups/` first.

---

## User Ownership

### What You Control

You have **complete ownership** over:

#### 1. Local Configuration File

```bash
~/.zshrc.local
```

**Guarantees**:
- ✅ Created once from template
- ✅ **NEVER** touched again by the repo
- ✅ Not tracked in git
- ✅ Your permanent customization space

#### 1a. Early Env Overrides (Optional)

```bash
~/.zshenv.local
```

**Use for** variables that must be set before any modules load (e.g., update settings).

#### 2. Local Overrides

Any settings in `~/.zshrc.local` override repo settings because it loads last:

```zsh
# In repo: zsh/zshrc.d/30-env.zsh
export EDITOR='vim'

# In ~/.zshrc.local (wins!)
export EDITOR='nvim'
```

#### 3. Machine-Specific Content

Everything that differs between your machines:
- API keys and secrets
- Work vs personal environment differences
- Machine-specific paths
- Local development tools

#### 4. Backup Directory

```bash
~/.dotfiles-backups/
```

Contains timestamped backups of files before they were overwritten. You control when to clean these up.

### What You Can Safely Modify

**Outside the repo**:
- ✅ `~/.zshrc.local` - Your personal space
- ✅ Any dotfiles not managed by the repo
- ✅ Backup directory contents

**Inside the repo** (with git commit):
- ✅ `zsh/zshrc.d/*.zsh` - Portable configurations
- ✅ `git/.gitconfig` - Git settings
- ✅ `vim/.vimrc` - Vim settings
- ✅ Any configuration file in the repo

---

## Shared Ownership Model

Some files have **split ownership**:

### Zsh Configuration

```
Repo owns:          You own:
  │                   │
  ├─ Framework        └─ Local overrides
  ├─ Modules            (~/.zshrc.local)
  ├─ Defaults
  └─ Structure
```

**How it works**:
1. Repo sets up framework and defaults
2. Repo loads all modules in order
3. Your `~/.zshrc.local` loads last
4. Your settings override repo settings

### Git Configuration

```
Repo owns:          You own:
  │                   │
  ├─ .gitconfig       └─ .gitconfig.local
  │  (global)            (user identity)
  │  - aliases           - name
  │  - settings          - email
  │  - includes          - GPG key
```

**Pattern**:
```bash
# In repo: git/.gitconfig
[include]
    path = ~/.gitconfig.local  # User's local file

# Created by setup-git-config.sh: ~/.gitconfig.local
[user]
    name = Your Name
    email = work@example.com  # Work machine
    signingkey = YOUR_GPG_KEY  # Optional
```

**Setup**: Run `~/.dotfiles/bin/setup-git-config.sh` to interactively configure your git identity.

---

## The Lifecycle of a Configuration File

### New File - Repo Owned

```
1. You create: ~/.dotfiles/tool/.toolrc
2. You commit to git
3. You update Ansible to link it
4. Bootstrap creates: ~/.toolrc → ~/.dotfiles/tool/.toolrc
5. Repo now owns ~/.toolrc
```

### New File - User Owned

```
1. You create: ~/.some-local-config
2. Don't add to repo
3. Don't configure Ansible to link it
4. You own ~/.some-local-config
5. It survives bootstrap runs unchanged
```

### Existing File - Converting to Repo Ownership

```
1. Bootstrap backs up: ~/.oldconfig → ~/.dotfiles-backups/oldconfig.TIMESTAMP
2. Bootstrap links: ~/.oldconfig → ~/.dotfiles/tool/.oldconfig
3. Repo now owns ~/.oldconfig
4. Your original is safely backed up
```

---

## Boundaries and Rules

### Hard Rules

#### ❌ Never Edit Repo Files In-Place Without Committing

```bash
# Wrong
vim ~/.gitconfig  # Edits repo, but doesn't commit
# Risk: Next git pull overwrites your changes

# Right
cd ~/.dotfiles
vim git/.gitconfig
git add git/.gitconfig
git commit -m "Update git settings"
```

#### ❌ Never Put Secrets in Repo Files

```bash
# Wrong - in repo file
export GITHUB_TOKEN='ghp_xxx'  # Will be committed!

# Right - in ~/.zshrc.local
export GITHUB_TOKEN='ghp_xxx'  # Never committed
```

#### ✅ Always Use ~/.zshrc.local for Machine Differences

```bash
# Right approach
# ~/.zshrc.local (not in git)
if [[ "$(hostname)" == "work-laptop" ]]; then
    export WORK_SPECIFIC='value'
fi
```

### Soft Guidelines

#### Consider Repo Ownership When...

- Configuration works across all your machines
- You want version control and history
- You want to share with others
- It's not sensitive information

#### Consider User Ownership When...

- Configuration is machine-specific
- Contains secrets or credentials
- Temporary or experimental
- Personal and not for sharing

---

## Practical Examples

### Example 1: Adding a New Alias

**Portable Alias** (works everywhere):
```bash
# Add to repo
vim ~/.dotfiles/zsh/zshrc.d/10-aliases.zsh
# Add: alias gs='git status'

cd ~/.dotfiles
git add zsh/zshrc.d/10-aliases.zsh
git commit -m "Add git status alias"
git push
```

**Machine-Specific Alias**:
```bash
# Add to local file
vim ~/.zshrc.local
# Add: alias vpn='sudo openvpn /etc/openvpn/work.conf'

# No git commit needed - it's yours
```

### Example 2: Setting EDITOR

**Same editor everywhere** (repo):
```bash
vim ~/.dotfiles/zsh/zshrc.d/30-env.zsh
# Add: export EDITOR='vim'

git add zsh/zshrc.d/30-env.zsh
git commit -m "Set default editor to vim"
```

**Different editors per machine** (local):
```bash
# Work machine ~/.zshrc.local
export EDITOR='code --wait'  # VS Code

# Personal machine ~/.zshrc.local
export EDITOR='nvim'  # Neovim
```

### Example 3: Git User Configuration

**Setup**: Run the interactive configuration script:
```bash
~/.dotfiles/bin/setup-git-config.sh
```

This creates `~/.gitconfig.local` with your settings:

**On work machine** (`~/.gitconfig.local`):
```ini
[user]
    name = Your Name
    email = work@company.com
    signingkey = WORK_GPG_KEY
```

**On personal machine** (`~/.gitconfig.local`):
```ini
[user]
    name = Your Name
    email = personal@gmail.com
    signingkey = PERSONAL_GPG_KEY
```

The repo's `git/.gitconfig` automatically includes your local config:
```ini
# In repo: git/.gitconfig
[include]
    path = ~/.gitconfig.local

[commit]
    gpgsign = true  # Repo enables signing

[alias]
    co = switch
    # ... other aliases
```

**Advanced**: Conditional includes for different directories
```bash
# In ~/.gitconfig.local (your file, not in repo)
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work
[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

---

## Transfer of Ownership

### Taking Ownership from Repo

Remove from repo control:
```bash
cd ~/.dotfiles

# Remove from git
git rm vim/.vimrc
git commit -m "Stop managing vimrc in repo"

# Remove symlink
rm ~/.vimrc

# Create your own
cp ~/.dotfiles-backups/vimrc.TIMESTAMP ~/.vimrc
# Now you own ~/.vimrc
```

### Giving Ownership to Repo

Add to repo control:
```bash
cd ~/.dotfiles

# Copy your file to repo
cp ~/.myconfig tool/.myconfig

# Add to git
git add tool/.myconfig
git commit -m "Add myconfig to repo"

# Update Ansible to link it
vim ansible/roles/dotfiles/tasks/main.yml
# Add linking task

# Re-provision
./bootstrap.sh
# Now repo owns ~/.myconfig
```

---

## Ownership Decision Tree

```
Does the config work the same on all machines?
│
├─ YES ─→ Is it sensitive/secret?
│          │
│          ├─ NO ─→ Repo ownership ✅
│          │       (commit to git)
│          │
│          └─ YES ─→ User ownership ⚠️
│                    (~/.zshrc.local)
│
└─ NO ─→ User ownership ⚠️
         (~/.zshrc.local)
```

---

## Best Practices

### Do:
✅ Keep portable config in repo  
✅ Keep secrets in `~/.zshrc.local`  
✅ Commit repo changes to git  
✅ Test changes before pushing  
✅ Document complex configurations  
✅ Use version control for repo files  

### Don't:
❌ Hardcode machine-specific paths in repo  
❌ Commit secrets to git  
❌ Edit symlinked files without committing  
❌ Mix sensitive and non-sensitive config  
❌ Assume others have same machine setup  

---

## Summary

| Aspect | Repo Owned | User Owned |
|--------|-----------|------------|
| **Location** | `~/.dotfiles/*` | `~/.zshrc.local` |
| **Tracked in Git** | ✅ Yes | ❌ No |
| **Synced across machines** | ✅ Yes | ❌ No |
| **Overwritten by bootstrap** | ✅ Yes | ❌ Never |
| **Backed up before changes** | ✅ Yes | N/A |
| **Version controlled** | ✅ Yes | ❌ No |
| **Can contain secrets** | ❌ No | ✅ Yes |
| **Machine-specific** | ❌ No | ✅ Yes |

**Key Principle**: The repo provides structure and defaults; you provide customization and secrets.

---

## Related Documentation

- [Configuration Guide](configuration.md) - How to customize
- [Architecture](architecture.md) - System design
- [FAQ](faq.md) - Common questions
