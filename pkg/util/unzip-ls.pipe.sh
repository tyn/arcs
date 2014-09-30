sng_import path

sng_export path filesize date_mdy time filename

while sng_next; do
  unzip -lq "$path" | sed -n '3,$p' | sed -e '$d' | sed -e '$d' \
  | awk 'BEGIN{OFS="'"$SNG_SEP"'"}{$1=$1;print "'"$path"'", $0}'
done
