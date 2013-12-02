#!/usr/bin/bash

### Usage: bash conf.sh [actions] [-i module,...]
###
###       -U            Update all git submodules
###       -i            Install all listed modules
###       -l            List available modules
###       -n            Avoid making changes and echo commands instead
###
### Examples:
###   Install the vim, tmux and ssh modules:
###     bash conf.sh -i vim,tmux,ssh
###
###   Update all git submodules and install vim and tmux configs:
###     bash conf.sh -Ui vim,tmux
###

# This script's full path.
SELF=$(readlink -f "$0")
# Base directory, where this script resides
BASEDIR=$(dirname $SELF)
# Config directory
SRCDIR="${BASEDIR}/src"
# Modules directory
MODBASE="${BASEDIR}/modules"
# Extract help from this file.
HELP=$(grep "^###" "$0" | cut -c 5-)

# Shorthand for stderr
warn(){
  echo "$*" > /dev/fd/2
}

# The listing for a module looks like:
#   ## <name>: description 
list_modules(){
    grep -h '^## ' $MODBASE/*.sh | cut -c 4-
}

# Run git and get that ...
update_submodules(){
  cmd='git submodule'
  if [ $DRYRUN ]; then
    cmd="echo ${cmd}"
  fi
  $cmd init
  $cmd update --recursive
  $cmd foreach git pull origin master
}

config_install(){
  source="${SRCDIR}/${1}"
  dest="${HOME}/.${2}"
  if [ -d $source ]; then
    cmd='cp -R'
  else
    cmd='install -D -m 0600'
  fi
  if [[ $DRYRUN ]]; then
    cmd="echo ${cmd}"
  fi
  $cmd $source $dest
}

install_modules(){
    IFS=',' read -a modules <<<$1
    for module in ${modules[@]}; do
      mod_path="${MODBASE}/${module}.sh"
      if [ -f $mod_path ]; then
        echo " + Running module: ${module}"
        . "${mod_path}"
      else
        warn " - Module '${module}' doesn't exist."
      fi
    done
}

## Handle options {{{
# Print help and exit if there're no options given.
if [ -z $1 ]; then
  warn "${HELP}"
  exit 255
fi

while getopts "Uhlni:" opt; do
  case $opt in
    U)
      # ensure external sources are up-to-date
      update_submodules
      ;;
    h)
      echo "${HELP}"
      ;;
    l)
      # list the available modules
      list_modules
      ;;
    n)
      warn "DRYRUN!!!"
      DRYRUN=1
      ;;
    i)
      if [ -z "${OPTARG}" ]; then
          warn 'A single option or quoted space-separated list of arguments is required.'
          exit 255
      fi
      install_modules $OPTARG
      ;;
    *)
      warn "${HELP}"
      exit 255
      ;;
  esac
done
# }}}
