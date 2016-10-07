sng_stderr() {
  echo "$*" >&2
}

sng_puterr() {
  sng_stderr "$*"
}

sng_warn() {
  sng_puterr "warn: $*"
}

sng_report() {
  echo "$@" >&2
}

sng_reportf() {
  printf "$@" >&2
}

sng_debug() {
  [ -z $SNG_DEBUG ] || sng_puterr "debug: $*"
}

sng_err()
{
  sng_puterr "error: $*"
}

sng_info()
{
  sng_puterr "info: $*"
}

sng_msg()
{
  sng_puterr "$*"
}

sng_mkpath() {
  for __dir ; do
    [ -d "$__dir" ] || mkdir -p "$__dir"
  done
}

sng_mkstemp()
{
  sng_mkpath "$SNG_BASEDIR/.sng/tmp"
  mktemp "$SNG_BASEDIR/.sng/tmp/XXXXXXXXXXXX"
}

sng_isnewer()
{
  [ -z "$1" ] && sng_die "sng_isnewer: Insufficent arguments."
  if [ -e "$2" ] ; then
    find "$1" -type f -newer "$2" 2>/dev/null | grep "$1" > /dev/null
  else
    [ -e "$1" ] && return 0
    return 1
  fi
}

sng_seq()
{
  (
    i=${1:-0}
    j=1
    while [ "$j" -le "$i" ] ; do
      echo "$j"
      j=`expr "$j" + 1`
    done
  )
}

sng_with_tempfiles() {
  (
    tmps=`sng_mkstemp`
    sng_seq "$1" | while read i ; do
      sng_mkstemp
    done > "$tmps"
    [ $# -gt 0 ] && shift
    cleanup() {
      sng_warn "cleanup()" 
      cat "$tmps" | while read tmpfile ; do
        [ -f "$tmpfile" ] && rm "$tmpfile"
      done
      [ -f "$tmps" ] && rm "$tmps"
    }
    trap cleanup EXIT
    cat "$tmps" | "$@"
  )
}

sng_require()
{
  . "$SNG_BASEDIR/$1"
}

sng_exec_or_install()
{
  command -v "$1" >/dev/null 2>&1 < /dev/null && exec "$@"

  sng_err "unable to run $1: no such command"

  sng_instruction="$SNG_SUBCMD_IMPL.install"
  [ -r "$sng_instruction" ] && cat "$sng_instruction"
  exit 1
}

sng_die_with_retcode() {
  sng_retcode=${1:1}
  [ $# -ne 0 ] && shift
  sng_err "$*"
  exit "$sng_retcode"
}

sng_die() {
  sng_die_with_retcode 1 "$*"
}

sng_normalize_basedir() {
  SNG_BASEDIR=`cd "$SNG_BASEDIR" ; pwd`
}

sng_prog() {
  echo `basename "$SNG_SELF"`" $SNG_SUBCMD"
}

sng_define_vars() {
  sng_normalize_basedir
  [ -r "$SNG_BASEDIR"/etc/sng.conf ] && . "$SNG_BASEDIR"/etc/sng.conf
  SNG_SELF="$SNG_BASEDIR"/bin/${SNG_SELF##*/}

  SNG_APPDIR="$SNG_BASEDIR/.sng/apps/$SNG_SUBCMD"
  if [ -z "$SNG_PKGPATH" ] ; then
    SNG_PKGPATH="$SNG_BASEDIR/lib/pkg.d"
  else
    SNG_PKGPATH="$SNG_PKGPATH":"$SNG_BASEDIR"/lib/pkg.d
  fi
}

sng_write_exec_script() {
  # $1 : output path
  sng_tmp=`sng_mkstemp`
  cat > "$sng_tmp"
  chmod 0755 "$sng_tmp"
  mv -f "$sng_tmp" "$1" || sng_die "Failed to write launcher script."
}

sng_launcher_preamble() {
  cat <<EOS
SNG_SUBCMD_IMPL="$SNG_SUBCMD_IMPL"
SNG_SUBCMD_EXT="$SNG_SUBCMD_EXT"
SNG_SUBCMD_LEXT="$SNG_SUBCMD_LEXT"
PATH="\$SNG_BASEDIR/lib/sng/enforce:\$PATH"

export PATH
export SNG_SELF
export SNG_SUBCMD
export SNG_BASEDIR
EOS
}

sng_write_launcher_script_builtin() {
  sng_write_exec_script "$SNG_APPDIR/exec.sh" << EOS
`sng_launcher_preamble "$@" `
"$SNG_SUBCMD" "\$@"
EOS
}


sng_write_launcher_script_external() {
  sng_write_exec_script "$SNG_APPDIR/exec.sh" << EOS
`sng_launcher_preamble "$@"`
[ ! -f "\$SNG_BASEDIR"/lib/sng/ext/"$SNG_SUBCMD_LEXT"/run.sh ] \
  && sng_die "Unsupported extension: $SNG_SUBCMD_LEXT"
[ -r "\$SNG_SUBCMD_IMPL".env ] \
  && . "\$SNG_SUBCMD_IMPL".env
. "\$SNG_BASEDIR"/lib/sng/ext/"$SNG_SUBCMD_LEXT"/run.sh
EOS
}

sng_write_launcher_script() {
  IFS="|" read -r SNG_SUBCMD_IMPL SNG_SUBCMD_EXT SNG_SUBCMD_LEXT <<EOS
`sng_find_commands | awk ' \
  BEGIN{FS="|";OFS="|";} \
  { \
    if ($2=="'$SNG_SUBCMD'") { \
      print $1,$3,$4; exit 0 \
    } \
  } \
'`
EOS
  sng_mkpath "$SNG_APPDIR"
  if [ -f "$SNG_SUBCMD_IMPL" ] ; then
    sng_write_launcher_script_external \
    || sng_die "Failed to create external launcher script: $2"
  elif command -v "$SNG_SUBCMD" >/dev/null 2>&1 ; then
    sng_write_launcher_script_builtin \
    || sng_die "Failed to create internal launcher script: $2"
  else
    sng_die "No such sub-command: $SNG_SUBCMD"
  fi
}

sng_pkgdirs() {
  echo "$SNG_PKGPATH" | tr ':' '\012' \
  | awk 'BEGIN{OFS="|"}{print (sprintf("%06d",NR)),$0}'
}

sng_find_commands() {
  sng_pkgdirs | while IFS="|" read -r ord p ; do
    cd "$p" 2>/dev/null && find . -type f | while read path ; do
      printf "$ord|$p|$path\n"
    done
  done \
  | while IFS='|' read -r ord plugin_dir f; do
    dir="${f%/*}"; dir="${dir##.}"; dir="${dir##/}"
    script="${f##*/}"
    subcmd="${script%%.*}"
    type="${script##*.}"
    ltype="${script#*.}"
    [ -f "$SNG_BASEDIR/lib/sng/ext/$ltype/run.sh" ] && \
      echo "$ord|$plugin_dir/$dir/$script|$subcmd|$type|$ltype|$dir"
  done | sort -t '|' | sed 's/^[^|]*|//'
}

sng_usage0() {
  echo "Sub-commands:"
  sng_find_commands | while IFS="|" read -r script subcmd type ltype dir; do
    if [ -x "$script" ] ; then
      desc="No description"
      [ -r "$script".desc ] && desc=`cat "$script".desc`
      printf "   %-10s %s\n" "$subcmd" "$desc"
    fi
  done
}

sng_usage1() {
  echo "All sub-commands:"
  sng_find_commands | while IFS="|" read -r script subcmd type ltype dir; do
    if [ -e "$script" ] ; then
      desc="No description"
      [ -r "$script".desc ] && desc=`cat "$script".desc`
      printf " %12s %-18s %s\n" "($dir)" "$subcmd" "$desc"
    fi
  done
}

sng_init_launcher() {
  sng_write_launcher_script
}

sng_with_target() {
  # $1 : output
  [ -f "$1" ] && return 0
  (
    output="$1"
    [ $# -gt 0 ] && shift
    tmp1=`sng_mkstemp`
    tmp2=`sng_mkstemp`
    cleanup() {
      for f in "$tmp1" "$tmp2" ; do
        [ -f "$f" ] && rm "$f"
      done
    }
    trap cleanup EXIT
    "$@" > "$tmp1" 2> "$tmp2"
    ret=$?
    if [ $ret -ne 0 ] ; then
#    cat "$tmp1"
      cat "$tmp2" >&2
    fi
    return $ret
  )
}

sng_settrap() {
  trap '
    echo "$SNG_DELETE_STACK" | sed -e "s/:/\n/g" | while read -r tmp ; do \
      sng_rmtmp "$tmp"; \
    done \
  ' EXIT
}

sng_rmtmp() {
  [ ! -e "$1" ] && return
  if [ -d "$1" ] ; then
    [ -f "$1/.sngmanaged" -a -f "$1/.deleteonexit" ] && rm -rf "$1"
  elif [ -f "$1" ] ; then
    rm -f "$1"
  else
    sng_warn "Unrecognized tmp object: $1"
  fi
}

sng_rmlater() {
  [ -z $1 ] && return
  [ -d "$1" ] && touch "$1"/.deleteonexit

  if [ -z "$SNG_DELETE_STACK" ] ; then
    SNG_DELETE_STACK="$1"
  else
    SNG_DELETE_STACK="$1:$SNG_DELETE_STACK"
  fi
}

sng_using_tmpdir() {
  sng_mkpath "$SNG_BASEDIR"/.sng/tmp
  # TODO: make this POSIX compliant.
  tmpdir=`mktemp -d "$SNG_BASEDIR/.sng/tmp/mgd.XXXXXXXXXXXXX"` \
    || sng_die "Failed to create tmpdir."
  touch "$tmpdir"/.sngmanaged

  for arg; do
    case "$arg" in
    '--delete')
      shift
      sng_rmlater "$tmpdir"
      sng_settrap
      ;;
    *)
      break
      ;;
    esac
  done

  var="$1"
  if [ -z "$var" ] ; then
    echo "$tmpdir"
  else 
    read -r "$var" <<EOS
$tmpdir
EOS
  fi
}

# TODO: support multiple files
sng_using_tmp() {
  _sng_tmp=`sng_mkstemp` || sng_die "Failed to create tmpdir."

  for _sng_arg; do
    case "$_sng_arg" in
    '--delete')
      shift
      sng_rmlater "$_sng_tmp"
      sng_settrap
      ;;
    *)
      break
      ;;
    esac
  done

  _sng_var="$1"
  if [ -z "$_sng_var" ] ; then
    echo "$_sng_tmp"
  else 
    read -r "$_sng_var" <<EOS
$_sng_tmp
EOS
  fi
}

sng_sep2() {
  if [ $# -gt 2 ] ; then
    read "$1" "$2" << EOS
`echo "$3" | sed -e 's/^\(..\)\(.*\)/\1 \2/'`
EOS
  elif [ $# -eq 2 ] ; then
    read "$1" "$2" << EOS
`sed -e 's/^\(..\)\(.*\)/\1 \2/'`
EOS
  else
    sng_die "sng_sep2: Insufficient arguments."
  fi
}

sng_include() {
  [ -r "$1" ] && . "$1"
}

sng_require() {
  . "$1" || sng_die "sng_require: failed to source \`$1'."
}

sng_forread() {
    sed -n 's/^\([-A-Za-z0-9]*\):[ ]*\(.*\)$/\1|\2/p' "$@" \
  | awk -F"|" 'BEGIN{IFS="|";OFS="|"}{$1=toupper($1);gsub("-","_",$1);print}' \
  | tr -d '\r'
}
sng_readobj() {
  varprefix=${2:-X_}
  while IFS="|" read -r var value ; do
    [ -z "$var" ] && continue
    IFS= read -r "$varprefix$var" << EOS
$value
EOS
  done << EOS
`sng_forread "$1"`
EOS
}
