#!/bin/bash

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

# Ending
echo
figlet "DONE!"
echo "Installation of yay completed successfully! Now run 'yi' to install programs from AUR."
