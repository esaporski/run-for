#!/usr/bin/env bash
# Pure bash script to wait some time after exiting a command
# (Heavily inspired by wait-for-it.sh)

RUN_cmdname=${0##*/}

usage() {
	cat <<USAGE >&2
Usage:
    $RUN_cmdname [-t time] [-q] [-- command args]
    -t TIME | --time=TIME       Time (in seconds) to wait for script to exit
    -q | --quiet                Don't output any status messages
    -- COMMAND ARGS             Command with args to be executed
USAGE
	exit 1
}

echoerr() { if [[ $RUN_QUIET -ne 1 ]]; then echo "$@" 1>&2; fi; }

run() {
	echoerr "$RUN_cmdname: Starting command \"${RUN_CLI[*]}\" at $(date)"
	RUN_start_ts=$(date +%s)

	"${RUN_CLI[@]}"
	CLI_RETURN=$?

	if [[ $CLI_RETURN -ne 0 ]]; then
		echoerr "$RUN_cmdname: Error executing command"
		return $CLI_RETURN
	fi

	echoerr "$RUN_cmdname: Command \"${RUN_CLI[*]}\" exited at $(date)"
	RUN_stop_ts=$(date +%s)

	RUN_elapsed_time=$((RUN_stop_ts - RUN_start_ts))
	echoerr "$RUN_cmdname: \"${RUN_CLI[*]}\" took $RUN_elapsed_time second(s) to run"

	SECONDS_TO_WAIT=$((RUN_TIME - RUN_elapsed_time))

	if [[ $SECONDS_TO_WAIT -lt 1 ]]; then
		echoerr "$RUN_cmdname: Command took longer than $RUN_TIME second(s)"
		return 0
	fi

	echoerr "$RUN_cmdname: Waiting $SECONDS_TO_WAIT second(s) before exiting"

	for second in $(seq $SECONDS_TO_WAIT); do
		echoerr "$RUN_cmdname: $((SECONDS_TO_WAIT - second + 1)) second(s) to wait..."
		sleep 1
	done
	return 0
}

# Process arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	-q | --quiet)
		RUN_QUIET=1
		shift 1
		;;
	-t)
		RUN_TIME="$2"
		if [[ $RUN_TIME == "" ]]; then break; fi
		shift 2
		;;
	--time=*)
		RUN_TIME="${1#*=}"
		shift 1
		;;
	--)
		shift
		RUN_CLI=("$@")
		break
		;;
	-h | --help)
		usage
		;;
	*)
		echoerr "$RUN_cmdname: Unknown argument: $1"
		usage
		;;
	esac
done

RUN_TIME=${RUN_TIME:-60}

if [[ $RUN_TIME -lt 1 ]]; then
	echoerr "$RUN_cmdname: Script must run for at least 1 second"
	exit 1
fi

if [ ${#RUN_CLI[@]} -ne 0 ]; then
	run
	RUN_RETURN=$?
	exit $RUN_RETURN
else
	echoerr "$RUN_cmdname: Must specify a command to run"
	exit 1
fi
