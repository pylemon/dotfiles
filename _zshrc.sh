#!/bin/sh

# language settings

# zsh settings
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

bgnotify_threshold=5  ## set your own notification threshold

function bgnotify_formatted {
  ## $1=exit_status, $2=command, $3=elapsed_time
  ##[ $1 -eq 0 ] && title="#Done" || title="## Failed!"
  bgnotify "#done (took $3 secs), cmd:" "$2";
}

ZSH_THEME="../../dotfiles/pylemon"
# ZSH_THEME="random"
# themes I don't like
# agnoster avit fishy gentoo minimal mgutz tjkirch fwalch kphoen juanghurtado lambda essembeh norm intheloop wedisagree josh trapd00r rixius example kiwi
plugins=(git github pip encode64 fabric last-working-dir zsh-syntax-highlighting gitfast command-not-found cp rsync python django history-substring-search per-directory-history colored-man docker golang z colorize bgnotify)

source $ZSH/oh-my-zsh.sh
unsetopt correct_all

# system alias
alias c='colorize'
alias l='ls -C --group-directories-first'
alias ll='ls -ahlF --group-directories-first'
alias la='ls -A'
alias df='df -h'
alias t='teamocil'
alias ipy='ipython'
alias kk='sudo fuser -k -n tcp $@'
alias fontls="fc-list | sed 's,:.*,,' | sort -u"
alias nettop='sudo nethogs $@'
alias update='sudo apt-fast update'
alias upgrade='sudo apt-fast update && sudo apt-fast -y upgrade'
alias search='aptitude search'
alias mnt='mount | column -t'

#alias halt='sudo halt -p'
#alias suspend='sudo pm-suspend'
#alias tpoff='synclient touchpadoff=1'
#alias tpon='synclient touchpadoff=0'
#alias gfw='ssh -ND 7070 -p 10086 liwei@localhost -v'

# git
alias git="LANG=C git"
alias gl='git glog'
alias gla='git glog --all'
alias gls='git slog'
alias gup='git remote update && git remote prune origin'
alias gdf='git diff -w'

# software
alias vi='vim'
alias du='ncdu'
alias nau='nautilus --no-desktop'
alias nautilus='nautilus --no-desktop'
alias pdf='evince'
alias epub='fbreader'
alias tree='tree -C'
alias pg='sudo -u postgres psql'

# project
alias bolo='cd ~/bolo-server/'
alias penv='bolo && workon bolo'
#alias fb='penv && fab -f sysadmin/fabric/fabfile.py'
#alias message='penv && dowant && python manage.py compilemessages && penv'
#alias rskill='fuser -k -n tcp 8000'
#alias rs='rskill || message && python dowant/manage.py runserver 0.0.0.0:8000 --settings=dowant.dev_settings'
#alias shell='penv && python dowant/manage.py shell_plus --settings=dowant.dev_settings --quiet-load'

# awesome
#alias ax='Xephyr :1 -ac -br -noreset -screen 1280x800 &'
#alias ay='DISPLAY=:1.0 awesome -c ~/.config/awesome/rc.lua'
#alias setscreen='xrandr --output DP-1 --mode 1920x1080 --above LVDS-1'

# custom commands
function m(){
   penv && python dowant/manage.py $1 $2 $3 $4 --settings=dowant.dev_settings
}

function psg(){
    ps auxw | grep -v grep | grep -i '[ ]\?'"$1";
}

function clean(){
    #git branch | grep '^ ' | grep -v 'leeway' | xargs git branch -D 2> /dev/null;

    find . -name '*.pyc' | xargs rm -f;
    # clean up golang main binary file
    if [ -f "main" ]; then
        rm main
    fi
}

# for colorful ls
test -r ~/.dircolors && eval "$(dircolors ~/.dircolors)"

# exports
# add dropbox bin path to sys.path
export PATH=$HOME/Dropbox/bin:$PATH

# zsh syntax highlighting when input a command
source $HOME/dotfiles/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# python settings
export IPYTHONDIR=$HOME/.ipython
export WORKON_HOME=~/Envs
source /usr/local/bin/virtualenvwrapper.sh

# Bolo.me settings
PROJECT_HOME='/home/liwei/bolo-server/'
CORE_SRC_HOME=$PROJECT_HOME/core/src
INTERNAL_SRC_HOME=$PROJECT_HOME/internal/src
INTERNAL_TEST_HOME=$PROJECT_HOME/internal/test
INTERNAL_LOG_HOME=$PROJECT_HOME/internal/log
API_SRC_HOME=$PROJECT_HOME/rest_api/src
API_TEST_HOME=$PROJECT_HOME/rest_api/test
API_SQL_HOME=$PROJECT_HOME/rest_api/sql
API_LOG_HOME=$PROJECT_HOME/rest_api/log
CRON_SRC_HOME=$PROJECT_HOME/cron/src
CRON_TEST_HOME=$PROJECT_HOME/cron/test
CRON_LOG_HOME=$PROJECT_HOME/cron/log


PYTHONPATH=$PYTHONPATH:$CORE_SRC_HOME:$INTERNAL_SRC_HOME:$INTERNAL_TEST_HOME:$INTERNAL_LOG_HOME:$API_SRC_HOME:$API_TEST_HOME:$API_SQL_HOME:$API_LOG_HOME:$CRON_SRC_HOME:$CRON_TEST_HOME:$CRON_LOG_HOME
export PYTHONPATH

function internal_run {
    fuser -k -n tcp 8871
    echo "Starting server at: http://localhost:8871"
    python $INTERNAL_SRC_HOME/handler.py -port=8871 -logging=debug -log_to_stderr=True -log_file_prefix=$INTERNAL_LOG_HOME/bolo-internal.log
}

function rest_api_run {
    fuser -k -n tcp 8870
    echo "Starting server at: http://192.168.1.218:8870"
    python $API_SRC_HOME/handler.py -port=8870 -logging=error -log_to_stderr=True -log_file_prefix=$API_LOG_HOME/bolo-dev.log
}

# Go settings
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export GOARCH=amd64
export GOOS=linux

# teamocil auto-complete
compctl -g '~/.teamocil/*(:t:r)' teamocil

# emacs daemon must after LC_CTYPE update.
#export EDITOR='emacsclient -nw'
#pgrep -f 'emacs --daemon' > /dev/null
#if [ $? -ne 0 ]
#then
#    emacs --daemon
#fi
#alias e=$EDITOR

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'
