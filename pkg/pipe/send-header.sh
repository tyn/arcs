if [ -t 1 ] ; then
  :
else
  _ send-header0 "$@"
fi
