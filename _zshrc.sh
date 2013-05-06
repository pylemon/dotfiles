# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

ZSH_THEME="../../dotfiles/pylemon"
# ZSH_THEME="random"
# themes I don't like
# agnoster avit fishy gentoo minimal mgutz tjkirch fwalch kphoen juanghurtado lambda essembeh norm intheloop wedisagree josh trapd00r rixius example kiwi

plugins=(git pip virtualenvwrapper history-substring-search zsh-syntax-highlighting gitfast command-not-found cp rsync python django)

source $ZSH/oh-my-zsh.sh
setopt correctall

compctl -g '~/.teamocil/*(:t:r)' teamocil

export EDITOR="emacsclient -a ''"
export LC_CTYPE="zh_CN.UTF-8"

# system
alias l='ls -C --group-directories-first'
alias ll='ls -ahlF --group-directories-first'
alias la='ls -A'
alias df='df -h'
alias tm='teamocil'
alias ipy='ipython'
alias rmpyc='find . -name "*.pyc" -print0 | xargs -0 rm -Rf'
alias kk='sudo fuser -k -n tcp $@'
alias fontls="fc-list | sed 's,:.*,,' | sort -u"
alias halt='sudo halt -p'
alias suspend='sudo pm-suspend'
alias iotop='sudo iotop'
alias iftop='sudo iftop'
alias nettop='sudo nethogs $@'
alias aptinstall='sudo aptitude install'
alias update='sudo aptitude update'
alias upgrade='sudo aptitude update && sudo aptitude -y upgrade'
alias show='aptitude show'
alias search='aptitude search'
alias mnt='mount | column -t'
alias gfw='ssh -ND 7070 -p 10086 liwei@localhost -v'
alias tpoff='synclient touchpadoff=1'
alias tpon='synclient touchpadoff=0'

# git
alias gl='git glog'
alias gla='git glog --all'
alias gls='git slog'
alias gup='git remote update && git remote prune origin'
alias gs='git status -s'
alias gdf='git diff -w'
alias grm='git rm --cached'

# software
alias et="emacsclient -a '' -t"
alias vi='vim'
alias du='ncdu'
alias nau='nautilus --no-desktop'
alias nautilus='nautilus --no-desktop'
alias pdf='evince'
alias epub='fbreader'
alias tree='tree -C'
alias pg='sudo -u postgres psql'

# project
alias fabls='fab --list'
alias dhero='cd ~/work/dhero/'
alias dowant='cd ~/work/dhero/dowant/'
alias penv='dhero && source /opt/venvs/p27_d13_dh/bin/activate'
alias collect='penv && python dowant/manage.py collectstatic --noinput'
alias message='penv && dowant && python manage.py compilemessages && penv'
alias rs='collect && message && python dowant/manage.py runserver 0.0.0.0:8000'
alias shell='penv && python dowant/manage.py shell_plus'

alias logs='tail -f -s 1 /var/log/DeliveryHeroChina/deliveryhero.log | grep ">>>"'
alias backup_setup='penv && fab set_up_scheduled_backups:liwei,production -H hk'
alias backup_setuphk='fab set_up_scheduled_backups:liwei,hk -H production'


# awesome
alias ax='Xephyr :1 -ac -br -noreset -screen 800x600 &'
alias ay='DISPLAY=:1.0 awesome -c ~/dotfiles/_config/awesome/rc.lua'
alias setscreen='xrandr --output DP-1 --mode 1920x1080 --above LVDS-1'

# custom commands
# mkdir and cd into that dirctionary
function mcd(){
    test -e $1 || mkdir $1; cd $1;
}

function psg(){
    ps auxw | grep -v grep | grep -i '[ ]\?'"$1";
}

function replace_unicode(){
    sed 's/ü/u/g' $1 | sed 's/Ä/A/g' | sed 's/ä/a/g' | sed 's/ß/B/g' | sed 's/ö/o/g' | sed 's/—/-/g' > /tmp/hero_temp;
    mv /tmp/hero_temp $1;
}

# make man documents have color
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
			man "$@"
}

# for colorful ls
test -r ~/.dircolors && eval "$(dircolors ~/.dircolors)"

# exports
# add dropbox bin path to sys.path
export PATH=$HOME/Dropbox/bin:$PATH
# for virtualenvwrapper
export WORKON_HOME=~/Envs
# zsh syntax highlighting when input a command
source $HOME/dotfiles/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# delivery hero envs
# export dhero=$HOME/work/dhero/
# export PYTHONPATH=$dhero/dowant:$dhero/msupport
# export DJANGO_SETTINGS_MODULE=dowant.settings

# default mode is LIVE
export OPERATION_MODE=LIVEDEV
