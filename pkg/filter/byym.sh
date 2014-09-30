# $1: year and month inYYYY-MM (e.g. 2014-03)
IFS="-" read -s year month << EOS
$1
EOS

[ "x$year-$month" != "x$1" ] \
  && sng_die "Invalid date: $* (expecting YYYY-MM)"

_ having date_ym "$1"
