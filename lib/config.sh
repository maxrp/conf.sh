MODULES=()
SRCDIR="${PWD}/src"

function update_submodules(){
  git submodule init
  git submodule update --recursive
  git submodule foreach git pull origin master
}

function config_install(){
  source="${SRCDIR}/${1}"
  dest="${HOME}/.${1}"
  if [[ -n $2 ]]; then
    source="${source}/${2}"
    dest="${HOME}/.${2}"
  fi
  if [[ -z $installopts ]]; then
    installopts='-C --mode=0600'
  fi 
  install $installopts $source $dest
}

function warn(){
  echo "$*" > /dev/fd/2
}
