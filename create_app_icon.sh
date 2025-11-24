#!/bin/bash

# Script to create app icon from Odyssey.png
# This creates an .icns file and sets up the app bundle structure

ICON_SOURCE="Odyssey.png"
ICONSET_DIR="Odyssey.iconset"
ICNS_FILE="Odyssey.icns"

# Check if source image exists
if [ ! -f "$ICON_SOURCE" ]; then
    echo "Error: $ICON_SOURCE not found!"
    exit 1
fi

# Create iconset directory
rm -rf "$ICONSET_DIR"
mkdir "$ICONSET_DIR"

# Generate all required icon sizes
sips -z 16 16     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16.png"
sips -z 32 32     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16@2x.png"
sips -z 32 32     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32.png"
sips -z 64 64     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32@2x.png"
sips -z 128 128   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128.png"
sips -z 256 256   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128@2x.png"
sips -z 256 256   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256.png"
sips -z 512 512   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256@2x.png"
sips -z 512 512   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512.png"
sips -z 1024 1024 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512@2x.png"

# Create .icns file
iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE"

# Clean up iconset directory
rm -rf "$ICONSET_DIR"

echo "Created $ICNS_FILE successfully!"
echo "To use this icon, you'll need to create an app bundle structure."
echo "For now, the icon file is ready at: $ICNS_FILE"




