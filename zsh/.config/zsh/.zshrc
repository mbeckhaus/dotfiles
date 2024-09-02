# Created by Zap installer
eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh
bindkey "ç" fzf-cd-widget

if [ -d "/Applications/IntelliJ IDEA.app/Contents/bin" ]; then
    # Add the Intellij/bin to the path so i can run format.sh in neovim/conform for formatting
    export PATH="/Applications/IntelliJ IDEA.app/Contents/bin:$PATH"
fi

source "$XDG_CONFIG_HOME/zsh/zsh_exports"
source "$XDG_CONFIG_HOME/zsh/zsh_prompt"
source "$XDG_CONFIG_HOME/zsh/zsh_keybinds"
source "$XDG_CONFIG_HOME/zsh/zsh_alias"
source "$XDG_CONFIG_HOME/zsh/fzf-git.sh"
source "$XDG_CONFIG_HOME/tmux/startup.sh"

plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zsh-users/zsh-syntax-highlighting"

# vi mode
set -o vi

# rebind delete key in normal mode
bindkey -a '^[[3~' vi-delete-char
bindkey '^y' autosuggest-accept
bindkey '^p' up-line-or-search
bindkey '^n' down-line-or-search

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Load and initialise completion system
autoload -Uz compinit
compinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source ~/fzf/fzf.zsh

# zoxide has to be initialized after compinit is called
eval "$(zoxide init zsh)"
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
pyenv global 2.7.18
eval "$(pyenv init -)"
