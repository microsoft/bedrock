#!/bin/bash

function require_root() {
    # verify we are running as root
    if [[ "$EUID" != 0 ]]; then
        echo "Script must be run as root or sudo."
        exit 1
    fi
}

function linux_distro() {
    local distroname
    if [ -n "$(command -v lsb_release)" ]; then
            distroname=$(lsb_release -s -d)
    elif [ -f "/etc/os-release" ]; then
            distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')
    elif [ -f "/etc/debian_version" ]; then
            distroname="Debian $(cat /etc/debian_version)"
    elif [ -f "/etc/redhat-release" ]; then
            distroname=$(cat /etc/redhat-release)
    else
            distroname="$(uname -s) $(uname -r)"
    fi
    echo "${distroname}"
}

function os_type() {
    local ostype
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        ostype="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        ostype="macos"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        ostype="cygwin"
    elif [[ "$OSTYPE" == "msys" ]]; then
        ostype="mingwin"
    elif [[ "$OSTYPE" == "win32" ]]; then
        ostype="windows"
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        ostype="freebsd"
    else
        ostype=""
    fi
    echo "${ostype}"
}

function is_macos() {
    local os=`os_type`
    if [ "$os" = "macos" ]; then
        return 1
    fi
    return 0
}

function is_ubuntu() {
    local os=`os_type`
    if [ "$os" != "linux" ]; then
        return 0
    fi

    local distro=`linux_distro`
    if [ "$distro" == "Ubuntu"* ]; then
        return 1
    fi
    return 0
}

function is_debian() {
    local os=`os_type`
    if [ "$os" != "linux" ]; then
        return 0
    fi

    local distro=`linux_distro`
    if [ "$distro" == "Debian"* ]; then
        return 1
    fi
    return 0
}

function is_apt_system() {
    if [[ "$(is_debian)" != 0 ]] || [[ "$(is_ubuntu)" != 0 ]]; then
        return 1
    fi
    return 0
}