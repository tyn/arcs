sng_require "$SNG_BASEDIR/lib/sng/dat.sh"
exec perl -I"$SNG_BASEDIR"/lib/sng/perl5 "$SNG_SUBCMD_IMPL" "$@"
