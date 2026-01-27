# Early local env overrides (loaded before other modules)
# Use for vars that must be set before module initialization.

if [[ -f "$HOME/.zshenv.local" ]]; then
  # Avoid double-sourcing if user sources it elsewhere
  if [[ -z "${ZSHRC_LOCAL_ENV_LOADED:-}" ]]; then
    export ZSHRC_LOCAL_ENV_LOADED=1
    source "$HOME/.zshenv.local"
  fi
fi
