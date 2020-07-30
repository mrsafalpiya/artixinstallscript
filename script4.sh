#!/bin/bash

# Downloading programs from AUR
echo
figlet "Downloading from AUR"
aurlist=""
cat aur_install.list | { while read line 
do
  aurlist="$aurlist $line"
done
yay -S --noconfirm $aurlist
gpg --keyserver keys.gnupg.net --recv-keys A2FB9E081F2D130E
yay -S libxft-bgra
}

chsh -s $(which zsh)
