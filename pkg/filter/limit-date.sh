  _ ifset "$ARCS_DATE_YM" \
    _ having "date_ym" "$ARCS_DATE_YM" \
| _ ifset "$ARCS_DATE_Y" \
    _ having "date_y" "$ARCS_DATE_Y" \

