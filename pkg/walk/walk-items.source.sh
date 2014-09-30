manifest_type=${1:-src}

index="$ARCS_DATA_ROOT"/var/s3/arxiv/"$manifest_type"/scan-arxiv-"$manifest_type".dsv.gz

[ -r "$index" ] || sng_wtd_error 400 "Not Found"

  _ zcat "$index"
