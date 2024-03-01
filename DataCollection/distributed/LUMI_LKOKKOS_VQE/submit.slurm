#!/bin/bash
#SBATCH --job-name=LK_64Node
#SBATCH --account=<ACCT>
#SBATCH --time=6:00:00
#SBATCH --nodes=64
#SBATCH --ntasks-per-node=8
#SBATCH --gpus-per-node=8
#SBATCH --partition=standard-g

module load rocm
module load cray-python
module load gcc/11.2.0
module load PrgEnv-cray-amd/8.4.0

cd <PROJECT_DIR> 
source <PROJECT_DIR>/pyenv/bin/activate

export LD_LIBRARY_PATH=<OPENMPI_INSTALL_DIR>/lib/:$LD_LIBRARY_PATH
export PATH=<OPENMPI_INSTALL_DIR>/bin/:$PATH
export PL_FWD_BATCH=512
export PL_BWD_BATCH=512

TSTART=$SECONDS
mpirun --np 512 ./select_gpu python -m mpi4py.futures ./qchem.py 512
TEND=$SECONDS
echo "$(($TEND - $TSTART)) seconds elapsed."

