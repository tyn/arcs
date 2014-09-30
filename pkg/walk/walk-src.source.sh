file="$ARCS_DATA_ROOT"/var/s3/arxiv/src/index-arxiv-src.dsv.gz 

[ -r "$file" ] || sng_wtd_error 400 "Not Found"

_ zcat "$file"
