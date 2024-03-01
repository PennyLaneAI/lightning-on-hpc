# Hybrid quantum programming with PennyLane Lightning on HPC platforms

This repository serves accompanying data and documentation for the manuscript "Hybrid quantum programming with PennyLane Lightning on HPC platforms".

The structures of this repository is as follows:

```
DataCollection/
├─ distributed/
|  ├─ LUMI_LKOKKOS_VQE
|  |    # Data, notebooks and scripts used for the distributed VQE workload 
|  |    # running on 8 - 256 AMD MI250X GPUs on LUMI, using Lightning-Kokkos, 
|  |    # OpenMPI+UCX and mpi4py.
|  |
|  ├─ Perlmutter_LGPU_MPI/
|  |  |  # All materials related to fully-distributed Lightning-GPU workloads.
|  |  ├─ sampling_results/
|  |  |    # Data and scripts for the 33-41 qubit sampling workload running on 
|  |  |    # 4 - 512 NVIDIA A100 (80GB) GPUs on Perlmutter, using Lightning-GPU
|  |  |    # Cray-MPICH 8.1.25, mpi4py and CUDA 11.7.
|  |  |
|  |  ├─ sel_gradient_results/
|  |  |    # Data and scripts for the 33-37 qubit distributed quantum gradient workload 
|  |  |    # running on 16 - 512 NVIDIA A100 (80GB) GPUs on Perlmutter, using 
|  |  |    # Lightning-GPU, Cray-MPICH 8.1.25, mpi4py and CUDA 11.7.
|  |  |
|  ├─ Perlmutter_LGPU_MPI/
|  |  |  # All materials related to task-based circuit cutting Lightning-GPU workloads.
|  |  ├─ QAOA_QCUT_BATCHED_CUDA12/
|  |  |    # Data and scripts for the 79-qubit circuit cutting workload, with 40k+ 
|  |  |    # intermediate circuits, using batched execution, and running on between 
|  |  |    # 4 - 256 NVIDIA A100 (80GB) GPUs on Perlmutter, using Lightning-GPU
|  |  |    # CUDA 12.2, and Ray.
|  |  |
|  |  ├─ QAOA_QCUT_ONDEMAND_CUDA12/
|  |  |    # Data and scripts for the 79-qubit circuit cutting workload, with 40k+ 
|  |  |    # intermediate circuits, using on-demand execution, and running on between 
|  |  |    # 4 - 256 NVIDIA A100 (80GB) GPUs on Perlmutter, using Lightning-GPU
|  |  |    # CUDA 12.2, and Ray.
|  |  |
├─ single_node/
|  ├─ GateKernels_LQUBIT/
|  |  | # Targeted kernel evaluation for LM, AVX2 and AVX512 implementations, with 
|  |  | # comparisons against other HPC-focused simulators.
```

The included `requirements.txt` contains all used dependencies for running the attached notebooks and plotting scripts. 