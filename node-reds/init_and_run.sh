#!/bin/bash
# cd into this sh file directory
cd "$(dirname "$0")"

# To do: check if .env exist or use template
set -a
. ../.env # add env vars
set +a

set -o errexit # make sure script stops in case of errors
./add_ssh_then_compose_up.sh --build
./clone_projects.sh
./add_secret.sh
set +o errexit