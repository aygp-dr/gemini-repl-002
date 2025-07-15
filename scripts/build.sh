#!/bin/sh
# Build script for Gemini REPL
set -e
echo "Building Gemini REPL..."
npx shadow-cljs compile app
echo "Build complete!"
