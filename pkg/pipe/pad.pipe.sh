sng_export _lpad $_header_ _rpad

awk -F"\t" '
  BEGIN{OFS="\t"} {
    for (i=1;i<=NF;i++)
      if ($i=="") $i="\"\"";
      print "{",$0,"}"
  }
'
