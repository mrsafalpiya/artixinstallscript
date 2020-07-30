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
yay -S libxft-bgra
}
