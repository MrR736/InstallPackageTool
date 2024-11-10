#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

for cmd in curl sed chmod mkdir read awk wget grep tee ln rm "$ZZ_BIN"; do
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

if ! command -v "/usr/ProgramFiles/cpu-x/bin/cpu-x" &> /dev/null; then
    echo "Install CPU-X..."
else
    echo "CPU-X is Already Installed, so Cancelling Installation."
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

appimage_format() {
if ! command -v "/usr/ProgramFiles/cpu-x/bin/cpu-x" &> /dev/null; then
    mkdir -p /usr/ProgramFiles/cpu-x/bin &> /dev/null

    URL=$(curl -s https://api.github.com/repos/TheTumultuousUnicornOfDarkness/CPU-X/releases/latest | grep '"browser_download_url":' | grep '.*\.AppImage' | cut -d '"' -f 4)

    wget -q -O"/usr/ProgramFiles/cpu-x/bin/cpu-x" $URL

    chmod +x "/usr/ProgramFiles/cpu-x/bin/cpu-x"

    ln -s "/usr/ProgramFiles/cpu-x/bin/cpu-x" "/usr/bin/cpu-x"

    $ZZ_BIN x "../../libc/cpu-x.zip" -O"/" -y &> /dev/null

    chmod 644 "/usr/share/applications/cpu-x.desktop"

    update-desktop-database

    VERSION=$(curl -s https://api.github.com/repos/TheTumultuousUnicornOfDarkness/CPU-X/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')
    echo "VERSION=$VERSION" | sudo tee /usr/ProgramFiles/cpu-x/Cpu-X_Version > /dev/null
fi
}

type_of_install() {
read -p "What Type Of Install Format, Do You Want? [AppImage=a/No=n]" InstallFormat

if [[ "$InstallFormat" == "a" ]]; then
    appimage_format
else
    echo "Abort."
    exit 1
fi
exit 1
}

if [[ "$1" == "-a" ]]; then
    appimage_format
    exit 1
fi

type_of_install
