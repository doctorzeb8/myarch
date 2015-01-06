source /myarch/config/variables

pacset() {
    pacman -S $1 --noconfirm
}

#- pacman -#
cp /myarch/config/mirrorlist /etc/pacman.d/mirrorlist
pacman -Syu haveged --noconfirm
systemctl start haveged
systemctl enable haveged
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux
sed -i '$ a \\n[multilib]\nInclude = /etc/pacman.d/mirrorlist' /etc/pacman.conf
sed -i '$ a \\n[archlinuxfr]\nServer = http://repo.archlinux.fr/$arch\nSigLevel = Never' /etc/pacman.conf
pacman -Syyu yaourt --noconfirm

#- host -#
echo $HOSTNAME > /etc/hostname
sed -i "s/localhost.localdomain/$HOSTNAME/g" /etc/hosts

#- locale -#
sed -i 's/#en_US/en_US/' /etc/locale.gen
sed -i 's/#ru_RU/ru_RU/' /etc/locale.gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
locale-gen

#- time -#
ln -s /usr/share/zoneinfo/Asia/Irkutsk /etc/localtime
pacset ntp
systemctl enable ntpd.service

#- grub -#
pacset grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

#- user -#
pacset openssh
useradd -m -s /bin/bash $USERNAME
sed -i "s/$USERNAME:[^:]*:/$USERNAME::/" /etc/shadow
su $USERNAME -c 'cat /dev/zero | ssh-keygen -t rsa -N ""'
username=$USERNAME nopasswd=/usr/bin/systemctl,/usr/bin/pacman,/usr/bin/netctl /myarch/scripts/myvisudo.sh
cp /myarch/config/bashrc /root/.bashrc
cp /myarch/config/bashrc /home/$USERNAME/.bashrc
sed -i '$ a alsi' /home/$USERNAME/.bashrc

#- xorg -#
pacset xorg-server xorg-server-utils xorg-xinit xorg-xprop

#- net -#
if [ $HOSTNAME == 'arch-laptop' ]
then
    pacset wireless_tools wpa_supplicant wpa_actiond dialog xf86-input-synaptics
    systemctl enable netctl-auto@wlan0.service
else
    systemctl enable dhcpcd.service
fi

#- utils -#
pacset git alsi gvfs polkit-gnome ntfs-3g p7zip unrar
pacset ttf-droid ttf-liberation ttf-dejavu ttf-ubuntu-font-family

#- video -#
pacset xf86-video-ati

#- sound -#
pacset alsa-utils alsa-plugins

#- xfce -#
pacset wget slim xfce4 xfce4-xkb-plugin file-roller
cp /etc/skel/.xinitrc /home/$USERNAME/.xinitrc
sed -i 's/# exec startxfce4/exec startxfce4/' /home/$USERNAME/.xinitrc
systemctl enable slim.service
sed -i "$ a default_user $USERNAME" /etc/slim.conf
sed -i "$ a auto_login yes" /etc/slim.conf

#- packages -#
su $USERNAME -c 'yaourt -S
google-chrome
sublime-text-dev
skype
python2-virtualev
--noconfirm'

#- git -#
git config --global user.email $user_email
git config --global user.name $user_fullname
git config --global push.default simple

#- finish -#
passwd
exit
