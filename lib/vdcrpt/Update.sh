#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if ! command -v "/usr/ProgramFiles/vdcrpt/bin/vdcrpt" &> /dev/null; then
    exit 1
fi

for cmd in chmod curl wget cut sed mkdir grep case awk while mv ln update-desktop-database rm "$ZZ_BIN"; do
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

upgrade_vdcrpt() {
VDCRPT_LATEST_VERSION=$(curl -s https://api.github.com/repos/branchpanic/vdcrpt/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')

list_file="/usr/ProgramFiles/vdcrpt/Version"

if [[ ! -f "$list_file" ]]; then
    echo -e "\e[31mE: Unknown Version\e[0m" >&2
    exit 1
fi

VDCRPT_VERSION=""
while IFS= read -r line; do
    case "$line" in
        VERSION=*)
            VDCRPT_VERSION="${line#VERSION=}"
            ;;
    esac
done < "$list_file"


if [[ "$VDCRPT_LATEST_VERSION" > "$VDCRPT_VERSION" ]]; then
    echo "Updating Godot..."
else
    echo "You Are Already Using The Latest Version Of VdCrpt: $VDCRPT_VERSION"
    exit 1
fi

chmod +x ./Remove.sh &> /dev/null
chmod +x ./Install.sh &> /dev/null

./Remove.sh > /dev/null
./Install.sh -v > /dev/null
}

upgrade_vdcrpt
