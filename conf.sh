#!/usr/bin/sh

### Usage: sh conf.sh [actions] [-i module,...]
###
###       -U            Update all git submodules
###       -u            List projects provided as git submodules
###       -m            Run all listed modules
###       -l            List available modules
###       -n            Avoid making changes and echo commands instead
###       -v            Be verbose
###       -a            Install all modules
###
### Examples:
###   Install the vim, tmux and ssh modules:
###     bash conf.sh -m "vim tmux ssh"
###
###   Update all git submodules and install vim and tmux configs:
###     bash conf.sh -Um "vim tmux"
###

# Why weird assignment? To ensure trickery isn't done via newlines in dirname.
# To do this we add a 'safety' char (X here) after the last newline then strip.

# Global variables for the script and it's modules {{{
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
# }}}

# Presentation functions {{{
# Are colors supported?
if command -v tput > /dev/null && tput setaf 1 > /dev/null; then
    # If colors are supported, define a wrapper which resets the terminal
    # and generally makes things not messy with escap sequences.
    # color <code> <text>
    color(){
        tput sgr 0
        tput setaf $1
        echo "$2"
        tput sgr 0
    }
else
    # If colors aren't supported, discard the color integer and just call echo
    color(){
        echo "$2"
    }
fi

# debug level verbosity
# debug <msg>
debug(){
  color 4 "D: $*"
}

# shorthand for stderr
# warn <msg>
warn(){
  color 3 " - [$*]" > /dev/fd/2
}

# log or informational messages
# log <msg>
log(){
  color 2 " + [$*]"
}

# Print a fatal error message and stop execution
# err <msg>
err(){
  color 1 " ! [$*]" > /dev/fd/2
  exit 127
}
# }}}

# Core functions {{{
# Run a command that must exhibit the verbose or dryrun behaviors
# rcmd <cmd [opts, ...]>
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

# List available modules based on their headers.
# The header for a module looks like:
#   ## <name>: description 
list_modules(){
    grep -h '^## ' $MODBASE/*.sh | cut -c 4-
}

# List packages provided by git submodules in this directory
list_git_submodules(){
  if command -v git > /dev/null; then
    echo 'Packages provided by git submodules:'
    for mod in $(git submodule status | awk '{ print $2;}'); do
      color 7 $(basename $mod)
      printf '\t'
      color 3 $mod
    done
  else
    err 'Git is required for submodule listings.'
  fi
}

# Run git and get that ...
update_submodules(){
  if command -v git > /dev/null; then
    rcmd git submodule init
    rcmd git submodule update --recursive
    rcmd git submodule foreach git pull origin master
  else
    err 'Git is required to fetch submodule updates.'
  fi
}

# Copy configs from SRCDIR/<source> to ~/.<dest>
# conf <src> <dst>
conf(){
  source="${SRCDIR}/${1}"
  dest="${HOME}/.${2}"
  if [ -d $source ]; then
    rcmd install -m 0700 -d -v ${dest}
    rcmd cp -avR ${source}/* ${dest}/
  else
    if [ -x $source  ]; then mode_arg='-m 0700';
    else mode_arg='-m 0600'; fi
    rcmd install ${mode_arg} -D ${source} ${dest}
  fi
}

# Run all loadable modules requested -- quoted and space-delimited
# run_modules '[module ...]'
run_modules(){
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
# }}}

## Handle command options (or absence thereof) {{{
# Print help and exit if there're no options given.
if [ -z $1 ]; then
  echo "${HELP}"
  err 'No arguments given.'
fi

while getopts "nvUuhlm:a" opt; do
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
    u)
      list_git_submodules
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
    m)
      run_modules "${OPTARG}"
      ;;
    a)
      modules=$(head -1 /home/maxp/code/conf.sh/modules/*.sh | grep '##' | sed 's/## //g; s/: .*$//g')
      run_modules $modules
      ;;
    *)
      err "Unrecognized option '${1}'. For help, run: 'sh ${0} -h'"
      ;;
  esac
done
# }}}
