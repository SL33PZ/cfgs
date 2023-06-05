#!/bin/bash
#shellcheck source=.env
#shellcheck disable=SC1091
set -x
source .env

old_mountpoint="$/mnt/*"

log "Create Systemd Machine ID"
init_packages=('base' 'dosfstools' 'openssl' 'parted' 'micro' 'nano' 'base-devel')
packages_root=(
'base' 'base-devel' 'linux' 'linux-firmware' 'linux-headers' 'mesa' 'ruby' 'networkmanager' 'network-manager-applet' 'xorg' 'xorg-xinit' 'xorg-server' 
'grub' 'efibootmgr' 'dosfstools' 'mtools' 'os-prober' 'sof-firmware' 'alsa-utils' 'alsa-plugins' 'alsa-firmware' 'intel-ucode' 
'intel-media-driver' 'vulkan-intel' 'xf86-video-intel' 'plasma' 'plasma-wayland-session' 'pulseaudio' 'pacutils' 'pacman-contrib'
'bash' 'zsh' 'bash-completion' 'sddm' 'kitty' 'iw' 'iwd' 'nano' 'micro' 'wget' 'curl' 'git' 'axel' 'lftp' 'aria2' 'python-pip' 'dolphin'
'python-poetry' 'python-numpy' 'python-virtualenv' 'geany' 'geany-plugins' 'bleachbit' 'unzip' 'zip' 'unrar' 'p7zip' 'lz4' 'gtk3' 'cairo'
'gtk4' 'gtkmm' 'cmake' 'extra-cmake-modules' 'neofetch' 'lolcat' 'iproute2' 'net-tools' 'iproute' 'npm' 'nodejs' 'gparted' 'parted' 'go')

rm -rf "$old_mountpoint"
systemd-machine-id-setup 
pacman-key --init
pacman-key --populate  
pacman -Syu --needed --noconfirm "${init_packages[@]}"

wipefs -a -f "/dev/$ROOT_PARTITION"  
mkfs.ext4 "/dev/$ROOT_PARTITION" 
mount "/dev/$ROOT_PARTITION" /mnt 

pacstrap -K /mnt "${packages_root[@]}"

genfstab -U /mnt >> /mnt/etc/fstab
cp -v .env /mnt/tmp/.env
cp -v chroot.sh /mnt

arch-chroot /mnt /usr/bin/bash chroot.sh
wait


#printf '%s\n' 'echo "Welcome to Arch Linux"' >> /etc/profile

#bash --login



