#!/usr/bin/bash

### Usage: bash setup.sh [options] module,...
###
###       -U            Update all git submodules
###       -i            Install all listed modules
###       -l            List available modules

. config.sh

if [[ -z $1 ]]; then
  warn "${help}"
  exit 255
fi

while getopts ":Uhli:" opt; do
  case $opt in
    U)
      # ensure external sources are up-to-date
      update_submodules
      ;;
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
