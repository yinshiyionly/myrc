#!/bin/bash

function proxyOff() {
    unset http_proxy
    unset https_proxy
    unset all_proxy
}

function proxyOn() {
    export http_proxy=$1
    export https_proxy=$1
    export no_proxy="localhost,127.0.0.1,localhostaddress"
    curl google.com
}
