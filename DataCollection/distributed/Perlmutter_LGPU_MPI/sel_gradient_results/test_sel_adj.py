from mpi4py import MPI
import pennylane as qml
from pennylane import numpy as np
from timeit import default_timer as timer
import sys

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

# Set number of runs for timing averaging
num_runs = 1

# Choose number of qubits (wires) and circuit layers
n_wires = 0

if rank == 0:
    n_wires = int(sys.argv[1])

n_wires = comm.bcast(n_wires, root=0)
num_runs = comm.bcast(num_runs, root=0)

n_layers = 1

# Instantiate CPU (lightning.qubit) or GPU (lightning.gpu) device
# mpi=True to switch on distributed simulation
# batch_obs=True to reduce the device memory demand for adjoint backpropagation
dev = qml.device('lightning.gpu', wires=n_wires, mpi=True, batch_obs=True)

# Create QNode of device and circuit
@qml.qnode(dev, diff_method="adjoint")
def circuit_adj(weights):
    qml.StronglyEntanglingLayers(weights, wires=list(range(n_wires)))
    return qml.math.hstack([qml.expval(qml.PauliZ(i)) for i in range(n_wires)])

# Set trainable parameters for calculating circuit Jacobian at the rank=0 process
if rank == 0:
    params = np.random.random(qml.StronglyEntanglingLayers.shape(n_layers=n_layers, n_wires=n_wires))
else:
    params = None

# Broadcast the trainable parameters across MPI processes from rank=0 process
params = comm.bcast(params, root=0)

# Run, calculate the quantum circuit Jacobian and average the timing results
timing = []
for t in range(num_runs):
    start = timer()
    jac = qml.jacobian(circuit_adj)(params)
    end = timer()
    timing.append(end - start)

# MPI barrier to ensure all calculations are done
comm.Barrier()

if rank == 0:
    print("num_gpus: ", size, " wires: ", n_wires, " layers ", n_layers, " time: ", qml.numpy.mean(timing)) 

