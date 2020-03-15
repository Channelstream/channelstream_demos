#!/bin/bash
set -e
if [ -n "${USER_UID}" ]; then
  usermod -u $USER_UID application
fi
if [ -n "${USER_GID}" ]; then
  groupmod -g $USER_GID application
fi

cd /opt/application/frontend

if [ ! -d node_modules ]; then
     gosu application yarn
fi
gosu application "$@"
