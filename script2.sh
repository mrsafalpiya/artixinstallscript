#!/bin/bash

username=""
# Starting up services
figlet "Services"
ln -s /etc/runit/sv/NetworkManager /run/runit/service/NetworkManager
ln -s /etc/runit/sv/bluetoothd /run/runit/service/bluetoothd
ln -s /etc/runit/sv/cupsd /run/runit/service/cupsd
echo "Waiting for the network service to startup properly"
sleep 15s
echo
echo "Check for internet below: "
ping -c 4 google.com

# Downloading other programs
echo
figlet "Post Downloads"
postlist=""
cat /home/$username/ArtixScript/post_install.list | { while read line 
do
  postlist="$postlist $line"
done
postinstall () { pacman -Syy; pacman -S --noconfirm $postlist; [[ ! $(pacman -Qi xorg-xinit) ]] && postinstall; }
postinstall
}

# Installing external programs
echo
figlet "External programs"
mkdir -p /home/$username/extprograms/
cat /home/$username/ArtixScript/extgit_smci.list | { while read line
do
	prog=$(echo $line | sed 's/^.*\///g')
	figlet $prog
	git clone $line /home/$username/extprograms/$prog
	figlet $prog
	make clean install -C "/home/$username/extprograms/$prog"
done
}
ln -sfT /bin/dash /bin/sh

# Ending
echo
figlet "DONE!"
echo "Now run the following command 'artixinstall3' to install yay."
