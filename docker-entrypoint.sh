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

cat <<EOF > "$sourcesList"
Types: deb deb-src
URIs: http://mirrors.ustc.edu.cn/debian
Suites: bookworm bookworm-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://mirrors.ustc.edu.cn/debian-security
Suites: bookworm-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

echo "APT sources replaced successfully."

echo "Updating APT sources"
apt update

# Install software
echo "Install autojump, curl, git, ssh, vim, wget, zsh."
apt install -y autojump curl git ssh sudo vim wget zsh

echo "Install Docker."
curl -fsSL https://get.docker.com -o get-docker.sh && bash get-docker.sh

# Add user
user="eleven"
useradd -m -p $(echo "123456" | openssl passwd -1 -stdin) $user
usermod -aG docker $user

usermod -aG sudo $user

echo "user: $user created complete successfully, joined docker group"


echo "Switch user: $user"
su - $user <<EOF
    # Now you are in the context of the "eleven" user

    # Clone a Git project (replace with your Git repository URL)
    git clone https://github.com/yinshiyionly/myrc.git /home/eleven/.myrc

    echo "Git project cloned successfully."

    # You can add any additional commands you want to execute as the "eleven" user here

EOF

echo "done"
