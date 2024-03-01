import pennylane as qml
from pennylane import numpy as np
from typing import List, Optional, Tuple, Sequence
import networkx as nx
from matplotlib import pyplot as plt
from timeit import default_timer as timer
import ray
import os

from common_utils import clustered_chain_graph, get_qaoa_circuit, chunks, find_depth
split = 1  # number of gpus per tape execution (can be fractional)

@ray.remote(num_gpus=split)
def exec_tape(tapes_indices):
    indices = [i[0] for i in tapes_indices]
    tapes = [i[1] for i in tapes_indices]
    max_wires = max([len(t.wires) for t in tapes])
    if isinstance(tapes, Sequence):
        dev = qml.device("lightning.gpu", wires=range(max_wires))
        return indices, qml.execute(tapes, dev, gradient_fn=None)
    dev = qml.device("lightning.gpu", wires=tapes.wires)
    return (indices, qml.execute([tapes], dev, gradient_fn=None))


if __name__ == "__main__":

    r = 3  # number of clusters
    n = 25  # nodes in clusters
    k = 2  # vertex separators
    layers = 1
    print(f"clusters={r},cluster_nodes={n},vertex_sep={k},layers={layers}")
    q1 = 0.7
    q2 = 0.3

    seed = 1967

    G, cluster_nodes, separator_nodes = clustered_chain_graph(n, r, k, q1, q2, seed=seed)

    nx.draw_kamada_kawai(G, node_size=80, width=0.5)
    plt.savefig(f"graph_kamada_kawai_r{r}_n{n}_k{k}_l{layers}.png")

    params = np.array([[7.20792567e-01, 1.02761748e-04]] * layers, requires_grad=True)
    circuit = get_qaoa_circuit(G, cluster_nodes, separator_nodes, params, layers)
    start = timer()
    circuit_frags, proc_fn = qml.cut_circuit(circuit, device_wires=range(30))
    end = timer()
    print(
        f"Original_circuit:={circuit}, Max_wires:={circuit.num_wires}, num. cut circuits:={len(circuit_frags)}, cut time:={end-start}"
    )

    if circuit.num_wires < 25:
        res_exact = qml.execute(
            [circuit], qml.device("lightning.gpu", wires=circuit.num_wires), None
        )
    else:
        res_exact = np.nan

    ray.init(address=os.environ["ip_head"])

    print(f"Nodes in the Ray cluster:={ray.nodes()}")
    print(f"cluster resources:={ray.available_resources()}")

    num_cores = int(ray.available_resources()["CPU"]) // 2
    num_gpus = int(ray.available_resources()["GPU"])

    results = []
    index_order = []

    start = timer()

    # Sort circuit fragments to have lower qubit requirements up-front
    circ_sorted = [i for i in sorted(enumerate(circuit_frags), key=lambda x:len(x[1].wires))]
    # Create a shard/chunk of tapes for each compute resource we have available
    res = [exec_tape.remote(tapes_indices) for tapes_indices in chunks(circ_sorted, num_gpus)]

    for chunk in res:
        result = ray.get(chunk)
        index_order.extend(result[0])
        results.extend(list(result[1]))

    end = timer()
    print(f"fragment execution time:={end-start}")
    results = [val for _,val in sorted(zip(index_order, results), key=lambda x: x[0])]

    res_cut = proc_fn(results)
    print(f"postproc time:={timer() - end}")
    
    print(f"QAOA expval:={res_cut} with params:={params}")
    ray.shutdown()
