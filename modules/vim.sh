## vim: vimrc, pathogen & vim bundles
config_install vim vimrc
mkdir -p ${HOME}/.vim/autoload
cp -R $SRCDIR/vim/autoload/pathogen/autoload/pathogen.vim $HOME/.vim/autoload
cp -R $SRCDIR/vim/bundle $HOME/.vim 2>&1 | grep -v '.git'
