var="$1"
shift

sng_export $_header_ "$var"
while IFS= read -r line ; do
  sng_next << EOS
$line
EOS
  out=`eval "$@"`
  echo "$line$SNG_SEP$out"
done
