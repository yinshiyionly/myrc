#!/bin/bash

# unset proxy
function proxyOff() {
    unset http_proxy
    unset https_proxy
    unset all_proxy
}

# set proxy $1
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
function t2date() {
    if [ ! -n "$1" ]; then
        echo 'Shanghai: \t' $(TZ="Asia/Shanghai" date +"%Y-%m-%d %H:%M:%S")
        echo 'Los_Angeles: \t' $(TZ="America/Los_Angeles" date +"%Y-%m-%d %H:%M:%S") 
        echo 'Tokyo: \t\t' $(TZ="Asia/Tokyo" date +"%Y-%m-%d %H:%M:%S")
        echo 'New_York: \t' $(TZ="America/New_York" date +"%Y-%m-%d %H:%M:%S")
        echo 'Paris: \t\t' $(TZ="Europe/Paris" date +"%Y-%m-%d %H:%M:%S")
        return 0
    else
        # echo $(date -d @$1 +"%Y-%m-%d %H:%M:%S")
        # echo $(date -d @$1 +"%Y-%m-%d %H:%M:%S %Z")
        echo 'Shanghai: \t' $(TZ="Asia/Shanghai" date -d @$1 +"%Y-%m-%d %H:%M:%S")
        echo 'Los_Angeles: \t' $(TZ="America/Los_Angeles" date -d @$1 +"%Y-%m-%d %H:%M:%S")
        echo 'Tokyo: \t\t' $(TZ="Asia/Tokyo" date -d @$1 +"%Y-%m-%d %H:%M:%S")
        echo 'New_York: \t' $(TZ="America/New_York" date -d @$1 +"%Y-%m-%d %H:%M:%S")
        echo 'Paris: \t\t' $(TZ="Europe/Paris" date -d @$1 +"%Y-%m-%d %H:%M:%S")
    fi
}

# attention: Timezone depends on your setting/machine
# date to timestamp
function date2t() {
    if [ ! -n "$1" ]; then
        echo $(date +%s)
    else
        echo $(date -d "$1" +%s)
    fi
}
