#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"
Tar_BIN="../../bin/tar"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

for cmd in curl wget awk sed grep ln cp update-mime-database echo mkdir "$ZZ_BIN" "$Tar_BIN"; do
    if ! command -v "$cmd" &> /dev/null; then
        if [[ "$ZZ_BIN" == "$cmd" ]]; then
            echo -e "\e[31mE: 7zz Is Not Installed.\e[0m" >&2
            exit 1
        elif [[ "$Tar_BIN" == "$cmd" ]]; then
            echo -e "\e[31mE: tar Is Not Installed.\e[0m" >&2
            exit 1
        else
            echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
            exit 1
        fi
    fi
done

if command -v librepcb &> /dev/null; then
    echo "Librepcb is Already Installed, so Cancelling Installation."
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

LIBREPCB_LATEST_VERSION=$(curl -s https://api.github.com/repos/LibrePCB/LibrePCB/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

add_librepcb_to_mime() {
chmod 644 "/usr/share/applications/org.librepcb.LibrePCB.desktop"

update-desktop-database

echo "application/x-librepcb-file" | sudo tee -a /usr/share/mime/types &> /dev/null
echo "application/x-librepcb-project" | sudo tee -a /usr/share/mime/types &> /dev/null
echo "application/x-librepcb-project-archive" | sudo tee -a /usr/share/mime/types &> /dev/null

echo "application/x-librepcb-file" | sudo tee -a /usr/share/mime/icons &> /dev/null
echo "application/x-librepcb-project" | sudo tee -a /usr/share/mime/icons &> /dev/null
echo "application/x-librepcb-project-archive" | sudo tee -a /usr/share/mime/icons &> /dev/null

echo "application/x-librepcb-file text/plain" | sudo tee -a /usr/share/mime/subclasses &> /dev/null
echo "application/x-librepcb-project text/plain" | sudo tee -a /usr/share/mime/subclasses &> /dev/null
echo "application/x-librepcb-project-archive application/zip" | sudo tee -a /usr/share/mime/subclasses &> /dev/null

update-mime-database /usr/share/mime
}

package_format() {
echo "Install Librepcb..."
if command -v apt &> /dev/null; then
    if ! sudo apt install librepcb &> /dev/null; then
        echo -e "\e[31mE: Failed to install LibrePCB using apt.\e[0m" >&2
        exit 1
    fi
elif command -v dnf &> /dev/null; then
    if ! sudo dnf install librepcb &> /dev/null; then
        echo -e "\e[31mE: Failed to install LibrePCB using dnf.\e[0m" >&2
        exit 1
    fi
elif command -v yum &> /dev/null; then
    if ! sudo yum install librepcb &> /dev/null; then
        echo -e "\e[31mE: Failed to install LibrePCB using yum.\e[0m" >&2
        exit 1
    fi
elif command -v snap &> /dev/null; then
    if ! sudo snap install librepcb &> /dev/null; then
        echo -e "\e[31mE: Failed to install LibrePCB using snap.\e[0m" >&2
        exit 1
    fi
elif command -v nix-shell &> /dev/null; then
    if ! nix-shell -p librepcb &> /dev/null; then
        echo -e "\e[31mE: Failed to install LibrePCB using nix-shell.\e[0m" >&2
        exit 1
    fi
elif command -v flatpak &> /dev/null; then
    if ! flatpak install flathub org.librepcb.LibrePCB &> /dev/null; then
        echo -e "\e[31mE: Failed to install LibrePCB using flatpak.\e[0m" >&2
        exit 1
    fi
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
    exit 1
fi
}

appimage_format() {
echo "Install Librepcb..."

mkdir -p /usr/ProgramFiles/librepcb/bin &> /dev/null

wget -q -O"/usr/ProgramFiles/librepcb/bin/librepcb" https://download.librepcb.org/releases/$LIBREPCB_LATEST_VERSION/librepcb-$LIBREPCB_LATEST_VERSION-linux-x86_64.AppImage

wget -q -O"/usr/ProgramFiles/librepcb/bin/librepcb-cli" https://download.librepcb.org/releases/$LIBREPCB_LATEST_VERSION/librepcb-cli-$LIBREPCB_LATEST_VERSION-linux-x86_64.AppImage

rm -rf "/usr/bin/librepcb" "/usr/bin/librepcb-cli"

$ZZ_BIN x "../../libc/librepcb.zip" -O"/" -y &> /dev/null

chmod +x "/usr/ProgramFiles/librepcb/bin/librepcb"
chmod +x "/usr/ProgramFiles/librepcb/bin/librepcb-cli"

ln -s "/usr/ProgramFiles/librepcb/bin/librepcb" "/usr/bin/librepcb"
ln -s "/usr/ProgramFiles/librepcb/bin/librepcb-cli" "/usr/bin/librepcb-cli"

add_librepcb_to_mime

echo "librepcb_type=appimage_format" | sudo tee /usr/ProgramFiles/librepcb/Data > /dev/null

echo "Librepcb has been Install successfully."
}

portable_format() {
echo "Install Librepcb..."

wget -q -O"/tmp/librepcb.tar.gz" https://download.librepcb.org/releases/$LIBREPCB_LATEST_VERSION/librepcb-$LIBREPCB_LATEST_VERSION-linux-x86_64.tar.gz

mkdir -p "/usr/ProgramFiles/librepcb" "/tmp/librepcb" &> /dev/null

$Tar_BIN -xzf "/tmp/librepcb.tar.gz" -C "/tmp/librepcb" &> /dev/null

cp -r /tmp/librepcb/*/* /usr/ProgramFiles/librepcb

$ZZ_BIN x "../../libc/librepcb.zip" -O"/" -y &> /dev/null

rm -rf "/tmp/librepcb.tar.gz" "/tmp/librepcb" "/usr/bin/librepcb" "/usr/bin/librepcb-cli"

ln -s "/usr/ProgramFiles/librepcb/bin/librepcb" "/usr/bin/librepcb"
ln -s "/usr/ProgramFiles/librepcb/bin/librepcb-cli" "/usr/bin/librepcb-cli"

add_librepcb_to_mime

echo "librepcb_type=portable_format" | sudo tee /usr/ProgramFiles/librepcb/Data > /dev/null

echo "Librepcb has been Install successfully."
}

type_of_install() {
read -p "What Type Of Install Format, Do You Want? [Package=p/Portable=t/AppImage=a/No=n]" InstallFormat

if [[ "$InstallFormat" == "p" ]]; then
    package_format
elif [[ "$InstallFormat" == "a" ]]; then
    appimage_format
elif [[ "$InstallFormat" == "t" ]]; then
    portable_format
else
    echo "Abort."
    exit 1
fi
exit 1
}

if [[ "$1" == "-p" ]]; then
    package_format
    exit 1
elif [[ "$1" == "-a" ]]; then
    appimage_format
    exit 1
elif [[ "$1" == "-t" ]]; then
    portable_format
    exit 1
fi

type_of_install
