MANIFEST_TYPE=${1:-src}

MANIFEST_DIR="$SNG_BASEDIR/data/s3/arxiv/$MANIFEST_TYPE"
MANIFEST_XML="$MANIFEST_DIR/arXiv_$MANIFEST_TYPE"_manifest.xml

if sng_isnewer "$SNG_BASEDIR/.sng/timestamp" "$MANIFEST_DIR/timestamp" ; then
  _ update
fi

  _ parse-manifest "$MANIFEST_XML" \
| _ deriv
