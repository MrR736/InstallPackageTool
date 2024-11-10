#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v peazip &> /dev/null; then
    exit 1
fi

for cmd in whoami uname curl chmod while case awk sed grep; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
        exit 1
    fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

upgrade_peazip_package() {
if command -v apt &> /dev/null; then
    if ! sudo apt upgrade -y peazip &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade PeaZip using apt.\e[0m" >&2
    fi
elif command -v dnf &> /dev/null; then
    if ! sudo dnf upgrade -y peazip &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade PeaZip using dnf.\e[0m" >&2
    fi
elif command -v yum &> /dev/null; then
    if ! sudo yum upgrade -y peazip &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade PeaZip using yum.\e[0m" >&2
    fi
elif command -v snap &> /dev/null; then
    if ! sudo snap refresh peazip &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade PeaZip using snap.\e[0m" >&2
    fi
elif command -v nix-shell &> /dev/null; then
    if ! nix-shell -u peazip &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade PeaZip using nix-shell.\e[0m" >&2
    fi
elif command -v flatpak &> /dev/null; then
    if ! flatpak upgrade flathub org.peazip.PeaZip &> /dev/null; then
        echo -e "\e[31mE: Failed To Upgrade PeaZip using flatpak.\e[0m" >&2
    fi
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m"
fi
}

upgrade_peazip() {
if [ "$(uname -m)" == "x86_64" ] || [ "$(uname -m)" == "aarch64" ]; then
    PEAZIP_LATEST_VERSION=$(curl -s https://api.github.com/repos/peazip/PeaZip/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    PEAZIP_LATEST_VERSION=8.4.0
fi

list_file="/usr/ProgramFiles/peazip/Data"

if [[ -f "$list_file" ]]; then
    PEAZIP_VERSION=""
    update_peazip_type=""
    while IFS= read -r line; do
        case "$line" in
            VERSION=*)
                PEAZIP_VERSION="${line#VERSION=}"
                ;;
            peazip_type=*)
                update_peazip_type="${line#peazip_type=}"
                ;;
        esac
    done < "$list_file"
else
    PEAZIP_VERSION=$(dpkg -l | grep peazip | awk '{print $3}')
fi

if [[ "$PEAZIP_LATEST_VERSION" > "$PEAZIP_VERSION" ]]; then
    echo "Updating PeaZip..."
else
    echo "You Are Already Using The Latest Version Of PeaZip: $PEAZIP_VERSION"
    exit 1
fi

chmod +x ./Remove.sh &> /dev/null
chmod +x ./Install.sh &> /dev/null

if [[ ! -f "$list_file" ]]; then
    upgrade_peazip_package
    exit 1
elif [[ "$update_peazip_type" == "appimage_dev_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -a > /dev/null
    exit 1
elif [[ "$update_peazip_type" == "portable_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -t > /dev/null
    exit 1
fi
}

upgrade_peazip
