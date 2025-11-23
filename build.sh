#!/bin/bash

# Build script for Odyssey macOS app

echo "Building Odyssey..."
swift build -c release

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Run with: swift run"
else
    echo "Build failed!"
    exit 1
fi


