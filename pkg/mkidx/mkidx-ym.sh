manifest_type=src

date_ym="$1"
IFS="-" read -r date_y date_m << EOS
$date_ym
EOS

path="$ARCS_DATA_ROOT"/var/s3/arxiv/"$manifest_type"/"$date_y/$date_m"
sng_mkpath "$path"
index="$path/index-ym-$date_y-$date_m.dsv.gz"

  _ tar-ls \
| _ having filename '[^/]$' \
| _ item-deriv \
| _ fjoin pj_type ' _ inspect $tar_path $filename' \
| _ sink "$index"
