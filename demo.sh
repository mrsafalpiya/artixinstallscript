#!/bin/bash

# Installing suckless programs
echo
figlet "Suckless programs"
cat slgit_install.list | { while read line
do
	prog=$(echo $line | sed 's/^.*\///g')
	[ $prog == "dotfiles" ] && cd ~/$prog; cp -rt ~ . || cd ~/$prog; sudo make clean install
done
}
