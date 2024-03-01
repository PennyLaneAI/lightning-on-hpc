#!/bin/bash

PLQ_HASH=v0.33.0-dev

/bin/bash ./env_setup.sh pyenv_iqs

#setup_env pyenv_lightning
source pyenv_iqs/bin/activate
. /opt/intel/oneapi/setvars.sh --force

COMPILER=icx

CXX=${COMPILER} cmake -BBuild . -DIqsMKL=ON -DIqsPython=OFF -DIqsUtest=OFF -DIqsNoise=OFF -DBuildExamples=OFF -DBuildInterface=OFF -DIqsNative=ON -DIqsBuildAsStatic=ON

cmake --build ./Build -j 
cp ./Build/IQSBin* ..

deactivate
popd . &> /dev/null