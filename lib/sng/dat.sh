SNG_SEP="|"
[ -z $sng_ifs ] && sng_ifs="
$SNG_SEP"
export SNG_SEP

sng_puttsv() {
  sep=""
  for rec; do
    printf "$sep%s" "$rec"
    sep="$SNG_SEP"
  done
  printf "\n"
}

sng_crlf() {
  sed 's/\([^\r]\)$/\1\r/'
}
sng_lf() {
  sed 's/\r/d'
}

sng_import() {
  echo " $_header_ " | tr "$SNG_SEP" ' ' | grep " $1 " > /dev/null 2>&1\
    || sng_die "Undefined column: $1"
}

sng_export() {
  _ send-header <<EOS
WTD/1.0 200 OK
Columns: `sng_puttsv "$@"`
EOS
}

sng_read() {
  IFS="$sng_ifs" read "$@"
}

sng_next() {
  sng_read -r $_header_
}

sng_wtd_error() {
  _ send-header <<EOS
WTD/1.0 $1 $2
EOS
  exit 1
}
