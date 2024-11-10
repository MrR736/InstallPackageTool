#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
ZZ_BIN="../../bin/7zz"

if command -v "/usr/ProgramFiles/godot/bin/godot" &> /dev/null; then
    echo "Godot is Already Installed, so Cancelling Installation." >&2
    exit 1
fi

for cmd in chmod curl sed mkdir awk wget grep tee cat ln rm "$ZZ_BIN"; do
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

add_godot_to_mime() {
chmod 644 "/usr/share/applications/org.godotengine.Godot.desktop"

update-desktop-database

echo "application/x-godot-shader" | sudo tee -a /usr/share/mime/types &> /dev/null
echo "application/x-godot-scene" | sudo tee -a /usr/share/mime/types &> /dev/null
echo "application/x-godot-resource" | sudo tee -a /usr/share/mime/types &> /dev/null
echo "application/x-godot-project" | sudo tee -a /usr/share/mime/types &> /dev/null
echo "application/x-gdscript" | sudo tee -a /usr/share/mime/types &> /dev/null

echo "application/x-godot-shader" | sudo tee -a /usr/share/mime/icons &> /dev/null
echo "application/x-godot-scene" | sudo tee -a /usr/share/mime/icons &> /dev/null
echo "application/x-godot-resource" | sudo tee -a /usr/share/mime/icons &> /dev/null
echo "application/x-godot-project" | sudo tee -a /usr/share/mime/icons &> /dev/null
echo "application/x-gdscript" | sudo tee -a /usr/share/mime/icons &> /dev/null

echo "application/x-godot-project text/plain" | sudo tee -a /usr/share/mime/subclasses &> /dev/null
echo "application/x-gdscript text/plain" | sudo tee -a /usr/share/mime/subclasses &> /dev/null
echo "application/x-godot-shader text/plain" | sudo tee -a /usr/share/mime/subclasses &> /dev/null

update-mime-database /usr/share/mime
}

godot_stable_format() {
if [ "$(uname -m)" == "x86_64" ]; then
    echo "Install Godot Engine x64 version..."
    URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep '"browser_download_url":' | grep '.*\.x86_64.zip' | cut -d '"' -f 4)
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    echo "Install Godot Engine x32 version..."
    URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep '"browser_download_url":' | grep '.*\.x86_32.zip' | cut -d '"' -f 4)
elif [[ "$(uname -m)" == "armv7l" || "$(uname -m)" == "armv6l" || "$(uname -m)" == "armv5tel" ]]; then
    echo "Install Godot Engine Arm32 version..."
    URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep '"browser_download_url":' | grep '.*\.arm32.zip' | cut -d '"' -f 4)
elif [ "$(uname -m)" == "aarch64" ]; then
    echo "Install Godot Engine Arm64 version..."
    URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep '"browser_download_url":' | grep '.*\.arm64.zip' | cut -d '"' -f 4)
else
    echo -e "\e[31mE: Unknown Type of Arch\e[0m" >&2
    exit 1
fi

mkdir -p /usr/ProgramFiles/godot/bin &> /dev/null

wget -q -O"/tmp/Godot.zip" $URL

$ZZ_BIN x "../../libc/Godot.zip" -O"/" -y &> /dev/null
$ZZ_BIN x "/tmp/Godot.zip" -O"/tmp/Godot" -y &> /dev/null
rm -rf "/tmp/Godot.zip"

mv "$(find /tmp/Godot -maxdepth 1 -type f | head -n 1)" "/usr/ProgramFiles/godot/bin/godot"
rm -rf "/tmp/Godot" "/usr/bin/godot"
ln -s "/usr/ProgramFiles/godot/bin/godot" "/usr/bin/godot"

add_godot_to_mime

echo "godot_type=godot_stable_format" | sudo tee /usr/ProgramFiles/godot/Type > /dev/null

echo "Godot has been Install Successfully."
}

godot_stable_mono_format() {
if [ "$(uname -m)" == "x86_64" ]; then
    echo "Install Godot Engine x64 version..."
    URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep '"browser_download_url":' | grep '.*\mono_linux_x86_64.zip' | cut -d '"' -f 4)
elif [[ "$(uname -m)" =~ ^i[3-6]86$ ]]; then
    echo "Install Godot Engine x32 version..."
    URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep '"browser_download_url":' | grep '.*\mono_linux_x86_32.zip' | cut -d '"' -f 4)
elif [[ "$(uname -m)" == "armv7l" || "$(uname -m)" == "armv6l" || "$(uname -m)" == "armv5tel" ]]; then
    echo "Install Godot Engine Arm32 version..."
    URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep '"browser_download_url":' | grep '.*\mono_linux_arm32.zip' | cut -d '"' -f 4)
elif [ "$(uname -m)" == "aarch64" ]; then
    echo "Install Godot Engine Arm64 version..."
    URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep '"browser_download_url":' | grep '.*\mono_linux_arm64.zip' | cut -d '"' -f 4)
else
    echo -e "\e[31mE: Unknown Type of Arch\e[0m" >&2
    exit 1
fi

mkdir -p "/usr/ProgramFiles/godot/bin" "/usr/ProgramFiles/godot/lib" &> /dev/null

wget -q -O"/tmp/Godot.zip" $URL

$ZZ_BIN x "../../libc/Godot.zip" -O"/" -y &> /dev/null
$ZZ_BIN x "/tmp/Godot.zip" -O"/tmp/Godot" -y &> /dev/null
rm -rf "/tmp/Godot.zip"

src_dir=$(ls /tmp/Godot/ | head -n 1)
src=$(ls /tmp/Godot/*/ | head -n 1)

mv "$(find /tmp/Godot/*/ -maxdepth 1 -type f | head -n 1)" "/usr/ProgramFiles/godot/bin/godot"
mv "/tmp/Godot/$src_dir/$(ls /tmp/Godot/$src_dir/ | head -n 1)" "/usr/ProgramFiles/godot/lib/$(ls /tmp/Godot/*/ | head -n 1)"
mv "/tmp/Godot/$src_dir/${src}" "/usr/ProgramFiles/godot/lib/${src}"
rm -rf "/tmp/Godot" "/usr/bin/godot"
ln -s "/usr/ProgramFiles/godot/bin/godot" "/usr/bin/godot"
ln -s "/usr/ProgramFiles/godot/lib/$(ls /usr/ProgramFiles/godot/lib/ | head -n 1)" "/usr/ProgramFiles/godot/bin/$(ls /usr/ProgramFiles/godot/lib/ | head -n 1)"

add_godot_to_mime

echo "godot_type=godot_stable_mono_format" | sudo tee /usr/ProgramFiles/godot/Type > /dev/null

echo "Godot has been Install Successfully."
}

type_of_install() {
read -p "What Type Of Install Format, Do You Want? [Stable=s/Stable_Mono=m/No=n]" InstallFormat

if [[ "$InstallFormat" == "s" ]]; then
    godot_stable_format
elif [[ "$InstallFormat" == "m" ]]; then
    godot_stable_mono_format
else
    echo "Abort."
    exit 1
fi
exit 1
}

if [[ "$1" == "-s" ]]; then
    godot_stable_format
    exit 1
elif [[ "$1" == "-m" ]]; then
    godot_stable_mono_format
    exit 1
fi

type_of_install
