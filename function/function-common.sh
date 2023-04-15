#!/bin/bash

function proxyOff() {
    unset http_proxy
    unset https_proxy
    unset all_proxy
}

function proxyOn() {
    if [ ! -n  "$1" ];then
        echo "Please input proxy URL"
        return 0
    fi
    export http_proxy=$1
    export https_proxy=$1
    export no_proxy="localhost,127.0.0.1,localhostaddress"
    curl google.com
    return
}

# attention: Additional outputt with timezone
# timestamp to date
function ttdate() {
    echo $(date -d @$1 +"%Y-%m-%d %H:%M:%S")
    echo $(date -d @$1 +"%Y-%m-%d %H:%M:%S %Z")
}

# attention: Timezone depends on your setting/mmachine
# date to timestamp
function datett() {
    if [ ! -n "$1" ]; then
        echo $(date +%s)
    else
        echo $(date -d "$1" +%s)
    fi
}
