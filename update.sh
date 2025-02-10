#!/bin/bash

# Currently a very rudimentary script
set -e

# Fetch latest
git stash
git pull

# Fetch global environment variables
source .env
stacks=$(ls -d */ | sed 's:/$::')

update_env() {
	local ENV_FILE=".env"
	local VAR_NAME="$1"
	local NEW_VALUE="$2"

	if [[ -f "$ENV_FILE" ]]; then
		if grep -q "^$VAR_NAME=" "$ENV_FILE"; then
			sed -i "s|^$VAR_NAME=.*|$VAR_NAME=$NEW_VALUE|" "$ENV_FILE"
		else
			echo "$VAR_NAME=$NEW_VALUE" >> "$ENV_FILE"
		fi
	else
		echo "$ENV_FILE does not exist."
	fi
}

for stack in ${stacks}
do
	cd ${stack}
	update_env DATA_PATH "${DATA_HOME}/${stack}"
	DATA_PATH=${DATA_HOME}/${stack} docker compose up -d
	cd ..
done
