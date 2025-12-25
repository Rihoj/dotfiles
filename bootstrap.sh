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
      "${SUDO[@]}" apt-get install -y "${pkgs[@]}"
      ;;
    dnf)
      "${SUDO[@]}" dnf install -y "${pkgs[@]}"
      ;;
    yum)
      "${SUDO[@]}" yum install -y "${pkgs[@]}"
      ;;
    pacman)
      "${SUDO[@]}" pacman -Syu --noconfirm "${pkgs[@]}"
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
  else
    python3 -m pip install --user --upgrade ansible
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

main() {
  detect_privilege_escalation
  
  if [[ $INSTALL_DEPS -eq 0 ]]; then
    need_cmd python3
  fi

  if [[ $INSTALL_DEPS -eq 1 ]]; then
    install_packages
  else
    log "Skipping dependency install (per flag)"
  fi

  install_ansible

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

  log "Running Ansible playbook"
  local check_flag=""
  if [[ $DRY_RUN -eq 1 ]]; then
    check_flag="--check"
    log "DRY RUN MODE: No changes will be made"
  fi
  ansible-playbook -i localhost, -c local ansible/playbook.yml $check_flag ${extra_vars:+-e "${extra_vars[*]}"}
}

main "$@"
