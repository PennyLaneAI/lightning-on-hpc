#!/bin/bash

PLQ_HASH=v0.31.0

/bin/bash ./env_setup.sh pyenv_lightning_omp_stream

#setup_env pyenv_lightning
source pyenv_lightning_omp_stream/bin/activate
. /opt/intel/oneapi/setvars.sh

cmake -BBuild . -DENABLE_NATIVE=ON -DENABLE_GATE_DISPATCHER=ON -DENABLE_OPENMP=ON -DENABLE_BLAS=ON -DLQ_ENABLE_KERNEL_OMP=ON
cmake --build ./Build -j 
cp ./Build/LightningOMPBin* ..

deactivate
popd . &> /dev/null
