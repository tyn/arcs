TARGET="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD/target"
OBJC=${OBJC:-clang}
FRAMEWORKS="-framework Foundation $FRAMEWORKS"

sng_with_target "$TARGET" \
  $OBJC -o "$TARGET" $FRAMEWORKS "$SNG_SUBCMD_IMPL" $LIBS

exec "$TARGET" "$@"
