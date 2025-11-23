#!/bin/bash

# Build script that creates an app bundle with icon

APP_NAME="Odyssey"
APP_BUNDLE="${APP_NAME}.app"
BUILD_DIR=".build/release"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Building ${APP_NAME}..."

# Build the executable
swift build -c release

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Remove old app bundle if it exists
rm -rf "${APP_BUNDLE}"

# Create app bundle structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy executable
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"

# Copy icon if it exists
if [ -f "Odyssey.icns" ]; then
    cp "Odyssey.icns" "${RESOURCES_DIR}/"
    echo "Icon copied to app bundle"
fi

# Create Info.plist
cat > "${CONTENTS_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>Odyssey</string>
    <key>CFBundleIdentifier</key>
    <string>com.odyssey.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>book</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Odyssey Book</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>com.odyssey.book</string>
            </array>
        </dict>
    </array>
    <key>UTExportedTypeDeclarations</key>
    <array>
        <dict>
            <key>UTTypeIdentifier</key>
            <string>com.odyssey.book</string>
            <key>UTTypeDescription</key>
            <string>Odyssey Book File</string>
            <key>UTTypeTagSpecification</key>
            <dict>
                <key>public.filename-extension</key>
                <array>
                    <string>book</string>
                </array>
            </dict>
        </dict>
    </array>
</dict>
</plist>
EOF

echo "App bundle created: ${APP_BUNDLE}"
echo "You can now run it with: open ${APP_BUNDLE}"
echo "Or double-click it in Finder!"


