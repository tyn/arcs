tar_path="$1"
filename="$2"

[ ! -r "$tar_path" ] && sng_die "Unable to read: $tar_path"
tar xfO "$tar_path" "$filename" 2>/dev/null | _ detect-type
