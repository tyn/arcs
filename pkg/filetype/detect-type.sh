sng_using_tmp --delete tmp
head -c 4096 "$@" > "$tmp"
fileinfo=`file "$tmp"`

if [ `tar tfz "$tmp" 2>/dev/null | wc -l` -gt 0 ]; then
  echo "{filetype:tar.gz}"
elif echo "$fileinfo" | grep -i 'gzip' > /dev/null ; then
  filedat=`gzip -cd "$tmp" 2> /dev/null`
  if echo "$fileinfo" | grep -i '.tex"' > /dev/null ; then
    echo "{filetype:tex.gz}"
  elif echo "$fileinfo" | grep -i '.ltx"' > /dev/null ; then
    echo "{filetype:ltx.gz}"
  elif echo "$filedat" | file - | grep -i 'pdf' > /dev/null ; then
    echo "{filetype:pdf.gz}"
  elif echo "$filedat" | file - | grep -i 'tar' > /dev/null ; then
    echo "{filetype:tar.gz}"
  elif echo "$filedat" | sed -e '/^%/d' | file - | grep -i 'LaTeX' > /dev/null ; then
    echo "{filetype:ltx.gz}"
  elif echo "$filedat" | sed -e '/^%/d' | file - | grep -i 'TeX' > /dev/null ; then
    echo "{filetype:tex.gz}"
  else
    echo "{filetype:gz}"
  fi
elif echo "$fileinfo" | grep -i 'pdf' > /dev/null ; then
  echo "{filetype:pdf}"
elif grep -E '^%PDF-' "$tmp" > /dev/null ; then
  echo "{filetype:pdf}"
else 
  echo "{filetype:unknown}"
fi
