#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v "/usr/lib/ventoy/VentoyGUI.x86_64" &> /dev/null; then
    exit 1
elif ! command -v "/usr/lib/ventoy/VentoyGUI.i386" &> /dev/null; then
    exit 1
elif ! command -v "/usr/lib/ventoy/VentoyGUI.aarch64" &> /dev/null; then
    exit 1
elif ! command -v "/usr/lib/ventoy/VentoyGUI.mips64el" &> /dev/null; then
    exit 1
fi

for cmd in curl echo; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
        exit 1
    fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

VENTOY_VERSION=$(cat /lib/ventoy/version)
VENTOY_LATEST_VERSION=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')

upgrade_ventoy() {
chmod +x ./Remove.sh &> /dev/null
chmod +x ./Install.sh &> /dev/null

./Remove.sh > /dev/null
./Install.sh -v > /dev/null
}

if [[ "$VENTOY_LATEST_VERSION" > "$VENTOY_VERSION" ]]; then
    echo "Updating Ventoy..."
else
    echo "You Are Already Using The Latest Version Of Ventoy: $VENTOY_VERSION"
    exit 1
fi

upgrade_ventoy

echo "Ventoy has been Update Successfully."
