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
  local message=$0

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

# echo "This script installs a base arch system"
# read -p "Are you sure you want to continue? (y/N): " continueArchInstall

check_continue "This script installs a base arch system"

echo ""
echo "these are your current partitions:"
lsblk 2>/dev/null || echo "!!!! lsblk was not found.. !!!!"

echo "echo make sure you have the following partitions setup like this:"
cat << EOF | column -t
device size type
sdb/sdb3 512M EFI
sdb/sdb4 16G SWAP
sdb/sdb5 ~100G ROOT
EOF
