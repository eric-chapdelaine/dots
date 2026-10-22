# ─────────────────────────────────────────────────────────────
# Arch Linux specifics. Sourced by ~/.zshrc when uname -s = Linux.
# ─────────────────────────────────────────────────────────────

alias goose="$HOME/.local/bin/goose"

# open a directory after navigating in lf
ra() {
    local dir
    dir=$(command lf -print-last-dir "$@") && [ -n "$dir" ] && cd "$dir"
}

alias open="xdg-open"
alias s="maim -s ~/Pictures/$(date +%s).png"

export OLLAMA_API_BASE=http://127.0.0.1:11434

# ***REDACTED*** gems installed with --user-install
if command -v ***REDACTED*** >/dev/null 2>&1; then
    case ":$PATH:" in
        *":$(***REDACTED*** -e 'print Gem.user_dir')/bin:"*) ;;
        *) export PATH="$(***REDACTED*** -e 'print Gem.user_dir')/bin:$PATH" ;;
    esac
fi

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME/bin:"*) ;;
    *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
