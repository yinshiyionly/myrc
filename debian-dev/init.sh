#!/bin/bash
#
# echo color
COLOR_DEFAULT="\033[0m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_CYAN="\033[0;36m"

# need installed software list
NEED_INSTALLED_SOFTWARE_LIST=(
    "grep"
    "sed"
    "ssh"
    "vim"
    "git"
    "curl"
    "zsh"
    "wget"
    "docker"
    "autojump"
)

# missing software list
MISSING_SOFTWARE_LIST=(
)

LINUX_RELEASE=""

# info echo
colorEchoInfo() {
    local message="$1"
    printf "${COLOR_CYAN}${message}${COLOR_DEFAULT}\n"
}

# success echo
colorEchoSuccess() {
    local message="$1"
    printf "${COLOR_GREEN}${message}${COLOR_DEFAULT}\n"
}

# error echo
colorEchoError() {
    local message="$1"
    printf "${COLOR_RED}${message}${COLOR_DEFAULT}\n"
}

# check Linux release
checkLinuxRelease() {
    # read /etc/os-release and find ID value
    distro=$(grep '^ID=' /etc/os-release | cut -d'=' -f2)
    # if release is Ubuntu or Debian
    if [[ "$distro" == "ubuntu" ]]; then
        LINUX_RELEASE="ubuntu"
        colorEchoSuccess "Linux release is Ubuntu"
    elif [[ "$distro" == "debian" ]]; then
        LINUX_RELEASE="debian"
        colorEchoSuccess "Linux release is Debian"
    else
        colorEchoError "Release not Ubuntu or Debian"
        exit 0
    fi
}

# create user and group
createUser() {
    local username="$1"

    # check group exists
    if grep -q "^$username:" /etc/group; then
        colorEchoInfo "user group $username already exists"
    else
        colorEchoInfo "create user group: $username"
        groupadd "$username"
        colorEchoSuccess "user group $username create success！"
    fi

    # check user exists
    if id -u "$username" >/dev/null 2>&1; then
        colorEchoInfo "user $username already exists"
    else
        colorEchoInfo "create user: $username"
        useradd -m -g "$username" "$username"
        colorEchoSuccess "user $username create success！"

        # setting password
        passwd "$username"
    fi
}

# checkEnv
checkEnv() {
    for item in ${NEED_INSTALLED_SOFTWARE_LIST[@]}; do
        if command -v "$item" >/dev/null 2>&1; then
        # printf "%-25s %s\n"  "${COLOR_RED}This is red text.${COLOR_DEFAULT}\n"
            # Example: Align multiple columns of text and add color support
            # printf "\033[1;33m%-15s\033[0m \033[1;35m%-10s\033[0m \033[1;36m%5d\033[0m\n" "张三" "男" 25
            printf "\033[1;32m%-15s\033[0m \033[1;32m%s\033[0m \n" "$item" "installed"
        else
            printf "\033[1;31m%-15s\033[0m \033[1;31m%s\033[0m \n" "$item" "uninstall"
            MISSING_SOFTWARE_LIST+=("$item")
        fi
    done
}

installEnv() {
    local env="$1"
    if [[ "$env" == "docker" ]]; then
        installDockerCe
    else
        apt install "$env"
    fi
}

installDockerCe() {
    colorEchoInfo "Install dependent software: gnupg apt-transport-https lsb-release ca-certificates"
    apt install gnupg apt-transport-https lsb-release ca-certificates
    colorEchoInfo "Add Docker GPG"
    curl -sSL https://download.docker.com/linux/${LINUX_RELEASE}/gpg | gpg --dearmor >/usr/share/keyrings/docker-ce.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/${LINUX_RELEASE} $(lsb_release -sc) stable" >/etc/apt/sources.list.d/docker.list
    colorEchoInfo "Update apt"
    apt update
    colorEchoInfo "Install Docker"
    apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

checkMissingSoftwareList() {
    if [ ! -z "$MISSING_SOFTWARE_LIST" ]; then
        # installed missing software
        read -rp "Do you want install missing software? (Y/n): " answer

        # transfer lower
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

        # check answer
        if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
            checkUserIsRoot
            colorEchoInfo "Ready install..."
            for item in ${MISSING_SOFTWARE_LIST[@]}; do
                colorEchoInfo "Installing $item..."
                installEnv $item
            done
        else
            colorEchoInfo "User quit"
            exit 0
        fi
    fi
}

checkUserIsRoot() {
    if [ $EUID -ne 0 ]; then
        colorEchoError "The current user is not the root user, please switch to the root user to execute"
        exit 0
    fi
}

declare -A softLinkList

softLinkItem() {
    softLinkList[/home/eleven/.alias]="/home/eleven/.myrc/alias"
    softLinkList[/home/eleven/.function]="/home/eleven/.myrc/function"
    softLinkList[/home/eleven/.gitconfig]="/home/eleven/.myrc/gitconfig/gitconfig"
    softLinkList[/home/eleven/.oh-my-zsh]="/home/eleven/.myrc/oh-my-zsh/ohmyzsh"
    softLinkList[/home/eleven/.p10k.zsh]="/home/eleven/.myrc/oh-my-zsh/p10k.zsh"
    softLinkList[/home/eleven/.powerlevel10k]="/home/eleven/.myrc/oh-my-zsh/themes/powerlevel10k"
    softLinkList[/home/eleven/.ssh]="/home/eleven/.myrc/ssh"
    softLinkList[/home/eleven/.vim]="/home/eleven/.myrc/vim/vim"
    softLinkList[/home/eleven/.vimrc]="/home/eleven/.myrc/vim/vimrc"
    softLinkList[/home/eleven/.zshrc]="/home/eleven/.myrc/oh-my-zsh/zshrc"
    softLinkList[/etc/docker/daemon.json]="/home/eleven/.myrc/docker/daemon.json"
    softLinkList[/etc/wsl.conf]="/home/eleven/.myrc/wsl/wsl.conf"

    for key in "${!softLinkList[@]}"; do
    value="${softLinkList[$key]}"
    if [[ ! -L $value ]]; then
        colorEchoInfo "$key exists"
    else
    echo 11
        ln -s $value $key
        colorEchoSuccess "$key generate success"
    fi
done
}

######### function end

######### start
# check grep sed ssh
colorEchoInfo "step1: check env"
checkEnv
# check Linux Release Ubuntu or Debian
colorEchoInfo "step2: check Linux Release"
checkLinuxRelease

# missing software
checkMissingSoftwareList

softLinkItem


# input user
read -p "Please input username: " username
# create user
createUser "$username"
