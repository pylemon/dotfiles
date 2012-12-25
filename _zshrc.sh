# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

ZSH_THEME="../../dotfiles/pylemon"


plugins=(git pip virtualenvwrapper history-substring-search zsh-syntax-highlighting gitfast command-not-found cp rsync python django)

source $ZSH/oh-my-zsh.sh
setopt correctall

compctl -g '~/.teamocil/*(:t:r)' teamocil

export EDITOR="emacsclient -a ''"
export LC_CTYPE="zh_CN.UTF-8"

# system
alias l='ls -C --group-directories-first'
alias ll='ls -ahlF'
alias la='ls -A'
alias df='df -h'
alias tm='teamocil'
alias ipy='ipython'
alias svnclean='find . -type d -name ".svn" -print0 | xargs -0 rm -Rf'
alias killtcp='fuser -k -n tcp $@'
alias kk='fuser -k -n tcp 8000'
alias fontls="fc-list | sed 's,:.*,,' | sort -u"
alias htop='htop'
alias halt='sudo halt -p'
alias suspend='sudo pm-suspend'
alias iotop='sudo iotop'
alias iftop='sudo iftop'
alias netop='sudo nethogs $@'
alias update='sudo apt-get update'
alias upgrade='sudo apt-get update && sudo apt-get -y upgrade'
alias show='apt-cache show'
alias search='apt-cache search'
alias m='udisks --mount'
alias m1='udisks --mount /dev/sdb1'
alias m2='udisks --mount /dev/sdc1'
alias m3='udisks --mount /dev/sdd1'
alias um='udisks --unmount'
alias um1='udisks --unmount /dev/sdb1'
alias um2='udisks --unmount /dev/sdc1'
alias um3='udisks --unmount /dev/sdd1'
alias gfw='ssh liwei@pylemon -ND 10086 -p 1423 -v'
alias tpoff='synclient touchpadoff=1'
alias tpon='synclient touchpadoff=0'

# git
alias gl='git glog'
alias gla='git glog --all'
alias gls='git slog'
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
alias ack='ack-grep'
alias epub='fbreader'
alias tree='tree -C'
alias sdf='svn diff > /tmp/svn.diff && emacsclient -t /tmp/svn.diff'

# adaptive
alias fabls='fab --list'

# awesome
alias ax='Xephyr :1 -ac -br -noreset -screen 800x600 &'
alias ay='DISPLAY=:1.0 awesome -c ~/dotfiles/_config/awesome/rc.lua'
alias setscreen='xrandr --output DP-1 --mode 1920x1080 --above LVDS-1'

# custom commands
# mkdir and cd into that dirctionary
function mcd(){
    test -e $1 || mkdir $1; cd $1;
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
