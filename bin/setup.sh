#!/usr/bin/env bash
GID=$(id -g ${USER})

docker-compose run --rm -u ${UID}:${GID} ruby bundle install
