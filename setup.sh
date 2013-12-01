#!/usr/bin/bash

. ./lib/config.sh

MODULES+=(bash)
MODULES+=(dircolors)
MODULES+=(gpg)
MODULES+=(proxychains)
MODULES+=(ssh)
MODULES+=(theme)
MODULES+=(tmux)
MODULES+=(vim)


# ensure external sources are up-to-date
update_submodules > /dev/null

for module in ${MODULES[@]}; do
  mod_path="./lib/${module}.sh"
  if [[ -f $mod_path ]]; then
    echo " + Running module: ${module}"
    . "${mod_path}"
  else
    warn " - Module '${module}' doesn't exist."
  fi
done
