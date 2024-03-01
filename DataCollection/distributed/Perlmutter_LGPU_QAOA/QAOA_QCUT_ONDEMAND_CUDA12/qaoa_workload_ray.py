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
def exec_tape(tape):
    dev = qml.device("lightning.gpu", wires=tape.wires)
    return qml.execute([tape], dev, gradient_fn=None)


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

    start = timer()

    res = [exec_tape.remote(tape) for tape in circuit_frags]

    for t in res:
        result = ray.get(t)
        results.extend(list(result))

    end = timer()
    print(f"fragment execution time:={end-start}")

    res_cut = proc_fn(results)
    print(f"postproc time:={timer() - end}")
    
    print(f"QAOA expval:={res_cut} with params:={params}")
    ray.shutdown()
