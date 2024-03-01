#!/bin/bash

QUEST_HASH=v3.7.0

/bin/bash ./env_setup.sh pyenv_quest

#setup_env pyenv_quest
source pyenv_quest/bin/activate
. /opt/intel/oneapi/setvars.sh --force

cmake -BBuild .
cmake --build ./Build -j 
cp ./Build/QuESTBin* ..

deactivate
popd . &> /dev/null
