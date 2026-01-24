# Testing Contract: dotfiles-check-updates.sh

## Purpose
Behavior specification for `dotfiles-check-updates.sh` to ensure consistent update checking across environments.

## Behavioral Contract

| Condition | Expected Behavior | Exit Code | Side Effects |
|-----------|-------------------|-----------|--------------|
| Not a git repository | Silent exit immediately | 0 | None |
| Lock directory exists, process running | Silent exit immediately | 0 | None |
| Lock directory exists, process dead, lock age < 300s | Silent exit immediately | 0 | None |
| Lock directory exists, process dead, lock age >= 300s | Remove stale lock, acquire new lock, continue | 0 | Lock cleaned and reacquired |
| Lock acquired successfully | Create lock with PID and timestamp | - | `.update.lock/info` created |
| Check frequency not met (last check < FREQ days) | Silent exit after lock cleanup | 0 | Lock released |
| git fetch fails | Silent exit after lock cleanup | 0 | Lock released, no timestamp update |
| git fetch succeeds | Update `.last_update_check` timestamp | - | Timestamp written |
| No upstream configured | Silent exit after lock cleanup | 0 | Lock released |
| Up to date (0 commits behind) | Silent exit after lock cleanup | 0 | Lock released |
| Behind, AUTOUPDATE=true | Background update via pull script | 0 | Lock released, update process spawned |
| Behind, interactive shell | Prompt with 8s timeout | 0 | Lock released, update on 'y' response |
| Behind, non-interactive | Print notice to stderr | 0 | Lock released |

## Configuration Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_DIR` | Script location's parent dir | Root directory of dotfiles repo |
| `ZSH_DOTFILES_UPDATE_FREQ` | 1 | Days between update checks |
| `ZSH_DOTFILES_AUTOUPDATE` | true | Auto-update when behind |

## Lock Mechanism

- **Lock Directory**: `.update.lock/` in dotfiles root
- **Lock Info File**: `.update.lock/info` format: `<PID> <TIMESTAMP>`
- **Timeout**: 300 seconds
- **Cleanup**: Automatic via EXIT trap

## Edge Cases

1. **Symlinked script**: Resolves symlinks to find actual dotfiles directory
2. **Invalid FREQ value**: Falls back to default (1 day)
3. **Corrupted lock info**: Treats as missing, exits safely
4. **Missing .last_update_check**: Treats as never checked (timestamp 0)
5. **Non-interactive prompt timeout**: Defaults to "no" after 8 seconds

## Test Isolation Requirements

Tests must:
- Mock external commands: `git`, `ps`, `date`
- Provide isolated temp directory per test
- Create fake git repository structure (`.git/` directory)
- Control environment variables: `DOTFILES_DIR`, `ZSH_DOTFILES_UPDATE_FREQ`, `ZSH_DOTFILES_AUTOUPDATE`
- Verify lock acquisition/release
- Not interfere with actual dotfiles repository

## Success Criteria

Script considered working when:
- All behavioral contracts pass
- No lock leaks occur (lock always cleaned up)
- Frequency checking prevents excessive git operations
- Stale locks are properly detected and cleaned
- All exit paths respect lock cleanup
