##########
# Common #
##########

system_type=$(uname -s)

# Change zsh prompt
autoload -U colors && colors
PS1="%{$fg[cyan]%} %1~ %# %{$reset_color%}"

# User-local binaries (pi, scripts, etc.) — applies to every machine
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

d() {
    docker $1 $(docker ps | fzf --tmux | awk '{print $1}') $2
}

cdt() {
    cd $(fzf --tmux)
}

alias ag='ag -U --path-to-ignore ~/.ignore'

alias t='tmux a -t'

##################
# Linux Specific #
##################

if [ "$system_type" = "Linux" ]; then
    export EDITOR="/usr/bin/vim"
    export VISUAL="/usr/bin/vim"

    alias vim='nvim'

    alias goose='~/.local/bin/goose'

    # cd into directory once navigated from lf
    # (alias is short for ranger)
    alias ra="cd \"\$(command lf -print-last-dir $@)\""

    alias open="xdg-open"
    alias s="maim -s ~/Pictures/$(date +%s).png"

    export OLLAMA_API_BASE=http://127.0.0.1:11434

    # opencode (obsolete — pi coding agent is the current tool)
    [ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

    # ruby gems installed with --user-install
    if command -v ruby >/dev/null 2>&1; then
        export PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
    fi

    # pnpm
    export PNPM_HOME="$HOME/.local/share/pnpm"
    case ":$PATH:" in
        *":$PNPM_HOME/bin:"*) ;;
        *) export PATH="$PNPM_HOME/bin:$PATH" ;;
    esac
fi

################
# Mac Specific #
################

if [ "$system_type" = "Darwin" ]; then
    # Prioritize Homebrew binaries (e.g. python3) over the older system ones in /usr/bin
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

    alias ra="ranger ."

    alias vim='nvim'
    export EDITOR='nvim'

    alias goose='~/goose'

    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

    alias ctags="/opt/homebrew/bin/ctags"

    alias python3="/opt/homebrew/bin/python3.11"
    [ -d "$HOME/.pyenv/shims" ] && {
        export PYTHON="$HOME/.pyenv/shims/python"
        PATH="$(pyenv root)/shims:$PATH"
    }

    # Lazy load nvm
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "$HOME/.nvm" || printf %s "$XDG_CONFIG_HOME/nvm")"

    # Function to load nvm only when needed
    load_nvm() {
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    }

    nvm() {
      load_nvm
      nvm "$@"
    }

    # Add node v24 directly to PATH (bypasses nvm for faster shell startup)
    export PATH="$HOME/.nvm/versions/node/v24.2.0/bin:$PATH"

    # The next line updates PATH for the Google Cloud SDK.
    if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi

    # The next line enables shell command completion for gcloud.
    if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi

    export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

    export DOCKER_DEFAULT_PLATFORM=linux/amd64

    #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

    # mise (runtime version manager, pins ruby/node per project)
    [ -x /opt/homebrew/bin/mise ] && eval "$(/opt/homebrew/bin/mise activate zsh)"

    # opencode (obsolete — pi coding agent is the current tool)
    [ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

    # qmd CLI (local markdown/wiki search)
    if [ -f "$HOME/.nvm/versions/node/v24.13.1/lib/node_modules/@tobilu/qmd/dist/cli/qmd.js" ]; then
        alias qmd='node "$HOME/.nvm/versions/node/v24.13.1/lib/node_modules/@tobilu/qmd/dist/cli/qmd.js"'
    fi
fi

# Local secrets — untracked (see ~/.config/secrets.sh.example)
[ -f "$HOME/.config/secrets.sh" ] && source "$HOME/.config/secrets.sh"
