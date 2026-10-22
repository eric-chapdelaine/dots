# ─────────────────────────────────────────────────────────────
# Shared across Arch Linux and macOS. Sourced by ~/.zshrc.
# ─────────────────────────────────────────────────────────────

# User-local binaries (pi, scripts, etc.)
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# opencode (obsolete — pi coding agent is the current tool)
if [ -d "$HOME/.opencode/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.opencode/bin:"*) ;;
        *) export PATH="$HOME/.opencode/bin:$PATH" ;;
    esac
fi

##################
# Functions
##################

d() {
    docker $1 $(docker ps | fzf --tmux | awk '{print $1}') $2
}

cdt() {
    cd $(fzf --tmux)
}

###############
# Aliases
###############

alias ag='ag -U --path-to-ignore ~/.ignore'
alias t='tmux a -t'
# neovim is the editor on both machines
alias vim='nvim'
alias vi='nvim'
