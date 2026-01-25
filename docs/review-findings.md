# Code Review Findings

Tracking issues found during code reviews and their status.

## Review Log

- **2026-01-24**: Initial review focused on dotfiles update flow (auto-check + updater).

## Findings

| ID | Severity | Status | Area | Summary | File |
|----|----------|--------|------|---------|------|
| CR-001 | High | Done | Update notifications | Non-interactive notice path is effectively muted because the check runs in the background with stderr redirected, so AUTOUPDATE=false users never see update messages. | zsh/zshrc.d/05-dotfiles-updates.zsh, bin/dotfiles-check-updates.sh |
| CR-002 | Medium | Done | Lock cleanup | Stale lock cleanup uses `>` instead of `>=`, so a lock at exactly 300s age is treated as fresh and blocks checks longer than intended. | bin/dotfiles-check-updates.sh |
| CR-003 | Medium | Done | Lock recovery | Missing or unreadable `.update.lock/info` causes the script to exit without removing the lock dir, potentially wedging updates until manual cleanup. | bin/dotfiles-check-updates.sh |
| CR-004 | High | Done | Bootstrap git config | Bootstrap collects git identity/signing key but no Ansible task consumes these values, so git identity is not actually configured. | bootstrap.sh, ansible/roles/dotfiles/tasks/main.yml |
| CR-005 | High | Not a bug | .zshrc overwrite | Repo `.zshrc` is overwritten on every run; the “Create initial .zshrc if missing” task has no guard and replaces customized repo versions. | ansible/roles/dotfiles/tasks/main.yml |
| CR-006 | High | Done | Dotfile symlink overwrite | Managed dotfiles are force-symlinked without backup even when migration is disabled, potentially overwriting user files. | ansible/roles/dotfiles/tasks/dotfile_tasks.yml |
| CR-007 | Medium | Done | Dotfiles path hardcoded | Generated `.zshrc` uses `$HOME/.dotfiles` path, breaking module loads when `dotfiles_dir` is customized. | ansible/roles/dotfiles/tasks/main.yml |
| CR-008 | Medium | Done | Update detection path | Update check discovery expects `~/.zshrc` symlink; provisioning copies the file so non-standard locations may not be detected. | zsh/zshrc.d/05-dotfiles-updates.zsh, ansible/roles/dotfiles/tasks/main.yml |
| CR-009 | Medium | Done | Arch pacman module | Uses `community.general.pacman` but `ansible/requirements.yml` declares no external collections, so installs will fail on Arch. | ansible/roles/dotfiles/tasks/main.yml, ansible/requirements.yml |
| CR-010 | Medium | Done | Font cache on macOS | `fc-cache` may not exist on macOS, so font cache refresh can fail after downloads. | ansible/roles/dotfiles/tasks/main.yml |
| CR-011 | Low | Done | Lock PID match | Lock validation can match empty script path and treat any running PID as the updater, blocking checks with corrupted lock info. | bin/dotfiles-check-updates.sh |
| CR-012 | High | Done | Unsupported OS flow | Bootstrap detects non-apt package managers but Ansible now only installs via apt; on non-Debian systems the run proceeds and then fails later with apt-specific guidance. | bootstrap.sh, ansible/roles/dotfiles/tasks/main.yml |
| CR-013 | Medium | Open | Update check-only upstream | `dotfiles-pull-updates.sh --check-only` assumes an upstream exists; missing `@{u}` can yield misleading output. | bin/dotfiles-pull-updates.sh |
| CR-014 | Medium | Open | Update pull prechecks | `dotfiles-pull-updates.sh` does not check for local changes or local commits before `git pull --ff-only`, causing a hard failure without clear guidance. | bin/dotfiles-pull-updates.sh |
| CR-015 | Low | Open | Bin linker failure mode | `dotfiles-link-bin.sh` removes existing targets and `chmod +x` unconditionally; if the target path is unwritable, the script exits due to `set -e` without a helpful message. | bin/dotfiles-link-bin.sh |
| CR-016 | Low | Open | Hardcoded env paths | `zsh/zshrc.d/30-env.zsh` hardcodes platform-specific paths (e.g., Windows Chrome path, /snap/bin) which may be incorrect outside WSL/Linux. | zsh/zshrc.d/30-env.zsh |

## Notes

- These findings map to the behavioral contract in `docs/testing-contract.md`.
- When a fix lands, update status to `Done`, note the commit SHA, and add a brief resolution summary.
