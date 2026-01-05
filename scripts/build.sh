#!/bin/sh

set -eu

script_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

mkdir -p "${script_dir}/../build"
cp "${script_dir}/../src/run_for.sh" "${script_dir}/../build/run_for.sh"

# Get source commands from script
sources=$(
	sed -n '/^# @source start$/,/^# @source end$/{//!p;}' "${script_dir}/../build/run_for.sh" |
		awk '$0 ~ /^\./ { print $2 }' |
		xargs -I{} basename "{}" ".sh"
)

# Load sources into environment variable
embed=$(
	echo "$sources" |
		xargs -I{} sh -c 'printf "\n"; sed -n "/^# @{} start$/,/^# @{} end$/{//!p;}" "src/{}.sh";'
)

# Remove sources from original script
sed -i '/^# @source start$/,/^# @source end$/d' "${script_dir}/../build/run_for.sh"

# Append after `VERSION` variable
printf "%s" "$embed" | sed -i '/^VERSION=.*$/r /dev/stdin' "${script_dir}/../build/run_for.sh"
chmod +x "${script_dir}/../build/run_for.sh"

# sed -i '/^# @end$/{n;d;}' "${script_dir}/../build/run_for.sh"
# sed -i '/^# @source$/,/^# @end$/d' "${script_dir}/../build/run_for.sh"

# Print
# sed -n '/^# @source$/,/^# @end$/p' "${script_dir}/../build/run_for.sh"
# sed -n '/^# @source$/,/^# @end$/{//!p;}' "${script_dir}/../build/run_for.sh"

# Remove
# sed '/^# @source$/,/^# @end$/d' "${script_dir}/../build/run_for.sh"
# sed '/^# @source$/,/^# @end$/{/^# @source$/!{/^# @end$/!d;};}' "${script_dir}/../build/run_for.sh"
