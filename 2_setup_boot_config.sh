#!/bin/bash
clear

cd $(dirname $0)
source check_continue 
source config

cat <<EOF
 ____  _____ _____ _   _ ____    ____   ___   ___ _____ 
/ ___|| ____|_   _| | | |  _ \  | __ ) / _ \ / _ \_   _|
\___ \|  _|   | | | | | | |_) | |  _ \| | | | | | || |  
 ___) | |___  | | | |_| |  __/  | |_) | |_| | |_| || |  
|____/|_____| |_|  \___/|_|     |____/ \___/ \___/ |_|  
                                                        
  ____ ___  _   _ _____ ___ ____ 
 / ___/ _ \| \ | |  ___|_ _/ ___|
| |  | | | |  \| | |_   | | |  _ 
| |__| |_| | |\  |  _|  | | |_| |
 \____\___/|_| \_|_|   |___\____|
EOF

check_continue "This script sets up the bootloader with secure boot and dualboot to windows + an ssh server"

#################################################
#  _____ ___ __  __ _____ ________  _   _ _____
# |_   _|_ _|  \/  | ____|__  / _ \| \ | | ____|
#   | |  | || |\/| |  _|   / / | | |  \| |  _|
#   | |  | || |  | | |___ / /| |_| | |\  | |___
#   |_| |___|_|  |_|_____/____\___/|_| \_|_____|
#################################################

echo "setting correct timezone"
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

########################################################################
#  _     ___   ____    _    _     ___ _____   _  _____ ___ ___  _   _ 
# | |   / _ \ / ___|  / \  | |   |_ _|__  /  / \|_   _|_ _/ _ \| \ | |
# | |  | | | | |     / _ \ | |    | |  / /  / _ \ | |  | | | | |  \| |
# | |__| |_| | |___ / ___ \| |___ | | / /_ / ___ \| |  | | |_| | |\  |
# |_____\___/ \____/_/   \_\_____|___/____/_/   \_\_| |___\___/|_| \_|
########################################################################

echo "generating localization"

sed -i -e "s/#${fullLocale}/${fullLocale}/" /etc/locale.gen
locale-gen                                                                    
echo "LANG=${chosenLocale}" > /etc/locale.conf
echo "KEYMAP=${keymap}" > /etc/vconsole.conf

####################################################
#  _   _ _____ _______        _____  ____  _  __
# | \ | | ____|_   _\ \      / / _ \|  _ \| |/ /
# |  \| |  _|   | |  \ \ /\ / / | | | |_) | ' / 
# | |\  | |___  | |   \ V  V /| |_| |  _ <| . \ 
# |_| \_|_____| |_|    \_/\_/  \___/|_| \_\_|\_\
####################################################

echo "network configuration"

pacman -S --noconfirm networkmanager

echo $hostName >> /etc/hostname
                                              
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost ip6-localhost ip6-loopback
127.0.0.1   ${hostName}.localdomain ${hostName}
EOF

systemctl enable NetworkManager
systemctl enable sshd

##################################################################
#  _   _ ____  _____ ____        ____ ___  _   _ _____ ___ ____ 
# | | | / ___|| ____|  _ \      / ___/ _ \| \ | |  ___|_ _/ ___|
# | | | \___ \|  _| | |_) |____| |  | | | |  \| | |_   | | |  _ 
# | |_| |___) | |___|  _ <_____| |__| |_| | |\  |  _|  | | |_| |
#  \___/|____/|_____|_| \_\     \____\___/|_| \_|_|   |___\____|
##################################################################

# echo "set root password"
# passwd
#
# echo "allowing wheel group to use sudo"
# sed -i -e 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
#
# check_continue "setting up local user ${archUsername}"
# useradd -m -G wheel ${archUsername}
# echo "setting password for user ${archUsername}"
# passwd ${archUsername}

##########################################################################
#  ____   ___   ___ _____ __  __    _    _   _    _    ____ _____ ____  
# | __ ) / _ \ / _ \_   _|  \/  |  / \  | \ | |  / \  / ___| ____|  _ \ 
# |  _ \| | | | | | || | | |\/| | / _ \ |  \| | / _ \| |  _|  _| | |_) |
# | |_) | |_| | |_| || | | |  | |/ ___ \| |\  |/ ___ \ |_| | |___|  _ < 
# |____/ \___/ \___/ |_| |_|  |_/_/   \_\_| \_/_/   \_\____|_____|_| \_\
##########################################################################

echo "setting up the bootloader"
bootctl install

pacman -S --noconfirm edk2-shell

systemctl enable systemd-boot-update.service
root_uuid=$(blkid -o value -s UUID ${ROOT_PARTITION})
 
mkdir -p /boot/EFI/Shell
cp /usr/share/edk2-shell/x64/Shell.efi /boot/EFI/Shell/shellx64.efi

echo "${efi_boot_id}:EFI\Boot\bootx64.efi" > /boot/windows.nsh

cat <<EOF > /boot/loader/loader.conf
default       69-arch.conf
timeout       4
console-mode  max
editor        no
EOF

cat <<EOF > /boot/loader/entries/89-windows.conf
title     Windows
efi       /EFI/Shell/shellx64.efi
options   -nointerrupt -noconsolein -noconsoleout windows.nsh
EOF

cat <<EOF > /boot/loader/entries/69-arch.conf
title     Arch Linux
linux     /vmlinuz-linux
initrd    /initramfs-linux.img
options   root=UUID=${root_uuid} rw
EOF

cat <<EOF > /boot/loader/entries/65-arch-fallback.conf
title     Arch Linux (fallback initramfs)
linux     /vmlinuz-linux
initrd    /initramfs-linux-fallback.img
options   root=UUID=${root_uuid} rw
EOF

cat <<EOF > /boot/loader/entries/49-shell.conf
title     Shell
efi       /EFI/Shell/shellx64.efi
EOF
