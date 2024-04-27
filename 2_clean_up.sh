#!/bin/bash

clear

cd $(dirname $0)
source check_continue 
source config 

#######################################################################
#   ____ _     _____    _    _   _   _   _ ____  
#  / ___| |   | ____|  / \  | \ | | | | | |  _ \ 
# | |   | |   |  _|   / _ \ |  \| | | | | | |_) |
# | |___| |___| |___ / ___ \| |\  | | |_| |  __/ 
#  \____|_____|_____/_/   \_\_| \_|  \___/|_|    
#                                                
#  ___ _   _ ____ _____  _    _     _        _  _____ ___ ___  _   _ 
# |_ _| \ | / ___|_   _|/ \  | |   | |      / \|_   _|_ _/ _ \| \ | |
#  | ||  \| \___ \ | | / _ \ | |   | |     / _ \ | |  | | | | |  \| |
#  | || |\  |___) || |/ ___ \| |___| |___ / ___ \| |  | | |_| | |\  |
# |___|_| \_|____/ |_/_/   \_\_____|_____/_/   \_\_| |___\___/|_| \_|
#######################################################################

check_continue "Cleaning up install scripts and reboot to BIOS"

rm /mnt/2_setup_boot_config.sh
rm /mnt/config
rm /mnt/check_continue

echo "adjusting file permission"
sed -i -e "s/fmask=\([[:digit:]]\)\{4\},dmask=\([[:digit:]]\)\{4\}/fmask=0077,dmask=0077/" /mnt/etc/fstab

echo "Here is the final fstab"
cat /mnt/etc/fstab
echo
echo
check_continue "Does the fstab look alright?"

umount -R /mnt
systemctl reboot --firmware-setup
