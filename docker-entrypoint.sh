#!/bin/bash
set -e

echo "Check Linux release version"
distro=$(grep '^ID=' /etc/os-release | cut -d'=' -f2)
if [[ "$distro" == "debian" ]]; then
    echo "Linux release version is Debian"
else
    echo "Other linux version"
    exit 1
fi

echo "Check Debian version"
debianVersion=$(cat /etc/debian_version)
minVersion="12.0"

# Less than 12.0 does not allow replacement of APT sources
if dpkg --compare-versions "$debianVersion" "lt" "$minVersion"; then
    echo "Debian version is too old. Minimum supported version is $minVersion."
    exit 1
fi

echo "Replace APT sources"
sourcesList="/etc/apt/sources.list.d/debian.sources"
backupSourcesList="/etc/apt/sources.list.d/debian.sources.bak"

if [ ! -e "$backupSourcesList" ]; then
    echo "Backing up existing APT sources"

    mv "$sourcesList" "$backupSourcesList" || {
        echo "Failed to backup APT sources"
        exit 1
    }

    echo "Backup completed successfully"
fi

cat <<EOF >> "$sourcesList"
Types: deb deb-src
URIs: http://mirrors.ustc.edu.cn/debian
Suites: bookworm bookworm-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

EOF


cat <<EOF >> "$sourcesList"
Types: deb
URIs: http://mirrors.ustc.edu.cn/debian-security
Suites: bookworm-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

EOF

echo "APT sources replaced successfully."

echo "Updating APT sources"
#apt update

# Install software
echo "Install autojump, curl, git, ssh, vim, wget, zsh."
apt install -y autojump curl git ssh vim wget zsh

echo "Install Docker."
curl -fsSL https://get.docker.com -o get-docker.sh && bash get-docker.sh

