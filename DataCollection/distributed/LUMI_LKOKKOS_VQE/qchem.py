import pennylane as qml
from pennylane import numpy as np
from timeit import default_timer as timer
import sys
import os

if __name__ == "__main__":
    rng = np.random.default_rng(seed=1337)  # make the results reproducable
    mol = qml.data.load("qchem", molname="C2H4", bondlength=1.339, basis="STO-3G")[0]

    hf_state = mol.hf_state
    ham = mol.hamiltonian
    wires = ham.wires
    dev = qml.device("lightning.kokkos", wires=wires, batch_obs=True, mpi=True)

    n_electrons = mol.molecule.n_electrons
    singles, doubles = qml.qchem.excitations(n_electrons, len(wires))
    hf_state.requires_grad = False
    hf_ops = []

    for idx,i in enumerate(hf_state):
        if i==1:
            hf_ops.append((qml.PauliX, idx))


    @qml.qnode(dev, diff_method="adjoint")
    def cost(weights):
        for (x,i) in hf_ops: # HF state
            x(i)
        for idx,s in enumerate(singles):
            qml.SingleExcitation(weights[idx], wires=s)
        for idx,d in enumerate(doubles):
            qml.DoubleExcitation(weights[idx+len(singles)], wires=d)
        return qml.expval(ham)

    params = qml.numpy.array(rng.normal(0, np.pi, len(singles) + len(doubles)))
    opt = qml.GradientDescentOptimizer(stepsize=0.5)

    # store the values of the circuit parameter
    angle = [params]
    max_iterations = 50
    procs = int(os.getenv("PL_FWD_BATCH", "0"))
    pre_s = f"qubits={len(wires)},num_terms={len(ham.terms()[0])},procs={procs},"

    energies = []

    for n in range(max_iterations):
        start_grad = timer()
        params, prev_energy = opt.step_and_cost(cost, params)
        energies.append(prev_energy)
        end_grad = timer()
        angle.append(params)
        print(f"{pre_s},Step={n},Time_grad={end_grad-start_grad}")

    start_fwd = timer()
    energy = cost(params)
    energies.append(energy)
    end_fwd = timer()
    print(f"Energies={energies},Time_fwd={end_fwd - start_fwd}")

