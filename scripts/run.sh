#!/bin/sh
# Run the compiled REPL
set -e
if [ ! -f target/main.js ]; then
    echo "Application not built. Running build first..."
    ./scripts/build.sh
fi
node target/main.js
