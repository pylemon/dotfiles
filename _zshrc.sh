#!/bin/sh

# language settings
export LC_CTYPE=zh_CN.UTF-8

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
setopt correctall

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
alias gl='git glog'
alias gla='git glog --all'
alias gls='git slog'
alias gup='git remote update && git remote prune origin'
alias gs='git status -s'
alias gdf='git diff -w'
alias grm='git rm --cached'

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
alias dhero='cd ~/work/dhero/'
alias dowant='cd ~/work/dhero/dowant/'
alias penv='dhero && source /opt/venvs/deliveryhero_venv/bin/activate'
alias fb='penv && fab -f sysadmin/fabric/fabfile.py'
alias message='penv && dowant && python manage.py compilemessages && penv'
alias rskill='fuser -k -n tcp 8000'
alias rs='rskill || message && python dowant/manage.py runserver 0.0.0.0:8000 --settings=dowant.dev_settings'
alias shell='penv && python dowant/manage.py shell_plus --settings=dowant.dev_settings --quiet-load'

alias logs='tail -f -s 1 /var/log/DeliveryHeroChina/deliveryhero.log | grep ">>>"'
alias backup_setup='penv && fab set_up_scheduled_backups:liwei,production -H hk'
alias backup_setuphk='fab set_up_scheduled_backups:liwei,hk -H production'

# awesome
alias ax='Xephyr :1 -ac -br -noreset -screen 1280x800 &'
alias ay='DISPLAY=:1.0 awesome -c ~/.config/awesome/rc.lua'
alias setscreen='xrandr --output DP-1 --mode 1920x1080 --above LVDS-1'

# custom commands
function m(){
   penv && python dowant/manage.py $1 $2 $3 $4 --settings=dowant.dev_settings
}

function psg(){
    ps auxw | grep -v grep | grep -i '[ ]\?'"$1";
}

function vpntest(){
    sudo fping -C 5 -q < ~/work/vpn_ip_list.txt 2>&1 >/dev/null | awk '{ print ($3+$4+$5+$6+$7)/5 "\t " $1}' | sort -n
}

function clean(){
    git branch | grep '^ ' | grep -v 'leeway' | xargs git branch -D 2> /dev/null;

    find . -name '*.pyc' | xargs rm -f;

    if [ -f "fixture.py" ]; then
        rm fixture.py
    fi

    if [ -f "DeliveryService" ]; then
        rm DeliveryService
    fi

    if [ -f "main" ]; then
        rm main
    fi

    if [ -f "fixture_maker" ]; then
        rm fixture_maker
    fi

    if [ -f "make_fixture.log" ]; then
        rm make_fixture.log
    fi
}

# for colorful ls
test -r ~/.dircolors && eval "$(dircolors ~/.dircolors)"

# exports
# add dropbox bin path to sys.path
export PATH=$HOME/Dropbox/bin:$PATH

# zsh syntax highlighting when input a command
source $HOME/dotfiles/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# DHC django settings
source ~/work/dhero/sysadmin/envs/env_leeway
export OPERATION_MODE=LIVEDEV
export IPYTHONDIR=$HOME/.ipython
export PYTHONPATH=/home/liwei/work/dhero/:$PYTHONPATH
export WORKON_HOME=~/Envs
source /usr/local/bin/virtualenvwrapper.sh

# Management settings
export MANAGEMENT_MODEL_URL=http://192.168.1.11:8000
export MANAGEMENT_POINT_URL=http://127.0.0.1
export MANAGEMENT_POLLING_URL=http://192.168.1.11:4001
export MANAGEMENT_POLLING_CHANNEL=leeway
export MANAGEMENT_ALLOWED_ORDER_POST_IPS=127.0.0.1,114.80.201.200,192.168.1.11
export MANAGEMENT_MONGODB_URI=mongodb://127.0.0.1:27017/management
export MANAGEMENT_LOG_FILE_PREFIX=/var/log/management.log
export MANAGEMENT_LOG_TO_STDERR=1
export MANAGEMENT_PORT=22222
export MANAGEMENT_DEBUG=1

# Go settings
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export GOARCH=amd64
export GOOS=linux

# Ruby settings
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# teamocil auto-complete
compctl -g '~/.teamocil/*(:t:r)' teamocil

# emacs daemon must after LC_CTYPE update.
export EDITOR='emacsclient -nw'
pgrep -f 'emacs --daemon' > /dev/null
if [ $? -ne 0 ]
then
    emacs --daemon
fi
alias e=$EDITOR

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'
