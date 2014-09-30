meta_type=${1:-src}

  find "$ARCS_DATA_ROOT"/s3/arxiv/"$meta_type" \
       -name "arXiv_${meta_type}_*.tar" \
| sort \
| _ from-csv tar_path \
| _ deriving -a filename tar_path \
| _ deriv \
| _ rmcol filename \
