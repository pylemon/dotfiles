#!/bin/sh

# set timezone to Asia Shanghai
sudo dpkg-reconfigure tzdata

#TODO: check if setup the ssh-key in github for clone repo on github

sudo apt-get update
sudo apt-get -y upgrade

# useful tools
sudo apt-get -y install htop tmux git mg zsh nginx apache2-utils

# python dependence
sudo apt-get -y install python-dev build-essential python-pip

# set locales to en_US
sudo locale-gen --lang en_US.UTF-8

# install zsh
if [ ! -d $HOME/.oh-my-zsh ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
fi
if which zsh > /dev/null; then
    echo "chsh -s `which zsh`"
else
    echo "[Error] Can not find zsh"
fi

# install dotfiles
if [ ! -d $HOME/dotfiles ]; then
    cd $HOME/
    git clone git@github.com:pylemon/dotfiles.git
    cd $HOME/dotfiles
    git submodule init
    git submodule update
    cd $HOME/
    if [ ! -d $HOME/.zshrc ]; then
	mv $HOME/.zshrc $HOME/.zshrc.`date +%s`
    fi
    ln -s $HOME/dotfiles/_dircolors $HOME/.dircolors
    ln -s $HOME/dotfiles/_gitconfig $HOME/.gitconfig
    ln -s $HOME/dotfiles/_gitignore_global $HOME/.gitignore_global
    ln -s $HOME/dotfiles/_zshrc $HOME/.zshrc
fi

# virtualenv wrapper
sudo pip install virtualenvwrapper
if [ ! -d $HOME/Envs ]; then
    mkdir $HOME/Envs
fi
