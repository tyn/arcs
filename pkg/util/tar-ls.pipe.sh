sng_import tar_path

sng_export tar_path filesize date_ymd time filename

while sng_next; do
  _ tarls "$tar_path"
  [ $? -eq 0 ] || sng_die "Failed to inspect \`$tar_path'"
done || sng_die "Stop."
