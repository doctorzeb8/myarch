prompt() {
    echo "Run $1?"
    select resp in "y" "n"; do
        case $resp in
            y ) $2; break;;
            n ) exit;;
        esac
    done
}


prompt 'blackhole' '
dd if=/dev/zero of=/dev/sda count=2048'

prompt 'space dividing' '
cfdisk
mkswap /dev/sda2
e2label /dev/sda1 boot
e2label /dev/sda5 root
e2label /dev/sda6 home'

prompt 'format partiotions' '
mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/sda5
mkfs.ext4 /dev/sda6'

swapon /dev/sda2
mount /dev/sda5 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/sda1 /mnt/boot
mount /dev/sda6 /mnt/home

cp -R /myarch /mnt/myarch
pacstrap /mnt base base-devel
genfstab -U -p /mnt >> /mnt/etc/fstab
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
