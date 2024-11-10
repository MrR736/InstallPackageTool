#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m" >&2
    exit 1
fi

if ! command -v gb-studio &> /dev/null; then
    exit 1
fi

for cmd in curl sed mkdir awk wget grep tee cat ln rm "$ZZ_BIN"; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "\e[31mE: $cmd Is Not Installed.\e[0m" >&2
    exit 1
  fi
done

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m" >&2
    exit 1
fi

package_format() {
if command -v dpkg &> /dev/null && ! command -v gb-studio &> /dev/null; then
    URL=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep '"browser_download_url":' | grep '.*\.deb' | cut -d '"' -f 4)
    wget -q -O"/tmp/gb-studio.deb" "$URL"
elif command -v rpm &> /dev/null && ! command -v gb-studio &> /dev/null; then
    URL=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep '"browser_download_url":' | grep '.*\.rpm' | cut -d '"' -f 4)
    wget -q -O"/tmp/gb-studio.rpm" "$URL"
else
    echo -e "\e[31mE: Unknown This Linux System.\e[0m" >&2
    exit 1
fi

if [[ -e "/tmp/gb-studio.deb" ]]; then
    if ! command -v apt-get &> /dev/null; then
        echo -e "\e[31mE: apt-get Is Not Installed.\e[0m" >&2
        exit 1
    fi

    if ! command -v dpkg &> /dev/null; then
        echo -e "\e[31mE: dpkg Is Not Installed.\e[0m" >&2
        exit 1
    fi

    {
        dpkg -i /tmp/gb-studio.deb && \
        apt-get install -f && \
        rm -rf "/tmp/gb-studio.deb"
    } || {
        echo -e "\e[31mE: Installation failed.\e[0m" >&2
        rm -f "/tmp/gb-studio.deb"  # Ensure cleanup on failure
        exit 1
    }
elif [[ -e "/tmp/gb-studio.rpm" ]]; then
    if ! command -v rpm &> /dev/null; then
        echo -e "\e[31mE: rpm Is Not Installed.\e[0m" >&2
        exit 1
    fi

    {
        rpm -i /tmp/gb-studio.rpm && \
        rm -rf "/tmp/gb-studio.rpm"
    } || {
        echo -e "\e[31mE: Installation failed.\e[0m" >&2
        rm -f "/tmp/gb-studio.rpm"  # Ensure cleanup on failure
        exit 1
    }
else
    echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
    exit 1
fi
}

appimage_format() {
mkdir -p /usr/ProgramFiles/gb-studio/bin &> /dev/null

URL=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep '"browser_download_url":' | grep '.*\.AppImage' | cut -d '"' -f 4)

wget -q -O"/usr/ProgramFiles/gb-studio/bin/gb-studio" $URL

chmod +x "/usr/ProgramFiles/gb-studio/bin/gb-studio"

ln -s "/usr/ProgramFiles/gb-studio/bin/gb-studio" "/usr/bin/gb-studio"

$ZZ_BIN x "../../libc/gb-studio.zip" -O"/" -y &> /dev/null

chmod 644 "/usr/share/applications/gb-studio.desktop"

update-desktop-database

VERSION=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')
echo "VERSION=$VERSION" | sudo tee /usr/ProgramFiles/gb-studio/gb-studio_Version > /dev/null
}

remove_gb_studio() {
if command -v "/usr/ProgramFiles/gb-studio/bin/gb-studio" &> /dev/null; then
    rm -rf "~/.config/GB Studio" "/usr/share/pixmaps/gb-studio.png" "/usr/share/applications/gb-studio.desktop" "/usr/share/doc/gb-studio" "/usr/share/lintian/overrides/gb-studio" "/usr/bin/gb-studio" "/usr/ProgramFiles/gb-studio"
else
    if command -v yum &> /dev/null; then
        if ! yum remove -y gb-studio; then
            echo -e "\e[31mE: Failed to remove gb-studio using yum.\e[0m" >&2
            exit 1
        fi
    elif command -v apt &> /dev/null; then
        if ! apt autoremove -y gb-studio; then
            echo -e "\e[31mE: Failed to remove gb-studio using apt.\e[0m" >&2
            exit 1
        fi
    elif command -v dnf &> /dev/null; then
        if ! dnf remove -y gb-studio; then
            echo -e "\e[31mE: Failed to remove gb-studio using dnf.\e[0m" >&2
            exit 1
        fi
    else
        echo -e "\e[31mE: No supported package manager found.\e[0m" >&2
        exit 1
    fi
fi

rm -rf "~/.config/GB Studio" "/usr/share/pixmaps/gb-studio.png" "/usr/share/applications/gb-studio.desktop" "/usr/share/doc/gb-studio" "/usr/share/lintian/overrides/gb-studio" "/usr/bin/gb-studio" "/usr/ProgramFiles/gb-studio"
}


update_gb_studio() {
list_file="/usr/ProgramFiles/gb-studio/Version"

if [[ ! -f "$list_file" ]]; then
    echo -e "\e[31mE: Unknown Version\e[0m" >&2
    exit 1
fi

gb_studio_VERSION=""
while IFS= read -r line; do
    case "$line" in
        VERSION=*)
            gb_studio_VERSION="${line#VERSION=}"
            ;;
    esac
done < "$list_file"
}

if command -v "/usr/ProgramFiles/gb-studio/bin/gb-studio" &> /dev/null; then
    update_gb_studio
else
    if command -v dpkg &> /dev/null; then
        gb_studio_VERSION=$(dpkg -l | grep gb-studio | awk '{print $3}')
        gb_studio_VERSION="${gb_studio_VERSION%-*}"
    elif command -v rpm &> /dev/null; then
        gb_studio_VERSION=$(rpm -q --queryformat '%{VERSION}' gb-studio)
    else
        echo -e "\e[31mE: No Supported Package Manager Found.\e[0m" >&2
        exit 1
    fi
fi

GB_STUDIO_LATEST_VERSION=$(curl -s https://api.github.com/repos/chrismaltby/gb-studio/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g' | sed 's/v//g')

if [[ "$GB_STUDIO_LATEST_VERSION" > "$gb_studio_VERSION" ]]; then
    echo "Updating GB Studio..."
else
    echo "You are already using the latest version of GB Studio: $gb_studio_VERSION"
    exit 1
fi

if command -v gb-studio &> /dev/null; then
    if command -v "/usr/ProgramFiles/gb-studio/bin/gb-studio" &> /dev/null; then
        remove_gb_studio
        appimage_format
    else
        remove_gb_studio
        package_format
    fi
fi
