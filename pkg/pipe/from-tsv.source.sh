default_header=""
while [ $# -gt 0 ] ; do
  case "$1" in
    -H)
      IFS=`printf " \t\n"` read -r default_header
    ;;
    *)
      break
    ;;
  esac
  shift
done
if [ -z "$default_header" ] ; then
  sng_export "$@"
else
  sng_export $default_header "$@"
fi
tr -d '\r' | tr '\t' "$SNG_SEP"
