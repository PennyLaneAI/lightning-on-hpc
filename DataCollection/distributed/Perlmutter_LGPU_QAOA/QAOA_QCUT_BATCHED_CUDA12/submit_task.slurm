#!/bin/bash
#SBATCH -A m4139_g
#SBATCH -C gpu&hbm80g
#SBATCH -q regular
#SBATCH -t 1:00:00
#SBATCH --job-name=QCUT_BATCHED_64N_r3_n25_k2_l1
#SBATCH --nodes=64
#SBATCH --cpus-per-task=64 
#SBATCH --exclusive
#SBATCH --ntasks-per-node=1 # 1 ray worker runtime per node
#SBATCH --gpus-per-task=4 # 4 GPUs per node
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lee+PERLMUTTER@xanadu.ai
#SBATCH --output=Job-%x.%j.out
#SBATCH --error=Job-%x.%j.err

# Load modules
module load cudatoolkit gcc/11.2.0

################################################################
# Go to appropriate dir
cd /pscratch/sd/m/mlxd/Paper_Task_V_MPI/runscripts/on_demand_consumption/cuda_12/rundir/batched
################################################################

################################################################
# Source Python env
################################################################
source /pscratch/sd/m/mlxd/Paper_Task_V_MPI/runscripts/on_demand_consumption/cuda_12/pyenv_cuda12/bin/activate

################################################################
# Define Bash utility functions 
################################################################

get_node_names(){
    # Getting the node names
    export nodes=$(scontrol show hostnames "$SLURM_JOB_NODELIST")
    export nodes_array=($nodes)
    
    redis_password=$(uuidgen)
    export redis_password

    export head_node=${nodes_array[0]}
    export head_node_ip=$(srun --nodes=1 --ntasks=1 -w "$head_node" hostname --ip-address)

    # if we detect a space character in the head node IP, we'll
    # convert it to an ipv4 address. This step is optional.
    if [[ "$head_node_ip" == *" "* ]]; then
        IFS=' ' read -ra ADDR <<<"$head_node_ip"
            if [[ ${#ADDR[0]} -gt 16 ]]; then
                head_node_ip=${ADDR[1]}
            else
                head_node_ip=${ADDR[0]}
            fi
        echo "IPV6 address detected. We split the IPV4 address as $head_node_ip"
    fi
    echo "Head node=${head_node}::[${head_node_ip}]"
}

start_head(){
    port=6379
    export ip_head=$head_node_ip:$port
    echo "IP Head: $ip_head"
    echo "Starting HEAD at $head_node"
    srun --nodes=1 --ntasks=1 -w "$head_node" \
        ray start --head \
        --node-ip-address="$head_node_ip" \
        --port=$port \
        --redis-password=${redis_password} \
        --num-cpus 5 \
        --num-gpus "${SLURM_GPUS_PER_TASK}" \
        --block &
}

start_workers(){
    # number of nodes other than the head node
    export worker_num=$((${SLURM_JOB_NUM_NODES} - 1))

    for ((i = 1; i <= worker_num; i++)); do
        node_i=${nodes_array[$i]}
        echo "Starting WORKER $i at ${node_i} connecting to ${ip_head}"
        srun --nodes=1 --ntasks=1 -w "$node_i" \
            ray start --address "$ip_head" \
            --redis-password=${redis_password} \
            --num-cpus 4 \
            --num-gpus "${SLURM_GPUS_PER_TASK}" \
            --block &
        sleep 3
    done
}
################################################################
# Initialize Ray cluster environment
################################################################

get_node_names
start_head
start_workers

################################################################
# Run Python scripts
################################################################

# python -u ray_sample.py "${SLURM_CPUS_PER_TASK}" 
# python -u run_ray.py "${SLURM_CPUS_PER_TASK}" 
python -u qaoa_workload_ray.py 
