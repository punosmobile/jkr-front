#!/bin/sh
set -e
TEMPLATE="/usr/share/nginx/html/runtime_config.js.template"
OUTPUT="/usr/share/nginx/html/runtime_config.js"

if [ -f "$TEMPLATE" ]; then
    envsubst < "$TEMPLATE" > "$OUTPUT"
    echo "30-runtime-config.sh: runtime_config.js luotu ympäristömuuttujista"
else
    echo "30-runtime-config.sh: varoitus - $TEMPLATE puuttuu"
fi
