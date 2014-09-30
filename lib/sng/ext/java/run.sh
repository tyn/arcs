TARGET_DIR="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD"
TARGET="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD/$SNG_SUBCMD_IMPL.class"
JAVAC=${JAVAC:-javac}
JAVA=${JAVA:-java}

sng_with_target "$TARGET" \
  $JAVAC -d "$TARGET_DIR" "$SNG_SUBCMD_IMPL" \

exec $JAVA -cp "$TARGET_DIR" "$SNG_SUBCMD" "$@"
