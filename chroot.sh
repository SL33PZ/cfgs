#!/bin/bash

set -x
#shellcheck disable=SC1091
#shellcheck disable=SC2181
#shellcheck source=/tmp/.env
source /tmp/.env
# ---------------------------------------------------------------------------
plasmoids=(
  'org.communia.apptitle' 'org.kde.latte.sidebarbutton' 'org.kde.latte.spacer' 
  'org.kde.netspeedWidget' 'org.kde.plasma.betterinlineclock' 'org.kde.plasma.mediacontroller_plus' 
  'org.kde.plasma.panon' 'org.kde.plasma.simplemenu' 'org.kde.plasma.virtualdesktopbar' 'org.kde.windowbuttons'
)

sed_sudo=(
's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' 
's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/'
's/^# %sudo ALL=(ALL:ALL) ALL/%sudo ALL=(ALL:ALL) ALL/')

xorg_conf=('00-keyboard.conf' '20-intel.conf' '30-touchpad.conf')

root_conf=('locale.conf' 'nanorc' 'pacman.conf' 'timezone' 'vconsole.conf')

vmware_conf=('vmware.service' 'vmware-usbarbitrator.service' 'vmware-networks-server.service')

user_conf=('kitty' 'klassyrc' 'krunnerrc' 'ksplashrc' 'ktimezonerc' 'systemsettings.conf' 'user-dir.dirs' 'user-dir.locale')

rc=('zshrc' "bashrc" "bashrc.backup")

ohmyzsh=('ohmyzsh')

burnmywindows=('burn_my_windows_kwin4')

etc="/etc"
tmp="/tmp"
skel="$etc/skel"
skel_stng="$skel/settings"
tmp_a="/tmp/archives"
kwin="/usr/share/kwin/effects"
sddm="/usr/share/sddm/themes"
plsmd="/usr/share/plasma/plasmoids"
xorg="$etc/X11/xorg.conf.d"
vmware="$etc/systemd/system"
sddm="/usr/share/sddm/themes"
efi="/boot/efi"

trap signal_exit "TERM" TERM HUP
trap signal_exit "INT"  INT

mkdir -p "$efi"
mount "/dev/$EFI_PARTITION" "$efi" || error_exit

grub-install --bootloader-id=BlackNet 
sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null
mkdir -p /var/lock/dmraid
grub-mkconfig -o /boot/grub/mnt/*/grub.cfg || error_exit

sed -i "s/^#$LANGUAGE/$LANGUAGE/m" "$etc/locale.gen"
echo "Modifying Locale Generation"
locale-gen 

useradd -m -p "$UPASSWD" "$USERNAME"
usermod -aG wheel "$USERNAME"


#{
#  echo "auth  [success=ignore default=1] pam_succeed_if.so user = $USERNAME"
#  echo "auth  sufficient                 pam_succeed_if.so use_uid user = root"
#} >> /etc/pam.d/su

for s in "${sed_sudo[@]}"; do
  sed -i "${s}" "$etc/sudoers"
done

git clone https://aur.archlinux.org/yay.git "$tmp/yay" && 
su -c "cd "$tmp/yay" && makepkg -sri --noconfirm --needed && cd /" "$USERNAME"

echo -e "$UPASSWD\n$UPASSWD\n" | passwd "$USERNAME"
echo -e "$RPASSWD\n$RPASSWD\n" | passwd

mkdir -p "$skel_stng"
mkdir -p "$tmp_a"
mkdir -p "$kwin"
mkdir -p "$sddm"
mkdir -p "$plsmd"

rm -rf "$skel/.bashrc"

for u in "${user_conf[@]}"; do
  wget "https://raw.githubusercontent.com/SL33PZ/cfgs/main/settings/$u" -O "$skel_stng/$u"
done

for x in "${xorg_conf[@]}"; do
  wget "https://raw.githubusercontent.com/SL33PZ/cfgs/main/settings/$x" -O "$xorg/$x"
done

for r in "${root_conf[@]}"; do
  wget "https://raw.githubusercontent.com/SL33PZ/cfgs/main/settings/$r" -O "$etc/$r"
done

for v in "${vmware_conf[@]}"; do
  wget "https://raw.githubusercontent.com/SL33PZ/cfgs/main/settings/$v" -O "$vmware/$v"
done

for rc in "${rc[@]}"; do
  wget "https://raw.githubusercontent.com/SL33PZ/cfgs/main/settings/$rc" -O "$skel/.$rc"
done

for o in "${ohmyzsh[@]}"; do
  wget "https://github.com/SL33PZ/cfgs/raw/main/archives/$o.tar.gz" -O "$tmp/$o.tar.gz"
done

for b in "${burnmywindows[@]}"; do
  wget "https://github.com/SL33PZ/cfgs/raw/main/archives/$b.tar.gz" -O "$tmp/$b.tar.gz"
done

for p in "${plasmoids[@]}"; do
  wget "https://github.com/SL33PZ/cfgs/raw/main/archives/$p.tar.gz" -O "$tmp/$p.tar.gz"
done

cd "$tmp" || exit

for o in "${ohmyzsh[@]}"; do
  tar -xzfv "$o.tar.gz" -C "$skel"
done

for b in "${burnmywindows[@]}"; do
  tar -xzfv "$b.tar.gz" -C "$kwin" 
done

for p in "${plasmoids[@]}"; do
  tar -xzfv "$p.tar.gz" -C "$plsmd"
done


su -c "/usr/bin/wget https://repo.anaconda.com/miniconda/Miniconda3-py39_23.3.1-0-Linux-x86_64.sh -O $tmp/miniconda.sh && /usr/bin/chmod +x $tmp/miniconda.sh && /usr/bin/bash $tmp/miniconda.sh -b -p /home/$USERNAME/.miniconda" "$USERNAME"

git clone https://github.com/SL33PZ/Panda "$sddm/Panda"

systemctl enable NetworkManager.service  

systemctl enable sddm.service 

mkinitcpio -P

