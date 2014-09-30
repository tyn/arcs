if [ $# -eq 1 -a "x$1" = "x-h" ] ; then
  echo "fsize fdate ftime fname"
  exit 0
fi
unzip -lq "$@" | sed -n '3,$p' | sed -e '$d' | sed -e '$d'
