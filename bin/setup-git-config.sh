#!/usr/bin/env bash
set -euo pipefail

# Setup script for git user configuration
# Creates ~/.gitconfig.local with user-specific settings

readonly CONFIG_FILE="$HOME/.gitconfig.local"
readonly BACKUP_DIR="$HOME/.dotfiles-backups"

log() { printf "\033[1;36m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!!\033[0m %s\n" "$*"; }
error() { printf "\033[1;31mxx\033[0m %s\n" "$*"; }
die() { error "$*"; exit 1; }

prompt() {
  local prompt_text="$1"
  local default_value="${2:-}"
  local response
  
  if [[ -n "$default_value" ]]; then
    read -r -p "$prompt_text [$default_value]: " response
    echo "${response:-$default_value}"
  else
    read -r -p "$prompt_text: " response
    echo "$response"
  fi
}

list_gpg_keys() {
  # List available GPG keys
  if ! command -v gpg >/dev/null 2>&1 && ! command -v gpg2 >/dev/null 2>&1; then
    return 1
  fi
  
  local gpg_cmd="gpg"
  command -v gpg2 >/dev/null 2>&1 && gpg_cmd="gpg2"
  
  # Get list of secret keys
  local keys
  keys=$($gpg_cmd --list-secret-keys --keyid-format=long 2>/dev/null | grep -E "^(sec|ssb)" || true)
  
  if [[ -z "$keys" ]]; then
    return 1
  fi
  
  echo "$keys"
  return 0
}

extract_key_ids() {
  # Extract key IDs from gpg output
  local gpg_cmd="gpg"
  command -v gpg2 >/dev/null 2>&1 && gpg_cmd="gpg2"
  
  $gpg_cmd --list-secret-keys --keyid-format=long 2>/dev/null | \
    grep -E "^(sec|ssb)" | awk '{print $2}' | cut -d'/' -f2
}

generate_gpg_key() {
  local name="$1"
  local email="$2"
  
  log "Generating new GPG key (ed25519)..." >&2
  
  local gpg_cmd="gpg"
  command -v gpg2 >/dev/null 2>&1 && gpg_cmd="gpg2"
  
  # Create GPG key generation batch file
  local batch_file
  batch_file=$(mktemp)
  
  # Ensure cleanup on exit
  trap 'rm -f "$batch_file"' RETURN
  
  # Validate inputs don't contain newlines or other problematic characters
  if [[ "$name" =~ $'\n' ]] || [[ "$email" =~ $'\n' ]]; then
    error "Name and email cannot contain newlines" >&2
    return 1
  fi
  
  # Note: Using %no-protection to avoid passphrase prompt in non-interactive context
  # Users can add a passphrase later with: gpg --edit-key <KEY_ID> passwd
  cat > "$batch_file" <<EOF
%no-protection
Key-Type: eddsa
Key-Curve: ed25519
Key-Usage: sign
Subkey-Type: ecdh
Subkey-Curve: cv25519
Subkey-Usage: encrypt
Name-Real: $name
Name-Email: $email
Expire-Date: 0
EOF
  
  log "Note: Key will be created without passphrase protection" >&2
  log "You can add a passphrase later with: gpg --edit-key <KEY_ID> passwd" >&2
  
  if $gpg_cmd --batch --generate-key "$batch_file" 2>&1 >&2; then
    log "GPG key generated successfully" >&2
    
    # Get the newly generated key ID (prefer primary key, but accept subkey)
    local key_id
    key_id=$($gpg_cmd --list-secret-keys --keyid-format=long "$email" 2>/dev/null | \
      grep -E "^(sec|ssb)" | awk '{print $2}' | cut -d'/' -f2 | head -n1)
    
    if [[ -n "$key_id" ]]; then
      log "Key ID: $key_id" >&2
      echo "$key_id"
      return 0
    else
      error "Failed to extract key ID from generated key" >&2
      return 1
    fi
  else
    error "Failed to generate GPG key" >&2
    return 1
  fi
}

main() {
  log "Git User Configuration Setup"
  echo ""
  
  # Check if config file already exists
  if [[ -f "$CONFIG_FILE" ]]; then
    warn "Configuration file already exists: $CONFIG_FILE"
    local overwrite
    overwrite=$(prompt "Do you want to overwrite it? (yes/no)" "no")
    
    if [[ "$overwrite" != "yes" ]]; then
      log "Keeping existing configuration. Exiting."
      exit 0
    fi
    
    # Backup existing config
    mkdir -p "$BACKUP_DIR"
    local timestamp
    timestamp=$(date +%Y%m%dT%H%M%S)
    cp "$CONFIG_FILE" "$BACKUP_DIR/gitconfig.local.$timestamp"
    log "Backed up existing config to: $BACKUP_DIR/gitconfig.local.$timestamp"
  fi
  
  # Get current git config values as defaults if they exist
  local current_name=""
  local current_email=""
  current_name=$(git config --global user.name 2>/dev/null || true)
  current_email=$(git config --global user.email 2>/dev/null || true)
  
  # Prompt for user information
  log "Enter your git user information:"
  local user_name
  local user_email
  
  user_name=$(prompt "Full name" "$current_name")
  # Validate name: not empty, no newlines, no special git config characters
  while [[ -z "$user_name" ]] || [[ "$user_name" =~ [$'\n'$'\r'[=\]] ]]; do
    if [[ -z "$user_name" ]]; then
      error "Name cannot be empty"
    else
      error "Name contains invalid characters (newlines, brackets, or equals signs)"
    fi
    user_name=$(prompt "Full name" "$current_name")
  done
  
  user_email=$(prompt "Email address" "$current_email")
  # Validate email: not empty, no newlines, no special git config characters, basic email format
  while [[ -z "$user_email" ]] || [[ "$user_email" =~ [$'\n'$'\r'[=\]] ]] || [[ ! "$user_email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; do
    if [[ -z "$user_email" ]]; then
      error "Email cannot be empty"
    elif [[ "$user_email" =~ [$'\n'$'\r'[=\]] ]]; then
      error "Email contains invalid characters (newlines, brackets, or equals signs)"
    else
      error "Email format appears invalid (should be user@domain.tld)"
    fi
    user_email=$(prompt "Email address" "$current_email")
  done
  
  echo ""
  log "GPG Signing Key Configuration"
  
  # Check for GPG
  if ! command -v gpg >/dev/null 2>&1 && ! command -v gpg2 >/dev/null 2>&1; then
    warn "GPG is not installed. Skipping GPG key configuration."
    warn "Install GPG and re-run this script to configure commit signing."
    local signing_key=""
  else
    # Check for existing GPG keys
    log "Checking for existing GPG keys..."
    
    if list_gpg_keys >/dev/null 2>&1; then
      log "Found existing GPG keys:"
      list_gpg_keys
      echo ""
      
      local key_ids
      key_ids=$(extract_key_ids)
      
      if [[ -n "$key_ids" ]]; then
        log "Available key IDs:"
        local i=1
        local -a key_array
        while IFS= read -r key; do
          echo "  $i) $key"
          key_array+=("$key")
          ((i++))
        done <<< "$key_ids"
        echo "  $i) Generate a new key"
        echo "  0) Skip GPG key configuration"
        echo ""
        
        local choice
        choice=$(prompt "Select a key (enter number)" "1")
        
        if [[ "$choice" == "0" ]]; then
          log "Skipping GPG key configuration"
          signing_key=""
        elif [[ "$choice" == "$i" ]]; then
          # Generate new key
          local new_key
          if new_key=$(generate_gpg_key "$user_name" "$user_email"); then
            signing_key="$new_key"
          else
            warn "Failed to generate key. Skipping GPG configuration."
            signing_key=""
          fi
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -lt "$i" ]]; then
          signing_key="${key_array[$((choice-1))]}"
          log "Selected key: $signing_key"
        else
          warn "Invalid choice. Skipping GPG key configuration."
          signing_key=""
        fi
      else
        warn "No valid GPG keys found"
        local gen_key
        gen_key=$(prompt "Generate a new GPG key? (yes/no)" "yes")
        
        if [[ "$gen_key" == "yes" ]]; then
          local new_key
          if new_key=$(generate_gpg_key "$user_name" "$user_email"); then
            signing_key="$new_key"
          else
            warn "Failed to generate key. Skipping GPG configuration."
            signing_key=""
          fi
        else
          signing_key=""
        fi
      fi
    else
      log "No existing GPG keys found"
      local gen_key
      gen_key=$(prompt "Generate a new GPG key? (yes/no)" "yes")
      
      if [[ "$gen_key" == "yes" ]]; then
        local new_key
        if new_key=$(generate_gpg_key "$user_name" "$user_email"); then
          signing_key="$new_key"
        else
          warn "Failed to generate key. Skipping GPG configuration."
          signing_key=""
        fi
      else
        signing_key=""
      fi
    fi
  fi
  
  # Create config file
  log "Creating $CONFIG_FILE..."
  
  cat > "$CONFIG_FILE" <<EOF
# ~/.gitconfig.local
# Machine-specific git configuration. This file stays out of version control.
# Generated by setup-git-config.sh

[user]
	name = $user_name
	email = $user_email
EOF
  
  if [[ -n "${signing_key:-}" ]]; then
    cat >> "$CONFIG_FILE" <<EOF
	signingkey = $signing_key
EOF
  fi
  
  log "Configuration created successfully!"
  log "File: $CONFIG_FILE"
  echo ""
  log "Configuration:"
  cat "$CONFIG_FILE"
  echo ""
  
  if [[ -n "${signing_key:-}" ]]; then
    log "GPG commit signing is enabled in your .gitconfig"
    log "Your commits will be automatically signed with key: $signing_key"
  else
    log "GPG commit signing is enabled in your .gitconfig but no key is configured"
    log "To add a key later, re-run this script or edit $CONFIG_FILE manually"
  fi
}

main "$@"
