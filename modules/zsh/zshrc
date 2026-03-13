# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $HOME/.rcs/omz_customizations/themes/powerlevel10k/powerlevel10k.zsh-theme

# TODO: Move this to .rcs directory and create symlink
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set CLICOLOR if you want Ansi Colors in iTerm2
# export CLICOLOR=1

# Set colors to match iTerm2 Terminal Colors
# export TERM=xterm-256color

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_CUSTOM=$HOME/.rcs/omz_customizations/
# ZSH_THEME="cletus_one"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to disable command auto-correction.
# DISABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

#export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

#export PS1="\d : \t \u@\h : \w \n$ "

# My aliases
alias ls="ls -G"
alias py="python"
alias epoch='date +%s | pbcopy'
alias g='git'
alias gpush='branch=$(git describe --contains --all HEAD); git push origin $branch;'
alias gpull='~/.rcs/scripts/git_pull'
alias gitd='git diff --color'
alias gcom='~/.rcs/scripts/git_commit'
alias mvim='mv ~/.vimrc ~/.vimrc-git-committing'     # Move vim config to avoid conflicts when doing a git pull
alias mvimback='mv ~/.vimrc-git-committing ~/.vimrc' # Move vim config back
#alias gitm='branch=$(git describe --contains --all HEAD); git checkout master; git fetch; git pull origin master; git checkout $branch; git merge master;'
alias code='open -a Visual\ Studio\ Code'
alias mvnode='~/.rcs/scripts/mv_node_modules.sh'

# Local Aliases and Settings
if [ -f $HOME/.aliases_local ]; then
    source $HOME/.aliases_local
fi

# NVM
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm use --lts
fi

bindkey -v

# Normal Bindings
bindkey '^U'    backward-kill-line                      # Ctrl + U
bindkey '^A'    beginning-of-line                       # Ctrl + A
bindkey '^[OH'  beginning-of-line                       # Home
bindkey '^[[1~' beginning-of-line                       # Home
bindkey '^[[H'  beginning-of-line                       # Home

bindkey '^K'    kill-line                               # Ctrl + K
bindkey '^E'    end-of-line                             # Ctrl + E
bindkey '^[OF'  end-of-line                             # End
bindkey '^[[4~' end-of-line                             # End
bindkey '^[[F'  end-of-line                             # End

bindkey '^R'    history-incremental-pattern-search-backward # Ctrl + R
bindkey '^S'    history-incremental-pattern-search-forward # Ctrl + S
bindkey '^[[A'  up-line-or-search                       # Up Arrow
bindkey '^[OA'  up-line-or-search                       # Up Arrow
bindkey '^[[5~' up-line-or-history                      #
bindkey '^[[B'  down-line-or-search                     # Down Arrow
bindkey '^[OB'  down-line-or-search                     # Down Arrow
bindkey '^[[6~' down-line-or-history                    #
bindkey ' '     magic-space                             # Space

bindkey '^[[1;2C' forward-word                          # Ctrl + Right Arrow
bindkey '^[[1;2D' backward-word                         # Ctrl + Left Arrow
bindkey '^[[Z'    reverse-menu-complete                 # Shift + Tab

bindkey '^[[3~'  delete-char                            # Delete
bindkey '^[[3~'  delete-char                            # Delete
bindkey '^[3;5~' delete-char                            # Delete
bindkey '^[[3~'  delete-char                            # Delete
bindkey '^?'     backward-delete-char                   # Backspace

# Specific Bindings
bindkey "^[m" copy-earlier-word                         # http://chneukirchen.org/blog/archive/2013/03/10-fresh-zsh-tricks-you-may-not-know.html

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
