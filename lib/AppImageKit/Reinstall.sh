#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v "/usr/ProgramFiles/appimagekit/AppRun" &> /dev/null; then
    echo "AppImage Tool is Not Installed, So Cancelling Reinstall." >&2
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

reinstall_appimagetool() {
./Remove.sh > /dev/null
./Install.sh -a > /dev/null

echo "AppImage Tool has been Reinstall Successfully." >&2
}

reinstall_appimagetool
