sng_normalize_basedir
GOPATH="$SNG_BASEDIR"/w/
export GOPATH
GO="$GOPATH/go/bin/go"
exec "$GO" run "$SNG_SUBCMD_IMPL" "$@"
