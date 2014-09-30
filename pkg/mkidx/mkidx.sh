set -e

out_dir="$ARCS_DATA_ROOT"/var
sng_mkpath "$out_dir"/s3/arxiv/src

sng_report "  mkidx-sub"
_ mkidx-sub

sng_report "  index-arxiv-src"
_ mergeidx | _ sink "$out_dir"/s3/arxiv/src/index-arxiv-src.dsv.gz

sng_report "  scan-arxiv-src"
_ walk | _ scan | _ sink "$out_dir"/s3/arxiv/src/scan-arxiv-src.dsv.gz

sng_report "  deploy-arxiv-src"
_ walk | _ deploy | _ sink "$out_dir"/s3/arxiv/src/deploy-arxiv-src.dsv.gz
