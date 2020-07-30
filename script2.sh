#!/bin/bash

# Starting up services
figlet "Services"
ln -s /etc/runit/sv/NetworkManager /run/runit/service/NetworkManager
ln -s /etc/runit/sv/bluetoothd /run/runit/service/bluetoothd
ln -s /etc/runit/sv/cupsd /run/runit/service/cupsd
echo "Waiting for the network service to startup properly"
sleep 5s
echo "Checking for internet below"
ping -c 4 google.com

# Creating user dirs
echo
figlet "User dirs"
xdg-user-dirs-update

# Installing yay
echo
figlet "Installing yay"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si PKGBUILD

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
	prog=$(echo $line | sed 's/^.*\///g')
	[ $prog == "dotfiles" ] && cd ~/$prog; cp -rt ~ .; cd || cd ~/$prog; sudo make clean install; cd
done
}

# Ending
echo
figlet "DONE!"
echo "Now reboot, login to your non-root user and run the following command 'sh script3.sh' to install AUR programs from yay."
