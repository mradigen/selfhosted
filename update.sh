#!/bin/bash

# Currently a very rudimentary script
set -e

update_env() {
	local ENV_FILE=".env"
	local VAR_NAME="$1"
	local NEW_VALUE="$2"

	if grep -q "^$VAR_NAME=" "$ENV_FILE"; then
		sed -i "s|^$VAR_NAME=.*|$VAR_NAME=$NEW_VALUE|" "$ENV_FILE"
	else
		echo "$VAR_NAME=$NEW_VALUE" >> "$ENV_FILE"
	fi
}

# Fetch global environment variables
source .env
stacks=(baikal balti balti-minio borgmatic chota flatnotes+syncthing headscale immich kachra n8n paperless-ng traefik tui_suite vaultwarden)

# Stop all services:
for stack in ${stacks[@]}
do
	cd ${stack}
	update_env DATA_PATH "${DATA_HOME}/${stack}"
	docker compose down
	cd ..
done

# Fetch latest
git stash
git pull

stacks=(baikal balti balti-minio borgmatic chota flatnotes+syncthing headscale immich kachra n8n paperless-ng traefik tui_suite vaultwarden)

# Start them back up
for stack in ${stacks[@]}
do
	cd ${stack}
	update_env DATA_PATH "${DATA_HOME}/${stack}"
	docker compose pull
	docker compose up -d
	cd ..
done
