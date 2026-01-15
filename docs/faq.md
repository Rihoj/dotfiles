# Frequently Asked Questions

Answers to common questions about the dotfiles system.

## General Questions

### What are dotfiles?

Dotfiles are configuration files for Unix-like systems that typically start with a dot (`.`), making them hidden by default. They configure:
- Shell environments (`.zshrc`, `.bashrc`)
- Text editors (`.vimrc`)
- Version control (`.gitconfig`)
- And many other tools

This system helps you manage and version control these files.

---

### Why should I use a dotfiles management system?

**Benefits**:
- ✅ Consistency across multiple machines
- ✅ Version control for your configuration
- ✅ Easy setup on new machines
- ✅ Backup and recovery capabilities
- ✅ Share configuration with team members
- ✅ Track what changes broke your setup

---

### Is this safe to use?

Yes, the system includes multiple safety features:
- Automatic backups before any changes
- Dry-run mode to preview changes
- Idempotent operations (safe to run multiple times)
- Clear separation between repo and user files
- Git version control for rollback

---

## Installation Questions

### Do I need to know Ansible?

No. The bootstrap script handles everything. You only interact with Ansible directly if you want to:
- Customize the provisioning process
- Run specific parts with tags
- Debug advanced issues

For daily use, just run `./bootstrap.sh`.

---

### Can I use this on multiple machines?

Absolutely! That's the main point. Just:
```bash
# On each machine
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

Use `~/.zshrc.local` for machine-specific differences.

---

### What if I already have dotfiles?

The system backs up existing files automatically. Check `~/.dotfiles-backups/` for your originals.

To migrate your existing config:
1. Run `./bootstrap.sh` (backs up existing files)
2. Copy your custom content from backups
3. Add to appropriate modules in `zsh/zshrc.d/`
4. Or add to `~/.zshrc.local` for personal content

See [Migration Guide](migration.md) for details.

---

### Can I use this without Oh My Zsh?

Yes, but you'd need to modify the Ansible playbook to skip OMZ installation. Oh My Zsh provides:
- Plugin ecosystem
- Themes (like Powerlevel10k)
- Sensible defaults
- Active community

Consider keeping it even if you only use a few plugins.

---

## Configuration Questions

### What's the difference between repo files and ~/.zshrc.local?

| Aspect | Repo Files | ~/.zshrc.local |
|--------|------------|----------------|
| **Tracked in Git** | ✅ Yes | ❌ No |
| **Synced across machines** | ✅ Yes | ❌ No |
| **Overwritten by repo** | ✅ Yes | ❌ Never |
| **Best for** | Portable config | Secrets, machine-specific |

**Rule of thumb**: If it works on all your machines → repo. If it's specific to one machine → `~/.zshrc.local`.

---

### Can I override repo settings?

Yes! Settings in `~/.zshrc.local` load last, so they override earlier settings:

```zsh
# In repo: zsh/zshrc.d/30-env.zsh
export EDITOR='vim'

# In ~/.zshrc.local (overrides above)
export EDITOR='nvim'
```

---

### How do I add a new configuration file?

1. **Create the file** in appropriate directory:
   ```bash
   vim ~/.dotfiles/newtool/.newtoolrc
   ```

2. **Update Ansible** to link it:
   ```yaml
   # In ansible/roles/dotfiles/tasks/main.yml
   - name: Link newtool configuration
     ansible.builtin.file:
       src: "{{ dotfiles_dir }}/newtool/.newtoolrc"
       dest: "{{ ansible_env.HOME }}/.newtoolrc"
       state: link
       force: true
   ```

3. **Re-provision**:
   ```bash
   ./bootstrap.sh
   ```

---

### Why are zsh files numbered?

Numbers control load order:
- `00-omz.zsh` - Loads first (framework)
- `10-aliases.zsh` - Loads after framework
- `99-p10k.zsh` - Loads last (theme)

Lower numbers = loads earlier. This ensures dependencies are met.

---

## Usage Questions

### How often should I update?

Depends on your workflow:

**Default**:
```zsh
# Check daily, auto-update
export ZSH_DOTFILES_UPDATE_FREQ=1
export ZSH_DOTFILES_AUTOUPDATE=true
```

**Conservative**:
```zsh
# Check every 7 days, manual update
export ZSH_DOTFILES_UPDATE_FREQ=7
export ZSH_DOTFILES_AUTOUPDATE=false
```

**Manual only**:
```zsh
# Never auto-check
export ZSH_DOTFILES_UPDATE_FREQ=999999
```

---

### What if I make changes on multiple machines?

**Best practice**: Work on one machine, push, then pull on others.

```bash
# Machine 1: Make changes
cd ~/.dotfiles
git add zsh/zshrc.d/10-aliases.zsh
git commit -m "Add new aliases"
git push

# Machine 2: Get changes
dotfiles-pull-updates.sh
```

**If you forgot and edited on both**:
```bash
# Resolve conflicts
cd ~/.dotfiles
git pull  # Will show conflicts
# Edit conflicted files
git add .
git commit
git push
```

---

### Can I have different configurations for work vs personal?

Yes! Use `~/.zshrc.local`:

```zsh
# Detect which machine this is
if [[ "$(hostname)" == "work-laptop" ]]; then
    export ENVIRONMENT="work"
    # Work-specific settings
    alias vpn='sudo openvpn /etc/openvpn/work.conf'
else
    export ENVIRONMENT="personal"
    # Personal settings
fi
```

Or use git branches:
```bash
# Work machine
git checkout work-branch

# Personal machine
git checkout main
```

---

### How do I share my dotfiles but keep secrets private?

Use `~/.zshrc.local` for secrets (not tracked in git):

```zsh
# In ~/.zshrc.local (NEVER committed)
export GITHUB_TOKEN='ghp_xxxxxxxxxxxx'
export AWS_ACCESS_KEY_ID='AKIA...'
```

Or use environment variable files:
```bash
# In ~/.zshrc.local
[[ -f ~/.secrets ]] && source ~/.secrets

# In ~/.secrets (add to .gitignore)
export API_KEY='secret'
```

---

## Update Questions

### Why am I not seeing updates?

Check:
1. **Last check time**: `cat ~/.dotfiles/.last_update_check`
2. **Frequency**: `echo $ZSH_DOTFILES_UPDATE_FREQ`
3. **Actually behind**: `cd ~/.dotfiles && git fetch && git status`

Manual check:
```bash
~/.dotfiles/bin/dotfiles-check-updates.sh
```

---

### How do I rollback a bad update?

**Option 1**: Restore from backup
```bash
ls -lt ~/.dotfiles-backups/
cp ~/.dotfiles-backups/zshrc.2025-12-24_15-30-00 ~/.zshrc
exec zsh
```

**Option 2**: Git revert
```bash
cd ~/.dotfiles
git log --oneline -5  # Find bad commit
git revert abc1234   # Revert that commit
exec zsh
```

**Option 3**: Git reset (destructive)
```bash
cd ~/.dotfiles
git reset --hard HEAD~1  # Go back 1 commit
exec zsh
```

---

### Can updates break my system?

Very unlikely. Safety mechanisms:
- Automatic backups
- Dry-run mode available
- Git version control
- Only affects dotfiles, not system files

**Worst case**: Restore from `~/.dotfiles-backups/` or `git reset`.

---

## Oh My Zsh Questions

### Do I need Oh My Zsh?

Not strictly, but it provides:
- 200+ plugins
- 100+ themes
- Active community
- Sensible defaults
- Easy plugin management

You could use:
- **zinit** - Faster, more complex
- **zplug** - Middle ground
- **Plain zsh** - Most control, most work

This system defaults to Oh My Zsh for simplicity.

---

### How do I add Oh My Zsh plugins?

**Built-in plugins**:
```bash
vim ~/.dotfiles/zsh/zshrc.d/00-omz.zsh
# Add to plugins array
plugins=(... new-plugin)
```

**Third-party plugins**:
```bash
# Clone to custom directory
git clone https://github.com/author/plugin \
  ~/.dotfiles/zsh/omz-custom/plugins/plugin

# Enable in config
vim ~/.dotfiles/zsh/zshrc.d/00-omz.zsh
plugins=(... plugin)
```

---

### Why is Powerlevel10k the default theme?

**Benefits**:
- Fast (faster than most themes)
- Rich information display
- Easy configuration (`p10k configure`)
- Git integration
- Instant prompt feature

You can change it:
```bash
vim ~/.dotfiles/zsh/zshrc.d/00-omz.zsh
# Change:
ZSH_THEME="robbyrussell"  # Or any other theme
```

---

## Performance Questions

### My shell is slow to start. What do I do?

**Diagnose**:
```bash
time zsh -i -c exit
```

If > 2 seconds, profile it:
```bash
# Add to top of ~/.zshrc
zmodload zsh/zprof

# Add to bottom
zprof
```

**Common culprits**:
1. Too many OMZ plugins (remove unused ones)
2. NVM loading synchronously (lazy-load it)
3. Command substitution in prompt (use Powerlevel10k instant prompt)
4. Complex startup scripts (optimize or remove)

See [Troubleshooting - Slow Shell Startup](troubleshooting.md#slow-shell-startup).

---

### Does this system slow down my shell?

The system itself has minimal overhead:
- Module loading: ~50ms
- Update check: Runs in background, non-blocking
- Configuration: Static files, loaded once

Slowness usually comes from:
- Your own configurations
- Oh My Zsh plugins
- External tools (NVM, RVM, etc.)

---

## Customization Questions

### Can I use this with bash instead of zsh?

The system is designed for zsh, but you could adapt it:
1. Replace `zsh/` with `bash/`
2. Create `.bashrc` modules
3. Update Ansible to link `.bashrc`
4. Remove Oh My Zsh setup

**But why?** Zsh offers:
- Better completion
- Spelling correction
- Plugin ecosystem
- Modern features

---

### Can I add vim/neovim plugins?

Yes! Two approaches:

**Option 1**: Commit plugin manager setup
```bash
# In vim/.vimrc
" Use vim-plug
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'junegunn/fzf.vim'
call plug#end()
```

**Option 2**: Use Ansible to install plugins
```yaml
# In ansible/roles/dotfiles/tasks/main.yml
- name: Install vim-plug
  ansible.builtin.get_url:
    url: https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    dest: ~/.vim/autoload/plug.vim
```

---

### Can I use this with tmux?

Absolutely! Add tmux configuration:

```bash
# Create tmux config
vim ~/.dotfiles/tmux/.tmux.conf

# Update Ansible to link it
# Add to ansible/roles/dotfiles/tasks/main.yml
- name: Link tmux configuration
  ansible.builtin.file:
    src: "{{ dotfiles_dir }}/tmux/.tmux.conf"
    dest: "{{ ansible_env.HOME }}/.tmux.conf"
    state: link
```

---

## Troubleshooting Questions

### Something broke. How do I get help?

1. **Check Troubleshooting Guide**: [troubleshooting.md](troubleshooting.md)
2. **Check syntax**: `zsh -n ~/.zshrc`
3. **Check recent changes**: `cd ~/.dotfiles && git log -5`
4. **Restore backup**: `ls ~/.dotfiles-backups/`
5. **Open issue** with debug info (see troubleshooting guide)

---

### Can I test changes without affecting my current setup?

Yes! Use dry-run mode:
```bash
./bootstrap.sh --dry-run
```

Or test in a new shell:
```bash
zsh --no-rcs  # Start without config
source ~/.dotfiles/zsh/zshrc.d/10-aliases.zsh  # Test specific file
```

---

### Where are the logs?

The system doesn't keep persistent logs. Outputs are:
- **Bootstrap**: Stdout during execution
- **Ansible**: Stdout during playbook run
- **Update checks**: Stderr visible in shell
- **Errors**: Displayed immediately

For debugging, redirect to file:
```bash
./bootstrap.sh 2>&1 | tee bootstrap.log
```

---

## Advanced Questions

### Can I run specific parts of the provisioning?

Yes! Use Ansible tags:

```bash
# Only install packages
./bootstrap.sh --tags packages

# Only link configs
ansible-playbook ansible/playbook.yml --tags config

# Multiple tags
ansible-playbook ansible/playbook.yml --tags omz,config

# Skip packages
ansible-playbook ansible/playbook.yml --skip-tags packages
```

---

### Can I provision remote machines?

Yes, but requires Ansible setup:

```bash
# Create inventory file
cat > inventory << EOF
[servers]
server1.example.com
server2.example.com
EOF

# Run playbook remotely
ansible-playbook -i inventory ansible/playbook.yml
```

**Note**: This assumes:
- SSH access to remote machines
- Ansible installed locally
- User has sudo on remote machines

---

### Can I use this in Docker?

Yes! Example Dockerfile:

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    git curl zsh sudo && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/zsh devuser
USER devuser
WORKDIR /home/devuser

RUN git clone https://github.com/username/dotfiles.git .dotfiles
RUN cd .dotfiles && ./bootstrap.sh

CMD ["zsh"]
```

---

### How do I contribute improvements?

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

Changes to document:
- New features or modules
- Bug fixes
- Documentation improvements
- Performance optimizations

---

### Can I use different remote repos for different machines?

Yes! On each machine, set different remotes:

```bash
# Work machine
cd ~/.dotfiles
git remote set-url origin git@work-github.com:username/work-dotfiles.git

# Personal machine
cd ~/.dotfiles
git remote set-url origin git@github.com:username/personal-dotfiles.git
```

Or use branches:
```bash
# Setup
git branch work
git branch personal

# On work machine
git checkout work

# On personal machine  
git checkout personal

# Share common changes
git checkout work
git merge personal
```

---

## Security Questions

### Is it safe to make my dotfiles public?

Yes, **IF** you:
- ✅ Keep secrets in `~/.zshrc.local` (not tracked)
- ✅ Never commit API keys, passwords, or tokens
- ✅ Review commits before pushing
- ✅ Use `.gitignore` for sensitive files

**Never commit**:
- API keys/tokens
- Passwords
- SSH private keys
- Personal paths
- Internal company information

---

### What if I accidentally committed a secret?

**Don't just delete it!** Git history still contains it.

```bash
# Remove from history (destructive)
cd ~/.dotfiles
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/file" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (be careful!)
git push origin --force --all

# Rotate the secret (most important!)
# Change the API key/password that was exposed
```

Better: Use tools like [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) or [git-secrets](https://github.com/awslabs/git-secrets).

---

## Still Have Questions?

- Check the [Architecture](architecture.md) to understand how it works
- Review [Configuration Guide](configuration.md) for customization
- See [Troubleshooting](troubleshooting.md) for specific issues
- Check [Command Reference](command-reference.md) for available commands

---

**Didn't find your answer?** Open an issue with your question!
