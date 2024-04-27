#!/bin/bash
clear

cat <<'END_ASCII'
    _             _       ___           _        _ _ 
   / \   _ __ ___| |__   |_ _|_ __  ___| |_ __ _| | |
  / _ \ | '__/ __| '_ \   | || '_ \/ __| __/ _` | | |
 / ___ \| | | (__| | | |  | || | | \__ \ || (_| | | |
/_/   \_\_|  \___|_| |_| |___|_| |_|___/\__\__,_|_|_|
                                                     
 ____            _       _   
/ ___|  ___ _ __(_)_ __ | |_ 
\___ \ / __| '__| | '_ \| __|
 ___) | (__| |  | | |_) | |_ 
|____/ \___|_|  |_| .__/ \__|
                  |_|        
END_ASCII

check_continue() {
  local message=$1

  echo "${message}"
  read -p "Are you sure you want to continue? (y/N): " continueCheck

  case $continueCheck in
    y)
      ;;
    *)
      echo "Aborting arch installation"
      exit 0
      ;;
  esac
}

############################################
#   ____ ___  _   _ _____ ___ ____ ____  
#  / ___/ _ \| \ | |  ___|_ _/ ___/ ___| 
# | |  | | | |  \| | |_   | | |  _\___ \ 
# | |__| |_| | |\  |  _|  | | |_| |___) |
#  \____\___/|_| \_|_|   |___\____|____/ 
############################################

EFI_PARTITION=/dev/sdb3
SWAP_PARTITION=/dev/sdb4
ROOT_PARTITION=/dev/sdb5

check_continue "This script installs a base arch system"

#################################################
#  _____ ___ __  __ _____ ________  _   _ _____
# |_   _|_ _|  \/  | ____|__  / _ \| \ | | ____|
#   | |  | || |\/| |  _|   / / | | |  \| |  _|
#   | |  | || |  | | |___ / /| |_| | |\  | |___
#   |_| |___|_|  |_|_____/____\___/|_| \_|_____|
#################################################

echo
echo "setting timezone"
timedatectl set-local-rtc 1
timedatectl set-timezone Europe/Berlin

##########################################################
#  ____   _    ____ _____ ___ _____ ___ ___  _   _ ____
# |  _ \ / \  |  _ \_   _|_ _|_   _|_ _/ _ \| \ | / ___|
# | |_) / _ \ | |_) || |  | |  | |  | | | | |  \| \___ \
# |  __/ ___ \|  _ < | |  | |  | |  | | |_| | |\  |___) |
# |_| /_/   \_\_| \_\|_| |___| |_| |___\___/|_| \_|____/
##########################################################

echo
echo "these are your current partitions:"
lsblk -o NAME,SIZE,TYPE,FSTYPE 2>/dev/null || echo "!!!! lsblk was not found.. !!!!"

echo
echo "echo make sure you have the following partitions setup like this:"
echo
cat << EOF | column -t
device size type
${EFI_PARTITION} 512M EFI
${SWAP_PARTITION} 16G SWAP
${ROOT_PARTITION} ~100G ROOT
EOF

echo
check_continue "listed partitions will be formated"
echo "FORMATING EFI PARTITION"
mkfs.fat -F 32 ${EFI_PARTITION}
echo "DONE"
echo "FORMATING SWAP PARTITION"
mkswap ${SWAP_PARTITION}
echo "DONE"
echo "FORMATING ROOT PARTITION"
mkfs.ext4 ${ROOT_PARTITION}
echo "DONE"

echo "here are your new partitions:"
echo
lsblk -o NAME,SIZE,TYPE,FSTYPE 2>/dev/null || echo "!!!! lsblk was not found.. !!!!"

############################################
#  ___ _   _ ____ _____  _    _     _
# |_ _| \ | / ___|_   _|/ \  | |   | |
#  | ||  \| \___ \ | | / _ \ | |   | |
#  | || |\  |___) || |/ ___ \| |___| |___
# |___|_| \_|____/ |_/_/   \_\_____|_____|
############################################

echo "Mounting filesystems to /mnt"
mount ${ROOT_PARTITION} /mnt
mount --mkdir ${EFI_PARTITION} /mnt/boot
swapon ${SWAP_PARTITION}

echo "Installing arch base system"
pacstrap -K /mnt base base-devel git linux linux-firmware vim openssh reflector intel-ucode

echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab
echo
echo "Here is the generated fstab"
cat /mnt/etc/fstab
echo
echo
check_continue "Does the fstab look alright?"


echo "arch-chroot to /mnt"
arch-chroot /mnt
