#!/bin/bash

# install gitconfig

rm -f /home/liwei/.gitconfig
cp -f /home/liwei/dotfiles/gitconfig /home/liwei/.gitconfig

echo 'setting up .gitconfig ...'


# install vimperator

rm -f /home/liwei/.vimperatorrc
cp -f /home/liwei/dotfiles/vimperatorrc /home/liwei/.vimperatorrc

rm -rf /home/liwei/.vimperator
cp -rf /home/liwei/dotfiles/vimperator /home/liwei/.vimperator

echo 'setting up .vimperator ...'