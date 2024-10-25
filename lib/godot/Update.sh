#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

GODOT_BIN="/usr/ProgramFiles/godot/bin/godot"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPTS_DIR
ZZ_BIN="../../bin/7zz"

# Check if script is run as superuser
if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m"
    exit 1
fi

# Check if Godot is installed
if [[ ! -e "$GODOT_BIN" ]]; then
    echo "Godot is Not Installed, So Cancelling Update."
    exit 1
fi

# Check for required binaries
for cmd in chmod curl wget "$ZZ_BIN"; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "\e[31mE: $cmd Is Not Installed.\e[0m"
    exit 1
  fi
done

# Get current and latest version
GODOT_VERSION=$(godot --version | awk -F '.' '{print $1"."$2}')
GODOT_LATEST_VERSION=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

# Compare versions
if [[ $(echo -e "$GODOT_LATEST_VERSION\n$GODOT_VERSION" | sort -V | head -n1) != "$GODOT_VERSION" ]]; then
    echo "Updating Godot..."
else
    echo "You Are Already Using The Latest Version Of Godot: $GODOT_VERSION"
    exit 1
fi

rm -rf "/usr/ProgramFiles/godot/bin/godot" "/usr/share/applications/org.godotengine.Godot.desktop" "/usr/share/icons/hicolor/16x16/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/22x22/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/32x32/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/64x64/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/scalable/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/16x16/places/folder-godot.svg" "/usr/share/icons/hicolor/22x22/places/folder-godot.svg" "/usr/share/icons/hicolor/32x32/places/folder-godot.svg" "/usr/share/icons/hicolor/64x64/places/folder-godot.svg" "/usr/share/icons/hicolor/scalable/places/folder-godot.svg" "/usr/share/mime/packages/org.godotengine.Godot.xml" "/usr/ProgramFiles/godot"

sed -i '/application\/x-godot-shader/d' /usr/share/mime/types &> /dev/null
sed -i '/application\/x-godot-scene/d' /usr/share/mime/types &> /dev/null
sed -i '/application\/x-godot-resource/d' /usr/share/mime/types &> /dev/null
sed -i '/application\/x-godot-project/d' /usr/share/mime/types &> /dev/null
sed -i '/application\/x-gdscript/d' /usr/share/mime/types &> /dev/null

sed -i '/application\/x-godot-shader/d' /usr/share/mime/icons &> /dev/null
sed -i '/application\/x-godot-scene/d' /usr/share/mime/icons &> /dev/null
sed -i '/application\/x-godot-resource/d' /usr/share/mime/icons &> /dev/null
sed -i '/application\/x-godot-project/d' /usr/share/mime/icons &> /dev/null
sed -i '/application\/x-gdscript/d' /usr/share/mime/icons &> /dev/null

sed -i '/application\/x-godot-project text\/plain/d' /usr/share/mime/subclasses &> /dev/null
sed -i '/application\/x-gdscript text\/plain/d' /usr/share/mime/subclasses &> /dev/null
sed -i '/application\/x-godot-shader text\/plain/d' /usr/share/mime/subclasses &> /dev/null

update-mime-database /usr/share/mime

# Download the URL to the Godot binary
if [ "$(uname -m)" == "x86_64" ]; then
    echo "Install Godot Engine x64 version..."
    URL="https://github.com/godotengine/godot/releases/download/$GODOT_LATEST_VERSION-stable/Godot_v$GODOT_LATEST_VERSION-stable_linux.x86_64.zip"
fi

if [ "$(uname -m)" == "i686" ]; then
    echo "Install Godot Engine x32 version..."
    URL="https://github.com/godotengine/godot/releases/download/$GODOT_LATEST_VERSION-stable/Godot_v$GODOT_LATEST_VERSION-stable_linux.x86_32.zip"
fi

if [[ "$(uname -m)" == "armv7l" || "$(uname -m)" == "armv6l" || "$(uname -m)" == "armv5tel" ]]; then
    echo "Install Godot Engine Arm32 version..."
    URL="https://github.com/godotengine/godot/releases/download/$GODOT_LATEST_VERSION-stable/Godot_v$GODOT_LATEST_VERSION-stable_linux.arm32.zip"
fi

if [ "$(uname -m)" == "aarch64" ]; then
    echo "Install Godot Engine Arm64 version..."
    URL="https://github.com/godotengine/godot/releases/download/$GODOT_LATEST_VERSION-stable/Godot_v$GODOT_LATEST_VERSION-stable_linux.arm64.zip"
fi

# Download the URL to the Godot binary
wget -q -O "/tmp/Godot.zip" "$URL"

# Extract the zip files
cd $SCRIPTS_DIR
$ZZ_BIN x "../../libc/Godot.zip" -O"/" -y &> /dev/null
$ZZ_BIN x "/tmp/Godot.zip" -O"/tmp/Godot" -y &> /dev/null
rm -rf "/tmp/Godot.zip"

chmod 644 "/usr/share/applications/Godot.desktop"

# Rename and move the executable
mv "/tmp/Godot/$(ls /tmp/Godot | head -n 1)" "$GODOT_BIN"
rm -rf "/tmp/Godot"
ln -s "$GODOT_BIN" "/usr/bin/godot"

ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/16x16/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/16x16/apps/org.godotengine.Godot.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/22x22/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/22x22/apps/org.godotengine.Godot.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/32x32/apps/org.godotengine.Godot.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/64x64/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/64x64/apps/org.godotengine.Godot.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/scalable/apps/org.godotengine.Godot.svg" "/usr/share/icons/hicolor/scalable/apps/org.godotengine.Godot.svg"

ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/16x16/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-gdscript.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/22x22/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-gdscript.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-gdscript.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/64x64/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-gdscript.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/mimetypes/application-x-gdscript.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-gdscript.svg"

ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/16x16/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-project.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/22x22/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-project.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-project.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/64x64/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-project.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/mimetypes/application-x-godot-project.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-project.svg"

ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/16x16/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-resource.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/22x22/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-resource.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-resource.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/64x64/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-resource.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/mimetypes/application-x-godot-resource.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-resource.svg"

ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/16x16/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-scene.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/22x22/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-scene.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-scene.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/64x64/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-scene.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/mimetypes/application-x-godot-scene.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-scene.svg"

ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/16x16/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/16x16/mimetypes/application-x-godot-shader.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/22x22/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/22x22/mimetypes/application-x-godot-shader.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/32x32/mimetypes/application-x-godot-shader.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/64x64/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/64x64/mimetypes/application-x-godot-shader.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/mimetypes/application-x-godot-shader.svg" "/usr/share/icons/hicolor/scalable/mimetypes/application-x-godot-shader.svg"

ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/16x16/places/folder-godot.svg" "/usr/share/icons/hicolor/16x16/places/folder-godot.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/22x22/places/folder-godot.svg" "/usr/share/icons/hicolor/22x22/places/folder-godot.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/places/folder-godot.svg" "/usr/share/icons/hicolor/32x32/places/folder-godot.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/64x64/places/folder-godot.svg" "/usr/share/icons/hicolor/64x64/places/folder-godot.svg"
ln -s "/usr/ProgramFiles/godot/share/icons/hicolor/32x32/places/folder-godot.svg" "/usr/share/icons/hicolor/scalable/places/folder-godot.svg"

ln -s "/usr/ProgramFiles/godot/share/mime/packages/org.godotengine.Godot.xml" "/usr/share/mime/packages/org.godotengine.Godot.xml"

ln -s "/usr/ProgramFiles/godot/share/applications/org.godotengine.Godot.desktop" "/usr/share/applications/org.godotengine.Godot.desktop"

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

echo "Godot has been Update successfully."
