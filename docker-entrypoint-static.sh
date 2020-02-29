#!/bin/bash
set -e
if [ ! -d node_modules ]; then
     yarn
fi
exec "$@"
