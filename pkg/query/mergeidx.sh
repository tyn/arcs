meta_type=${1:-src}

  find "$ARCS_DATA_ROOT"/var/s3/arxiv/"$meta_type" -name "index-ym-*.dsv.gz" \
| sort \
| xargs _ zcat \
| _ union \
