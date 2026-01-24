#!/usr/bin/env bats
# Tests for dotfiles-check-updates.sh
# Testing Milestones 0-1: Basic isolation and lock mechanism

# Load test helpers for isolation setup/teardown
load ../helpers/test_helper

setup() {
  setup_test_isolation
}

teardown() {
  teardown_test_isolation
}

# Test: Script exits silently when not a git repository
@test "exits silently when not a git repository" {
  # No .git directory created - not a git repo
  
  run "$TEST_BIN_DIR/dotfiles-check-updates.sh"
  
  # Should exit successfully without output
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  
  # Should not create lock
  [ ! -d "$TEST_DOTFILES_DIR/.update.lock" ]
}

# Test: Lock is acquired and released properly
@test "acquires and releases lock on successful run" {
  # Create fake git repo to pass initial check
  create_fake_git_repo
  
  # Set timestamp to skip frequency check
  echo "0" > "$TEST_DOTFILES_DIR/.last_update_check"
  
  run "$TEST_BIN_DIR/dotfiles-check-updates.sh"
  
  # Should complete successfully
  [ "$status" -eq 0 ]
  
  # Lock should be released (cleaned up)
  [ ! -d "$TEST_DOTFILES_DIR/.update.lock" ]
  
  # Should have called git fetch (verifies it got past lock acquisition)
  call_count=$(get_call_count "git")
  [ "$call_count" -gt 0 ]
}

# Test: Script respects existing lock from running process
@test "exits when lock held by running process" {
  create_fake_git_repo
  
  # Create lock with a "running" process
  fake_pid="12345"
  current_time="1737500000"
  
  export DATE_TIMESTAMP="$current_time"
  export PS_RUNNING_PIDS="$fake_pid"
  
  create_lock "$fake_pid" "$current_time"
  
  run "$TEST_BIN_DIR/dotfiles-check-updates.sh"
  
  # Should exit silently without disturbing lock
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  
  # Lock should still exist
  [ -d "$TEST_DOTFILES_DIR/.update.lock" ]
  
  # Should NOT have called git (exited before fetch)
  git_calls=$(get_call_count "git")
  [ "$git_calls" -eq 0 ]
}
