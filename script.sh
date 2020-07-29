##!/bin/bash

pacman -Syy
pacman -S --noconfirm figlet

# Ask for hostname or else return an error if left blank
figlet "Basic Info"
echo -n "Hostname: "
read hostname
: "${hostname:?"Missing hostname"}"

# Ask for zoneinfo or else return an error if left blank
echo -n "Zone: (Asia/Kathmandu) "
read zone
: "${zone:?"Missing hostname"}"

# Ask for username or else return an error if left blank
echo -n "Username: "
read username
: "${username:?"Missing username"}"

# Ask for password
echo -n "Password: "
read -s password
echo 
echo -n "Repeat Password: "
read -s password2
[[ "$password" == "$password2" ]] || ( echo; echo "Passwords did not match"; exit 1; )

# Ask for disk and open it with cfdisk
echo
figlet "Disk Configuration"
lsblk
echo -n "Select the disk you want to install to: (/dev/xxx) "
read disk
cfdisk ${disk}

# Ask for boot and root partition
clear
lsblk
echo -n "Select your boot partition: (/dev/sdxx) "
read part_boot
echo -n "Select your root partition: (dev/sdxx) "
read part_root

# Format and mount boot and root partitions
clear
figlet "Formatting and Mounting"
mkfs.fat -F32 ${part_boot}
mkfs.ext4 ${part_root}
mount ${part_root} /mnt
mkdir -p /mnt/boot/efi
mount ${part_boot} /mnt/boot/efi

# Basestrap install
clear
figlet "Basestrap Install"
baselist=""
cat basestrap_install.list | { while read line 
do
  baselist="$baselist $line"
done
basestrap /mnt $baselist
}

# Make swapfile
echo
figlet "Swap"
artools-chroot /mnt dd if=/dev/zero of=/swapfile bs=1M count=8192 status=progress
artools-chroot /mnt chmod 600 /swapfile
artools-chroot /mnt mkswap /swapfile
artools-chroot /mnt swapon /swapfile

# Generate fstab file
fstabgen -U /mnt >> /mnt/etc/fstab

# Localization
echo
figlet "Localization"
artools-chroot /mnt ln -sf /usr/share/zoneinfo/$local /etc/localtime
artools-chroot /mnt hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
artools-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf

# Hostname and Hosts configuration
echo $hostname > /mnt/etc/hostname
echo "127.0.0.1 localhost
::1 localhost
127.0.1.1 {hostname}.localdomain  {hostname}" > /mnt/etc/hosts

# Add user and set user + root passwords
artools-chroot /mnt useradd -mG wheel $username
echo "$username:$password" | chpasswd --root /mnt
echo "root:$password" | chpasswd --root /mnt
sed -i '1,/# %wheel.*/ s/# %wheel.*/%wheel ALL=(ALL) ALL/' /etc/sudoers

# grub + pacman downloads
echo
figlet "Other Downloads"
paclist=""
cat pacman_install.list | { while read line 
do
  paclist="$paclist $line"
done
pacinstall () { artools-chroot /mnt pacman -Syy; artools-chroot /mnt pacman -S --noconfirm $paclist; [ <(artools-chroot /mnt pacman -Qi grub) ] && pacinstall; }
pacinstall
}

# Install grub
echo
figlet "Installing grub"
artools-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/mnt --bootloader-id=GRUB
artools-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Copy another script and unmount partitions
echo
figlet "Some cleaning"
cp -t /mnt/home/${username} script2.sh post_install.sh
umount -R /mnt
echo
figlet "DONE!"
echo "Now reboot, login to your non-root user and run the following command 'sh scripts2.sh'"
