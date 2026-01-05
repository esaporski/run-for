# shellcheck shell=sh

# _rf_validate_seconds
# _rf_is_string_empty
# _rf_error
# parse? usage?

# Error messages:
#   $1: Default error message
#   $2: Error name
#     - `unknown` (Unrecognized option)
#     - `noarg` (Does not allow an argument)
#     - `required` (Requires an argument)
#     - `pattern:<PATTERN>` (Does not match the pattern)
#     - `validator_name:<STATUS>` (Validation error)
#     - `ambiguous` (Ambiguous option)
#   $3: Option
#   $4-: Validator name and arguments (if $2 is validator_name)
#   $4-: Candidate options (if $2 is ambiguous)
#   return: exit status
