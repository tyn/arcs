TARGET="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD/target.beam"
TARGET_DIR="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD/"
ERLC=${ERLC:-erlc}
ERL=${ERL:-erl}

sng_with_target "$TARGET" \
  $ERLC -o "$TARGET_DIR" "$SNG_SUBCMD_IMPL"

exec $ERL -noshell -pa "$TARGET_DIR" -s "$SNG_SUBCMD" start "$@" -s init stop
