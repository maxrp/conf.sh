#!/bin/sh
##### conf.sh: configuration set up targeting POSIX-like shells.
###
### [![Build Status](https://api.travis-ci.org/maxrp/conf.sh.svg)](https://travis-ci.org/maxrp/conf.sh)
###### What?
### For a long time I used puppet to manage my dotfiles. Then for a while I 
### used Ansible. But man, those are some heavyweight approaches. And (back then, at
### least) cross-platform support was iffy or inconsistent.
### 
### So I wrote this. It's intended to work anywhere you have have a POSIX shell,
### and to work really well anywhere you have a POSIX shell and git.
###
###### Requirements
### Older systems may only provide `command -v` as part of User Portability
### Utilities as it was flagged in [The Open Group Base Specifications Issue 6/
### POSIX.1-2004][1], by [The Open Group Base Specifications Issue 7/POSIX.1-2008][2]
### it was standard. Some versions of `checkbashisms` will complain about this,
### however we check for this extension early on in the script.
###
###### Usage
### ```
###~Usage: sh conf.sh [-Uvulands] [-i "module module ..."]
###~
###~      -U            Update all git submodules
###~      -u            List projects provided as git submodules
###~      -i            Install all listed modules
###~      -l            List available modules
###~      -n            Avoid making changes and echo commands instead
###~      -v            Be verbose
###~      -s            Sync all live configs to their repository origin
###~      -a            Install all modules
###~      -nv           Be verbose, don't change anything and show diffs
###~      -d            Extract documentation from this script
###~
###~Examples:
###~  Install the vim, tmux and ssh modules:
###~    ./conf.sh -i "vim tmux ssh"
###~
###~  Update all git submodules and install vim and tmux configs:
###~    ./conf.sh -Ui "vim tmux"
###~
###~  Discover what has changed between a local config and the repository copy:
###~    ./conf.sh -snvi "tmux ssh zsh"
###~
###~  Synchronize the files in the repository with the live configs:
###~    ./conf.sh -s "tmux ssh zsh"
### ```
### 
###### Tested Shells
###
### * **bash** (and POSIX compliant mode) 4.3.39(1)-release
### * **BusyBox** v1.23.2
### * **dash** 0.5.8.2
### * **ksh** ABIJM 93v-
### * **mksh** @(#)MIRBSD R50
### * **pdksh** @(#)PD v5.2.14
### * **yash** 2.37
### 
###### TODO
###  - Encryption of certain configs
###  - Automatically set up config submodule repository
###  - Automatically construct a "configs" directory hierarchy
###  - Optional self-installation to $PREFIX
###  - Roll up self and configs into a single archive for easy transport
###  - Testing with: ash, zsh
###  - More unit testing
###
### [1]: http://pubs.opengroup.org/onlinepubs/009695399/utilities/command.html "man page for `command`, IEEE Std 1003.1, 2004 Edition"
### [2]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/command.html "man page for `command`, IEEE Std 1003.1, 2013 Edition"
### 

POSIX_VERSION="$(getconf _POSIX_VERSION)"
# Prior to POSIX 2008 command's -v flag is only provided in the User
# Portability Utilities extension (POSIX2_UPE)
if [ "${POSIX_VERSION}" -lt 200800 ]; then
    if [ "$(getconf POSIX2_UPE)" = "undefined" ]; then
        exit 127;
    fi
fi;


# Presentation functions {{{
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

# Generate markdown README and run shell integration tests
gendoc(){
    grep "^###" "${SELF}" | cut -c 5-
}

# If args are longer than `tput lines`, use $PAGER
# _pager <content>
_pager(){
    txt_len=$(echo "${1}" | wc -l | cut -f1 -d' ')
    if [ $txt_len -gt "$(tput lines)" ]; then
        echo "${1}" | $PAGER
    else
        echo "${1}"
    fi;
}

# Diff, and colordiff if available, paging if needed
# _diff <dest> <source>
_diff(){
    log "Showing difference between [${1}] and [${2}]"
    diff_contents=$(diff -Nur "${1}" "${2}")
    _pager "${diff_contents}"
}
# }}}

# Core functions {{{
# Run a command that must exhibit the verbose or dryrun behaviors
# rcmd <cmd [opts, ...]>
rcmd(){
  if [ "$DRYRUN" ]; then
      debug "${@}"
  elif [ "$VERBOSE" ]; then
      debug "${@}"
      "$@"
  else
      "$@"
  fi
}

# List available modules based on their headers.
# The header for a module looks like:
#   ## <name>: description 
list_modules(){
    grep -h '^## ' "$MODBASE"/*.sh | cut -c 4-
}

# List packages provided by git submodules in this directory
list_git_submodules(){
  if command -v git > /dev/null; then
    echo 'Packages provided by git submodules:'
    for mod in $(git submodule status --recursive | awk '{ print $2;}'); do
      color 7 "$(basename "$mod")"
      printf '\t'
      color 3 "$mod"
    done
  else
    err 'Git is required for submodule listings.'
  fi
}

# Run git and get that ...
update_submodules(){
  if command -v git > /dev/null; then
    rcmd git -C "${BASEDIR}/src" submodule init
    rcmd git -C "${BASEDIR}/src" submodule update --recursive
    rcmd git submodule foreach --recursive git pull origin master
  else
    err 'Git is required to fetch submodule updates.'
  fi
}

# TODO: update docs here
# Alternatively, when SYNC is set, sync ~/.<dest> to SRCDIR/<source>
# conf <dst>
conf(){
  source_name=$(basename "${1}")
  if [ "$SYNC" ]; then
    source="${1}"
    dest="${SRCDIR}"/"${source_name}"
  else
    source="${SRCDIR}"/"${source_name}"
    dest="${1}"
  fi

  if [ "$VERBOSE" ]; then
    _diff "${dest}" "${source}";
  fi

  if [ -d "$source" ]; then
    rcmd install -m 0700 -d -v "${dest}"
    rcmd cp -avR "${source}"/* "${dest}"/
  elif [ -e "$source" ]; then
    if [ -x "$source"  ]; then mode_arg='-m 0700';
    else mode_arg='-m 0600'; fi
    rcmd install ${mode_arg} -D "${source}" "${dest}"
  else
    debug "${source} doesn't exist and was skipped."
  fi
}

# Run all loadable modules requested -- quoted and space-delimited
# run_modules '[module ...]'
run_modules(){
    for module in $@; do
      mod_path="${MODBASE}/${module}.sh"
      if [ -f "$mod_path" ]; then
        log "Running module: ${module}"
        . "${mod_path}"
      else
        warn "Module '${module}' doesn't exist."
      fi
    done
}
# }}}

main(){
    # Global variables for the script and it's modules {{{
    # Why weird assignment? To ensure trickery isn't done via newlines in dirname.
    # To do this we add a 'safety' char (X here) after the last newline then strip.

    # This script's full path.
    SELF=$(readlink -f "$0" ; echo X) ; SELF=${SELF%??}
    # Base directory, where this script resides
    BASEDIR=$(dirname "$SELF" ; echo X) ; BASEDIR=${BASEDIR%??} # strip \n and X
    # Config directory
    SRCDIR="${BASEDIR}/src"
    # Modules directory
    MODBASE="${BASEDIR}/modules"
    # Extract help from this file.
    HELP=$(grep "^###~" "${SELF}" | cut -c 5-)
    # }}}

    # Print help and exit if there're no options given, otherwise handle options {{{
    if [ -z "$1" ]; then
      echo "${HELP}"
      err 'No arguments given.'
    fi

    while getopts "nvUuhli:ads" opt; do
      case $opt in
        n)
          warn 'This will be a dry run and will only list the commands to be run.'
          DRYRUN=1
          if [ "$VERBOSE" ]; then log 'Verbosity + dry run was enabled; showing diffs.'; fi
          ;;
        v)
          warn 'Verbosity enabled.'
          VERBOSE=1
          if [ "$DRYRUN" ]; then log 'Dry run + verbosity was enabled; showing diffs.'; fi
          ;;
        s)
          warn 'Copying live configs to repository.'
          SYNC=1
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
        i)
          run_modules "${OPTARG}"
          ;;
        a)
          run_modules "$(list_modules | cut -f1 -d':' | tr '\n' ' ')"
          ;;
        d)
          gendoc
          ;;
        *)
          err "Unrecognized option '${1}'. For help, run: 'sh ${0} -h'"
          ;;
      esac
    done
    # }}}
}

# If we're not being sourced, setup colors and run main()
if [ -z "${0##*conf.sh}" ]; then
    # Are colors supported?
    if command -v tput > /dev/null && tput setaf 1 > /dev/null; then
        # If colors are supported, define a wrapper which resets the terminal
        # and generally makes things not messy with escap sequences.
        # color <code> <text>
        color(){
            tput sgr 0
            tput setaf "$1"
            echo "$2"
            tput sgr 0
        }
        # If color is supported and colordiff installed, alias diff to colordiff
        if command -v colordiff > /dev/null; then
            alias diff=colordiff
        fi;
    else
        # If colors aren't supported, discard the color integer and just call echo
        color(){
            echo "$2"
        }
    fi

    # Run main()
    main "$@"
else
    # Stub color() definition for tests
    color(){
        echo "$2"
    }
fi;
