#!/usr/bin/bash

### Usage: bash setup.sh [actions] [-i module,...]
###
###       -U            Update all git submodules
###       -i            Install all listed modules
###       -l            List available modules
###
### Examples:
###   Install the vim, tmux and ssh modules:
###     bash setup.sh -i vim,tmux,ssh
###
###   Update all git submodules and install vim and tmux configs:
###     bash setup.sh -Ui vim,tmux
###

# Extract help from this file.
help=$(grep "^###" "$0" | cut -c 5-)

# Source the functions to call later.
. config.sh

# Print help and exit if there're no options given.
if [[ -z $1 ]]; then
  warn "${help}"
  exit 255
fi

while getopts "Uhli:" opt; do
  case $opt in
    U)
      # ensure external sources are up-to-date
      update_submodules
      ;;
    h)
      echo "${help}"
      ;;
    l)
      # list the available modules
      list_modules
      ;;
    i)
      install_modules $OPTARG
      ;;
    *)
      warn "${help}"
      exit 255
      ;;
  esac
done
