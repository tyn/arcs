sng_require "$ARCS_VAR_DIR"/s3cmd.env
export PYTHONPATH

"$ARCS_VAR_DIR"/bin/s3cmd "$@"
