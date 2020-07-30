#!/bin/bash

username=""
# Starting up services
figlet "Services"
ln -s /etc/runit/sv/NetworkManager /run/runit/service/NetworkManager
ln -s /etc/runit/sv/bluetoothd /run/runit/service/bluetoothd
ln -s /etc/runit/sv/cupsd /run/runit/service/cupsd
echo "Waiting for the network service to startup properly"
sleep 12s
echo "Checking for internet below"
ping -c 4 google.com

# Downloading other programs
echo
figlet "Post Downloads"
postlist=""
cat post_install.list | { while read line 
do
  postlist="$postlist $line"
done
postinstall () { pacman -Syy; pacman -S --noconfirm $postlist; [[ ! $(pacman -Qi xorg-xinit) ]] && postinstall; }
postinstall
}

# Installing suckless programs
echo
figlet "Suckless programs"
cat slgit_install.list | { while read line
do
	mkdir -p /home/$username/slprograms/
	git clone $line /home/$username/slprograms
	prog=$(echo $line | sed 's/^.*\///g')
	[ $prog == "dotfiles" ] && cd /home/$username/slprograms/$prog; cp -rt ~ . || cd /home/$username/slprograms/$prog; make clean install
done
}

# Ending
echo
figlet "DONE!"
echo "Now run the following command 'artixinstall3' to install yay."
