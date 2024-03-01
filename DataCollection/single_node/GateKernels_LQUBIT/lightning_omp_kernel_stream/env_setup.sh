#!bin/bash

function setup_env() {
    VENV_NAME=$1
    python3 -m venv ${VENV_NAME}
    source ${VENV_NAME}/bin/activate
    python3 -m pip install cmake ninja
    deactivate
}

function install_oneAPI(){
    if ! [ -f /etc/yum.repos.d/oneAPI.repo ]; then
        tee > /tmp/oneAPI.repo << EOF
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

        mv /tmp/oneAPI.repo /etc/yum.repos.d
        dnf update -y
        dnf install intel-basekit -y
    fi
}

setup_env $1
install_oneAPI
