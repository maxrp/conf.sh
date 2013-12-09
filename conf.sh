#!/usr/bin/sh

### Usage: sh conf.sh [actions] [-i module,...]
###
###       -U            Update all git submodules
###       -i            Install all listed modules
###       -l            List available modules
###       -n            Avoid making changes and echo commands instead
###
### Examples:
###   Install the vim, tmux and ssh modules:
###     bash conf.sh -i "vim tmux ssh"
###
###   Update all git submodules and install vim and tmux configs:
###     bash conf.sh -Ui "vim tmux"
###

# Why weird assignment? To ensure trickery isn't done via newlines in dirname.
# To do this we add a 'safety' char (X here) after the last newline then strip.

# This script's full path.
SELF=$(readlink -f "$0" ; echo X) ; SELF=${SELF%?}
# Base directory, where this script resides
BASEDIR=$(dirname $SELF ; echo X) ; BASEDIR=${BASEDIR%??} # strip \n and X

# Config directory
SRCDIR="${BASEDIR}/src"
# Modules directory
MODBASE="${BASEDIR}/modules"
# Extract help from this file.
HELP=$(grep "^###" "$0" | cut -c 5-)

# Are colors supported?
if [ -x /usr/bin/tput ] && /usr/bin/tput setaf 1 2>&1 > /dev/null; then
    color(){
        tput setaf $1
        echo "$2"
        tput sgr 0
    }
else
    color(){
        echo "$2"
    }
fi

# Shorthand for stderr
warn(){
  color 3 " - [$*]" > /dev/fd/2
}

log(){
  color 2 " + [$*]"
}

err(){
  color 1 " ! [$*]" > /dev/fd/2
  exit 127
}

debug(){
  color 4 "D:  $*"
}

rcmd(){
  if [ $DRYRUN ]; then
      debug "${@}"
  elif [ $VERBOSE ]; then
      debug "${@}"
      $@
  else
      $@
  fi
}

# The listing for a module looks like:
#   ## <name>: description 
list_modules(){
    rcmd grep -h '^## ' $MODBASE/*.sh | cut -c 4-
}

# Run git and get that ...
update_submodules(){
  rcmd git submodule init
  rcmd git submodule update --recursive
  rcmd git submodule foreach git pull origin master
}

config_install(){
  source="${SRCDIR}/${1}"
  dest="${HOME}/.${2}"
  if [ -d $source ]; then
    cmd='cp -R'
  else
    cmd='install -D -m 0600'
  fi
  rcmd $cmd $source $dest
}

install_modules(){
    for module in $@; do
      mod_path="${MODBASE}/${module}.sh"
      if [ -f $mod_path ]; then
        log "Running module: ${module}"
        . "${mod_path}"
      else
        warn "Module '${module}' doesn't exist."
      fi
    done
}

## Handle options {{{
# Print help and exit if there're no options given.
if [ -z $1 ]; then
  echo "${HELP}"
  err 'No arguments given.'
fi

while getopts "nvUhli:" opt; do
  case $opt in
    n)
      warn 'This will be a dry run and will only list the commands to be run.'
      DRYRUN=1
      ;;
    v)
      warn 'Verbosity enabled.'
      VERBOSE=1
      if [ $DRYRUN ]; then warn 'Dry run was enabled first making -v redundant.'; fi
      ;;
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
      install_modules "${OPTARG}"
      ;;
    *)
      err "Unrecognized option '${1}'. For help, run: 'sh ${0} -h'"
      ;;
  esac
done
# }}}
