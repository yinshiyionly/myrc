#!/bin/bash
set -e

# Color echo
info() {
    echo -e "\033[32m[INFO] \033[0m$1"
}

error() {
    echo -e "\033[31m[error] \033[0m$1"
}


info "Check Linux release version"
distro=$(grep '^ID=' /etc/os-release | cut -d'=' -f2)
if [[ "${distro}" == "debian" ]]; then
    info "Linux release version is Debian"
else
    error "Other linux version"
    exit 1
fi

info "Check Debian version"
debianVersion=$(cat /etc/debian_version)
minVersion="12.0"

# Less than 12.0 does not allow replacement of APT sources
if dpkg --compare-versions "${debianVersion}" "lt" "${minVersion}"; then
    error "Debian version is too old. Minimum supported version is ${minVersion}."
    exit 1
fi

info "Replace APT sources"
sourcesList="/etc/apt/sources.list.d/debian.sources"
backupSourcesList="/etc/apt/sources.list.d/debian.sources.bak"

if [ ! -e "${backupSourcesList}" ]; then
    info "Backing up existing APT sources"

    mv "${sourcesList}" "${backupSourcesList}" || {
        error "Failed to backup APT sources"
        exit 1
    }

    info "Backup completed successfully"
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

info "APT sources replaced successfully."

info "Updating APT sources"
apt update

# Install software
info "Install autojump, curl, git, ssh, vim, wget, zsh."
apt install -y autojump curl git ssh sudo vim wget zsh

info "Install Docker."
curl -fsSL https://get.docker.com -o get-docker.sh && bash get-docker.sh

# Add user
user="eleven"
useradd -m -p $(echo "123456" | openssl passwd -1 -stdin) ${user}

usermod -aG docker ${user}

usermod -aG sudo ${user}

info "user: ${user} created complete successfully, joined docker group"


project=".myrc"
info "Switch user: ${user}"
su - ${user} <<EOF
    info() {
        echo  "\033[32m[INFO] \033[0m\$1"
    }

    error() {
        echo  "\033[31m[error] \033[0m\$1"
    }

    # Now you are in the context of the "${user}" user

    # Clone a Git project (replace with your Git repository URL)
    info "Git clone https://github.com/yinshiyionly/myrc.git"
    
    git clone https://github.com/yinshiyionly/myrc.git /home/${user}/${project}

    info "Git project cloned successfully."

    # You can add any additional commands you want to execute as the "${user}" user here

    info "ln -s /home/${user}/${project}/alias /home/${user}/.alias"
    [ ! -d /home/${user}/${project}/alias ] || ln -s /home/${user}/${project}/alias /home/${user}/.alias

    info "ln -s /home/${user}/${project}/function /home/${user}/.function"
    [ ! -d /home/${user}/${project}/function ] || ln -s /home/${user}/${project}/function /home/${user}/.function

    info "ln -s /home/${user}/${project}/gitconfig/gitconfig /home/${user}/.gitconfig"
    [ ! -f /home/${user}/${project}/gitconfig/gitconfig ] || ln -s /home/${user}/${project}/gitconfig/gitconfig /home/${user}/.gitconfig

    info "ln -s /home/${user}/${project}/oh-my-zsh/ohmyzsh /home/${user}/.oh-my-zsh"
    [ ! -d /home/${user}/${project}/oh-my-zsh/ohmyzsh ] || ln -s /home/${user}/${project}/oh-my-zsh/ohmyzsh /home/${user}/.oh-my-zsh

    info "ln -s /home/${user}/${project}/oh-my-zsh/p10k.zsh /home/${user}/.p10k.zsh"
    [ ! -f /home/${user}/${project}/oh-my-zsh/p10k.zsh ] || ln -s /home/${user}/${project}/oh-my-zsh/p10k.zsh /home/${user}/.p10k.zsh

    info "ln -s /home/${user}/${project}/oh-my-zsh/themes/powerlevel10k /home/${user}/.powerlevel10k"
    [ ! -d /home/${user}/${project}/oh-my-zsh/themes/powerlevel10k ] || ln -s /home/${user}/${project}/oh-my-zsh/themes/powerlevel10k /home/${user}/.powerlevel10k

    info "ln -s /home/${user}/${project}/ssh /home/${user}/.ssh"
    [ ! -d /home/${user}/${project}/ssh ] || ln -s /home/${user}/${project}/ssh /home/${user}/.ssh

    info "ln -s /home/${user}/${project}/vim/vim /home/${user}/.vim"
    [ ! -d /home/${user}/${project}/vim/vim ] || ln -s /home/${user}/${project}/vim/vim /home/${user}/.vim

    info "ln -s /home/${user}/${project}/vim/vimrc /home/${user}/.vimrc"
    [ ! -f /home/${user}/${project}/vim/vimrc ] || ln -s /home/${user}/${project}/vim/vimrc /home/${user}/.vimrc
    
    info "ln -s /home/${user}/${project}/oh-my-zsh/zshrc /home/${user}/.zshrc"
    [ ! -f /home/${user}/${project}/oh-my-zsh/zshrc ] || ln -s /home/${user}/${project}/oh-my-zsh/zshrc /home/${user}/.zshrc

    info "Change directory: /home/${user}/${project}" 
    cd /home/${user}/${project}

    # Change http version
    info "git config --global http.version HTTP/1.1"
    git config --global http.version HTTP/1.1

    # Change potbuffer
    info  "git config --global http.postBuffer 157286400"
    git config --global http.postBuffer 157286400

    info "Update git submodule for oh-my-zsh/ohmyzsh"
    git submodule update --init --recursive oh-my-zsh/ohmyzsh

    info "Update git submodule for oh-my-zsh/plugins/zsh-autosuggestions"
    git submodule update --init --recursive oh-my-zsh/plugins/zsh-autosuggestions

    info "Update git submodule for oh-my-zsh/plugins/zsh-syntax-highlighting"
    git submodule update --init --recursive oh-my-zsh/plugins/zsh-syntax-highlighting

    info "Update git submodule for oh-my-zsh/themes/powerlevel10k"
    git submodule update --init --recursive oh-my-zsh/themes/powerlevel10k

EOF

info "Create softlink"

# Check directory "/etc/docker" exists
if [ ! -d /etc/docker ]; then
    info "Mkdir /etc/docekr"
    mkdir /etc/docker
fi

info "ln -s /home/${user}/${project}/docker/daemon.json /etc/docker/daemon.json"
[ ! -f /home/${user}/${project}/docker/daemon.json ] || ln -s /home/${user}/${project}/docker/daemon.json /etc/docker/daemon.json

info "ln -s /home/${user}/${project}/wsl/wsl.conf /etc/wsl.conf"
[ ! -f /home/${user}/${project}/wsl/wsl.conf ] || ln -s /home/${user}/${project}/wsl/wsl.conf /etc/wsl.conf


if command -v zsh > /dev/null 2>&1; then
    info "zsh is installed at $(command -v zsh)"
    zsh_path=$(command -v zsh)

    info "Change ${user} Shell for zsh"
    if id -u ${user} > /dev/null 2>&1; then
        chsh -s /usr/bin/zsh eleven
        info "Shell for user '${user}' changed to zsh"
    else
        error "User '${user}' does not exist"
    fi

else
    error "zsh is not installed"
fi

info "done."
