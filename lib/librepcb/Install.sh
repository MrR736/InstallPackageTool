#!/bin/bash

librepcb_BIN="/usr/bin/librepcb"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPTS_DIR
ZZ_BIN="../../bin/7zz"

if [ "$(whoami)" != "root" ]; then
    echo -e "\e[31mE: You have to run as Superuser\e[0m"
    exit 1
fi

if [[ ! -e "$librepcb_BIN" ]]; then
    echo "Install Librepcb..."
else
    echo "Librepcb is Already Installed, so Cancelling Installation."
    exit 1
fi

# Check for required binaries
for cmd in curl wget awk sed grep ln rm update-mime-database echo mkdir "$ZZ_BIN"; do
  if ! command -v "$cmd" &> /dev/null; then
    if [[ "$ZZ_BIN" != "$cmd" ]]; then
      echo -e "\e[31mE: $cmd Is Not Installed.\e[0m"
      exit 1
    else
      echo -e "\e[31mE: 7zz Is Not Installed.\e[0m"
      exit 1
    fi
  fi
done

LIBREPCB_LATEST_VERSION=$(curl -s https://api.github.com/repos/LibrePCB/LibrePCB/releases/latest | grep tag_name | awk -F '"' '{print $4}' | sed 's/-stable//;s/\./,/g' | sed 's/\,/./g')

if [ "$(uname -m)" == "x86_64" ]; then
    URL=https://download.librepcb.org/releases/$LIBREPCB_LATEST_VERSION/librepcb-$LIBREPCB_LATEST_VERSION-linux-x86_64.tar.gz
else
    echo -e "\e[31mE: Disable Download need System Is Not 64-bit\e[0m"
    exit 1
fi

wget -q -O"/tmp/librepcb.tar.gz" $URL

mkdir /usr/ProgramFiles &> /dev/null
$ZZ_BIN x "/tmp/librepcb.tar.gz" -o"/tmp/" -y &> /dev/null
$ZZ_BIN x "/tmp/librepcb.tar" -o"/tmp/librepcb" -y &> /dev/null

for folder in $(find /tmp/librepcb -mindepth 1 -maxdepth 1 -type d -exec basename {} \;); do
    mv "/tmp/librepcb/$folder" "/usr/ProgramFiles/librepcb"
done

mkdir /usr/ProgramFiles/librepcb/librepcb &> /dev/null

rm -rf "/tmp/librepcb.tar.gz" "/tmp/librepcb.tar" "/tmp/librepcb"

ln -s "/usr/ProgramFiles/librepcb/bin/librepcb" "/usr/bin/librepcb"
ln -s "/usr/ProgramFiles/librepcb/bin/librepcb-cli" "/usr/bin/librepcb-cli"

ln -s "/usr/ProgramFiles/librepcb/share/librepcb" "/usr/share/librepcb"

ln -s "/usr/ProgramFiles/librepcb/plugins" "/usr/ProgramFiles/librepcb/librepcb/plugins"
ln -s "/usr/ProgramFiles/librepcb/qml" "/usr/ProgramFiles/librepcb/librepcb/qml"
ln -s "/usr/ProgramFiles/librepcb/lib" "/usr/ProgramFiles/librepcb/librepcb/lib"
ln -s "/usr/ProgramFiles/librepcb/share/doc" "/usr/ProgramFiles/librepcb/librepcb/doc"
ln -s "/usr/ProgramFiles/librepcb/translations" "/usr/ProgramFiles/librepcb/librepcb/translations"

ln -s "/usr/ProgramFiles/librepcb/share/icons/hicolor/16x16/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/16x16/apps/org.librepcb.LibrePCB.png"
ln -s "/usr/ProgramFiles/librepcb/share/icons/hicolor/24x24/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/24x24/apps/org.librepcb.LibrePCB.png"
ln -s "/usr/ProgramFiles/librepcb/share/icons/hicolor/32x32/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/32x32/apps/org.librepcb.LibrePCB.png"
ln -s "/usr/ProgramFiles/librepcb/share/icons/hicolor/48x48/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/48x48/apps/org.librepcb.LibrePCB.png"
ln -s "/usr/ProgramFiles/librepcb/share/icons/hicolor/64x64/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/64x64/apps/org.librepcb.LibrePCB.png"
ln -s "/usr/ProgramFiles/librepcb/share/icons/hicolor/128x128/apps/org.librepcb.LibrePCB.png" "/usr/share/icons/hicolor/128x128/apps/org.librepcb.LibrePCB.png"

ln -s "/usr/ProgramFiles/librepcb/share/icons/hicolor/scalable/apps/org.librepcb.LibrePCB.svg" "/usr/share/icons/hicolor/scalable/apps/org.librepcb.LibrePCB.svg"

ln -s "/usr/ProgramFiles/librepcb/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-archive.svg" "/usr/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-archive.svg"
ln -s "/usr/ProgramFiles/librepcb/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-file.svg" "/usr/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-file.svg"
ln -s "/usr/ProgramFiles/librepcb/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-project.svg" "/usr/share/icons/hicolor/scalable/mimetypes/org.librepcb.LibrePCB-project.svg"

ln -s "/usr/ProgramFiles/librepcb/librepcb" "/usr/librepcb"

ln -s "/usr/ProgramFiles/librepcb/share/metainfo/org.librepcb.LibrePCB.metainfo.xml" "/usr/share/metainfo/org.librepcb.LibrePCB.metainfo.xml"

ln -s "/usr/ProgramFiles/librepcb/share/mime/packages/org.librepcb.LibrePCB.xml" "/usr/share/mime/packages/org.librepcb.LibrePCB.xml"

ln -s "/usr/ProgramFiles/librepcb/share/applications/org.librepcb.LibrePCB.desktop" "/usr/share/applications/org.librepcb.LibrePCB.desktop"

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

echo "Librepcb has been Install successfully."
