#!/bin/bash

QULACS_HASH=v0.6.2

/bin/bash ./env_setup.sh pyenv_qulacs

source pyenv_qulacs/bin/activate
. /opt/intel/oneapi/setvars.sh --force

wget https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.tar.gz
tar xvf ./boost_1_83_0.tar.gz

cmake -BBuild . -DBoost_INCLUDE_DIR=$PWD/boost_1_83_0
cmake --build ./Build 

cp ./Build/QulacsBin* ..

deactivate
popd . &> /dev/null
