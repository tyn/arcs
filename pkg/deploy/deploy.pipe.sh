var="$ARCS_DATA_ROOT"/var

sng_import pj_archive_path pj_type preprint_id filename tar_path
sng_export preprint_id success isnew

while sng_next; do
  sng_report "    $preprint_id $pj_type"

  [ -r "$tar_path" ] || sng_die "tar file not readable: $tar_path"

  pj_d="$var"/"$pj_archive_path.d"
  sng_mkpath "$pj_d"
  cd "$pj_d"

  success=0
  isnew=0
  if [ ! -e ".arcs/timestamp" \
      -o "$tar_path" -nt ".arcs/timestamp" ] ; then
    isnew=1
    case "$pj_type" in
    {filetype:tar.gz})
      (
        sng_using_tmp --delete tmp
        tar xfO "$tar_path" "$filename" > "$tmp" || sng_die "tar failed."
        tar xfz "$tmp" || sng_die "second tar failed"
      ) && success=1
      ;;
    {filetype:tex.gz}|{filetype:ltx.gz})
      (
        sng_using_tmp --delete tmp
        tar xfO "$tar_path" "$filename" > "$tmp" || sng_die "tar failed."
        gzip -cd "$tmp" > "$preprint_id.tex" || sng_die "gzip failed"
      ) && success=1
      ;;
    {filetype:pdf.gz})
      (
        sng_using_tmp --delete tmp
        tar xfO "$tar_path" "$filename" > "$tmp" || sng_die "tar failed."
        gzip -cd "$tmp" > "$preprint_id.pdf" || sng_die "gzip failed"
      ) && success=1
      ;;
    {filetype:gz})
      (
        sng_using_tmp --delete tmp
        tar xfO "$tar_path" "$filename" > "$tmp" || sng_die "tar failed."
        gzip -cd "$tmp" > "$preprint_id.unknown" || sng_die "gzip failed"
      ) && success=1
      ;;
    {filetype:pdf})
      (
        tar xfO "$tar_path" "$filename" > "$preprnt_id.pdf" \
        || sng_die "tar failed."
      ) && success=1
      ;;
    *)
      sng_warn "Unrecognized project type: $pj_type"
      ;;
    esac
    [ $success -eq 1 ] || sng_warn "Failed to deploy $filename"

    sng_mkpath "$pj_d"/.arcs/
    touch "$pj_d"/.arcs/timestamp
  else
    success=1
  fi
  sng_puttsv "$preprint_id" "$success" "$isnew"
done
