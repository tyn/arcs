tar_path="$1"
[ -r "$tar_path" ] || sng_die "Tar file unreadable: $tar_path"

# N.B. The output format of tar tvf depends on O/S
# (BSD and Linux use different formats).
# So we only use tar tf here.

  tar tf "$tar_path" \
| awk 'BEGIN{OFS="'"$SNG_SEP"'"}{$1=$1;print "'"$tar_path"'", "", "", "", $1}'

#  tar tvf "$tar_path" \
#| awk 'BEGIN{OFS="'"$SNG_SEP"'"}{$1=$1;print "'"$tar_path"'", $3,$4,$5,$6}'
