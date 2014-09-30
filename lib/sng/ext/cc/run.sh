TARGET="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD/target"
CXX=${CXX:-c++}

sng_with_target "$TARGET" \
  $CXX -o "$TARGET" "$SNG_SUBCMD_IMPL" $LIBS

exec "$TARGET" "$@"
