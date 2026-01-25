# Update Management

Guide to keeping your dotfiles synchronized and up-to-date.

## Update System Overview

The dotfiles system includes automatic and manual update mechanisms:

```
┌────────────────────────────────┐
│      Shell Startup             │
└────────────┬───────────────────┘
             │
             ▼
┌────────────────────────────────┐
│  05-dotfiles-updates.zsh       │
│  (Sources update checker)      │
└────────────┬───────────────────┘
             │
             ▼
┌────────────────────────────────┐
│  dotfiles-check-updates.sh     │
│  • Check frequency             │
│  • Fetch upstream              │
│  • Compare commits             │
└────────────┬───────────────────┘
             │
             ├─ Behind? ─┐
             │           │
             ▼           ▼
    ┌────────────┐  ┌──────────────┐
    │   Notify   │  │ Auto-Update  │
    └────────────┘  └──────────────┘
```

## Automatic Updates

### How It Works

1. **On shell startup**, `05-dotfiles-updates.zsh` is sourced
2. It runs `dotfiles-check-updates.sh` in the background
3. Script checks if update check is due (based on frequency)
4. If due, fetches from origin
5. Compares local HEAD with upstream
6. Either notifies you or auto-updates (based on configuration)

**Note**: `DOTFILES_DIR` is derived from the update hook’s own path when possible, then falls back to a `~/.zshrc` symlink, and finally to `~/.dotfiles`.

### Configuration

Add these to `~/.zshrc.local`:

```zsh
# How often to check (in days)
export ZSH_DOTFILES_UPDATE_FREQ=1  # Default: 1 day

# Auto-update when behind
export ZSH_DOTFILES_AUTOUPDATE=true  # Default: true
```

### Update Frequencies

| Frequency | Use Case | Setting |
|-----------|----------|---------|
| **Daily** | Normal use (default) | `export ZSH_DOTFILES_UPDATE_FREQ=1` |
| **Weekly** | Conservative | `export ZSH_DOTFILES_UPDATE_FREQ=7` |
| **Bi-weekly** | Stable environment | `export ZSH_DOTFILES_UPDATE_FREQ=14` |
| **Monthly** | Conservative | `export ZSH_DOTFILES_UPDATE_FREQ=30` |
| **Never** | Manual only | `export ZSH_DOTFILES_UPDATE_FREQ=999999` |

### Auto-Update Behavior

**When `AUTOUPDATE=false`**:
```
Check → Fetch → Behind? → Notify
                    │
                    └→ "3 updates available"
                       "Run: dotfiles-pull-updates.sh"
```

**When `AUTOUPDATE=true`**:
```
Check → Fetch → Behind? → Auto-pull → Re-provision? → Done
```

**Notification Example**:
```
╭─────────────────────────────────────╮
│ Dotfiles Update Available           │
│ 3 commits behind upstream           │
│ Run: dotfiles-pull-updates.sh       │
╰─────────────────────────────────────╯
```

### Pros and Cons

#### Auto-Update Enabled

**Pros**:
- ✅ Always up to date
- ✅ No manual intervention
- ✅ Get bug fixes immediately

**Cons**:
- ⚠️ Breaking changes might surprise you
- ⚠️ No review before applying
- ⚠️ Could disrupt your workflow

#### Auto-Update Disabled

**Pros**:
- ✅ Review changes before applying
- ✅ Update on your schedule
- ✅ More control

**Cons**:
- ⚠️ Must manually run update
- ⚠️ Might miss important updates

---

## Manual Updates

### Quick Update

Pull latest changes and re-provision:
```bash
dotfiles-pull-updates.sh
```

This will:
1. Check for uncommitted changes
2. Stash them if present
3. Pull from origin
4. Pop stashed changes
5. Run Ansible playbook
6. Prompt to reload shell

### Update Without Re-provisioning

Pull changes but don't run Ansible:
```bash
dotfiles-pull-updates.sh --no-provision
```

Use when:
- You only want to review changes
- Changes don't require re-provisioning
- You'll provision manually later

### Preview Updates

See what would be pulled:
```bash
dotfiles-pull-updates.sh --dry-run
```

Or use git directly:
```bash
cd ~/.dotfiles
git fetch origin
git log HEAD..origin/main --oneline
```

### Update Specific Parts

Use Ansible tags to update only specific components:

```bash
cd ~/.dotfiles
git pull origin main

# Only update Oh My Zsh
ansible-playbook ansible/playbook.yml --tags omz

# Only relink configs
ansible-playbook ansible/playbook.yml --tags config

# Only update packages
ansible-playbook ansible/playbook.yml --tags packages
```

---

## Update Workflow

### Recommended Workflow

```bash
# 1. Check what's new
cd ~/.dotfiles
git fetch origin
git log HEAD..origin/main --oneline

# 2. Review changes
git log HEAD..origin/main -p

# 3. Pull if satisfied
dotfiles-pull-updates.sh

# 4. Test in new shell
zsh

# 5. If issues, rollback
git reset --hard HEAD~1
```

### Multi-Machine Workflow

#### Machine 1: Make changes
```bash
cd ~/.dotfiles

# Make changes
vim zsh/zshrc.d/10-aliases.zsh

# Commit
git add zsh/zshrc.d/10-aliases.zsh
git commit -m "Add new git aliases"

# Push
git push origin main
```

#### Machine 2: Get changes
```bash
# Option 1: Auto-update (if enabled)
# Just wait for next shell startup

# Option 2: Manual update
dotfiles-pull-updates.sh

# Option 3: Git pull only
cd ~/.dotfiles
git pull origin main
exec zsh
```

---

## State Files

### `.last_update_check`

Location: `~/.dotfiles/.last_update_check`

**Purpose**: Tracks when the last update check occurred

**Content**: Unix timestamp
```bash
$ cat ~/.dotfiles/.last_update_check
1735135200
```

**Reset manually**:
```bash
rm ~/.dotfiles/.last_update_check
# Next shell startup will check
```

**Check time since last check**:
```bash
echo $(( ($(date +%s) - $(cat ~/.dotfiles/.last_update_check)) / 86400 )) days
```

### `.update.lock`

Location: `~/.dotfiles/.update.lock`

**Purpose**: Prevents concurrent update checks

**Content**: Process ID of checking process
```bash
$ cat ~/.dotfiles/.update.lock
12345
```

**When to remove**:
- If update check hung or crashed
- Process no longer exists

```bash
# Check if process exists
ps -p $(cat ~/.dotfiles/.update.lock)

# If not, safe to remove
rm ~/.dotfiles/.update.lock
```

---

## Handling Conflicts

### Uncommitted Local Changes

**Symptom**:
```
error: Your local changes to the following files would be overwritten by merge:
    zsh/zshrc.d/10-aliases.zsh
```

**Solution 1**: Commit changes
```bash
cd ~/.dotfiles
git add zsh/zshrc.d/10-aliases.zsh
git commit -m "My local changes"
git pull origin main
```

**Solution 2**: Stash and pull
```bash
cd ~/.dotfiles
git stash
git pull origin main
git stash pop
# Resolve conflicts if any
```

**Solution 3**: Discard local changes
```bash
cd ~/.dotfiles
git checkout -- zsh/zshrc.d/10-aliases.zsh
git pull origin main
```

### Merge Conflicts

**Symptom**:
```
Auto-merging zsh/zshrc.d/10-aliases.zsh
CONFLICT (content): Merge conflict in zsh/zshrc.d/10-aliases.zsh
```

**Resolution**:
```bash
cd ~/.dotfiles

# Edit the conflicted file
vim zsh/zshrc.d/10-aliases.zsh

# Look for conflict markers:
<<<<<<< HEAD
Your changes
=======
Upstream changes
>>>>>>> origin/main

# Resolve by keeping what you want, then:
git add zsh/zshrc.d/10-aliases.zsh
git commit -m "Resolve merge conflict in aliases"
```

### Divergent Branches

**Symptom**:
```
Your branch and 'origin/main' have diverged,
and have 2 and 3 different commits each, respectively.
```

**Solution 1**: Rebase (cleaner history)
```bash
cd ~/.dotfiles
git pull --rebase origin main
# Resolve conflicts if any
```

**Solution 2**: Merge (preserves history)
```bash
cd ~/.dotfiles
git pull origin main
# Creates merge commit
```

**Solution 3**: Reset to origin (discard local)
```bash
cd ~/.dotfiles
git fetch origin
git reset --hard origin/main
# CAUTION: Loses all local commits
```

---

## Troubleshooting Updates

### Updates Not Checking

**Problem**: No update notifications despite being behind

**Diagnosis**:
```bash
# Check last check time
cat ~/.dotfiles/.last_update_check

# Check frequency setting
echo $ZSH_DOTFILES_UPDATE_FREQ

# Manually trigger check
~/.dotfiles/bin/dotfiles-check-updates.sh
```

**Solution**:
```bash
# Reset check timer
rm ~/.dotfiles/.last_update_check

# Verify settings in ~/.zshrc.local
echo $ZSH_DOTFILES_UPDATE_FREQ
echo $ZSH_DOTFILES_AUTOUPDATE

# Reload shell
exec zsh
```

### Update Check Hangs

**Problem**: Shell startup hangs during update check

**Diagnosis**:
```bash
# Check for stuck lock file
ls -la ~/.dotfiles/.update.lock

# Check process
ps -p $(cat ~/.dotfiles/.update.lock 2>/dev/null)
```

**Solution**:
```bash
# Remove stale lock file
rm ~/.dotfiles/.update.lock

# If git fetch is stuck
cd ~/.dotfiles
git fetch --all  # Test if git works

# If network issue, wait and retry
```

### Pull Fails with "fatal: refusing to merge unrelated histories"

**Problem**: Can't pull because histories diverged

**Solution**:
```bash
cd ~/.dotfiles
git pull origin main --allow-unrelated-histories
# Or if that fails:
git fetch origin
git reset --hard origin/main
```

---

## Best Practices

### ✅ Do:

1. **Review changes before updating**
   ```bash
   git log HEAD..origin/main -p
   ```

2. **Keep `~/.zshrc.local` backed up separately**
   ```bash
   cp ~/.zshrc.local ~/backups/zshrc.local.$(date +%Y%m%d)
   ```

3. **Test updates in new shell first**
   ```bash
   zsh  # Opens new shell to test
   ```

4. **Commit local changes before updating**
   ```bash
   git add -A && git commit -m "Local changes"
   ```

5. **Use semantic commit messages**
   ```bash
   git commit -m "Add Docker alias for compose command"
   ```

### ❌ Don't:

1. **Don't ignore conflicts**
   - Resolve them properly

2. **Don't force push to shared branches**
   - Use `git push --force-with-lease` if necessary

3. **Don't update during critical work**
   - Wait for a better time

4. **Don't disable update checks permanently**
   - At least check monthly

5. **Don't mix work and personal dotfiles**
   - Use separate repos or branches

---

## Update Checklist

Before updating:
- [ ] Commit or stash local changes
- [ ] Review what's changing (`git log HEAD..origin/main`)
- [ ] Ensure you have time to resolve issues
- [ ] Backup `~/.zshrc.local` if heavily customized
- [ ] Close important work or commit it

After updating:
- [ ] Test in new shell (`zsh`)
- [ ] Verify aliases work (`alias`)
- [ ] Check functions work (`type function-name`)
- [ ] Verify environment variables (`env`)
- [ ] Check for errors in startup
- [ ] Test key workflows
- [ ] If issues, check `~/.dotfiles-backups/`

---

## Emergency Rollback

If an update breaks your setup:

### Quick Rollback
```bash
cd ~/.dotfiles
git log --oneline -5  # Find last good commit
git reset --hard abc1234  # Replace with commit hash
exec zsh
```

### Restore from Backup
```bash
ls -lt ~/.dotfiles-backups/
cp ~/.dotfiles-backups/zshrc.2025-12-24_15-30-00 ~/.zshrc
exec zsh
```

### Complete Restore
```bash
# Reset repo
cd ~/.dotfiles
git reset --hard origin/main

# Restore backups
cp ~/.dotfiles-backups/zshrc.LATEST ~/.zshrc
cp ~/.dotfiles-backups/gitconfig.LATEST ~/.gitconfig

# Re-provision
./bootstrap.sh
```

---

## Advanced Update Strategies

### Scheduled Updates

Use cron for automatic updates:
```bash
# Add to crontab (crontab -e)
0 2 * * 0 cd ~/.dotfiles && git pull && ansible-playbook ansible/playbook.yml
# Updates every Sunday at 2 AM
```

### Conditional Auto-Update

Update only on trusted networks:
```bash
# In ~/.zshrc.local
if [[ "$(nmcli -t -f NAME con show --active)" == "HomeWiFi" ]]; then
    export ZSH_DOTFILES_AUTOUPDATE=true
else
    export ZSH_DOTFILES_AUTOUPDATE=false
fi
```

### Branch-Based Updates

Use different branches for stability:
```bash
# Stable branch (work machine)
git checkout stable

# Bleeding edge (personal machine)
git checkout main
```

---

## Related Documentation

- [Configuration Guide](configuration.md) - Managing your config
- [Troubleshooting](troubleshooting.md) - Fixing update issues
- [Command Reference](command-reference.md) - Update commands
- [FAQ](faq.md) - Common update questions
