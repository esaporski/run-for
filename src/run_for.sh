#!/bin/sh
#
# A POSIX-compliant shell script that waits some time before exiting a command.

set -eu

VERSION=0.0.1

# @source start
script_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
. "${script_dir}/parser.sh"
. "${script_dir}/sixlogger.sh"
# @source end

std_streams() {
	case "$1" in
	discard)
		exec 3>&1 # Link fd 3 with `stdout`
		exec 4>&2 # Link fd 4 with `stderr`

		exec 1>/dev/null # Discard output from `stdout`
		exec 2>/dev/null # Discard output from `stderr`
		;;
	restore)
		exec 1>&3 3>&- # Restore `stdout` and close fd 3
		exec 2>&4 4>&- # Restore `stderr` and close fd 4
		;;
	esac
}

run() {
	# Discard output from `stdout` and `stderr`
	if $_rf_quiet; then std_streams "discard"; fi

	sixlogger info "Starting command '${_rf_command}'"
	start_ts=$(date +%s)

	# Restore `stdout` and `stderr`
	if $_rf_quiet; then std_streams "restore"; fi

	# Run command
	command_status_code=0
	eval "$_rf_command" || command_status_code=$?

	# Discard output from `stdout` and `stderr`
	if $_rf_quiet; then std_streams "discard"; fi

	message="Command '${_rf_command}' exited with status code '${command_status_code}'"
	case $command_status_code in
	0)
		sixlogger info "$message"
		;;
	*)
		sixlogger fatal "$message"
		return "$command_status_code"
		;;
	esac

	stop_ts=$(date +%s)
	elapsed_time=$((stop_ts - start_ts))
	sixlogger info "'${_rf_command}' took $elapsed_time second(s) to run"

	seconds_to_wait=$((_rf_seconds - elapsed_time))

	if [ $seconds_to_wait -lt 1 ]; then
		sixlogger info "Command took longer than ${_rf_seconds} second(s)"
		return 0
	fi

	sixlogger info "Waiting $seconds_to_wait second(s) before exiting"

	for second in $(seq $seconds_to_wait); do
		sixlogger info "$((seconds_to_wait - second + 1)) second(s) to wait..."
		sleep 1
	done
	return 0
}

# Parse arguments
parse "$@"

export SIXLOGGER_DEBUG="$_rf_verbose"
sixlogger debug "Debug enabled"

# Unknown arguments
eval "set -- ${_rf_unknown_args}"
_rf_unknown_args=$*

if [ -n "$_rf_unknown_args" ]; then
	sixlogger fatal "Unknown arguments: '${_rf_unknown_args}'"
	exit 3
fi

run
exit $?
