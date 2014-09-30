  _ deriv tar_path tar_basename \
| _ deriving \
    -A preprint_ext filename 's{^(.*?)(\.([^.]+))?$}{$2}ex' \
    -A preprint_id filename 's{^(.*/)(.*?)(\.([^.]+))?$}{$2}ex' \
    -v pj_archive_path '"$h->{local_path}$h->{block_num}/$h->{preprint_id}"' \
    -v pj_archive_file '"$h->{pj_archive_path}$h->{preprint_ext}"' \

