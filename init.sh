#!/bin/bash
#shellcheck source=.env
#shellcheck disable=SC1091
set -x
source .envextra

old_mountpoint="$/mnt/*"
chroot="$(wget https://raw.githubusercontent.com/SL33PZ/cfgs/main/chroot.sh -O -)"

function err_log () {
  if [ "$?" != 0 ]; then
    2&>>log.txt; exit 1
  fi
}

init_packages=('base' 'dosfstools' 'openssl' 'parted' 'micro' 'nano' 'base-devel')
packages_root=(
'base' 'base-devel' 'linux' 'linux-firmware' 'linux-headers' 'mesa' 'ruby' 'networkmanager' 'network-manager-applet' 'xorg' 'xorg-xinit' 'xorg-server' 
'grub' 'efibootmgr' 'dosfstools' 'mtools' 'os-prober' 'sof-firmware' 'alsa-utils' 'alsa-plugins' 'alsa-firmware' 'intel-ucode' 
'intel-media-driver' 'vulkan-intel' 'xf86-video-intel' 'plasma' 'plasma-wayland-session' 'pulseaudio' 'pacutils' 'pacman-contrib'
'bash' 'zsh' 'bash-completion' 'sddm' 'kitty' 'iw' 'iwd' 'nano' 'micro' 'wget' 'curl' 'git' 'axel' 'lftp' 'aria2' 'python-pip' 'dolphin'
'python-poetry' 'python-numpy' 'python-virtualenv' 'geany' 'geany-plugins' 'bleachbit' 'unzip' 'zip' 'unrar' 'p7zip' 'lz4' 'gtk3' 'cairo'
'gtk4' 'gtkmm' 'cmake' 'extra-cmake-modules' 'neofetch' 'lolcat' 'iproute2' 'net-tools' 'iproute' 'npm' 'nodejs' 'gparted' 'parted' 'go')

rm -rf "$old_mountpoint" || err_log
systemd-machine-id-setup || err_log
pacman-key --init || err_log
pacman-key --populate   || err_log
pacman -Syu --needed --noconfirm "${init_packages[@]}" || err_log

wipefs -a -f "/dev/$ROOT_PARTITION" || err_log
mkfs.ext4 "/dev/$ROOT_PARTITION" || err_log
mount "/dev/$ROOT_PARTITION" /mnt || err_log

pacstrap -K /mnt "${packages_root[@]}" || err_log

genfstab -U /mnt >> /mnt/etc/fstab || err_log
cp -v /.env /mnt/tmp/.env || err_log


arch-chroot /mnt /usr/bin/bash -c "$chroot" || err_log
wait


printf '%s\n' 'echo "Welcome to Arch Linux"' >> /etc/profile || err_log

bash --login || err_log



