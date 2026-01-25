# Environment variables and PATH setup

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# PATH additions
if [[ -d /usr/local/go/bin ]]; then
  export PATH="$PATH:/usr/local/go/bin"
fi
if [[ -d /snap/bin ]]; then
  export PATH="$PATH:/snap/bin"
fi
if [[ -d "$HOME/go/bin" ]]; then
  export PATH="$HOME/go/bin:$PATH"
fi
if [[ -d "$HOME/.bin" ]]; then
  export PATH="$HOME/.bin:$PATH"
fi

# Composer (if available)
if command -v composer &> /dev/null; then
  export PATH="$(composer config -g home)/vendor/bin:$PATH"
fi

# GPG and browser
export GPG_TTY=$(tty)
if [[ -x "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe" ]]; then
  export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
fi

# AWS
export AWS_PAGER=''
