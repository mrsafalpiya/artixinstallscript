#!/bin/bash

# Downloading programs from AUR
echo
figlet "Downloading from AUR"
aurlist=""
cat ~/ArtixScript/aur_install.list | { while read line 
do
  aurlist="$aurlist $line"
done
yay -S --noconfirm $aurlist
gpg --keyserver keys.gnupg.net --recv-keys A2FB9E081F2D130E
yay -S libxft-bgra
}

# Change shell to zsh
chsh -s $(which zsh)

# Install pynvim
pip install pynvim
