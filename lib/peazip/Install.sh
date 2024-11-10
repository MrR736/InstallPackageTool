#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"
Tar_BIN="../../bin/tar"

if command -v peazip &> /dev/null; then
    echo "PeaZip is Already Installed, so Cancelling Installation." >&2
    exit 1
fi

for cmd in chmod curl sed mkdir awk wget grep tee cat ln rm "$ZZ_BIN" "$Tar_BIN"; do
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

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

error_upm() {
echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
rm -rf "/tmp/peazip.deb" "/tmp/peazip.rpm"
}

download_deb() {
URL=$(curl -s https://api.github.com/repos/peazip/PeaZip/releases/latest | grep '"browser_download_url":' | grep '.*\.deb' | grep "GTK" | cut -d '"' -f 4)

wget -q -O"/tmp/peazip.deb" $URL

if [[ -e "/tmp/peazip.deb" ]] && command -v apt-get &> /dev/null && command -v dpkg &> /dev/null; then
    dpkg -i /tmp/peazip.deb
    apt-get install -f
    rm -rf "/tmp/peazip.deb"
else
    error_upm
    exit 1
fi
}

download_rpm() {
if [ "$(uname -m)" == "x86_64" ]; then
    URL=$(curl -s https://api.github.com/repos/peazip/PeaZip/releases/latest | grep '"browser_download_url":' | grep '.*\.rpm' | grep "GTK" | cut -d '"' -f 4)
elif [ "$(uname -m)" == "aarch64" ]; then
    URL=https://rpmfind.net/linux/opensuse/ports/aarch64/tumbleweed/repo/oss/aarch64/$(curl -s https://rpmfind.net/linux/opensuse/ports/aarch64/tumbleweed/repo/oss/aarch64/ | grep "peazip" | grep "aarch64" | cut -d '"' -f 8)
else
    echo -e "\e[31mE: Unknown Type of Arch\e[0m" >&2
    exit 1
fi

wget -q -O"/tmp/peazip.rpm" $URL

if [[ -e "/tmp/peazip.rpm" ]] && command -v rpm &> /dev/null; then
    rpm -i /tmp/peazip.rpm
    rm -rf "/tmp/peazip.rpm"
else
    error_upm
    exit 1
fi
}

download_peazip() {
if [ "$(uname -m)" == "x86_64" ]; then
    echo "Install $software x64 version..."
    URL=$(curl -s https://api.github.com/repos/peazip/PeaZip/releases/latest | grep '"browser_download_url":' | grep '.*\.x86_64.tar.gz' | grep "peazip_portable" | grep "GTK" | grep "LINUX" | cut -d '"' -f 4)
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    echo "Install $software x32 version..."
    URL=$(curl -s https://api.github.com/repos/peazip/PeaZip/releases/tags/8.4.0 | grep '"browser_download_url":' | grep '.*\.x86.tar.gz' | grep "peazip_portable" | grep "GTK" | grep "LINUX" | cut -d '"' -f 4)
elif [ "$(uname -m)" == "aarch64" ]; then
    echo "Install $software Arm64 version..."
    URL=$(curl -s https://api.github.com/repos/peazip/PeaZip/releases/latest | grep '"browser_download_url":' | grep '.*\.aarch64.tar.gz' | grep "peazip_portable" | grep "GTK" | grep "LINUX" | cut -d '"' -f 4)
else
    echo -e "\e[31mE: Unknown Type of Arch\e[0m" >&2
    exit 1
fi

VERSION=$(echo $URL | cut -d/ -f8)
}

package_format() {
software="PeaZip"

download_peazip

if [ "$(uname -m)" == "x86_64" ]; then
    if command -v dpkg &> /dev/null && command -v apt-get &> /dev/null; then
        download_deb
    elif command -v rpm &> /dev/null; then
        download_rpm
    fi
elif [ "$(uname -m)" == "aarch64" ]; then
    if command -v rpm &> /dev/null; then
        download_rpm
    fi
else
    echo -e "\e[31mE: Unknown Type of Arch\e[0m" >&2
    exit 1
fi
}

portable_format() {
software="PeaZip"

download_peazip

mkdir -p "/tmp/peazip" "/usr/ProgramFiles/peazip/lib/peazip" "/usr/ProgramFiles/peazip/bin" &> /dev/null

wget -q -O"/tmp/peazip.tar.gz" $URL

$Tar_BIN -xzf /tmp/peazip.tar.gz -C /tmp/peazip

cp -r /tmp/peazip/*/* /usr/ProgramFiles/peazip/lib/peazip
chmod -R 755 /usr/ProgramFiles/peazip/lib/peazip/res/share
rm -rf "/tmp/peazip" "/tmp/peazip.tar.gz" "/usr/bin/pea" "/usr/bin/peazip" "/usr/share/peazip"

$ZZ_BIN x "../../libc/peazip.zip" -O"/" -y &> /dev/null

chmod 644 "/usr/share/applications/peazip.desktop"

update-desktop-database

ln -s "/usr/ProgramFiles/peazip/lib/peazip/res/share" "/usr/share/peazip"
ln -s "/usr/ProgramFiles/peazip/lib/peazip/pea" "/usr/ProgramFiles/peazip/bin/pea"
ln -s "/usr/ProgramFiles/peazip/lib/peazip/peazip" "/usr/ProgramFiles/peazip/bin/peazip"

ln -s "/usr/ProgramFiles/peazip/lib/peazip/pea" "/usr/bin/pea"
ln -s "/usr/ProgramFiles/peazip/lib/peazip/peazip" "/usr/bin/peazip"

echo "VERSION=$VERSION" | sudo tee -a /usr/ProgramFiles/peazip/Data > /dev/null
echo "peazip_type=portable_format" | sudo tee -a /usr/ProgramFiles/peazip/Data > /dev/null

echo "$software has been Install Successfully."
}

appimage_dev_format() {
software="PeaZip AppImage"

download_peazip

mkdir -p "/usr/ProgramFiles/peazip" &> /dev/null

$ZZ_BIN x "../../dev/PeaZip_Appimage.dev" -O"/usr/ProgramFiles/peazip/dev" -y &> /dev/null

$ZZ_BIN x "../../libc/peazip.zip" -O"/" -y &> /dev/null

chmod +x "/usr/ProgramFiles/peazip/dev/Install.sh"

/usr/ProgramFiles/peazip/dev/Install.sh &> /dev/null

rm -rf "/usr/ProgramFiles/peazip/dev"

ln -s "/usr/ProgramFiles/peazip/bin/peazip" "/usr/bin/peazip"

echo "VERSION=$VERSION" | sudo tee -a /usr/ProgramFiles/peazip/Data > /dev/null
echo "peazip_type=appimage_dev_format" | sudo tee -a /usr/ProgramFiles/peazip/Data > /dev/null

echo "$software has been Install Successfully."
}

type_of_install() {
read -p "What Type Of Install Format, Do You Want? [Package=p/AppImageDev=a/Portable=t/No=n]" InstallFormat

if [[ "$InstallFormat" == "t" ]]; then
    portable_format
elif [[ "$InstallFormat" == "a" ]]; then
    appimage_dev_format
elif [[ "$InstallFormat" == "p" ]]; then
    package_format
else
    echo "Abort."
    exit 1
fi
exit 1
}

if [[ "$1" == "-t" ]]; then
    portable_format
    exit 1
elif [[ "$1" == "-p" ]]; then
    package_format
    exit 1
elif [[ "$1" == "-a" ]]; then
    appimage_dev_format
    exit 1
fi

type_of_install
