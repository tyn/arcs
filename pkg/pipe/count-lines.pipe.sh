sng_export $_header_
i=0
while IFS= read -r line; do
  echo "$line"
  printf "\r%08d" $i >&2
  i=`expr $i + 1`
done
