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
)

# missing software list
MISSING_SOFTWARE_LIST=(
)

# myrc Git remote repository
MYRC_GIT_REMOTE_REPOSITORY="https://github.com/yinshiyionly/myrc.git"
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
        colorEchoSuccess "Release Ubuntu"
    elif [[ "$distro" == "debian" ]]; then
        LINUX_RELEASE="debian"
        colorEchoSuccess "Release Debian"
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
            colorEchoSuccess "$item \t\t\t\t installed"
        else
            colorEchoError "$item \t\t\t\t uninstall"
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

# clone myrc project
cloneMyrc() {
    local path="$1"
    git clone ${MYRC_GIT_REMOTE_REPOSITORY} $path/.myrc
}

######### function end

######### start
# check grep sed ssh
colorEchoInfo "step1: check env"
checkEnv
# check Linux Release Ubuntu 或者 Debian
colorEchoInfo "step2: check Linux Release"
checkLinuxRelease

# missing software
checkMissingSoftwareList

# input user
read -p "Please input username: " username
# create user
createUser "$username"

colorEchoInfo "Clone myrc project"
cloneMyrc "/home/$username"
