flag="$1"
shift

if [ -z "$flag" ] ; then
  cat
else
  exec "$@"
fi

