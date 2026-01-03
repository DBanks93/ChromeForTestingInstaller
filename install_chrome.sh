
#!/bin/bash

set -e

CHROME_VERSIONS_URL=https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json
CHROME_VERSIONS=$(curl -s "$CHROME_VERSIONS_URL")
LATEST_CHROME_VERSION=$(jq '.channels.Stable.version' <<< "$CHROME_VERSIONS" | tr -d '"')

DIR="$HOME/.local/share/chrome_for_testing"

if [ -z "$PLATFORM" ]; then
    PLATFORM="mac-arm64"
elif [ $PLATFORM != "mac-arm64" ] && [ $PLATFORM != "mac-x64" ] && [ $PLATFORM != "linux64" ]; then
    echo "ERROR: Invalid Platform"
    exit 1
fi

if [ "$FORCE_REINSTALL" = true ]; then
    rm -rf "$DIR"
fi

echo "-------------------- CHROME --------------------"
# Get latest Chrome version
CHROME_DIR="$DIR/chrome"

if [[  "$PLATFORM" == "linux64" ]]; then
    CHROME_BIN="$CHROME_DIR/chrome-$PLATFORM/chrome"
else
    CHROME_BIN="$CHROME_DIR/chrome-$PLATFORM/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"
fi

INSTALL_CHROME=true

if [[ -f "$CHROME_BIN" ]]; then
    INSTALLED_VERSION=$("$CHROME_BIN" --version | awk '{print $5}')
    echo "🔎 Current installed Chrome for Testing: $INSTALLED_VERSION"
    if [[ "$INSTALLED_VERSION" == "$LATEST_CHROME_VERSION" ]]; then
        echo "✅ Lastest version of Chrome for Testing already installed"
        INSTALL_CHROME=false
    else
        echo "⚠️ Current version $INSTALLED_VERSION doesn't match latest version $LATEST_CHROME_VERSION"
        echo "Deleting old Chrome...."
        rm -rf "$CHROME_DIR"
    fi
else
    echo "⚠️ No version of Chrome detected"
fi

if [ "$INSTALL_CHROME" = true ]; then
    echo "Installing version $LATEST_CHROME_VERSION of Chrome for Testing"

    mkdir -p "$DIR"
    cd "$DIR"

    curl -O "$(
        jq -r --arg platform "$PLATFORM" '
            .channels.Stable.downloads.chrome
            | .[]
            | select(.platform == $platform)
            | .url
        ' <<< "$CHROME_VERSIONS"
        )"

    unzip -q "chrome-$PLATFORM.zip" -d "$CHROME_DIR"

    if [ "$CREATE_SYMLINK" = true ]; then
        echo "Creating symlink..."
        ln -sf "$CHROME_BIN" "$HOME/.local/bin/chrome"
    fi

    echo "✅  Chrome sucesfully installed"
    "$CHROME_BIN" --version
fi

echo "-------------------- CHROME DRIVER --------------------"
# Get latest Chromedriver version
CHROMEDRIVER_DIR="$DIR/chromedriver"
CHROMEDRIVER_BIN="$CHROMEDRIVER_DIR/chromedriver-$PLATFORM/chromedriver"

INSTALL_CHROMEDRIVER=true

if [[ -f "$CHROMEDRIVER_BIN" ]]; then
    INSTALLED_VERSION=$("$CHROMEDRIVER_BIN" --version | awk '{print $2}')
    echo "🔎 Current installed Chromedriver: $INSTALLED_VERSION"
    if [[ "$INSTALLED_VERSION" == "$LATEST_CHROME_VERSION" ]]; then
        echo "✅ Lastest version of Chromedriver already installed"
        INSTALL_CHROMEDRIVER=false
    else
        echo "⚠️ Current version $INSTALLED_VERSION doesn't match latest version $LATEST_CHROME_VERSION"
        echo "Deleting old Chromedriver...."
        rm -rf "$CHROMEDRIVER_DIR"
    fi
else
    echo "⚠️ No version of Chromedriver detected"
fi

if [ "$INSTALL_CHROMEDRIVER" = true ]; then
    echo "Installing version $LATEST_CHROME_VERSION of Chromedriver"

    mkdir -p "$DIR"
    cd "$DIR"

    curl -O "$(
        jq -r --arg platform "$PLATFORM" '
            .channels.Stable.downloads.chromedriver
            | .[]
            | select(.platform == $platform)
            | .url
        ' <<< "$CHROME_VERSIONS"
        )"

    unzip -q "chromedriver-$PLATFORM.zip" -d "$CHROMEDRIVER_DIR"

    if [ "$CREATE_SYMLINK" = true ]; then
        echo "Creating symlink..."
        ln -sf "$CHROMEDRIVER_BIN" "$HOME/.local/bin/chromedriver"
    fi

    echo "✅ Chromedrvier sucesfully instsalled"
    "$CHROMEDRIVER_BIN" --version
fi

rm -f "$DIR"/*.zip
