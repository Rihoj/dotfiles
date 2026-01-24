Here’s a practical, staged plan that gets you to reliable automated tests without turning your dotfiles repo into a science fair volcano.

## Milestone 0: Define the contract

**Goal:** “Expected end result” becomes concrete and testable.

**Tasks**

* Write a short “behavior spec” doc for `dotfiles-check-updates.sh`:

  * when it runs, when it exits early
  * what it prints (interactive vs non-interactive)
  * when it should attempt `git fetch`
  * when it should update `.last_update_check`
  * lock behavior (atomic, stale recovery rules)
* List your “system state invariants” after provisioning:

  * required symlinks (`~/.gitconfig`, `~/.vimrc`, etc.)
  * required directories (`~/.zshrc.d`, fonts dir)
  * required binaries/packages (zsh, git, curl, etc.)
  * any required git config keys
* Decide the test split:

  * **logic tests** for scripts (Bats/pytest)
  * **state tests** for provisioned output (Goss)

**Deliverable:** `docs/testing-contract.md`

---

## Milestone 1: Script logic test harness (fast tests)

**Goal:** Deterministic tests for `bin/dotfiles-check-updates.sh` that run in seconds.

**Tasks**

* Add a test runner directory structure:

  * `tests/logic/`
  * `tests/fixtures/`
  * `tests/helpers/`
* Choose harness:

  * **Bats** (recommended for Bash-first repos), or
  * pytest (fine if you prefer Python ergonomics)
* Implement isolation helpers:

  * temp `HOME`
  * temp `DOTFILES_DIR`
  * temp `PATH` with `tests/helpers/fakebin/` prepended
  * cleanup traps so failures don’t leak state
* Create stubs in `fakebin`:

  * `git` (scriptable outputs for `fetch`, `rev-list`)
  * `ps` (simulate lock PID command lines)
  * `date` (fixed timestamps)
  * optionally `sleep` or `read` if you want to harden interactive paths
* Logging: stubs write invocations to `tests/tmp/calls.log` for assertions.

**Deliverable:** `tests/logic/` runs locally via `make test-logic`

---

## Milestone 2: Core behavioral test suite for check-updates

**Goal:** Cover the branches that historically break people.

**Tasks (write as tests first, then adjust script until green)**

1. **Not a git repo**

   * no `.git` → exit 0, no output, no lock.
2. **Lock acquire + release**

   * creates `.update.lock/info`, removes lock dir on exit.
3. **Concurrent lock respected**

   * lock exists + PID matches running “dotfiles-check-updates” → second run exits early.
4. **Stale lock recovery**

   * lock exists + old timestamp + PID not running script → lock removed and reacquired.
   * lock exists + young timestamp → exits early without deleting lock.
5. **Frequency gating**

   * `.last_update_check` recent + `FREQ=7` → exits early, doesn’t call git.
6. **Fetch failure behavior**

   * `git fetch` fails → script exits cleanly.
   * (Recommended expected behavior) `.last_update_check` should *not* advance on failed fetch.
7. **Behind triggers autoupdate**

   * `BEHIND=3` + `AUTOUPDATE=true` → calls `dotfiles-pull-updates.sh` (assert invocation).
8. **No upstream configured**

   * `rev-list` fails → no crash, no update attempt, minimal/no output.

**Deliverable:** `tests/logic/test_check_updates.*` with ~8–12 tests

---

## Milestone 3: Refactors for testability + correctness (small, surgical)

**Goal:** Make behavior stable and easy to test; fix the footguns.

**Tasks**

* Add dependency injection points:

  * `GIT_BIN`, `PS_BIN`, `DATE_BIN` defaulting to `git`, `ps`, `date`
* Make `.last_update_check` semantics consistent:

  * write timestamp **after successful fetch** (or after successful behind check)
* Make lock process identification more robust:

  * store “script id” in `info` (e.g., canonical script path) and compare it
  * or include hostname and compare `ps` args + hostname
* Fix any remaining “set -u” hazards (undefined vars, brittle reads)
* Ensure non-interactive mode is quiet by default (optional `DOTFILES_VERBOSE=1`)

**Deliverable:** tests still green, script becomes boring (highest compliment)

---

## Milestone 4: Goss state tests for installed dotfiles (integration)

**Goal:** After provisioning, validate the machine ends up in the expected state.

**Tasks**

* Add `tests/goss/` with:

  * `goss.yaml` (or multiple files)
  * optional custom goss tests for command outputs
* Write state assertions:

  * Files exist + correct type (symlink vs file)
  * Symlink targets point into `$DOTFILES_DIR`
  * Zsh config directory exists and has expected fragments
  * Fonts directory contains expected files
  * Commands exist: `zsh`, `git`, `ansible` (or whatever you expect)
  * `git config --global` keys that must exist
* Add a thin wrapper:

  * `bin/test-goss.sh` that sets HOME/DOTFILES_DIR appropriately, runs `goss validate`

**Deliverable:** `make test-state` runs locally (or in container)

---

## Milestone 5: CI pipeline (repeatable, non-flaky)

**Goal:** Every PR proves it didn’t break your setup.

**Tasks**

* Add CI jobs:

  1. `test-logic` (Bats/pytest) — fastest, always runs
  2. `test-state` (Goss) — runs in a container/VM
* Containerize where possible:

  * use a base image with `git`, `zsh`, `curl`, `sudo` (or mock sudo)
  * run bootstrap/provision step
  * run goss validation
* Add reporting:

  * test output artifacts on failure (calls.log, temp dirs)

**Deliverable:** CI green on main; failures are diagnosable without archaeology

---

## Milestone 6: Expand coverage to Ansible role behavior (optional but powerful)

**Goal:** Validate the role converges across OS families.

**Tasks**

* Add **Molecule** for Ansible role testing

  * scenarios: Debian/Ubuntu, Fedora, Arch (if you care)
  * verify idempotence (`molecule converge` twice, no changes)
  * verify outputs (can reuse goss or ansible assertions)
* Wire Molecule into CI (may run nightly if it’s heavy)

**Deliverable:** role is test-verified, not faith-based

---

## Suggested work order (so you don’t hate your life)

1. Milestone 1 + 2 first (logic tests catch most regressions fast)
2. Milestone 3 refactors (to remove flakiness and undefined behavior)
3. Milestone 4 goss (prove end-state correctness)
4. Milestone 5 CI (lock it in)
5. Milestone 6 Molecule (when you want cross-distro confidence)

That’s a path from “scripts in the wild” to “repeatable, measurable behavior” without turning dotfiles into an enterprise product. Which is good, because that would be tragic.
