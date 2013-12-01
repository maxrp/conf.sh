#!/usr/bin/bash

### Usage: bash setup.sh [options] module,...
###
###       -i            Install all listed modules
###       -l            List available modules

help=$(grep "^### " "$0" | cut -c 5-)

. ./lib/config.sh

while getopts ":hli:" opt; do
  case $opt in
    h)
      echo "${help}"
      ;;
    i)
      
      install_modules $OPTARG
      ;;
    \?)
      warn "Invalid option: -${OPTARG}"
      warn "${help}"
      ;;
     *)
      warn "${help}"
      ;;
  esac
done

# ensure external sources are up-to-date
update_submodules > /dev/null

