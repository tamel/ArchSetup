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
