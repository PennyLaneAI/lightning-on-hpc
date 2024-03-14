This directory contains the Lightning-GPU MPI workloads and output files.


## CUDA 11, Cray-MPICH 8.1.25, PennyLane Lightning-GPU <= v0.34.0

At the time of writing, the following steps were used to create the Lightning-GPU+MPI environment. The pre-release 0.34.0 candidate ("0.34.0-dev16") was used for running these examples, of which Lightning-GPU functionality did not receive any changes until the v0.34.0 release.
:

```bash
# Ensure all necessary modules are loaded up-front
module load PrgEnv-gnu cray-mpich cudatoolkit craype-accel-nvidia80 evp-patch gcc/11.2.0

# Required due to a potentially missing lib for the CUDA-aware MPICH library
export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:/opt/cray/pe/mpich/8.1.25/ofi/gnu/9.1/lib/:$LD_LIBRARY_PATH

# Create a python virtualenv
python -m venv pyenv && source ./pyenv/bin/activate

# install the following dependencies
python -m pip install cmake ninja custatevec-cu11 wheel pennylane~=0.34.0

# build mpi4py against the system's CUDA-aware MPICH
MPICC="cc -shared" python -m pip install --force --no-cache-dir --no-binary=mpi4py mpi4py

# clone and checkout lightning.gpu at version 0.34.0
git clone https://github.com/PennyLaneAI/pennylane-lightning
cd pennylane-lightning && git checkout v0.34.0

# build the extension module with MPI support, and package it all into a wheel
CXX=g++ python -m pip install . # Lightning-Qubit v0.34.0
CXX=g++ python setup.py build_ext --define="PLLGPU_ENABLE_MPI=ON;-DCMAKE_CXX_COMPILERS=$(which mpicxx);-DCMAKE_C_COMPILER=$(which mpicc)"
python setup.py bdist_wheel

# Assuming the above steps are reproduced, your wheel can be installed as needed
python -m pip install ./dist/*.whl

# Ensure Perlmutter GPUs are all visible per node https://docs.nersc.gov/systems/perlmutter/running-jobs/#1-node-4-tasks-4-gpus-all-gpus-visible-to-all-tasks
salloc -A <account> -C gpu -q regular -t 1:00:00 -N 4 --ntasks-per-node=4 -c 32 --gpus-per-task=1 --gpu-bind=none

# Run job
export SLURM_CPU_BIND="cores"
srun python my_workload.py
```

## CUDA 12, Cray-MPICH >= 8.1.28, PennyLane Lightning-GPU > v0.34.0

With the recent updates to Perlmutter, we have migrated to use CUDA 12 by default, which can now be set-up with the following steps for the v0.35.0 release:

```bash
# Set up your python environment, preferably on the SCRATCH partition
python -m venv lgpu_env && source lgpu_env/bin/activate

# Load the recommended packages on Perlmutter for building GPU-aware libraries/binaries for Python
# https://docs.nersc.gov/development/languages/python/using-python-perlmutter/#installing-mpi4py-with-gpu-aware-cray-mpich
module load PrgEnv-gnu cray-mpich cudatoolkit craype-accel-nvidia80 
MPICC="cc -shared" pip install --force --no-cache-dir --no-binary=mpi4py mpi4py

# Clone PennyLane Lightning and set-up your Python virtualenv
git clone https://github.com/PennyLaneAI/pennylane-lightning
cd pennylane-lightning && git checkout latest_release
python -m pip install -r requirements-dev.txt

# Build and install Lightning-Qubit
CXX=$(which CC) python -m pip install -e . --verbose

# Build and install Lightning-GPU+MPI using the CrayPE toolchain, Cray-MPICH and CUDA 12
CXX=$(which CC) PL_BACKEND="lightning_gpu" CMAKE_ARGS="-DENABLE_MPI=on -DCMAKE_CXX_COMPILER=$(which CC)" python -m pip install -e . --verbose

# Ensure the CRAY library paths are used for the MPI enviroment to be visible by the NVIDIA cuQuantum libraries
# https://support.hpe.com/hpesc/public/docDisplay?docLocale=en_US&docId=a00113984en_us&page=Modify_Linking_Behavior_to_Use_Non-default_Libraries.html
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

# Follow NERSCs recommendations for using GPU-aware MPI
# https://docs.nersc.gov/development/languages/python/using-python-perlmutter/#using-mpi4py-with-gpu-aware-cray-mpich
export MPICH_GPU_SUPPORT_ENABLED=1

# Allocate your nodes/GPUs, and ensure each process can see all others on each respective local node.
salloc -N 2 -c 32 --qos interactive --time 0:30:00 --constraint gpu --ntasks-per-node=4 --gpus-per-task=1 --gpu-bind=none --account=<Account ID>

# Run you workload, using a power-of-2 number of processes (and GPUs)
srun -n 8 python ./my_workload.py
```
