#!/bin/bash
set -euo pipefail
# Symlink utility scripts to ~/.local/bin or /usr/local/bin
# Makes dotfiles-* commands available globally

# Dynamically determine the dotfiles directory from script location
# Resolve symlinks to get the actual script location
SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
while [ -L "$SCRIPT_PATH" ]; do
  SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
  [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
done
DOTFILES_BIN_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}/bin"
TARGET_DIR="${1:-$HOME/.local/bin}"

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Find all .sh scripts in bin/
for script in "$DOTFILES_BIN_DIR"/*.sh; do
  if [[ -f "$script" ]]; then
    basename=$(basename "$script" .sh)
    link_path="$TARGET_DIR/$basename"
    
    # Remove existing file or symlink if it exists
    [[ -e "$link_path" || -L "$link_path" ]] && rm -f "$link_path"
    
    # Create new symlink
    ln -s "$script" "$link_path"
    chmod +x "$script"
    
    echo "✅ Linked: $basename -> $link_path"
  fi
done

echo ""
echo "💡 Make sure $TARGET_DIR is in your PATH:"
echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
