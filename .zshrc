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


################
# Mac Specific #
################


if [ "$system_type" = "Darwin" ]; then
    alias ra="ranger ."

    # Use update vim
    alias vim='/opt/homebrew/bin/vim'

    ####################
    # Wayfair specific #
    ####################

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    alias mamba="docker pull wayfair/mamba:latest && docker run -it --rm wayfair/mamba:latest"

    # The next line updates PATH for the Google Cloud SDK.
    if [ -f '/Users/ec825m/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ec825m/Downloads/google-cloud-sdk/path.zsh.inc'; fi

    # The next line enables shell command completion for gcloud.
    if [ -f '/Users/ec825m/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ec825m/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
    export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

    ####################

    # TODO: have different for thinkpad
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    
    alias ctags="/opt/homebrew/bin/ctags"

    #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi
