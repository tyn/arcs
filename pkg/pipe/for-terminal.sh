IFS= read -r line

if expr "$line" : "WTD/1.0 200 OK" > /dev/null ; then
  _ body | tr "$sng_sep" '\t'
else
  echo "error: $line"
  tr "$sng_sep" '\t'
fi
