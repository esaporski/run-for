# shellcheck shell=sh
# shellcheck disable=SC2034,SC2329

Describe 'script'
	It 'run script'
		When run source "$SCRIPT_PATH" --verbose --seconds=1 --command='uname -a'
		The status should be success
		The stdout should not be blank
		Dump
	End
End
