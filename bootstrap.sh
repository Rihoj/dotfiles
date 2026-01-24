#!/usr/bin/env bash
set -euo pipefail

# NOTE: This script exists ONLY to install prerequisites for Ansible.
# All actual dotfiles provisioning is done via ansible/playbook.yml
# This is the SINGLE canonical entrypoint.

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--repo URL] [--no-install-deps] [--no-chsh] [--dry-run]

Options:
  --repo URL          Dotfiles git repository to clone
  --no-install-deps   Skip installing system dependencies
  --no-chsh           Do not attempt to change the default shell
  --dry-run           Show what would be done without making changes
  -h, --help          Show this help
EOF
}

DOTFILES_REPO=""
INSTALL_DEPS=1
SET_DEFAULT_SHELL=1
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      [[ $# -ge 2 && -n "${2:-}" ]] || { echo "--repo requires a URL" >&2; exit 1; }
      DOTFILES_REPO="$2"
      shift 2
      ;;
    --no-install-deps)
      INSTALL_DEPS=0
      shift
      ;;
    --no-chsh)
      SET_DEFAULT_SHELL=0
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

log() { printf "\033[1;36m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!!\033[0m %s\n" "$*"; }
die() { printf "\033[1;31mxx\033[0m %s\n" "$*"; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

# Determine script directory and cd to it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || die "Failed to cd to script directory: $SCRIPT_DIR"

detect_privilege_escalation() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    SUDO=()
  elif command -v sudo >/dev/null 2>&1; then
    SUDO=(sudo)
  elif command -v doas >/dev/null 2>&1; then
    SUDO=(doas)
  else
    warn "Neither sudo nor doas found; package install may fail"
    SUDO=()
  fi
}

pkg_mgr=""
if command -v apt-get >/dev/null 2>&1; then
  pkg_mgr="apt"
elif command -v dnf >/dev/null 2>&1; then
  pkg_mgr="dnf"
elif command -v yum >/dev/null 2>&1; then
  pkg_mgr="yum"
elif command -v pacman >/dev/null 2>&1; then
  pkg_mgr="pacman"
elif command -v zypper >/dev/null 2>&1; then
  pkg_mgr="zypper"
fi

install_packages() {
  local pkgs=(python3 python3-venv python3-pip git curl)
  
  if [[ ${#SUDO[@]} -eq 0 && ${EUID:-$(id -u)} -ne 0 ]]; then
    warn "No privilege escalation available; skipping package install"
    return
  fi
  
  case "$pkg_mgr" in
    apt)
      "${SUDO[@]}" apt-get update -y
      # Try to install pipx as preferred solution for PEP 668 environments
      "${SUDO[@]}" apt-get install -y "${pkgs[@]}" pipx 2>/dev/null || "${SUDO[@]}" apt-get install -y "${pkgs[@]}"
      ;;
    dnf)
      # Try to install pipx as preferred solution for PEP 668 environments
      "${SUDO[@]}" dnf install -y "${pkgs[@]}" pipx 2>/dev/null || "${SUDO[@]}" dnf install -y "${pkgs[@]}"
      ;;
    yum)
      "${SUDO[@]}" yum install -y "${pkgs[@]}"
      ;;
    pacman)
      "${SUDO[@]}" pacman -Syu --noconfirm "${pkgs[@]}"
      # Try to install pipx as preferred solution for PEP 668 environments
      "${SUDO[@]}" pacman -S --noconfirm python-pipx 2>/dev/null || true
      ;;
    zypper)
      "${SUDO[@]}" zypper install -y "${pkgs[@]}"
      ;;
    *)
      warn "No supported package manager detected; ensure python3, pip, git, curl, and ansible are installed."
      ;;
  esac
}

install_ansible() {
  if command -v ansible-playbook >/dev/null 2>&1; then
    return
  fi
  if command -v pipx >/dev/null 2>&1; then
    pipx install --include-deps ansible
    export PATH="$HOME/.local/bin:$PATH"
  else
    # PEP 668: externally-managed environments may block pip install --user
    # Use --break-system-packages as fallback when pipx is unavailable
    warn "pipx not found; falling back to pip install --user --break-system-packages (may conflict with system packages)"
    python3 -m pip install --user --upgrade --break-system-packages ansible
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

validate_git_config_value() {
  local value="$1"
  # Check for characters that would break git config INI format
  [[ "$value" =~ [][$'\n'$'\r'=] ]]
}

prompt_git_config() {
  # Skip if .gitconfig.local already exists
  if [[ -f "$HOME/.gitconfig.local" ]]; then
    log "Git configuration already exists at ~/.gitconfig.local"
    return
  fi
  
  log "Git User Configuration"
  log "Setting up your git identity (name, email, GPG key)"
  echo ""
  
  # Get current git config values as defaults
  local current_name=""
  local current_email=""
  current_name=$(git config --global user.name 2>/dev/null || true)
  current_email=$(git config --global user.email 2>/dev/null || true)
  
  # Prompt for name
  local name=""
  while [[ -z "$name" ]] || validate_git_config_value "$name"; do
    read -r -p "Full name [$current_name]: " name
    name="${name:-$current_name}"
    if [[ -z "$name" ]]; then
      warn "Name cannot be empty"
    elif validate_git_config_value "$name"; then
      warn "Name contains invalid characters (newlines, brackets, or equals signs)"
    fi
  done
  
  # Prompt for email
  local email=""
  while [[ -z "$email" ]] || validate_git_config_value "$email" || [[ ! "$email" =~ ^[^@]+@[^@]+$ ]]; do
    read -r -p "Email address [$current_email]: " email
    email="${email:-$current_email}"
    if [[ -z "$email" ]]; then
      warn "Email cannot be empty"
    elif validate_git_config_value "$email"; then
      warn "Email contains invalid characters (newlines, brackets, or equals signs)"
    elif [[ ! "$email" =~ ^[^@]+@[^@]+$ ]]; then
      warn "Email format appears invalid"
    fi
  done
  
  # Check for GPG
  local signing_key=""
  if command -v gpg >/dev/null 2>&1 || command -v gpg2 >/dev/null 2>&1; then
    local gpg_cmd="gpg"
    command -v gpg2 >/dev/null 2>&1 && gpg_cmd="gpg2"
    
    # Check for existing keys
    local key_list
    key_list=$($gpg_cmd --list-secret-keys --keyid-format=long 2>/dev/null | grep -E "^(sec|ssb)" || true)
    
    if [[ -n "$key_list" ]]; then
      log "Found existing GPG keys:"
      echo "$key_list"
      echo ""
      
      # Extract key IDs
      local -a key_ids
      mapfile -t key_ids < <($gpg_cmd --list-secret-keys --keyid-format=long 2>/dev/null | \
        grep -E "^(sec|ssb)" | awk '{print $2}' | cut -d'/' -f2)
      
      if [[ ${#key_ids[@]} -gt 0 ]]; then
        echo "Available keys:"
        local i=1
        for key in "${key_ids[@]}"; do
          echo "  $i) $key"
          ((i++))
        done
        echo "  0) Skip GPG configuration"
        echo ""
        
        local choice=""
        read -r -p "Select a key (enter number) [1]: " choice
        choice="${choice:-1}"
        
        if [[ "$choice" == "0" ]]; then
          log "Skipping GPG key configuration"
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#key_ids[@]} ]]; then
          signing_key="${key_ids[$((choice-1))]}"
          log "Selected key: $signing_key"
        else
          warn "Invalid selection, skipping GPG configuration"
        fi
      fi
    else
      log "No existing GPG keys found"
      log "You can generate a GPG key later by running: setup-git-config.sh"
    fi
  else
    log "GPG not installed, skipping key configuration"
  fi
  
  # Export variables for ansible
  GIT_USER_NAME="$name"
  GIT_USER_EMAIL="$email"
  GIT_SIGNING_KEY="$signing_key"
  
  echo ""
}

main() {
  detect_privilege_escalation
  
  # Prompt for git configuration early (before long-running tasks)
  if [[ $DRY_RUN -eq 0 ]]; then
    prompt_git_config
  fi
  
  if [[ $INSTALL_DEPS -eq 0 ]]; then
    need_cmd python3
  fi

  if [[ $INSTALL_DEPS -eq 1 ]]; then
    install_packages
  else
    log "Skipping dependency install (per flag)"
  fi

  install_ansible

  # Build Ansible args robustly
  local -a ANSIBLE_ARGS
  ANSIBLE_ARGS=("-i" "localhost," "-c" "local")
  
  local extra_vars=()
  if [[ -n "$DOTFILES_REPO" ]]; then
    extra_vars+=("dotfiles_repo=${DOTFILES_REPO}")
  fi
  if [[ $INSTALL_DEPS -eq 0 ]]; then
    extra_vars+=("install_deps=false")
  fi
  if [[ $SET_DEFAULT_SHELL -eq 0 ]]; then
    extra_vars+=("set_default_shell=false")
  fi
  # Expose migration flag opt-in via env or args later; default false
  extra_vars+=("migrate_existing_dotfiles=${MIGRATE_EXISTING_DOTFILES:-false}")
  
  # Pass the actual repository directory location
  extra_vars+=("dotfiles_dir=${SCRIPT_DIR}")
  
  # Pass git config if collected
  if [[ -n "${GIT_USER_NAME:-}" ]]; then
    extra_vars+=("git_user_name=${GIT_USER_NAME}")
  fi
  if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
    extra_vars+=("git_user_email=${GIT_USER_EMAIL}")
  fi
  if [[ -n "${GIT_SIGNING_KEY:-}" ]]; then
    extra_vars+=("git_signing_key=${GIT_SIGNING_KEY}")
  fi

  log "Running Ansible playbook"
  local check_flag=""
  if [[ $DRY_RUN -eq 1 ]]; then
    check_flag="--check"
    log "DRY RUN MODE: No changes will be made"
  fi
  # Append check flag and extra vars safely
  [[ -n "$check_flag" ]] && ANSIBLE_ARGS+=("$check_flag")
  # Add --ask-become-pass if any privileged operation is enabled (requires sudo)
  if [[ $INSTALL_DEPS -eq 1 || $SET_DEFAULT_SHELL -eq 1 ]]; then
    ANSIBLE_ARGS+=("--ask-become-pass")
  fi
  if [[ ${#extra_vars[@]} -gt 0 ]]; then
    # Pass each var separately to avoid quoting collapse
    local -a EV_ARGS
    for ev in "${extra_vars[@]}"; do
      EV_ARGS+=("-e" "$ev")
    done
    ansible-playbook "${ANSIBLE_ARGS[@]}" ansible/playbook.yml "${EV_ARGS[@]}"
  else
    ansible-playbook "${ANSIBLE_ARGS[@]}" ansible/playbook.yml
  fi
}

main "$@"
