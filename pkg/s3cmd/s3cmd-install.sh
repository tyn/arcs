set -e
cd "$ARCS_WORK_DIR/s3cmd"
sng_mkpath "$ARCS_VAR_DIR"
python_path=`ls -d "$ARCS_VAR_DIR"/lib/python*`
cat << EOS > "$ARCS_VAR_DIR/s3cmd.env"
PYTHONPATH="$python_path/site-packages:$PYTHONPATH"
EOS
. "$ARCS_VAR_DIR"/s3cmd.env
export PYTHONPATH
python setup.py install --prefix="$ARCS_VAR_DIR"
