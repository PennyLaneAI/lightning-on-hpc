To successfully build a working environment with Lightning (both LQ and LK) we require a modern version of GCC (11.2.0 in this instance) and a recent version of the ROCm/HIP toolchain.

```bash
module load rocm
module load cray-python
module load gcc/11.2.0
module load PrgEnv-cray-amd/8.4.0
```

The support for MPI-based pool execution through the mpi4py `concurrent.futures` API requires support from a recent MPI library.
As Cray-MPICH does not have support for dynamic process spawning (see the [notes from Perlmutter](https://docs.nersc.gov/development/languages/python/parallel-python/#using-mpi4pyfutures), we must build our own MPI variant with the required supports.

Since we do not explicitly require the ability to send GPU-buffer data through the network interface (we can serialize and send a single packet if needed using the existing bindings), we can use mpi4py as a means to send the required serialized circuit payload to another process that can spawn an AMD-GPU backed LightningKokkos instance. For this we cloned OpenMPI, and built this against a UCX version with threads enabled (`--enable-mt`). The OpenMPI build was chosen as version 5.0, and configured with `--with-slurm` to allow us to run atop the allocated nodes from the LUMI scheduler.

We next set up a Python virtual environment to hold the package builds as `python3 -m venv pyenv_lk && source ./pyenv/bin/activate`.
With the OpenMPI backend built, it was used to generate a build of MPI4PY, using GCC 11.2 as the compiler to avoid any potential linkage with the CRAY-PE libraries.

Finally, we built and installed both LightningQubit and LightningKokkos+ROCm as:

```bash
git clone https://github.com/PennyLaneAI/pennylane-lightning/
cd pennylane-lightning
git checkout update/pickle_bindings
python -m pip install cmake ninja
PL_BACKEND="lightning_qubit" python -m pip install . --verbose
CXX="hipcc --gcc-toolchain=/opt/cray/pe/gcc/11.2.0/snos" CMAKE_ARGS="-DKokkos_ENABLE_HIP=ON -DKokkos_ARCH_VEGA90A=ON  -DCMAKE_CXX_FLAGS='--gcc-toolchain=/opt/cray/pe/gcc/11.2.0/snos/'" PL_BACKEND="lightning_kokkos" python -m pip install . --verbose
```

With the packages successfully installed, we can run a test workload through an allocation as:

```bash
salloc --nodes=8 --account=project_X --partition=dev-g --ntasks-per-node=8 --gpus-per-node=8 --time=00:15:00 mpirun --np 64 ./select_gpu python -m mpi4py.futures workload.py
```

which allocates 8 nodes, each with 8 GPUs (4 MI250X per node), uses the mpi4py [futures interface](https://mpi4py.readthedocs.io/en/stable/mpi4py.futures.html) to handle the remote execution, where batches of observables are controlled by the user specifying the `batch_obs=X` argument to the device.

To ensure each remote process gets a GPU, following a similar guideline as [here](https://docs.lumi-supercomputer.eu/runjobs/scheduled-jobs/distribution-binding/), we modify the `select_gpu` script to work with OpenMPI-specific options as:

```bash
#!/bin/bash
export ROCR_VISIBLE_DEVICES=$OMPI_COMM_WORLD_LOCAL_RANK
export MPI4PY_RC_RECV_MPROBE=false # See https://github.com/mpi4py/mpi4py/issues/223
export OMPI_MCA_pml=ucx # Only use UCX
echo $ROCR_VISIBLE_DEVICES
exec $*
```

We next create our SLURM submission script, and build our C2H4 example workload from the PennyLane datasets module, explicitly create our singles and doubles circuit, starting from a Hartree-Fock state, and distribute the execution across the GPUs. This workload currently requires use of the PennyLane Lightning [update/pickle_bindings](https://github.com/PennyLaneAI/pennylane-lightning/tree/update/pickle_bindings) branch, which allows us to package and send the required data packets.


The provided example can be modified to find the lowest energy by adjusting the optimizer, increasing the steps, and/or choosing a different starting state. However, given the scale of the problem (thousands of gates, thousands of Hamiltonian terms) as written this gives us a solid starting point to examine larger workloads.
