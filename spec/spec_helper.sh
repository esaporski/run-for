# shellcheck shell=sh

# Defining variables and functions here will affect all specfiles.
set -eu

# This callback function will be invoked only once before loading specfiles.
spec_helper_precheck() {
	minimum_version "0.28.1"

	setenv SCRIPT_PATH="${SHELLSPEC_SPECDIR}/../build/run_for.sh"

	# sixlogger.sh environment variables
	setenv SIXLOGGER_NO_COLOR=true # Default is `false`
}

# This callback function will be invoked after a specfile has been loaded.
spec_helper_loaded() {
	:
}

# This callback function will be invoked after core modules has been loaded.
spec_helper_configure() {
	:
}
