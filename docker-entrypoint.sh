#!/bin/bash
set -e

echo "Check Linux release version"
distro=$(grep '^ID=' /etc/os-release | cut -d'=' -f2)
if [[ "${distro}" == "debian" ]]; then
    echo "Linux release version is Debian"
else
    echo "Other linux version"
    exit 1
fi

echo "Check Debian version"
debianVersion=$(cat /etc/debian_version)
minVersion="12.0"

# Less than 12.0 does not allow replacement of APT sources
if dpkg --compare-versions "${debianVersion}" "lt" "${minVersion}"; then
    echo "Debian version is too old. Minimum supported version is ${minVersion}."
    exit 1
fi

echo "Replace APT sources"
sourcesList="/etc/apt/sources.list.d/debian.sources"
backupSourcesList="/etc/apt/sources.list.d/debian.sources.bak"

if [ ! -e "${backupSourcesList}" ]; then
    echo "Backing up existing APT sources"

    mv "${sourcesList}" "${backupSourcesList}" || {
        echo "Failed to backup APT sources"
        exit 1
    }

    echo "Backup completed successfully"
fi

cat <<EOF > "${sourcesList}"
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

# echo "Install Docker."
# curl -fsSL https://get.docker.com -o get-docker.sh && bash get-docker.sh

# # Add user
# user="eleven"
# useradd -m -p $(echo "123456" | openssl passwd -1 -stdin) ${user}

# usermod -aG docker ${user}

# usermod -aG sudo ${user}

# echo "user: ${user} created complete successfully, joined docker group"


# project=".myrc"
# echo "Switch user: ${user}"
# su - ${user} <<EOF
#     # Now you are in the context of the "${user}" user

#     # Clone a Git project (replace with your Git repository URL)
#     git clone https://github.com/yinshiyionly/myrc.git /home/${user}/${project}

#     echo "Git project cloned successfully."

#     # You can add any additional commands you want to execute as the "${user}" user here
#     ln -s /home/${user}/${project}/alias /home/${user}/.alias
#     ln -s /home/${user}/${project}/function /home/${user}/.function
#     ln -s /home/${user}/${project}/gitconfig/gitconfig /home/${user}/.gitconfig
#     ln -s /home/${user}/${project}/oh-my-zsh/ohmyzsh /home/${user}/.oh-my-zsh
#     ln -s /home/${user}/${project}/oh-my-zsh/p10k.zsh /home/${user}/.p10k.zsh
#     ln -s /home/${user}/${project}/oh-my-zsh/themes/powerlevel10k /home/${user}/.powerlevel10k
#     ln -s /home/${user}/${project}/ssh /home/${user}/.ssh
#     ln -s /home/${user}/${project}/vim/vim /home/${user}/.vim
#     ln -s /home/${user}/${project}/vim/vimrc /home/${user}/.vimrc
#     ln -s /home/${user}/${project}/oh-my-zsh/zshrc /home/${user}/.zshrc

#     echo "Change directory: " /home/${user}/${project}
#     cd /home/${user}/${project}

#     echo "Update git submodule for oh-my-zsh/ohmyzsh"
#     git submodule update --init --recursive oh-my-zsh/ohmyzsh

#     echo "Update git submodule for oh-my-zsh/plugins/zsh-autosuggestions"
#     git submodule update --init --recursive oh-my-zsh/plugins/zsh-autosuggestions

#     echo "Update git submodule for oh-my-zsh/plugins/zsh-syntax-highlighting"
#     git submodule update --init --recursive oh-my-zsh/plugins/zsh-syntax-highlighting

#     echo "Update git submodule for oh-my-zsh/themes/powerlevel10k"
#     git submodule update --init --recursive oh-my-zsh/themes/powerlevel10k

# EOF

# echo "Create softlink"
# # echo "mkdir /etc/docker"
# # mkdir /etc/docker
# echo "link /home/${user}/${project}/docker/daemon.json /etc/docker/daemon.json"
# ln -s /home/${user}/${project}/docker/daemon.json /etc/docker/daemon.json
# echo "link /home/${user}/${project}/wsl/wsl.conf /etc/wsl.conf"
# ln -s /home/${user}/${project}/wsl/wsl.conf /etc/wsl.conf

echo "done."
# 61-120