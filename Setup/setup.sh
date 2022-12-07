#!/usr/bin/env bash

set -eu
set -o pipefail

source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

echo "-------- $(date) --------"

need_shutdown="${NEED_SHUTDOWN:-0}"

state_file="$(dirname "${BASH_SOURCE[0]}")/state/.done"
if [[ -e "$state_file" ]]; then
	log "State file exists at '${state_file}', skipping setup"
	while [ $need_shutdown -eq 1 ]; do sleep 2; done;
	exit 0
fi

log 'Waiting for availability of Elasticsearch. This can take several minutes.'

declare -i exit_code=0
wait_for_elasticsearch || exit_code=$?

if ((exit_code)); then
	case $exit_code in
		6)
			suberr 'Could not resolve host. Is Elasticsearch running?'
			;;
		7)
			suberr 'Failed to connect to host. Is Elasticsearch healthy?'
			;;
		28)
			suberr 'Timeout connecting to host. Is Elasticsearch healthy?'
			;;
		*)
			suberr "Connection to Elasticsearch failed. Exit code: ${exit_code}"
			;;
	esac

	exit $exit_code
fi

sublog 'Elasticsearch is running'

sublog 'Setting password'
set_user_password "kibana_system" "${KIBANA_SYSTEM_PASSWORD:-}"

mkdir -p "$(dirname "${state_file}")"
touch "$state_file"
while [ $need_shutdown -eq 1 ]; do sleep 2; done;
