#!/bin/sh
# set locales to en_US
sudo locale-gen --lang en_US.UTF-8

# set timezone to Asia Shanghai
sudo dpkg-reconfigure tzdata

#TODO: check if setup the ssh-key in github for clone repo on github

sudo apt-get update
sudo apt-get -y upgrade

# useful tools
sudo apt-get -y install htop tilda tmux feh git mg zsh nginx apache2-utils awesome awesome-extra suckless-tools lxterminal fcitx-googlepinyin xcompmgr gnome-tweak-tool pgadmin3 volti libnss3-tools

# python dependence
sudo apt-get -y install python-dev build-essential python-pip

# disable ubuntu crash report
sudo sed -i "s/enabled=1/enabled=0/g" '/etc/default/apport'

# add goAgent crt to system
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n GoAgent -i '/home/liwei/Dropbox/goagent/local/CA.crt'

# install zsh
if [ ! -d $HOME/.oh-my-zsh ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
fi
if which zsh > /dev/null; then
    echo "chsh -s `which zsh`"
    chsh -s `which zsh`
else
    echo "[Error] Can not find zsh"
fi

# install dotfiles
if [ ! -d ~/dotfiles ]; then
    cd ~/
    git clone git@github.com:pylemon/dotfiles.git
    cd ~/dotfiles
    git submodule update --init
    cd ~/
    if [ ! -d ~/.zshrc ]; then
	mv ~/.zshrc ~/.zshrc.`date +%s`
    fi
    if [ ! -d ~/.dircolors ]; then
	mv ~/.dircolors ~/.dircolors.`date +%s`
    fi
    if [ ! -d ~/.gitconfig ]; then
	mv ~/.gitconfig ~/.gitconfig.`date +%s`
    fi
    if [ ! -d ~/.gitignore_global ]; then
	mv ~/.gitignore_global ~/.gitignore_global.`date +%s`
    fi

    ln -s ~/dotfiles/_zshrc.sh ~/.zshrc
    ln -s ~/dotfiles/_dircolors ~/.dircolors
    ln -s ~/dotfiles/_gitconfig ~/.gitconfig
    ln -s ~/dotfiles/_gitignore_global ~/.gitignore_global
fi

# virtualenv wrapper
sudo pip install virtualenvwrapper
if [ ! -d ~/Envs ]; then
    mkdir ~/Envs
fi
