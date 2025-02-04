#!/bin/sh

# Currently a very rudimentary script

set -e

source .env
stacks=$(ls -d */)

for stack in ${stacks}
do
	cd ${stack}
	DATA_PATH=${DATA_HOME}/${stack} docker compose up -d
	cd ..
done

