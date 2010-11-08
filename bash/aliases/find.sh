function ftd () {
	find "${@:-"."}" $FIND_OPTIONS -type d -print
}
