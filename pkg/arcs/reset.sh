if [ -d "$SNG_BASEDIR"/.sng/apps ] ; then
  rm -rf "$SNG_BASEDIR"/.sng/apps
fi

touch "$SNG_BASEDIR"/.sng/timestamp
