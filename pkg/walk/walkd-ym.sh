  _ walkd "$@" \
| _ select date_ym date_y date_m local_path \
| _ deriving -A ym_dir local_path 's{/arXiv_.*$}{}' \
| _ rmcol local_path \
| _ lift sort \
| _ lift uniq \
