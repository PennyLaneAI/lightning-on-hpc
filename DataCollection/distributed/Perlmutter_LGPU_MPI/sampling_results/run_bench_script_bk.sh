#!/bin/bash
#SBATCH -A m4139
#SBATCH -C gpu
#SBATCH -q regular
#SBATCH -t 0:45:00
#SBATCH -N 4
#SBATCH --ntasks-per-node=4
#SBATCH -c 32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=none

#SBATCH --output="output_full.log"  # Dynamic log file name

#set up envs
module load PrgEnv-gnu cray-mpich cudatoolkit craype-accel-nvidia80 python/3.11 gcc/11.2 cmake
module load evp-patch

conda activate py311-cu11-mpich

export SLURM_CPU_BIND="cores"
export MPICH_GPU_SUPPORT_ENABLED=1

export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:/opt/cray/pe/mpich/8.1.25/ofi/gnu/9.1/lib/:/opt/cray/pe/mpich/8.1.25/gtl/lib/:$LD_LIBRARY_PATH
export CUQUANTUM_SDK=/global/homes/s/shulishu/.local/perlmutter/python-3.11/lib/python3.11/site-packages/cuquantum

#set number of nodes and MPI ranks
num_nodes=$SLURM_JOB_NUM_NODES
n=$((num_nodes*SLURM_GPUS_ON_NODE)) # Set the initial number of gpus outside the loop

#set range of number of qubits to simulate
num_qubitsL=23 # Set the largest number of qubits outside the loop
num_qubitsS=20 # Set the smallest number of qubits outside the loop

num_qubits=$((num_qubitsL))
num_runs=1

#run the largest task that make use of all nodes first
LOG_FILE="output_${num_nodes}_nodes_${n}_gpus_${num_qubits}_qubits.log"
srun --nodes=$num_nodes --ntasks-per-node=4 -n $n python test_sample_script.py $num_qubits > "$LOG_FILE" 2>&1

# Wait for the largest task to be finished
wait

#run the rest tasks simultaneously
((num_qubits-=1))
((n/=2))
((num_nodes/=2))


for i in $(seq $((num_qubitsL - num_qubitsS)) -1 1); do
    echo "Iteration $i: num of nodes: $num_nodes n is $n and num_qubits is $num_qubits"

    LOG_FILE="output_${num_nodes}_nodes_${n}_gpus_${num_qubits}_qubits.log"
    if [ $num_nodes -gt 1 ]; then 
    	echo "Iteration $i: num of nodes: $num_nodes is larger than 1"
	srun --nodes=$num_nodes --ntasks-per-node=4 -n $n python test_sample_script.py $num_qubits > "$LOG_FILE" 2>&1 &
    	((num_nodes/=2))
    else
    	srun --nodes=1 -n $n python test_sample_script.py $num_qubits > "$LOG_FILE" 2>&1 &
    fi
    
    ((n/=2))
    ((num_qubits-=1))
done
# Wait for all tasks to be finished
wait
