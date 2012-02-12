# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="bucunzai"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git python django terminator autojump)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

# some aliases here
alias ll='ls -ahlF'
alias la='ls -A'
alias l='ls -CF'
alias df='df -h'
alias tree='tree -C'
alias nautilus='nautilus --no-desktop'
alias vi='vim'
alias sylvia='ssh -l administrator 172.16.21.80'
alias steve='ssh -l liwei 172.16.120.222'
alias run80='cd ~/work/src/ && sudo python manage.py runserver 0.0.0.0:80'
alias shell='cd ~/work/src/ && sudo python manage.py shell'
alias dbshell='cd ~/work/src/ && sudo python manage.py dbshell'
alias profile='python kernprof.py -l -v '