#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v scratch-desktop &> /dev/null; then
    echo "Scratch Desktop is Not Installed, So Cancelling Reinstall." >&2
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

reinstall_librepcb() {
if [ "$(uname -m)" == "x86_64" ]; then
    echo "Reinstall Scratch Desktop x64 version..." >&2
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    echo "Reinstall Scratch Desktop x32 version..." >&2
fi

./Remove.sh > /dev/null
./Install.sh -p > /dev/null

echo "Librepcb has been Reinstall Successfully." >&2
}

reinstall_librepcb
