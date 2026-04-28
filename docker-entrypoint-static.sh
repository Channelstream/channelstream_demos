#!/bin/bash
set -e
if [ -n "${USER_UID}" ]; then
  usermod -u $USER_UID application
fi
if [ -n "${USER_GID}" ]; then
  groupmod -g $USER_GID application
fi

cd /opt/application/frontend

# Install deps the first time the bind-mounted source is started.
if [ ! -d node_modules ]; then
     gosu application npm install
fi
gosu application "$@"
