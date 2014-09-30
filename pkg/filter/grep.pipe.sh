sng_import tex_file
sng_export matched_line

while sng_next ; do
  tex_path="$ARCS_DATA_ROOT/var/$tex_file"
  grep "$@" "$tex_path"
done
