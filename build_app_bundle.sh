#!/bin/bash

# Build script that creates an app bundle with icon

APP_NAME="Odyssey"
VERSION="1.2.0"
BUILD_NUMBER="120"
APP_BUNDLE="${APP_NAME}.app"
BUILD_DIR=".build/release"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
SIGN_IDENTITY="${SIGN_IDENTITY:-}"

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
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026</string>
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

if [ -z "${SIGN_IDENTITY}" ]; then
    DEFAULT_IDENTITY=$(security find-identity -v -p codesigning 2>/dev/null | grep "Apple Development:" | head -n 1 | sed -E 's/.*"(.+)"/\1/')
    if [ -n "${DEFAULT_IDENTITY}" ]; then
        SIGN_IDENTITY="${DEFAULT_IDENTITY}"
    else
        SIGN_IDENTITY="-"
    fi
fi

echo "Signing app bundle with: ${SIGN_IDENTITY}"
codesign --force --deep --sign "${SIGN_IDENTITY}" "${APP_BUNDLE}"

if [ $? -ne 0 ]; then
    echo "Code signing failed!"
    exit 1
fi

echo "App bundle created: ${APP_BUNDLE} (${VERSION})"
echo "You can now run it with: open ${APP_BUNDLE}"
echo "Or double-click it in Finder!"


