##########
# Common #
##########

system_type=$(uname -s)

# Change zsh prompt
PS1="%1~ %# "

d() {
    docker $1 $(docker ps | fzf --tmux | awk '{print $1}') $2
}

cdt() {
    cd $(fzf --tmux)
}

##################
# Linux Specific #
##################

if [ "$system_type" = "Linux" ]; then
    export EDITOR="/usr/bin/vim"
    export VISUAL="/usr/bin/vim"

    # cd into directory once navigated from lf
    # (alias is short for ranger)
    alias ra="cd \"\$(command lf -print-last-dir $@)\""

    alias open="xdg-open"
    alias s="maim -s ~/Pictures/$(date +%s).png"
fi

################
# Mac Specific #
################

if [ "$system_type" = "Darwin" ]; then
    alias ra="ranger ."

    # Use update vim
    alias vim='/opt/homebrew/bin/vim'

    # TODO: have different for thinkpad
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    
    alias ctags="/opt/homebrew/bin/ctags"

    ####################
    # Wayfair specific #
    ####################

    token() {
    curl --location --request GET 'localhost:5000/create/token?employeeId=1101825' \
--data '' | jq -r '.response' | pbcopy
    echo COPIED
    }

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    alias mamba="docker pull wayfair/mamba:latest && docker run -it --rm wayfair/mamba:latest"

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
