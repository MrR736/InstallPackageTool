#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

if ! command -v librepcb &> /dev/null; then
    exit 1
fi

for cmd in curl wget awk sed grep ln rm update-mime-database echo mkdir "$ZZ_BIN"; do
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

Librepcb_VERSION=$(librepcb-cli --version | grep "LibrePCB CLI Version" | sed 's/LibrePCB CLI Version//g' | sed 's/ //g')
LIBREPCB_LATEST_VERSION=$(curl -s https://api.github.com/repos/LibrePCB/LibrePCB/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

handle_error() {
    echo -e "\e[31mE: Failed to upgrade LibrePCB using $1.\e[0m" >&2
    exit 1
}

package_upgrade_librepcb() {
    case "$1" in
        apt)
            sudo apt upgrade librepcb ;;
        dnf)
            sudo dnf upgrade librepcb ;;
        yum)
            sudo yum upgrade librepcb ;;
        snap)
            sudo snap upgrade librepcb ;;
        nix-env)
            nix-env -u librepcb ;;
        flatpak)
            flatpak upgrade flathub org.librepcb.LibrePCB ;;
        *)
            echo -e "\e[31mE: Unsupported package manager.\e[0m" >&2
            exit 1 ;;
    esac
}

package_format() {
if command -v apt &> /dev/null; then
    package_upgrade_librepcb apt || handle_error "apt"
elif command -v dnf &> /dev/null; then
    package_upgrade_librepcb dnf || handle_error "dnf"
elif command -v yum &> /dev/null; then
    package_upgrade_librepcb yum || handle_error "yum"
elif command -v snap &> /dev/null; then
    package_upgrade_librepcb snap || handle_error "snap"
elif command -v nix-shell &> /dev/null; then
    package_upgrade_librepcb nix-shell || handle_error "nix-shell"
elif command -v flatpak &> /dev/null; then
    package_upgrade_librepcb flatpak || handle_error "flatpak"
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
    exit 1
fi
}

upgrade_librepcb() {
list_file="/usr/ProgramFiles/librepcb/Data"

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
    package_format
fi

if [[ "$update_librepcb_type" == "portable_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -t > /dev/null
elif [[ "$update_librepcb_type" == "appimage_format" ]]; then
    ./Remove.sh > /dev/null
    ./Install.sh -a > /dev/null
fi
}

if [[ "$LIBREPCB_LATEST_VERSION" > "$Librepcb_VERSION" ]]; then
    echo "Updating Librepcb..."
else
    echo "You Are Already Using The Latest Version Of Librepcb: $Librepcb_VERSION"
    exit 1
fi

upgrade_librepcb

echo "Librepcb has been Update Successfully."
