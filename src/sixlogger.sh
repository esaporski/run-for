#!/bin/sh

set -eu

# @sixlogger start
# URL: https://github.com/esaporski/sixlogger (v0.1.1)
sixlogger() {
	_sl_debug=$(printf "%s" "${SIXLOGGER_DEBUG:-${DEBUG:-false}}" | tr '[:upper:]' '[:lower:]')
	_sl_no_color=$(printf "%s" "${SIXLOGGER_NO_COLOR:-${NO_COLOR:-false}}" | tr '[:upper:]' '[:lower:]')

	_sl_color_debug=${SIXLOGGER_COLOR_DEBUG:-'\033[0;34m'}
	_sl_color_info=${SIXLOGGER_COLOR_INFO:-'\033[0;32m'}
	_sl_color_warn=${SIXLOGGER_COLOR_WARN:-'\033[1;33m'}
	_sl_color_error=${SIXLOGGER_COLOR_ERROR:-'\033[0;31m'}
	_sl_color_fatal=${SIXLOGGER_COLOR_FATAL:-'\033[1;31m'}
	_sl_color_off='\033[0m'

	e_sl_unknown_loglevel=${E_SIXLOGGER_UNKNOWN_LOGLEVEL:-30}
	_sl_status_code=0

	_sl_timestamp=$(date -u -Iseconds)
	_sl_filename=$(basename "$0")
	_sl_loglevel=$(printf "%s" "$1" | tr '[:upper:]' '[:lower:]')
	shift
	_sl_message="$*"

	case $_sl_loglevel in
	info)
		_sl_color_output=$_sl_color_info
		;;
	warn)
		_sl_color_output=$_sl_color_warn
		;;
	error)
		_sl_color_output=$_sl_color_error
		;;
	fatal)
		_sl_color_output=$_sl_color_fatal
		;;
	debug)
		if ! [ "$_sl_debug" = "true" ] && ! [ "$_sl_debug" = 1 ]; then return; fi
		_sl_color_output=$_sl_color_debug
		;;
	*)
		_sl_message="Unknown log level '$_sl_loglevel'"
		_sl_loglevel="fatal"
		_sl_color_output=$_sl_color_fatal
		_sl_status_code=$e_sl_unknown_loglevel
		;;
	esac

	_sl_output=$(printf '%s | %s | %s | %s' "$_sl_timestamp" "$_sl_loglevel" "$_sl_filename" "$_sl_message")
	if [ "$_sl_no_color" != "true" ] && [ "$_sl_no_color" != 1 ]; then
		_sl_output=$(printf "%b%s%b" "$_sl_color_output" "$_sl_output" "$_sl_color_off")
	fi

	case $_sl_loglevel in
	error | fatal) printf '%s\n' "$_sl_output" >&2 ;;
	*) printf '%s\n' "$_sl_output" >&1 ;;
	esac
	return "$_sl_status_code"
}
# @sixlogger end
