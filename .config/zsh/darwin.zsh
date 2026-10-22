# ─────────────────────────────────────────────────────────────
# macOS specifics. Sourced by ~/.zshrc when uname -s = Darwin.
# ─────────────────────────────────────────────────────────────

# Prioritize Homebrew over the older system binaries in /usr/bin
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

alias ra="ranger ."
alias goose="$HOME/goose"

# Homebrew ctags / python
alias ctags="/opt/homebrew/bin/ctags"
alias python3="/opt/homebrew/bin/python3.11"

# libpq (psql et al)
case ":$PATH:" in
    *":/opt/homebrew/opt/libpq/bin:"*) ;;
    *) export PATH="/opt/homebrew/opt/libpq/bin:$PATH" ;;
esac

# zsh-autosuggestions (Homebrew)
if command -v brew >/dev/null 2>&1; then
    _zsa="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [ -f "$_zsa" ] && source "$_zsa"
    unset _zsa
fi

# pyenv
if [ -d "$HOME/.pyenv/shims" ]; then
    export PYTHON="$HOME/.pyenv/shims/python"
    case ":$PATH:" in
        *"$(pyenv root)/shims:"*) ;;
        *) PATH="$(pyenv root)/shims:$PATH" ;;
    esac
fi

##################
# nvm (lazy-loaded — keeps shell startup fast)
##################
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "$HOME/.nvm" || printf %s "$XDG_CONFIG_HOME/nvm")"

_load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# Replace this stub with the real nvm the first time it is called.
nvm() {
    unset -f nvm 2>/dev/null
    _load_nvm
    nvm "$@"
}

# Node v24 directly on PATH — bypasses nvm for faster shell startup
case ":$PATH:" in
    *"$HOME/.nvm/versions/node/v24.2.0/bin:"*) ;;
    *) export PATH="$HOME/.nvm/versions/node/v24.2.0/bin:$PATH" ;;
esac

# Google Cloud SDK
[ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ] && . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"

# Docker: Apple Silicon defaults to arm64, some images are amd64-only
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# sdkman — must be sourced late
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# mise (runtime version manager, pins ruby/node per project)
[ -x /opt/homebrew/bin/mise ] && eval "$(/opt/homebrew/bin/mise activate zsh)"

# qmd CLI (local markdown/wiki search)
_qmd_js="$HOME/.nvm/versions/node/v24.13.1/lib/node_modules/@tobilu/qmd/dist/cli/qmd.js"
[ -f "$_qmd_js" ] && alias qmd="node $_qmd_js"
unset _qmd_js
