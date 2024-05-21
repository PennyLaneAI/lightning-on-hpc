#!/bin/bash

PLQ_HASH=v0.31.0

/bin/bash ./env_setup.sh pyenv_lightning_gpu

#setup_env pyenv_lightning
source pyenv_lightning_gpu/bin/activate
. /opt/intel/oneapi/setvars.sh

cmake -BBuild . -DENABLE_NATIVE=ON -DENABLE_GATE_DISPATCHER=ON -DENABLE_OPENMP=ON -DENABLE_BLAS=ON -DPL_BACKEND="lightning_gpu"
cmake --build ./Build -j 
cp ./Build/LightningGPUBin* ..

deactivate
popd . &> /dev/null