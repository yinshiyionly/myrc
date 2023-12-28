#!/bin/bash
set -e

# 定义一个函数来获取命令的安装位置和版本信息
get_info() {
    type -P $1 &> /dev/null
    if [ $? -eq 0 ]; then
        location=$(which $1)

        # 针对不同的命令使用不同的方法来获取版本信息
        case $1 in
            "curl" | "ssh" | "sudo" | "wget" )
                version=$($1 -V | head -n 1)
                ;;
            "autojump" | "docker" | "git" | "vim" )
                version=$($1 --version | head -n 1)
                ;;
        esac

        # 截取版本信息的前 25 个字符
        version=${version:0:25}
    else
        location="--"
        version="--"
    fi
    printf "| %-8s | %-45s | %-30s |\n" $1 "$location" "$version"
}

# 输出表头
printf "| %-8s | %-45s | %-30s |\n" "name" "location" "version"
printf "|%s|\n" "$(printf '=%.0s' {1..91})"

# 输出 autojump curl git ssh sudo vim wget zsh 的信息
# get_info "autojump"
get_info "curl"
get_info "docker"
get_info "git"
# get_info "ssh"
get_info "sudo"
get_info "vim"
get_info "wget"
