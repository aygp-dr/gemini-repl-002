#!/bin/sh
# Development environment setup
set -e

echo "Setting up Gemini REPL development environment..."

# Check for Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "Error: Node.js is required but not installed"
    exit 1
fi

# Check for npm
if ! command -v npm >/dev/null 2>&1; then
    echo "Error: npm is required but not installed"
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
npm install

# Create necessary directories
echo "Creating directories..."
mkdir -p logs
mkdir -p resources
mkdir -p target

# Check for .env file
if [ ! -f .env ]; then
    echo "Creating .env from template..."
    cp .env.example .env
    echo "Please edit .env and add your GEMINI_API_KEY"
fi

# Generate banner if it doesn't exist
if [ ! -f resources/repl-banner.txt ]; then
    echo "Generating banner..."
    if command -v toilet >/dev/null 2>&1; then
        toilet -f future "Gemini REPL" > resources/repl-banner.txt
    else
        echo "=== Gemini REPL ===" > resources/repl-banner.txt
    fi
fi

echo "Development environment ready!"
echo "Run 'gmake dev' to start development server"
