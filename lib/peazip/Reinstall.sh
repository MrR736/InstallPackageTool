#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v peazip &> /dev/null; then
    echo "PeaZip is Not Installed, So Cancelling Reinstall." >&2
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

reinstall_peazip() {
list_file="/usr/ProgramFiles/peazip/Data"

if [[ -f "$list_file" ]]; then
    PEAZIP_VERSION=""
    reinstall_peazip_type=""
    while IFS= read -r line; do
        case "$line" in
            peazip_type=*)
                reinstall_peazip_type="${line#peazip_type=}"
                ;;
        esac
    done < "$list_file"
fi

if [ "$(uname -m)" == "x86_64" ]; then
    echo "Reinstall PeaZip x64 version..." >&2
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    echo "Reinstall PeaZip x32 version..." >&2
elif [ "$(uname -m)" == "aarch64" ]; then
    echo "Reinstall PeaZip Arm64 version..." >&2
fi

chmod +x ./Remove.sh &> /dev/null
chmod +x ./Install.sh &> /dev/null

if [[ ! -f "$list_file" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -p > /dev/null
elif [[ "$reinstall_peazip_type" == "appimage_dev_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -a > /dev/null
elif [[ "$reinstall_peazip_type" == "portable_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -t > /dev/null
fi

echo "PeaZip has been Reinstall Successfully." >&2
}

reinstall_peazip
