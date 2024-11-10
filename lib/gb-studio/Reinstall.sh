#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

if ! command -v gb-studio &> /dev/null; then
    echo "GB Studio is Not Installed, So Cancelling Reinstall." >&2
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

reinstall_gb_studio() {
echo "Reinstall GB Studio x64 version..." >&2

if command -v "/usr/ProgramFiles/gb-studio/bin/gb-studio" &> /dev/null; then
    ./Remove.sh > /dev/null
    ./Install.sh -a > /dev/null
else
    ./Remove.sh > /dev/null
    ./Install.sh -p > /dev/null
fi

echo "GB Studio has been Reinstall Successfully." >&2
}

reinstall_gb_studio
