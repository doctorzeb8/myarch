cfdisk

mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/sda5
mkfs.ext4 /dev/sda6

e2label /dev/sda1 boot
e2label /dev/sda2 swap
e2label /dev/sda5 root
e2label /dev/sda6 home

mkswap /dev/sda2
swapon /dev/sda2

mount /dev/sda5 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/sda1 /mnt/boot
mount /dev/sda6 /mnt/home

cp -R /myarch /mnt/myarch
pacstrap /mnt base base-devel
genfstab -L -p /mnt >> /mnt/etc/fstab
sed -i 's/,data=ordered//' /mnt/etc/fstab

mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /etc/resolv.conf /mnt/etc/resolv.conf
chroot /mnt /bin/bash -c "su - -c /myarch/scripts/setup.sh"

rm -rf /mnt/myarch
umount /mnt/boot
umount /mnt/home
umount /mnt
swapoff /dev/sda2
reboot
