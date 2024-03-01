from mpi4py import MPI
import sys

import pennylane as qml
from pennylane import numpy as np
from timeit import default_timer as timer

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

n_wires = 0
num_runs = 1

if rank == 0:
    n_wires = int(sys.argv[1])

n_wires = comm.bcast(n_wires, root=0)
num_runs = comm.bcast(num_runs, root=0)


n_layers = 3

dev = qml.device("lightning.gpu", wires=n_wires, mpi=True, shots=10000)


@qml.qnode(dev, diff_method=None)
def circuit(weights):
    qml.StronglyEntanglingLayers(weights, wires=list(range(n_wires)))
    return qml.sample()


if rank == 0:
    params = np.random.random(
        qml.StronglyEntanglingLayers.shape(n_layers=n_layers, n_wires=n_wires)
    )
else:
    params = None

params = comm.bcast(params, root=0)
comm.Barrier()

timing = []

for t in range(num_runs):
    start = timer()
    sample = circuit(params)
    end = timer()
    timing.append(end - start)
comm.Barrier()

#print number of mpi ranks and timing result
if rank == 0:
    print(size, n_wires, qml.numpy.mean(timing))
