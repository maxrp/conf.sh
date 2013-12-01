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

function install_modules(){
    if [[ -z $1 ]]; then
        warn 'A comma-separated list of arguments is required.'
    else
        IFS=',' read -a MODULES <<<$1
        echo "Installing the modules: ${MODULES[@]}"
    fi

    for module in ${MODULES[@]}; do
      mod_path="./lib/${module}.sh"
      if [[ -f $mod_path ]]; then
        echo " + Running module: ${module}"
        #. "${mod_path}"
      else
        warn " - Module '${module}' doesn't exist."
      fi
    done
}

function warn(){
  echo "$*" > /dev/fd/2
}
