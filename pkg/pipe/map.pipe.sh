while IFS= read -r line; do
  "$@" <<EOS
`sng_export $_header_ ; echo "$line"`
EOS
done
