#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if ! command -v "/usr/ProgramFiles/appimagekit/AppRun" &> /dev/null; then
    exit 1
fi

for cmd in chmod curl wget "$ZZ_BIN"; do
    if ! command -v "$cmd" &> /dev/null; then
        if [[ "$ZZ_BIN" != "$cmd" ]]; then
            echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
            exit 1
        else
            echo -e "\e[31mE: 7zz Is Not Installed.\e[0m" >&2
            exit 1
        fi
    fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

remove_appimagetool() {
}

upgrade_appimagetool() {
AppImageTool_LATEST_VERSION=$(curl -s https://api.github.com/repos/AppImage/AppImageKit/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

list_file="/usr/ProgramFiles/appimagekit/Data"

if [[ ! -f "$list_file" ]]; then
    echo -e "\e[31mE: Type file not found: $list_file\e[0m" >&2
    exit 1
fi

VERSION=""
while IFS= read -r line; do
    case "$line" in
        VERSION=*)
            AppImageTool_VERSION="${line#VERSION=}"
            ;;
    esac
done < "$list_file"

if [[ "$AppImageTool_LATEST_VERSION" > "$AppImageTool_VERSION" ]]; then
    echo "Updating AppImageTool..."
else
    echo "You Are Already Using The Latest Version Of AppImageTool: $AppImageTool_VERSION"
    exit 1
fi

chmod +x ./Remove.sh &> /dev/null
chmod +x ./Install.sh &> /dev/null

./Remove.sh > /dev/null
./Install.sh -a > /dev/null
}

upgrade_appimagetool
