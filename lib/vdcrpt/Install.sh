#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

for cmd in chmod curl sed mkdir awk wget grep update-desktop-database tee cat ln rm "$ZZ_BIN"; do
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

if command -v "/usr/ProgramFiles/vdcrpt/bin/vdcrpt" &> /dev/null; then
    echo "VdCrpt is Already Installed, so Cancelling Installation."
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

vdcrpt_format() {
echo "Install VdCrpt x64 version..."

URL=$(curl -s https://api.github.com/repos/branchpanic/vdcrpt/releases/latest | grep '"browser_download_url":' | grep '.*\linux-x64.zip' | cut -d '"' -f 4)

mkdir -p /usr/ProgramFiles/vdcrpt/bin &> /dev/null

wget -q -O"/tmp/vdcrpt.zip" $URL

$ZZ_BIN x "../../libc/vdcrpt.zip" -O"/" -y &> /dev/null
$ZZ_BIN x "/tmp/vdcrpt.zip" -O"/tmp/vdcrpt" -y &> /dev/null
rm -rf "/tmp/vdcrpt.zip"

mv /tmp/vdcrpt/*.AppImage "/usr/ProgramFiles/vdcrpt/bin/vdcrpt"

chmod +x "/usr/ProgramFiles/vdcrpt/bin/vdcrpt"

chmod 644 "/usr/share/applications/vdcrpt.desktop"

update-desktop-database

rm -rf "/tmp/vdcrpt" "/usr/bin/vdcrpt"
ln -s "/usr/ProgramFiles/vdcrpt/bin/vdcrpt" "/usr/bin/vdcrpt"

vdcrpt_VERSION=$(curl -s https://api.github.com/repos/branchpanic/vdcrpt/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')
echo "VERSION=$vdcrpt_VERSION" | sudo tee /usr/ProgramFiles/vdcrpt/Version > /dev/null

echo "VdCrpt has been Install successfully."
}

type_of_install() {
read -p "What Type Of Install Format, Do You Want? [VdCrpt=v/No=n]" InstallFormat

if [[ "$InstallFormat" == "v" ]]; then
    vdcrpt_format
else
    echo "Abort."
    exit 1
fi
exit 1
}

if [[ "$1" == "-v" ]]; then
    vdcrpt_format
    exit 1
fi

type_of_install
