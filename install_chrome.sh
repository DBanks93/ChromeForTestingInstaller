
#!/bin/bash

set -e

CHROME_VERSIONS_URL=https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json
CHROME_VERSIONS=$(curl -s "$CHROME_VERSIONS_URL")
LATEST_CHROME_VERSION=$(jq '.channels.Stable.version' <<< "$CHROME_VERSIONS" | tr -d '"')

BASE_DIR="$HOME/.local/share/chrome_for_testing"

trap 'rm -f "$BASE_DIR"/*.zip;' EXIT

if [ -z "$PLATFORM" ]; then
    PLATFORM="mac-arm64"
elif [ $PLATFORM != "mac-arm64" ] && [ $PLATFORM != "mac-x64" ] && [ $PLATFORM != "linux64" ]; then
    echo "ERROR: Invalid Platform"
    exit 1
fi

if [ "$FORCE_REINSTALL" = true ]; then
    echo "⚠️ Removing previous downloads"
    rm -rf "$BASE_DIR"
fi


download_zip() {
    local type="$1"

    jq -r --arg platform "$PLATFORM" "
        .channels.Stable.downloads.$type[]
        | select(.platform == \$platform)
        | .url
    " <<< "$CHROME_VERSIONS" | xargs curl -O
}


install_tool() {
    local name="$1"
    local bin="$2"
    local install_dir="$3"
    local type="$4"

    if [[ -f "$bin" ]]; then
        local installed_version
        installed_version=$("$bin" --version | grep -oE '[0-9.]+')
         echo "🔎 Current installed $name for Testing: $installed_version"

         if [[ "$installed_version" == "$LATEST_CHROME_VERSION" ]]; then
            echo "✅ Latest version of $name already installed"
            return
        fi

        echo "⚠️ Current version $installed_version doesn't match latest version $LATEST_CHROME_VERSION"
        echo "Deleting old $name...."
        rm -rf "$install_dir"
    else
        echo "⚠️ No version of $name detected"
    fi

    echo "Installing version $LATEST_CHROME_VERSION of $name"

    mkdir -p "$BASE_DIR"
    cd "$BASE_DIR"
    download_zip $type "$PLATFORM"
    unzip -q "$type-$PLATFORM.zip" -d "$install_dir"

    if [ "$CREATE_SYMLINK" = true ]; then
        echo "Creating symlink..."
        ln -sf "$bin" "$HOME/.local/bin/$type"
    fi

    echo "✅  $name successfully installed"
    "$CHROME_BIN" --version
}


echo "-------------------- CHROME --------------------"
# Get latest Chrome version
CHROME_DIR="$BASE_DIR/chrome"

if [[  "$PLATFORM" == "linux64" ]]; then
    CHROME_BIN="$CHROME_DIR/chrome-$PLATFORM/chrome"
else
    CHROME_BIN="$CHROME_DIR/chrome-$PLATFORM/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"
fi

install_tool "Chrome for Testing" "$CHROME_BIN" "$CHROME_DIR" chrome


echo "-------------------- CHROME DRIVER --------------------"
# Get latest Chromedriver version
CHROMEDRIVER_DIR="$BASE_DIR/chromedriver"
CHROMEDRIVER_BIN="$CHROMEDRIVER_DIR/chromedriver-$PLATFORM/chromedriver"

install_tool Chromedriver $CHROMEDRIVER_BIN $CHROMEDRIVER_DIR chromedriver
