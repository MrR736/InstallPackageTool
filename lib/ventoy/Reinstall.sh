#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v "/usr/lib/ventoy/VentoyGUI.x86_64" &> /dev/null; then
    echo "Ventoy is Not Installed, So Cancelling Reinstall."
    exit 1
elif ! command -v "/usr/lib/ventoy/VentoyGUI.i386" &> /dev/null; then
    echo "Ventoy is Not Installed, So Cancelling Reinstall."
    exit 1
elif ! command -v "/usr/lib/ventoy/VentoyGUI.aarch64" &> /dev/null; then
    echo "Ventoy is Not Installed, So Cancelling Reinstall."
    exit 1
elif ! command -v "/usr/lib/ventoy/VentoyGUI.mips64el" &> /dev/null; then
    echo "Ventoy is Not Installed, So Cancelling Reinstall." >&2
    exit 1
fi

for cmd in chmod "./Remove.sh" "./Install.sh"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
        exit 1
    fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

reinstall_ventoy() {
echo "Reinstall Ventoy..." >&2

chmod +x ./Remove.sh &> /dev/null
chmod +x ./Install.sh &> /dev/null

./Remove.sh > /dev/null
./Install.sh -v > /dev/null

echo "Ventoy has been Reinstall Successfully." >&2
}

reinstall_ventoy
