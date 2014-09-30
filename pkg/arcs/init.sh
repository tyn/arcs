if [ -d "$SNG_BASEDIR"/.sng/apps ] ; then
  rm -rf "$SNG_BASEDIR"/.sng/apps
fi

_ npm install

if [ ! -x "$ARCS_VAR_DIR"/bin/s3cmd ] ; then
  sng_msg "Preparing s3cmd ..."
  _ s3cmd-fetch && _ s3cmd-install \
  || sng_die "Failed to install s3cmd."
fi

touch "$SNG_BASEDIR"/.sng/timestamp

if [ ! -f "$HOME"/.s3cfg ] ; then
  cat <<EOS
--------------------------------------------------------------------------
Configure s3cmd before running arcs.  See
  https://github.com/s3tools/s3cmd
When configuring s3cmd, run s3cmd under arcs:
  bin/arcs s3cmd --configure

IMPORTANT:
  When retrieving data from the arXiv repository, arcs command uses the
  Requester Pays buckets.  This means that you have to pay for the data
  transfer.  The details of the Requester Pays buckets can be found on
  http://docs.aws.amazon.com/AmazonS3/latest/dev/RequesterPaysBuckets.html
--------------------------------------------------------------------------
EOS
  exit 0
fi
