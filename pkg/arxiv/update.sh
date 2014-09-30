set -e

sng_using_tmpdir --delete tmpdir

(
  cd "$tmpdir"
  _ getrp s3://arxiv/src/arXiv_src_manifest.xml
  _ getrp s3://arxiv/pdf/arXiv_pdf_manifest.xml
)

for type in src pdf; do
  sng_mkpath "$ARCS_DATA_ROOT"/s3/arxiv/"$type"/
  mv "$tmpdir"/arXiv_"$type"_manifest.xml "$ARCS_DATA_ROOT"/s3/arxiv/"$type"/
  touch "$ARCS_DATA_ROOT"/s3/arxiv/"$type"/timestamp
done
