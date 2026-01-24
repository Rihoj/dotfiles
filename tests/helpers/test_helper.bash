#!/usr/bin/env bash
# Test helpers for dotfiles testing with Bats
# Provides test isolation via temp directories and PATH manipulation

# Test isolation setup - called at start of each test
setup_test_isolation() {
  # Create isolated temp directory for this test
  export TEST_TMP_DIR="$(mktemp -d)"
  export TEST_DOTFILES_DIR="$TEST_TMP_DIR/dotfiles"
  export TEST_BIN_DIR="$TEST_DOTFILES_DIR/bin"
  
  # Path to fixtures (fake binaries)
  export FIXTURES_BIN_DIR="$BATS_TEST_DIRNAME/../fixtures/bin"
  
  # Call log file for tracking fake binary invocations
  export TEST_CALL_LOG="$TEST_TMP_DIR/calls.log"
  touch "$TEST_CALL_LOG"
  
  # Prepend fixtures to PATH so fake binaries are used
  export ORIGINAL_PATH="$PATH"
  export PATH="$FIXTURES_BIN_DIR:$PATH"
  
  # Create fake dotfiles structure
  mkdir -p "$TEST_BIN_DIR"
  
  # Copy actual script under test to temp location
  cp "$BATS_TEST_DIRNAME/../../bin/dotfiles-check-updates.sh" "$TEST_BIN_DIR/"
  chmod +x "$TEST_BIN_DIR/dotfiles-check-updates.sh"
  
  # Override DOTFILES_DIR to point to test location
  export DOTFILES_DIR="$TEST_DOTFILES_DIR"
  
  # Set predictable defaults for test consistency
  export ZSH_DOTFILES_UPDATE_FREQ="1"
  export ZSH_DOTFILES_AUTOUPDATE="false"
}

# Cleanup after each test
teardown_test_isolation() {
  # Restore original PATH
  if [[ -n "${ORIGINAL_PATH:-}" ]]; then
    export PATH="$ORIGINAL_PATH"
  fi
  
  # Remove temp directory and all test artifacts
  if [[ -n "${TEST_TMP_DIR:-}" && -d "${TEST_TMP_DIR}" ]]; then
    rm -rf "$TEST_TMP_DIR"
  fi
}

# Helper: Create a fake git repository structure
create_fake_git_repo() {
  local repo_dir="${1:-$TEST_DOTFILES_DIR}"
  mkdir -p "$repo_dir/.git"
  # Minimal git structure to pass directory check
  touch "$repo_dir/.git/config"
}

# Helper: Create lock directory manually (for lock testing)
create_lock() {
  local lock_dir="$TEST_DOTFILES_DIR/.update.lock"
  local pid="${1:-$$}"
  local timestamp="${2:-$(date +%s)}"
  
  mkdir -p "$lock_dir"
  echo "$pid $timestamp" > "$lock_dir/info"
}

# Helper: Check if lock exists
lock_exists() {
  [[ -d "$TEST_DOTFILES_DIR/.update.lock" ]]
}

# Helper: Get call count for a specific command from call log
get_call_count() {
  local cmd="$1"
  grep -c "^$cmd " "$TEST_CALL_LOG" 2>/dev/null || echo "0"
}

# Helper: Check if a command was called with specific arguments
command_called_with() {
  local cmd="$1"
  shift
  local args="$*"
  grep -q "^$cmd $args" "$TEST_CALL_LOG"
}
