output="$1" || sng_die "no output."

tmp=`mktemp $output.tmp.$$.XXXXXXXX`
#trap 'test -f "$tmp" && rm -f "$tmp"' EXIT
(
  sng_export $_header_
  cat 
) | gzip > "$tmp" && mv -f "$tmp" "$output"
