sng_export $_header_

trap exit INT

while sng_next ; do
  abs_path="$ARCS_DATA_ROOT/$local_path"
  dname=`dirname "$abs_path"`
  sng_mkpath "$dname"
  sng_reportf "    %s\n" "$basename"
  if [ ! -f "$abs_path" ] ; then
    (
      sng_using_tmpdir --delete tmpdir
      cd "$tmpdir"
      _ getrp "$uri" || sng_die "failed to retrieve $uri"

      hash=`_ md5sum "$basename"`
      if [ "x$hash" = "x$md5sum" ] ; then
        mv "$basename" "$abs_path"
      else
        sng_warn "Digest mismatch: $hash (expecting $md5sum)"
        mv "$basename" "$abs_path"
      fi
    ) || sng_die "Stop."
  fi
done
