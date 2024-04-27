#!/bin/bash

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

echo
echo "setting timezone"
timedatectl set-local-rtc 1
timedatectl set-timezone Europe/Berlin

echo
echo "these are your current partitions:"
lsblk 2>/dev/null || echo "!!!! lsblk was not found.. !!!!"

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
