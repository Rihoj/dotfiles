# Environment variables and PATH setup

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# PATH additions
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/snap/bin
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.bin:$PATH"

# Composer (if available)
if command -v composer &> /dev/null; then
  export PATH="$(composer config -g home)/vendor/bin:$PATH"
fi

# GPG and browser
export GPG_TTY=$(tty)
export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"

# AWS
export AWS_PAGER=''
