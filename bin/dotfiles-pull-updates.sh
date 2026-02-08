#!/bin/bash
set -euo pipefail
# Update dotfiles repo from remote and reload shell config
# Usage: dotfiles-pull-updates [--check-only]

# Dynamically determine the dotfiles directory from script location
# Resolve symlinks to get the actual script location
SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
while [ -L "$SCRIPT_PATH" ]; do
  SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
  [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
done
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# Ensure it's a git repo
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
  echo "❌ Error: $DOTFILES_DIR is not a git repository"
  exit 1
fi

cd "$DOTFILES_DIR"

# Check for changes only
if [[ "${1-}" == "--check-only" ]]; then
  echo "Checking for updates..."
  if ! git rev-parse @{u} >/dev/null 2>&1; then
    echo "No upstream configured for this repository."
    exit 0
  fi
  # Avoid SSH passphrase prompts in check mode
  GIT_SSH_COMMAND="ssh -o BatchMode=yes" GIT_TERMINAL_PROMPT=0 \
    git fetch --quiet
  
  # Calculate behind/ahead relative to upstream
  BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
  AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
  if [[ "$BEHIND" -eq 0 ]]; then
    echo "✅ You're up to date!"
  else
    echo "📦 $BEHIND commit(s) available to pull"
    echo "Run: dotfiles-pull-updates"
  fi
  exit 0
fi

# Require upstream for pull updates
if ! git rev-parse @{u} >/dev/null 2>&1; then
  echo "❌ Error: No upstream configured for this repository." >&2
  exit 1
fi

# Optionally rewrite SSH remotes to HTTPS for public repos
if [[ "${ZSH_DOTFILES_AUTOHTTPS:-false}" == "true" ]]; then
  upstream_ref="$(git rev-parse --abbrev-ref @{u} 2>/dev/null || true)"
  upstream_remote="${upstream_ref%%/*}"
  if [[ -n "$upstream_remote" ]]; then
    remote_url="$(git remote get-url "$upstream_remote" 2>/dev/null || true)"
    case "$remote_url" in
      git@github.com:*|ssh://git@github.com/*)
        path="${remote_url#git@github.com:}"
        path="${path#ssh://git@github.com/}"
        path="${path%.git}"
        git remote set-url "$upstream_remote" "https://github.com/${path}.git" 2>/dev/null || true
        ;;
      git@gitlab.com:*|ssh://git@gitlab.com/*)
        path="${remote_url#git@gitlab.com:}"
        path="${path#ssh://git@gitlab.com/}"
        path="${path%.git}"
        git remote set-url "$upstream_remote" "https://gitlab.com/${path}.git" 2>/dev/null || true
        ;;
    esac
  fi
fi

# Refuse to pull with local changes
if [[ -n "$(git status --porcelain)" ]]; then
  echo "❌ Error: Working tree has local changes. Commit or stash before updating." >&2
  exit 1
fi

# Refuse to pull when local commits exist
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
if [[ "$AHEAD" -gt 0 ]]; then
  echo "❌ Error: Local commits detected ($AHEAD ahead). Push or reset before updating." >&2
  exit 1
fi

# Pull updates
echo "🔄 Pulling dotfiles updates..."
OLD_HEAD="$(git rev-parse HEAD 2>/dev/null || echo "")"
git fetch --quiet || true
git pull --ff-only
NEW_HEAD="$(git rev-parse HEAD 2>/dev/null || echo "")"

update_markers=()
if [[ -n "$OLD_HEAD" && -n "$NEW_HEAD" ]]; then
  while IFS= read -r marker; do
    [[ -n "$marker" ]] && update_markers+=("$marker")
  done < <(git diff --name-only "$OLD_HEAD..$NEW_HEAD" -- updates/ 2>/dev/null || true)
fi

any_marker=false
require_bootstrap=false
require_bootstrap_false=false
require_deps=false
require_chsh=false
declare -A ansible_tag_set=()

for marker in "${update_markers[@]}"; do
  [[ -f "$marker" ]] || continue
  any_marker=true
  rb="$(awk -F: '/^[[:space:]]*requires_bootstrap:/ {gsub(/[[:space:]]/,"",$2); print $2; exit}' "$marker" || true)"
  rd="$(awk -F: '/^[[:space:]]*requires_deps:/ {gsub(/[[:space:]]/,"",$2); print $2; exit}' "$marker" || true)"
  rc="$(awk -F: '/^[[:space:]]*requires_chsh:/ {gsub(/[[:space:]]/,"",$2); print $2; exit}' "$marker" || true)"
  at="$(awk -F: '/^[[:space:]]*ansible_tags:/ {sub(/^[[:space:]]*ansible_tags:[[:space:]]*/,""); print; exit}' "$marker" || true)"
  if [[ "$rb" == "true" ]]; then
    require_bootstrap=true
  elif [[ "$rb" == "false" ]]; then
    require_bootstrap_false=true
  fi
  [[ "$rd" == "true" ]] && require_deps=true
  [[ "$rc" == "true" ]] && require_chsh=true
  if [[ -n "${at:-}" ]]; then
    at="${at//[/}"
    at="${at//]/}"
    at="${at//,/ }"
    at="${at//\"/}"
    at="${at//\'/}"
    for tag in $at; do
      [[ -n "$tag" ]] && ansible_tag_set["$tag"]=1
    done
  fi
done

if [[ "$any_marker" == "true" ]]; then
  if [[ "$require_bootstrap" == "true" ]]; then
    do_bootstrap=true
  elif [[ "$require_bootstrap_false" == "true" ]]; then
    do_bootstrap=false
  else
    do_bootstrap=true
  fi
else
  do_bootstrap=true
fi

# Provision after pull
PROVISION_INSTALL_DEPS="${DOTFILES_PROVISION_INSTALL_DEPS:-true}"
PROVISION_CHSH="${DOTFILES_PROVISION_CHSH:-false}"
bootstrap_args=()
if [[ "$do_bootstrap" == "true" ]]; then
  ansible_tags=""
  if [[ ${#ansible_tag_set[@]} -gt 0 ]]; then
    for tag in "${!ansible_tag_set[@]}"; do
      if [[ -z "$ansible_tags" ]]; then
        ansible_tags="$tag"
      else
        ansible_tags="${ansible_tags},${tag}"
      fi
    done
    bootstrap_args+=(--tags "$ansible_tags")
  fi
  if [[ "$require_deps" == "true" ]]; then
    PROVISION_INSTALL_DEPS=true
  fi
  if [[ "$require_chsh" == "true" ]]; then
    PROVISION_CHSH=true
  fi
  if [[ "${DOTFILES_UPDATE_CONTEXT:-manual}" == "auto" && ( "$require_deps" == "true" || "$require_chsh" == "true" ) ]]; then
    msg="Provisioning requires manual run (deps/chsh needed). Run: dotfiles-pull-updates"
    echo "⚠️  $msg" >&2
    echo "$msg" > "$DOTFILES_DIR/.provision_required" 2>/dev/null || true
  else
    if [[ "$PROVISION_INSTALL_DEPS" != "true" ]]; then
      bootstrap_args+=(--no-install-deps)
    fi
    if [[ "$PROVISION_CHSH" != "true" ]]; then
      bootstrap_args+=(--no-chsh)
    fi
    echo "🛠️  Provisioning dotfiles via bootstrap.sh (install_deps=${PROVISION_INSTALL_DEPS}, chsh=${PROVISION_CHSH})..."
    "$DOTFILES_DIR/bootstrap.sh" "${bootstrap_args[@]}"
    rm -f "$DOTFILES_DIR/.provision_required" 2>/dev/null || true
  fi
else
  echo "ℹ️  Skipping bootstrap: no update marker required provisioning."
fi

echo "✅ Dotfiles updated successfully!"
echo "💡 Reload your shell to apply changes: exec zsh"
