#!/bin/bash

# Currently a very rudimentary script
set -e

# Fetch latest
git stash
git pull

# Fetch global environment variables
source .env
stacks=$(ls -d */)

update_env() {
    local env_file=".env"
    local var_name="$1"
    local new_value="$2"

    # Check if .env file exists
    if [[ -f "$env_file" ]]; then
        # Update variable if it exists, else append it
        grep -q "^$var_name=" "$env_file" && sed -i '' -E "s/^$var_name=.*/$var_name=$new_value/" "$env_file" || echo "$var_name=$new_value" >> "$env_file"
    else
        echo "$env_file does not exist."
    fi
}

for stack in ${stacks}
do
	cd ${stack}
	update_env DATA_PATH ${DATA_HOME}/${stack}
	DATA_PATH=${DATA_HOME}/${stack} docker compose up -d
	cd ..
done

