sng_mkpath "$ARCS_WORK_DIR"
cd "$ARCS_WORK_DIR"
if [ ! -f "s3cmd/setup.py" ] ; then
  git clone https://github.com/s3tools/s3cmd.git
fi
