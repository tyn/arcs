printf "%s: " "$1"
if file "$1" | cut -f2- -d: | grep -E 'script|text' > /dev/null 2>&1 ; then
  head -n 1 "$1"
else
  printf "\n"
fi
