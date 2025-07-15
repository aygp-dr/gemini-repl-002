#!/bin/sh
# Development script with live reload
set -e
echo "Starting development server..."
npx shadow-cljs watch app
