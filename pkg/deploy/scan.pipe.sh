var="$ARCS_DATA_ROOT"/var

sng_import pj_archive_path pj_type preprint_id filename tar_path
sng_export preprint_id pj_type pj_archive_path filesize date_ymd time item

while sng_next; do
  [ -r "$tar_path" ] || sng_die "tar file not readable: $tar_path"

  success=0

  case "$pj_type" in
  {filetype:tar.gz})
    (
      sng_using_tmp --delete tmp
      tar xfO "$tar_path" "$filename" > "$tmp" || sng_die "tar failed."
      _ tar tvf "$tmp" \
      | awk 'BEGIN{OFS="'"$SNG_SEP"'"}
             { $1=$1;
               print "'"$preprint_id"'" \
                   , "'"$pj_type"'" \
                   , "'"$pj_archive_path"'" \
                   , $3,$4,$5,$6 
             }' \
      || sng_die "second tar failed"
      success=1
    )
    ;;
  {filetype:tex.gz}|{filetype:ltx.gz})
    (
      sng_using_tmp --delete tmp
      tar xfO "$tar_path" "$filename" > "$tmp" || sng_die "tar failed."
      sng_puttsv "$preprint_id" "$pj_type" "$pj_archive_path" \
                 "" "" "" "$preprint_id.tex"
      success=1
    )
    ;;
  {filetype:pdf.gz})
    (
      sng_using_tmp --delete tmp
      tar xfO "$tar_path" "$filename" > "$tmp" || sng_die "tar failed."
      sng_puttsv "$preprint_id" "$pj_type" "$pj_archive_path" \
                 "" "" "" "$preprint_id.pdf"
      success=1
    )
    ;;
  {filetype:pdf})
    (
      sng_puttsv "$preprint_id" "$pj_type" "$pj_archive_path" \
                 "" "" "" "$preprint_id.pdf"
      success=1
    )
    ;;
  {filetype:gz})
    (
      sng_puttsv "$preprint_id" "$pj_type" "$pj_archive_path" \
                 "" "" "" "$preprint_id.unknown"
      success=1
    )
    ;;
  *)
    sng_warn "Unrecognized project type: $pj_type"
    ;;
  esac
  [ $success -eq 0 ] || sng_die "Failed to scan $filename"
done
