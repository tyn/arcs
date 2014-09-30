sng_require "$SNG_BASEDIR/lib/sng/dat.sh"

read -r proto_ver proto_status proto_msg
[ "WTD/1.0" != "$proto_ver" ] && sng_die "Invalid protocol: $proto_ver"
while IFS= read -r line; do
  [ "" = "$line" ] && break
  type=`echo "$line" | cut -f1 -d':'`
  case "$type" in
    Columns)
      _header_=`echo "$line" | cut -f2- -d' ' | tr "$SNG_SEP" ' '`
      ;;
    *)
      ;;
  esac
done

. "$SNG_SUBCMD_IMPL"
