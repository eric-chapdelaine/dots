# ─────────────────────────────────────────────────────────────
# zsh entry point. OS-specific settings live in ~/.config/zsh/.
#   zshenv → zprofile → zshrc  (this file) → zlogin
# ─────────────────────────────────────────────────────────────

# Change zsh prompt
autoload -U colors && colors
PS1="%{$fg[cyan]%} %1~ %# %{$reset_color%}"

# Editor: same on both machines (neovim everywhere)
export EDITOR="nvim"
export VISUAL="nvim"

# Shared shell config
[ -f "$HOME/.config/zsh/common.zsh" ] && source "$HOME/.config/zsh/common.zsh"

# Per-OS config
case "$(uname -s)" in
    Linux)  [ -f "$HOME/.config/zsh/linux.zsh"  ] && source "$HOME/.config/zsh/linux.zsh" ;;
    Darwin) [ -f "$HOME/.config/zsh/darwin.zsh" ] && source "$HOME/.config/zsh/darwin.zsh" ;;
esac

# Local secrets — untracked (see ~/.config/secrets.sh.example)
[ -f "$HOME/.config/secrets.sh" ] && source "$HOME/.config/secrets.sh"
