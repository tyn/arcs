TARGET_DIR="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD"
TARGET="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD/target.exe"
MCS=${MCS:-mcs}
MCS_OPTS="-codepage:932"
MONO=${MONO:-mono}

sng_with_target "$TARGET" \
  $MCS $MCS_OPTS \
       -out:"$TARGET" \
       "$SNG_SUBCMD_IMPL" \
       $LIBS

exec $MONO "$TARGET" "$@"
