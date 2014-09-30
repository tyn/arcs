set -e

ARCS_DATE_Y=${1:-`date +%Y`}
export ARCS_DATE_Y

sng_report "Retrieving chunks..."
  _ walkm src \
| _ ifset "$ARCS_DATE_Y" _ byyear "$ARCS_DATE_Y" \
| _ pget \
|| sng_die "Stop."

sng_report "Building indices..."
  _ mkidx \
|| sng_die "Stop."
