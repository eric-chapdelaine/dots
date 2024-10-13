# Autocomplete
autoload -Uz compinit
compinit

autoload -Uz promptinit
promptinit

export EDITOR="/usr/bin/vim"
export VISUAL="/usr/bin/vim"

# Created by `pipx` on 2023-09-11 21:00:54
export PATH="$PATH:/home/emchap4/.local/bin"
export PATH=/usr/local/texlive/2023/bin/x86_64-linux:$PATH
export MANPATH=/usr/local/texlive/2023/texmf-dist/doc/man:$MANPATH
export INFOPATH=/usr/local/texlive/2023/texmf-dist/doc/info:$INFOPATH

# Jekyll
export PATH=$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH

# cd into directory once navigated from lf
# (alias is short for ranger)
alias ra="cd \"\$(command lf -print-last-dir $@)\""

# Download Znap, if it's not there yet.
[[ -r ~/Repos/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh  # Start Znap

# Prompt theme
prompt redhat

### zsh-autocomplete ###
#zstyle '*:compinit' arguments -D -i -u -C -w

#bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
#bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

# all Tab widgets
# zstyle ':autocomplete:*complete*:*' insert-unambiguous yes
# 
# # all history widgets
# zstyle ':autocomplete:*history*:*' insert-unambiguous yes
# 
# # ^S
# zstyle ':autocomplete:menu-search:*' insert-unambiguous yes

alias open="xdg-open"
alias s="maim -s ~/Pictures/$(date +%s).png"

#alias vim="nvim"

# Have vim work in remote hosts (i.e. remarkable)
export TERM=xterm-256color ssh

# emacs
export PATH="$HOME/.emacs.d/bin:$PATH"

# drracket
export PATH="$HOME/racket/bin:$PATH"

# control + arrow key moves across words
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

