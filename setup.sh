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

# Config directory
SRCDIR=$(readlink -f ${PWD}/src)
# Modules directory
MODBASE=$(readlink -f ${PWD}/modules)
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
  git submodule init
  git submodule update --recursive
  git submodule foreach git pull origin master
}

config_install(){
  source="${SRCDIR}/${1}"
  dest="${HOME}/.${2}"
  if [ -d $source ]; then
    cmd='cp -R'
  else
    cmd='install -D -m 0600'
  fi
  $cmd $source $dest
}

install_modules(){
    if [[ -z $1 ]]; then
        warn 'A comma-separated list of arguments is required.'
    else
        IFS=',' read -a MODULES <<<$1
        echo "Installing the modules: ${MODULES[@]}"
    fi

    for module in ${MODULES[@]}; do
      mod_path="${MODBASE}/${module}.sh"
      if [[ -f $mod_path ]]; then
        echo " + Running module: ${module}"
        . "${mod_path}"
      else
        warn " - Module '${module}' doesn't exist."
      fi
    done
}

## Handle options {{{
# Print help and exit if there're no options given.
if [[ -z $1 ]]; then
  warn "${HELP}"
  exit 255
fi

while getopts "Uhli:" opt; do
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
    i)
      install_modules $OPTARG
      ;;
    *)
      warn "${HELP}"
      exit 255
      ;;
  esac
done
# }}}
