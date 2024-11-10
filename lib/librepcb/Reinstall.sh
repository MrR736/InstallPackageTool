#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

if ! command -v librepcb &> /dev/null; then
    echo "Librepcb is Not Installed, So Cancelling Reinstall." >&2
    exit 1
fi

for cmd in chmod while case "./Remove.sh" "./Install.sh"; do
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
list_file="/usr/ProgramFiles/librepcb/Data"

echo "Reinstall Librepcb x64 version..." >&2

chmod +x ./Remove.sh &> /dev/null
chmod +x ./Install.sh &> /dev/null

if [[ -f "$list_file" ]]; then
    librepcb_type=""
    while IFS= read -r line; do
        case "$line" in
                librepcb_type=*)
                    update_librepcb_type="${line#librepcb_type=}"
                    ;;
        esac
    done < "$list_file"
else
    ./Remove.sh > /dev/null
    ./Install.sh -p > /dev/null
fi

if [[ "$update_librepcb_type" == "portable_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -t > /dev/null
elif [[ "$update_librepcb_type" == "appimage_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -a > /dev/null
fi

echo "Librepcb has been Reinstall Successfully." >&2
}

reinstall_librepcb
