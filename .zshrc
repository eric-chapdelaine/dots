##########
# Common #
##########

system_type=$(uname -s)

# Change zsh prompt
autoload -U colors && colors
PS1="%{$fg[cyan]%} %1~ %# %{$reset_color%}"

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
fi

################
# Mac Specific #
################

if [ "$system_type" = "Darwin" ]; then
    alias ra="ranger ."

    alias vim='nvim'
    export EDITOR='nvim'

    alias goose='~/goose'

    export PATH="/Users/ec825m/.local/bin:$PATH"

    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

    alias ctags="/opt/homebrew/bin/ctags"

    alias python3="/opt/homebrew/bin/python3.11"
    export PYTHON="/Users/ec825m/.pyenv/shims/python"
    PATH=$(pyenv root)/shims:$PATH

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

    # Add node v18 directly to PATH (bypasses nvm for faster shell startup)
    export PATH="$HOME/.nvm/versions/node/v18.20.4/bin:$PATH"

    # The next line updates PATH for the Google Cloud SDK.
    if [ -f '/Users/ec825m/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ec825m/Downloads/google-cloud-sdk/path.zsh.inc'; fi

    # The next line enables shell command completion for gcloud.
    if [ -f '/Users/ec825m/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ec825m/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

    export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

    export DOCKER_DEFAULT_PLATFORM=linux/amd64

    #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

export PATH=/Users/ec825m/.opencode/bin:$PATH
