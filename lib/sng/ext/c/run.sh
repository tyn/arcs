TARGET="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD/target"
CC=${CC:-cc}

sng_with_target "$TARGET" \
  $CC -o "$TARGET" "$SNG_SUBCMD_IMPL" $LIBS

exec "$TARGET" "$@"
