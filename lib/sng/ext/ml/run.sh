TARGET="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD/target"
TARGET_DIR="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD/"
OCAMLC=${OCAMLC:-ocamlc}
OCAMLSCRIPT=${OCAMLSCRIPT:-ocamlscript}
OCAML=${OCAML:-ocaml}

sng_with_target "$TARGET" \
  $OCAMLC -o "$TARGET" "$SNG_SUBCMD_IMPL"

exec $OCAML "$SNG_SUBCMD_IMPL" "$@"
