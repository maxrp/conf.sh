## theme: Theme Xorg & WMII

# Xorg
install -m 0700 $SRCDIR/theme/xinitrc      $HOME/.xinitrc
install -m 0600 $SRCDIR/theme/Xresources   $HOME/.Xresources

# WMII
mkdir -p .wmii
install -m 0700 $SRCDIR/theme/wmiirc_local $HOME/.wmii/wmiirc_local
